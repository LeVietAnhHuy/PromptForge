import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// Highest PromptForge database `schemaVersion` this sidecar understands. Keep
/// in sync with `AppDatabase.schemaVersion` (lib/core/database/database.dart).
/// A newer on-disk schema is refused (see [PromptReadStore.open]).
const int kSupportedSchemaVersion = 8;

/// User-settings key the app writes to gate the MCP server (off by default).
const String kMcpEnabledKey = 'mcp_enabled';

/// Raised for any condition the sidecar must report to the client as a clean
/// error (disabled, missing/busy DB, schema mismatch) rather than crashing.
class McpStoreException implements Exception {
  final String message;
  const McpStoreException(this.message);
  @override
  String toString() => message;
}

/// A library prompt as seen by the MCP server (read-only projection).
class PromptSummary {
  final String id;
  final String title;
  final String? purpose;
  final String body;
  final DateTime updatedAt;
  const PromptSummary({
    required this.id,
    required this.title,
    required this.purpose,
    required this.body,
    required this.updatedAt,
  });
}

/// Stored metadata for one template variable (no Drift types here).
class PromptVariableMeta {
  final String name;
  final String? description;
  final String? defaultValue;
  const PromptVariableMeta({
    required this.name,
    required this.description,
    required this.defaultValue,
  });
}

/// Read-only access to the PromptForge SQLite database for the MCP sidecar.
///
/// Opens the database **read-only** — it never writes the user's data. It only
/// ever touches the prompt library tables and the `mcp_enabled` settings row;
/// it does not (and cannot, by construction) reach any secure-storage / API-key
/// data, which lives in the OS keychain, not this database.
class PromptReadStore {
  final Database _db;
  PromptReadStore._(this._db);

  /// Opens [dbPath] read-only with a brief busy wait, validating the schema
  /// version. Throws [McpStoreException] (never a raw crash) on any problem.
  static PromptReadStore open(String dbPath, {int busyTimeoutMs = 3000}) {
    if (!File(dbPath).existsSync()) {
      throw McpStoreException(
          'PromptForge database not found at "$dbPath". Pass the correct path '
          'with --db (see PromptForge → Settings → MCP Server).');
    }
    Database db;
    try {
      db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
      // Wait briefly if the app momentarily holds a write lock, then surface a
      // clean "busy" error rather than throwing a low-level exception.
      db.execute('PRAGMA busy_timeout = $busyTimeoutMs;');
    } on SqliteException catch (e) {
      throw McpStoreException('Could not open the PromptForge database: ${e.message}');
    }
    try {
      final version = db.select('PRAGMA user_version;').first.values.first as int;
      if (version > kSupportedSchemaVersion) {
        db.close();
        throw McpStoreException(
            'The PromptForge database (schema v$version) is newer than this MCP '
            'server understands (v$kSupportedSchemaVersion). Please update '
            'PromptForge.');
      }
      return PromptReadStore._(db);
    } on McpStoreException {
      rethrow;
    } on SqliteException catch (e) {
      db.close();
      throw McpStoreException('PromptForge database is busy or unreadable: ${e.message}');
    }
  }

  /// Whether the user enabled the MCP server in Settings (off by default).
  bool get mcpEnabled {
    try {
      final rows = _db.select(
          'SELECT value FROM user_settings WHERE key = ?;', [kMcpEnabledKey]);
      if (rows.isEmpty) return false;
      return (rows.first['value'] as String?)?.toLowerCase().trim() == 'true';
    } on SqliteException {
      return false; // missing table / unreadable → treat as disabled
    }
  }

  static const _activeWhere = 'is_archived = 0 AND deleted_at IS NULL';

  DateTime _dt(Object? v) => v is int
      ? DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: true)
      : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  PromptSummary _summary(Row r) => PromptSummary(
        id: r['id'] as String,
        title: r['title'] as String,
        purpose: r['purpose'] as String?,
        body: r['body'] as String? ?? '',
        updatedAt: _dt(r['updated_at']),
      );

  /// All non-archived prompts, newest-updated first.
  List<PromptSummary> listActivePrompts() {
    final rows = _db.select(
        'SELECT id, title, purpose, body, updated_at FROM prompts '
        'WHERE $_activeWhere ORDER BY updated_at DESC;');
    return rows.map(_summary).toList();
  }

  PromptSummary? promptById(String id) {
    final rows = _db.select(
        'SELECT id, title, purpose, body, updated_at FROM prompts '
        'WHERE id = ? AND $_activeWhere;',
        [id]);
    return rows.isEmpty ? null : _summary(rows.first);
  }

  /// Stored variable metadata for a prompt (may be empty even when the body has
  /// `{vars}` — those are then treated as required with no default/description).
  List<PromptVariableMeta> variablesForPrompt(String promptId) {
    final rows = _db.select(
        'SELECT name, description, default_value FROM prompt_variables '
        'WHERE prompt_id = ? ORDER BY sort_order;',
        [promptId]);
    return rows
        .map((r) => PromptVariableMeta(
              name: r['name'] as String,
              description: r['description'] as String?,
              defaultValue: r['default_value'] as String?,
            ))
        .toList();
  }

  List<String> tagsForPrompt(String promptId) {
    final rows = _db.select(
        'SELECT t.name FROM tags t '
        'JOIN prompt_tags pt ON pt.tag_id = t.id '
        'WHERE pt.prompt_id = ? ORDER BY t.name;',
        [promptId]);
    return rows.map((r) => r['name'] as String).toList();
  }

  /// Case-insensitive search over title, purpose, body, and tag names. When
  /// [tags] is given, only prompts carrying **every** listed tag match. Bounded
  /// to [limit] results, newest-updated first.
  List<PromptSummary> search(String query, {List<String> tags = const [], int limit = 20}) {
    final like = '%${query.toLowerCase()}%';
    final params = <Object?>[like, like, like, like];
    final sql = StringBuffer(
        'SELECT DISTINCT p.id, p.title, p.purpose, p.body, p.updated_at '
        'FROM prompts p '
        'LEFT JOIN prompt_tags pt ON pt.prompt_id = p.id '
        'LEFT JOIN tags t ON t.id = pt.tag_id '
        'WHERE p.is_archived = 0 AND p.deleted_at IS NULL AND ('
        'lower(p.title) LIKE ? OR lower(ifnull(p.purpose, \'\')) LIKE ? '
        'OR lower(p.body) LIKE ? OR lower(ifnull(t.name, \'\')) LIKE ?)');
    final cleanTags =
        tags.map((t) => t.toLowerCase().trim()).where((t) => t.isNotEmpty).toSet();
    if (cleanTags.isNotEmpty) {
      final placeholders = List.filled(cleanTags.length, '?').join(', ');
      sql.write(' AND (SELECT COUNT(DISTINCT lower(t2.name)) FROM prompt_tags pt2 '
          'JOIN tags t2 ON t2.id = pt2.tag_id '
          'WHERE pt2.prompt_id = p.id AND lower(t2.name) IN ($placeholders)) = ?');
      params.addAll(cleanTags);
      params.add(cleanTags.length);
    }
    sql.write(' ORDER BY p.updated_at DESC LIMIT ?;');
    params.add(limit);
    final rows = _db.select(sql.toString(), params);
    return rows.map(_summary).toList();
  }

  void close() => _db.close();
}
