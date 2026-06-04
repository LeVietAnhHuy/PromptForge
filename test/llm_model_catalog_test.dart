import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/features/prompt_examples/application/llm_model_catalog.dart';

void main() {
  group('LLM Model Catalog Tests', () {
    test('catalog includes required providers', () {
      expect(defaultModelCatalog.containsKey('openai'), isTrue);
      expect(defaultModelCatalog.containsKey('anthropic'), isTrue);
      expect(defaultModelCatalog.containsKey('google'), isTrue);
      expect(defaultModelCatalog.containsKey('deepseek'), isTrue);
    });

    test('OpenAI models are ordered old-to-new from provided catalog', () {
      final openai = defaultModelCatalog['openai']!;
      expect(openai.models.first.id, equals('gpt-3.5-turbo'));
      expect(openai.models.last.id, equals('text-embedding-3-large'));
      
      // Verify order is preserved correctly
      expect(
        openai.models.map<int>((e) => e.approximateReleaseOrder).toList(),
        isSorted<int>((a, b) => a.compareTo(b)),
      );
    });

    test('Anthropic models are ordered old-to-new from provided catalog', () {
      final anthropic = defaultModelCatalog['anthropic']!;
      expect(anthropic.models.first.id, equals('claude-instant'));
      expect(anthropic.models.last.id, equals('claude-mythos-preview'));
      
      expect(
        anthropic.models.map<int>((e) => e.approximateReleaseOrder).toList(),
        isSorted<int>((a, b) => a.compareTo(b)),
      );
    });

    test('Google models are ordered old-to-new from provided catalog', () {
      final google = defaultModelCatalog['google']!;
      expect(google.models.first.id, equals('text-bison'));
      expect(google.models.last.id, equals('gemini-embedding-001'));
      
      expect(
        google.models.map<int>((e) => e.approximateReleaseOrder).toList(),
        isSorted<int>((a, b) => a.compareTo(b)),
      );
    });

    test('Legacy flags are parsed/stored correctly', () {
      final openai = defaultModelCatalog['openai']!;
      final gpt4 = openai.models.firstWhere((m) => m.id == 'gpt-4');
      final gpt4o = openai.models.firstWhere((m) => m.id == 'gpt-4o');
      final gpt4oMini = openai.models.firstWhere((m) => m.id == 'gpt-4o-mini');
      
      expect(gpt4.isLegacy, isTrue);
      expect(gpt4o.isLegacy, isTrue);
      expect(gpt4oMini.isLegacy, isFalse);
    });

    test('Preview flags are parsed/stored correctly', () {
      final openai = defaultModelCatalog['openai']!;
      final o1Preview = openai.models.firstWhere((m) => m.id == 'o1-preview');
      final o1 = openai.models.firstWhere((m) => m.id == 'o1');
      
      expect(o1Preview.isPreview, isTrue);
      expect(o1.isPreview, isFalse);
    });
  });
}

Matcher isSorted<T>(int Function(T a, T b) compare) => _IsSorted(compare);

class _IsSorted<T> extends Matcher {
  final int Function(T a, T b) _compare;
  const _IsSorted(this._compare);

  @override
  bool matches(item, Map matchState) {
    if (item is! Iterable<T>) return false;
    final list = item.toList();
    for (int i = 0; i < list.length - 1; i++) {
      if (_compare(list[i], list[i + 1]) > 0) return false;
    }
    return true;
  }

  @override
  Description describe(Description description) => description.add('is sorted');
}
