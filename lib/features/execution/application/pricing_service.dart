import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

/// One model's per-1,000,000-token prices.
class ModelPrice {
  final double inputPer1M;
  final double outputPer1M;
  const ModelPrice(this.inputPer1M, this.outputPer1M);
}

/// Community-maintained pricing table. Sourced from the bundled asset, or a
/// user-edited copy persisted in [UserSettings]. All costs derived from it are
/// estimates (prices change); the UI labels them "est." and only shows a number
/// when BOTH real token counts and a matching price entry exist.
class PricingTable {
  final int schemaVersion;
  final String currency;
  final String note;
  final Map<String, ModelPrice> models;

  const PricingTable({
    required this.schemaVersion,
    required this.currency,
    required this.note,
    required this.models,
  });

  static PricingTable parse(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final modelsRaw = (map['models'] as Map<String, dynamic>? ?? {});
    final models = <String, ModelPrice>{};
    modelsRaw.forEach((id, v) {
      if (v is Map<String, dynamic>) {
        final inp = (v['input'] as num?)?.toDouble();
        final out = (v['output'] as num?)?.toDouble();
        if (inp != null && out != null) {
          models[id] = ModelPrice(inp, out);
        }
      }
    });
    return PricingTable(
      schemaVersion: (map['schemaVersion'] as num?)?.toInt() ?? 1,
      currency: map['currency'] as String? ?? 'USD',
      note: map['note'] as String? ?? '',
      models: models,
    );
  }

  /// Estimated cost for [modelId] given REAL token counts. Returns null when the
  /// model has no price entry or either token count is null — callers must then
  /// show "—" (never a fabricated number).
  double? costFor(String? modelId, int? inputTokens, int? outputTokens) {
    if (modelId == null) return null;
    final price = models[modelId];
    if (price == null) return null;
    if (inputTokens == null || outputTokens == null) return null;
    return inputTokens / 1e6 * price.inputPer1M +
        outputTokens / 1e6 * price.outputPer1M;
  }
}

const _kPricingSettingKey = 'model_pricing_json';
const _kBundledPricingAsset = 'assets/pricing/model_pricing.json';

/// Loads/saves the pricing table (user override in settings, else bundled asset).
class PricingService {
  PricingService(this._ref);
  final Ref _ref;

  Future<String> rawJson() async {
    final override = await _ref
        .read(userSettingsDaoProvider)
        .getSetting(_kPricingSettingKey);
    if (override != null && override.value.trim().isNotEmpty) {
      return override.value;
    }
    return rootBundle.loadString(_kBundledPricingAsset);
  }

  Future<PricingTable> load() async => PricingTable.parse(await rawJson());

  /// Persists a user-edited pricing table. Throws if [jsonStr] is invalid.
  Future<void> save(String jsonStr) async {
    PricingTable.parse(jsonStr); // validate (throws on bad JSON/shape)
    await _ref.read(userSettingsDaoProvider).setSetting(
          UserSettingsCompanion.insert(
            key: _kPricingSettingKey,
            value: jsonStr,
            updatedAt: DateTime.now(),
          ),
        );
    _ref.invalidate(pricingTableProvider);
  }

  /// Reverts to the bundled table by clearing the override.
  Future<void> resetToBundled() async {
    await _ref.read(userSettingsDaoProvider).setSetting(
          UserSettingsCompanion.insert(
            key: _kPricingSettingKey,
            value: '',
            updatedAt: DateTime.now(),
          ),
        );
    _ref.invalidate(pricingTableProvider);
  }

  Future<String> bundledJson() => rootBundle.loadString(_kBundledPricingAsset);
}

final pricingServiceProvider =
    Provider<PricingService>((ref) => PricingService(ref));

final pricingTableProvider = FutureProvider<PricingTable>((ref) async {
  return ref.read(pricingServiceProvider).load();
});
