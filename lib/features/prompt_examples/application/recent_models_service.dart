import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/daos/daos.dart';
import '../../../core/database/database_providers.dart';

/// Persists the most recently chosen models per provider (per workspace) in the
/// [UserSettings] table, so the model picker can surface a "Recent" group.
class RecentModelsService {
  RecentModelsService(this._dao);

  final UserSettingsDao _dao;
  static const int maxRecent = 5;

  String _key(String providerId) => 'recent_models:$providerId';

  Future<List<String>> getRecent(String providerId) async {
    final setting = await _dao.getSetting(_key(providerId));
    if (setting == null) return const [];
    try {
      final decoded = jsonDecode(setting.value);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<void> record(String providerId, String modelId) async {
    if (modelId.isEmpty || modelId == 'custom') return;
    final current = await getRecent(providerId);
    final updated = <String>[
      modelId,
      ...current.where((id) => id != modelId),
    ].take(maxRecent).toList();
    await _dao.setSetting(UserSettingsCompanion.insert(
      key: _key(providerId),
      value: jsonEncode(updated),
      updatedAt: DateTime.now(),
    ));
  }
}

final recentModelsServiceProvider = Provider<RecentModelsService>((ref) {
  return RecentModelsService(ref.watch(userSettingsDaoProvider));
});
