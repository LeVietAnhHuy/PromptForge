import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stream_channel/stream_channel.dart';

import 'package:dart_mcp/client.dart';
import 'package:promptforge/core/database/daos/daos.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/core/security/secure_storage_service.dart';
import 'package:promptforge/mcp/promptforge_mcp_server.dart';

/// Builds a fixture PromptForge database on disk (real schema, user_version set
/// by Drift) with a couple of prompts, variables, tags, and the mcp_enabled
/// flag. Returns the db file path. The secret never goes in here.
Future<String> buildFixtureDb({bool enabled = true, int? overrideUserVersion}) async {
  final dir = await Directory.systemTemp.createTemp('pf_mcp_test_');
  final path = p.join(dir.path, 'promptforge_db.sqlite');
  final db = AppDatabase(e: NativeDatabase(File(path)));
  final now = DateTime(2026, 1, 1, 12);
  await db.promptDao.createPrompt(PromptsCompanion.insert(
    id: 'p1',
    title: 'Greeting',
    purpose: const drift.Value('Say hi to someone in a place'),
    body: 'Hello {name}, welcome to {place}.',
    createdAt: now,
    updatedAt: now,
  ));
  await PromptVariableDao(db).syncVariablesForPrompt('p1', [
    PromptVariablesCompanion.insert(
        id: 'v1', promptId: 'p1', name: 'name', createdAt: now, updatedAt: now),
    PromptVariablesCompanion.insert(
        id: 'v2',
        promptId: 'p1',
        name: 'place',
        description: const drift.Value('Where to welcome them'),
        defaultValue: const drift.Value('Earth'),
        createdAt: now,
        updatedAt: now),
  ]);
  await db.tagDao.replaceTagsForPrompt('p1', ['demo', 'greeting']);
  await db.promptDao.createPrompt(PromptsCompanion.insert(
    id: 'p2',
    title: 'Summarize',
    body: 'Summarize the following: {text}',
    createdAt: now,
    updatedAt: now,
  ));
  await db.userSettingsDao.setSetting(UserSettingsCompanion.insert(
    key: 'mcp_enabled',
    value: enabled ? 'true' : 'false',
    updatedAt: now,
  ));
  if (overrideUserVersion != null) {
    await db.customStatement('PRAGMA user_version = $overrideUserVersion;');
  }
  await db.close();
  addTearDown(() => dir.delete(recursive: true));
  return path;
}

/// A connected client + server pair over an in-memory channel, recording every
/// raw string the server emits (for the no-leak scan).
class Harness {
  final ServerConnection connection;
  final MCPClient client;
  final List<String> serverOutput;
  Harness(this.connection, this.client, this.serverOutput);

  Future<void> close() => client.shutdown();
}

Future<Harness> connect(String dbPath) async {
  final toServer = StreamController<String>();
  final fromServer = StreamController<String>();
  final recorded = <String>[];

  final serverChannel = StreamChannel<String>(
    toServer.stream,
    _RecordingSink(fromServer.sink, recorded),
  );
  final clientChannel = StreamChannel<String>(fromServer.stream, toServer.sink);

  PromptForgeMcpServer(serverChannel, dbPath: dbPath, appVersion: 'test');
  final client = MCPClient(Implementation(name: 'test-client', version: '1.0.0'));
  final connection = client.connectServer(clientChannel);
  await connection.initialize(InitializeRequest(
    protocolVersion: ProtocolVersion.latestSupported,
    capabilities: client.capabilities,
    clientInfo: client.implementation,
  ));
  connection.notifyInitialized();
  return Harness(connection, client, recorded);
}

class _RecordingSink implements StreamSink<String> {
  final StreamSink<String> _inner;
  final List<String> log;
  _RecordingSink(this._inner, this.log);
  @override
  void add(String event) {
    log.add(event);
    _inner.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _inner.addError(error, stackTrace);
  @override
  Future addStream(Stream<String> stream) =>
      _inner.addStream(stream.map((e) {
        log.add(e);
        return e;
      }));
  @override
  Future close() => _inner.close();
  @override
  Future get done => _inner.done;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Part C — security: no API key material reachable', () {
    const secret = 'sk-MCP-NOLEAK-SECRET-7f3a2b1c9d';

    test('no MCP surface (list/get/tools) ever returns a planted key', () async {
      // The key lives ONLY in the (mocked) secure layer — never in the DB.
      FlutterSecureStorage.setMockInitialValues({'api_key_google': secret});
      final storage = SecureStorageService(const FlutterSecureStorage());
      expect(await storage.getApiKey('google'), secret,
          reason: 'sanity: the secret is in secure storage, separate from the DB');

      final dbPath = await buildFixtureDb();
      final h = await connect(dbPath);
      addTearDown(h.close);

      // Exercise every read surface.
      final prompts = await h.connection.listPrompts();
      for (final prompt in prompts.prompts) {
        final args = <String, Object?>{
          for (final a in prompt.arguments ?? const <PromptArgument>[])
            a.name: 'value-for-${a.name}',
        };
        await h.connection
            .getPrompt(GetPromptRequest(name: prompt.name, arguments: args));
      }
      await h.connection.callTool(
          CallToolRequest(name: 'search_prompts', arguments: {'query': 'hello'}));
      await h.connection.callTool(CallToolRequest(
          name: 'get_prompt',
          arguments: {
            'id': 'p1',
            'variables': {'name': 'Ada', 'place': 'Mars'}
          }));

      // The strongest check: scan ALL raw bytes the server emitted.
      final allOutput = h.serverOutput.join('\n');
      expect(allOutput.contains(secret), isFalse,
          reason: 'a planted API key leaked into MCP wire output');
      expect(allOutput.contains('api_key'), isFalse);
    });

    test('sidecar source links no secure-storage / key APIs', () {
      // A structural guarantee: nothing under the sidecar even imports the
      // secure-storage layer, so there is no code path to a key.
      final files = [
        File('lib/mcp/promptforge_mcp_server.dart').readAsStringSync(),
        File('lib/mcp/prompt_read_store.dart').readAsStringSync(),
        File('bin/promptforge_mcp.dart').readAsStringSync(),
      ].join('\n');
      expect(files.contains('flutter_secure_storage'), isFalse);
      expect(files.contains('secure_storage_service'), isFalse);
      expect(files.contains('getApiKey'), isFalse);
    });
  });
}
