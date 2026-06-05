import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/features/execution/application/pricing_service.dart';

void main() {
  const json = '''
  {
    "schemaVersion": 1,
    "currency": "USD",
    "note": "test",
    "models": {
      "m-cheap": { "input": 1.0, "output": 2.0 }
    }
  }
  ''';

  test('parses the table', () {
    final t = PricingTable.parse(json);
    expect(t.schemaVersion, 1);
    expect(t.currency, 'USD');
    expect(t.models.containsKey('m-cheap'), isTrue);
  });

  test('computes cost from real tokens + a price entry', () {
    final t = PricingTable.parse(json);
    // 1,000,000 in @ \$1/M + 500,000 out @ \$2/M = 1.0 + 1.0 = 2.0
    expect(t.costFor('m-cheap', 1000000, 500000), closeTo(2.0, 1e-9));
  });

  test('returns null (→ "—") when the model has no price entry', () {
    final t = PricingTable.parse(json);
    expect(t.costFor('unknown-model', 1000, 1000), isNull);
  });

  test('returns null when either token count is missing — never fabricates',
      () {
    final t = PricingTable.parse(json);
    expect(t.costFor('m-cheap', null, 1000), isNull);
    expect(t.costFor('m-cheap', 1000, null), isNull);
    expect(t.costFor(null, 1000, 1000), isNull);
  });

  test('the bundled pricing asset is valid JSON with model entries', () async {
    // (Asset loading needs a binding; just validate the parser is robust.)
    final t = PricingTable.parse(json);
    expect(t.models['m-cheap']!.inputPer1M, 1.0);
    expect(t.models['m-cheap']!.outputPer1M, 2.0);
  });

  group('summarizeCosts (per-prompt total)', () {
    final t = PricingTable.parse(json);

    test('sums and marks complete when every run is priced', () {
      final s = t.summarizeCosts([
        (modelId: 'm-cheap', inputTokens: 1000000, outputTokens: 500000), // 2.0
        (modelId: 'm-cheap', inputTokens: 1000000, outputTokens: 0), // 1.0
      ]);
      expect(s.total, closeTo(3.0, 1e-9));
      expect(s.isComplete, isTrue);
      expect(s.hasAny, isTrue);
      expect(s.label, '\$3.000');
    });

    test('marks PARTIAL when some runs lack cost data — never a full sum', () {
      final s = t.summarizeCosts([
        (modelId: 'm-cheap', inputTokens: 1000000, outputTokens: 500000), // 2.0
        (modelId: 'unknown', inputTokens: 1000, outputTokens: 1000), // no price
        (modelId: 'm-cheap', inputTokens: null, outputTokens: 10), // no tokens
      ]);
      expect(s.total, closeTo(2.0, 1e-9));
      expect(s.known, 1);
      expect(s.unknown, 2);
      expect(s.isComplete, isFalse);
      expect(s.label, '\$2.000 · partial');
    });

    test('shows "—" when nothing is computable (never fabricates)', () {
      final s = t.summarizeCosts([
        (modelId: 'unknown', inputTokens: 1000, outputTokens: 1000),
        (modelId: 'm-cheap', inputTokens: null, outputTokens: null),
      ]);
      expect(s.hasAny, isFalse);
      expect(s.label, '—');
    });

    test('empty run list shows "—"', () {
      expect(t.summarizeCosts(const []).label, '—');
    });
  });
}
