import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:stream_channel/stream_channel.dart';

import 'package:dart_mcp/client.dart';
import 'package:dart_mcp/stdio.dart';
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
  addTearDown(() async {
    // Best-effort: a lingering OS handle shouldn't fail the suite.
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });
  return path;
}

/// A connected client + server pair over an in-memory channel, recording every
/// raw string the server emits (for the no-leak scan).
class Harness {
  final ServerConnection connection;
  final MCPClient client;
  final List<String> serverOutput;
  final InitializeResult initResult;
  final PromptForgeMcpServer server;
  Harness(this.connection, this.client, this.serverOutput, this.initResult,
      this.server);

  Future<void> close() async {
    await client.shutdown();
    // Close the server's read-only DB handle so the fixture file is released
    // before the temp-dir teardown deletes it (required on Windows).
    await server.shutdown();
  }
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

  final server =
      PromptForgeMcpServer(serverChannel, dbPath: dbPath, appVersion: 'test');
  final client = MCPClient(Implementation(name: 'test-client', version: '1.0.0'));
  final connection = client.connectServer(clientChannel);
  final initResult = await connection.initialize(InitializeRequest(
    protocolVersion: ProtocolVersion.latestSupported,
    capabilities: client.capabilities,
    clientInfo: client.implementation,
  ));
  connection.notifyInitialized();
  return Harness(connection, client, recorded, initResult, server);
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

  group('Part F — protocol', () {
    Future<String> getText(
        Harness h, String name, Map<String, Object?> args) async {
      final r = await h.connection
          .getPrompt(GetPromptRequest(name: name, arguments: args));
      return r.messages.map((m) => (m.content as TextContent).text).join();
    }

    Future<CallToolResult> call(
            Harness h, String tool, Map<String, Object?> args) =>
        h.connection.callTool(CallToolRequest(name: tool, arguments: args));
    String toolText(CallToolResult r) =>
        r.content.map((c) => (c as TextContent).text).join('\n');

    test('initialize advertises prompts + tools and the server name', () async {
      final h = await connect(await buildFixtureDb());
      addTearDown(h.close);
      expect(h.initResult.capabilities.prompts, isNotNull);
      expect(h.initResult.capabilities.tools, isNotNull);
      expect(h.initResult.serverInfo.name, 'PromptForge');
      expect(h.initResult.protocolVersion, isNotNull);
    });

    test('prompts/list maps variables to arguments (required = no default)',
        () async {
      final h = await connect(await buildFixtureDb());
      addTearDown(h.close);
      final list = await h.connection.listPrompts();
      expect(list.prompts.length, 2);
      final p1 = list.prompts.firstWhere((p) => p.name == 'p1');
      expect(p1.title, 'Greeting');
      expect(p1.description, contains('Say hi'));
      final args = {for (final a in p1.arguments!) a.name: a};
      expect(args['name']!.required, isTrue); // no default → required
      expect(args['place']!.required, isFalse); // default 'Earth'
      expect(args['place']!.description, 'Where to welcome them');
      final p2 = list.prompts.firstWhere((p) => p.name == 'p2');
      expect({for (final a in p2.arguments!) a.name: a}['text']!.required, isTrue);
    });

    test('prompts/get uses defaults and applies overrides', () async {
      final h = await connect(await buildFixtureDb());
      addTearDown(h.close);
      expect(await getText(h, 'p1', {'name': 'Ada'}),
          'Hello Ada, welcome to Earth.');
      expect(await getText(h, 'p1', {'name': 'Ada', 'place': 'Mars'}),
          'Hello Ada, welcome to Mars.');
    });

    test('prompts/get errors on missing required argument', () async {
      final h = await connect(await buildFixtureDb());
      addTearDown(h.close);
      await expectLater(
        h.connection.getPrompt(GetPromptRequest(name: 'p1', arguments: {})),
        throwsA(predicate((e) =>
            '$e'.contains('Missing required') && '$e'.contains('name'))),
      );
    });

    test('search_prompts matches and respects the tags filter (AND)', () async {
      final h = await connect(await buildFixtureDb());
      addTearDown(h.close);
      expect(toolText(await call(h, 'search_prompts', {'query': 'welcome'})),
          contains('p1'));
      expect(
          toolText(await call(
              h, 'search_prompts', {'query': 'welcome', 'tags': 'demo'})),
          contains('Greeting'));
      expect(
          toolText(await call(
              h, 'search_prompts', {'query': 'welcome', 'tags': 'nope'})),
          contains('No prompts matched'));
      expect((await call(h, 'search_prompts', {'query': ''})).isError, isTrue);
    });

    test('get_prompt tool resolves and reports missing required', () async {
      final h = await connect(await buildFixtureDb());
      addTearDown(h.close);
      expect(
          toolText(await call(h, 'get_prompt',
              {'id': 'p1', 'variables': {'name': 'Bo'}})),
          'Hello Bo, welcome to Earth.');
      final miss = await call(h, 'get_prompt', {'id': 'p1'});
      expect(miss.isError, isTrue);
      expect(toolText(miss), contains('name'));
    });

    test('disabled flag blocks initialize with a clear error', () async {
      final db = await buildFixtureDb(enabled: false);
      await expectLater(connect(db),
          throwsA(predicate((e) => '$e'.toLowerCase().contains('disabled'))));
    });

    test('a newer schema is refused with an update message', () async {
      final db = await buildFixtureDb(overrideUserVersion: 99);
      await expectLater(connect(db),
          throwsA(predicate((e) => '$e'.toLowerCase().contains('newer'))));
    });

    test('the COMPILED sidecar serves prompts over real stdio (bundled sqlite3)',
        () async {
      final bin = _findSidecarBinary();
      if (bin == null) {
        markTestSkipped(
            'sidecar not built — run: dart build cli bin/promptforge_mcp.dart');
        return;
      }
      final db = await buildFixtureDb();
      final proc = await Process.start(bin, ['--db', db]);
      final client =
          MCPClient(Implementation(name: 'spawn-test', version: '1.0.0'));
      final conn = client
          .connectServer(stdioChannel(input: proc.stdout, output: proc.stdin));
      await conn.initialize(InitializeRequest(
        protocolVersion: ProtocolVersion.latestSupported,
        capabilities: client.capabilities,
        clientInfo: client.implementation,
      ));
      conn.notifyInitialized();
      final list = await conn.listPrompts();
      expect(list.prompts.length, 2);
      final got = await conn
          .getPrompt(GetPromptRequest(name: 'p1', arguments: {'name': 'Zed'}));
      expect(got.messages.map((m) => (m.content as TextContent).text).join(),
          'Hello Zed, welcome to Earth.');
      await client.shutdown();
      proc.kill();
      await proc.exitCode; // ensure the handle is released before teardown
    });
  });
}

/// Finds the compiled sidecar under build/cli (any OS target), or null.
String? _findSidecarBinary() {
  final root = Directory('build/cli');
  if (!root.existsSync()) return null;
  for (final e in root.listSync(recursive: true)) {
    if (e is File) {
      final name = p.basename(e.path);
      if (name == 'promptforge_mcp' || name == 'promptforge_mcp.exe') {
        return e.path;
      }
    }
  }
  return null;
}
