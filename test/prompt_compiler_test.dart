import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/features/prompt_compiler/domain/prompt_compiler.dart';

void main() {
  group('PromptCompiler', () {
    test('extracts zero variables from plain text', () {
      final variables = PromptCompiler.extractVariables('Just a plain text prompt');
      expect(variables, isEmpty);
    });

    test('extracts multiple variables and preserves order', () {
      final variables = PromptCompiler.extractVariables('Write a {{tone}} email to {{recipient}}.');
      expect(variables, ['tone', 'recipient']);
    });

    test('deduplicates variables', () {
      final variables = PromptCompiler.extractVariables('{{topic}} is great. Tell me more about {{topic}}.');
      expect(variables, ['topic']);
    });

    test('normalizes whitespace in variables', () {
      final variables = PromptCompiler.extractVariables('{{ topic }} and {{topic}} and {{  topic  }}');
      expect(variables, ['topic']);
    });

    test('safely ignores malformed variables', () {
      final variables = PromptCompiler.extractVariables('{{}} {{   }} {{variable \n variable}} {variable}');
      expect(variables, isEmpty);
    });

    test('compiles prompt by replacing variables', () {
      const prompt = 'Write a {{tone}} email to {{recipient}} about {{topic}} for a {{  tone  }} audience.';
      final values = {
        'tone': 'friendly',
        'recipient': 'Alice',
        'topic': 'Flutter',
      };
      
      final compiled = PromptCompiler.compilePrompt(prompt, values);
      expect(compiled, 'Write a friendly email to Alice about Flutter for a friendly audience.');
    });

    test('leaves unresolved variables intact', () {
      const prompt = 'Write a {{tone}} email to {{recipient}}';
      final values = {
        'tone': 'friendly',
        // recipient is missing
      };
      
      final compiled = PromptCompiler.compilePrompt(prompt, values);
      expect(compiled, 'Write a friendly email to {{recipient}}');
    });
  });
}
