import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/features/prompt_compiler/domain/prompt_compiler_service.dart';

void main() {
  group('extractVariables edge cases', () {
    test('returns variables in first-appearance order', () {
      expect(
        PromptCompilerService.extractVariables('{b} text {a} more {c}'),
        ['b', 'a', 'c'],
      );
    });

    test('deduplicates repeated variables', () {
      expect(
        PromptCompilerService.extractVariables('{x} {x} {y} {x}'),
        ['x', 'y'],
      );
    });

    test('adjacent / doubled braces resolve to the inner name', () {
      // The app convention is single-brace {var}; doubled braces {{var}} also
      // resolve to the inner name, and {a}{b} are two distinct variables.
      expect(PromptCompilerService.extractVariables('{{name}}'), ['name']);
      expect(PromptCompilerService.extractVariables('{a}{b}'), ['a', 'b']);
    });

    test('ignores malformed placeholders', () {
      expect(PromptCompilerService.extractVariables('{}'), isEmpty);
      expect(
          PromptCompilerService.extractVariables('{1abc}'), isEmpty); // digit
      expect(PromptCompilerService.extractVariables('{a b}'), isEmpty); // space
      expect(PromptCompilerService.extractVariables('{unclosed'), isEmpty);
      expect(PromptCompilerService.extractVariables('plain text'), isEmpty);
    });

    test('accepts underscores and digits after the first char', () {
      expect(
        PromptCompilerService.extractVariables('{file_path} {arg2} {_x}'),
        ['file_path', 'arg2', '_x'],
      );
    });

    test('detects variables that appear inside fenced code blocks', () {
      // Documented behavior: the compiler substitutes everywhere, so variables
      // in code fences are detected too (not excluded).
      const body = 'before\n```\nrun {cmd} now\n```\nafter {tail}';
      expect(
        PromptCompilerService.extractVariables(body),
        ['cmd', 'tail'],
      );
    });
  });
}
