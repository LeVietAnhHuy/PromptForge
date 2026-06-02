import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/core/database/database.dart';
import 'package:promptforge/features/prompt_compiler/domain/prompt_compiler_service.dart';
import 'package:promptforge/features/prompt_compiler/domain/target_tool_profile.dart';

void main() {
  group('PromptCompilerService - extractVariables', () {
    test('1. Detects a single variable', () {
      final vars = PromptCompilerService.extractVariables('Hello {name}');
      expect(vars, ['name']);
    });

    test('2. Detects multiple variables', () {
      final vars = PromptCompilerService.extractVariables('{greeting} {name}, how are you on this {day}?');
      expect(vars, ['greeting', 'name', 'day']);
    });

    test('3. Deduplicates repeated variables', () {
      final vars = PromptCompilerService.extractVariables('{name} {name} {age} {name}');
      expect(vars, ['name', 'age']);
    });

    test('4. Ignores invalid variable patterns', () {
      final vars = PromptCompilerService.extractVariables('{1name} {name-with-dash} { name } {}');
      // {1name} fails because it starts with a number
      // {name-with-dash} fails because of dash
      // { name } fails because of space
      // {} fails because it's empty
      expect(vars, isEmpty);
      
      final vars2 = PromptCompilerService.extractVariables('{_valid_123}');
      expect(vars2, ['_valid_123']);
    });
  });

  group('PromptCompilerService - compile', () {
    test('5. Replaces variables with runtime values', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Hello {name}, your role is {role}.',
        runtimeValues: {'name': 'Alice', 'role': 'Admin'},
        variableMetadata: {},
        contextPacks: [],
      );
      expect(result.compiledText, 'Hello Alice, your role is Admin.');
      expect(result.missingRequiredVariables, isEmpty);
    });

    test('6. Replaces repeated variables consistently', () {
      final result = PromptCompilerService.compile(
        promptBody: '{name} {name} {name}',
        runtimeValues: {'name': 'Echo'},
        variableMetadata: {},
        contextPacks: [],
      );
      expect(result.compiledText, 'Echo Echo Echo');
    });

    test('7. Uses default value when runtime value is empty', () {
      final meta = PromptVariable(
        id: '1', promptId: '1', name: 'color', defaultValue: 'blue', isRequired: true, sortOrder: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()
      );
      final result = PromptCompilerService.compile(
        promptBody: 'Sky is {color}.',
        runtimeValues: {'color': ''}, // empty runtime value
        variableMetadata: {'color': meta},
        contextPacks: [],
      );
      expect(result.compiledText, 'Sky is blue.');
    });

    test('8. Reports missing required variables', () {
      final meta = PromptVariable(
        id: '1', promptId: '1', name: 'age', isRequired: true, sortOrder: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()
      );
      final result = PromptCompilerService.compile(
        promptBody: '{name} is {age}.',
        runtimeValues: {}, // missing both
        variableMetadata: {'age': meta}, // 'name' defaults to required
        contextPacks: [],
      );
      expect(result.missingRequiredVariables.contains('name'), isTrue);
      expect(result.missingRequiredVariables.contains('age'), isTrue);
    });

    test('9. Does not silently empty missing required variables', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Hello {name}!',
        runtimeValues: {}, // missing name, implicitly required
        variableMetadata: {},
        contextPacks: [],
      );
      expect(result.compiledText, 'Hello {name}!'); // Keeps placeholder
      expect(result.missingRequiredVariables, ['name']);
    });

    test('Handles optional missing variables by emptying them', () {
      final meta = PromptVariable(
        id: '1', promptId: '1', name: 'title', isRequired: false, sortOrder: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()
      );
      final result = PromptCompilerService.compile(
        promptBody: 'Hello {title} {name}',
        runtimeValues: {'name': 'John'}, // missing title
        variableMetadata: {'title': meta},
        contextPacks: [],
      );
      expect(result.compiledText, 'Hello  John');
    });

    test('10. Handles prompt with no variables', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Just a plain string.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [],
      );
      expect(result.compiledText, 'Just a plain string.');
      expect(result.missingRequiredVariables, isEmpty);
    });

    test('11. Injects context packs before prompt', () {
      final pack = ContextPack(
        id: 'p1', name: 'Rules', content: 'Do not lie.', isBuiltin: false, sortOrder: 0, isArchived: false, createdAt: DateTime.now(), updatedAt: DateTime.now()
      );
      final result = PromptCompilerService.compile(
        promptBody: 'Tell me a story.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [pack],
      );
      expect(result.compiledText, contains('# Context Packs'));
      expect(result.compiledText, contains('## Rules'));
      expect(result.compiledText, contains('Do not lie.'));
      expect(result.compiledText, contains('# Prompt\n\nTell me a story.'));
    });

    test('12. Respects context pack sort order (done by caller, checking format here)', () {
      final pack1 = ContextPack(id: 'p1', name: 'P1', content: 'C1', isBuiltin: false, sortOrder: 0, isArchived: false, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final pack2 = ContextPack(id: 'p2', name: 'P2', content: 'C2', isBuiltin: false, sortOrder: 1, isArchived: false, createdAt: DateTime.now(), updatedAt: DateTime.now());
      // The caller is responsible for passing them sorted.
      final result = PromptCompilerService.compile(
        promptBody: 'Body',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [pack1, pack2],
      );
      final text = result.compiledText;
      expect(text.indexOf('## P1'), lessThan(text.indexOf('## P2')));
    });

    test('13. Omits empty sections', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Only prompt',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [], // no packs
        outputFormat: '', // no output format
      );
      expect(result.compiledText, 'Only prompt'); // no headings injected
    });

    test('14. Includes output requirements when present', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Summarize text.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [],
        outputFormat: 'Return JSON.',
        targetNotes: 'Must be short.',
      );
      expect(result.compiledText, contains('# Prompt\n\nSummarize text.'));
      expect(result.compiledText, contains('# Output Requirements\n\nReturn JSON.\n\nMust be short.'));
    });

    test('15. Produces stable output across repeated runs', () {
      final pack = ContextPack(id: 'p1', name: 'Rules', content: 'C1', isBuiltin: false, sortOrder: 0, isArchived: false, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final res1 = PromptCompilerService.compile(
        promptBody: '{var}',
        runtimeValues: {'var': 'val'},
        variableMetadata: {},
        contextPacks: [pack],
        outputFormat: 'fmt',
      );
      final res2 = PromptCompilerService.compile(
        promptBody: '{var}',
        runtimeValues: {'var': 'val'},
        variableMetadata: {},
        contextPacks: [pack],
        outputFormat: 'fmt',
      );
      expect(res1.compiledText, res2.compiledText);
    });
    test('16. ChatGPT Profile uses # Task', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Do this.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [],
        profile: const ChatGPTProfile(),
      );
      expect(result.compiledText, contains('# Task\n\nDo this.'));
    });

    test('17. Claude Profile uses XML tags', () {
      final pack = ContextPack(id: '1', name: 'P1', content: 'C1', isBuiltin: false, sortOrder: 0, isArchived: false, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final result = PromptCompilerService.compile(
        promptBody: 'Do this.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [pack],
        profile: const ClaudeProfile(),
      );
      expect(result.compiledText, contains('<context>\nC1\n\n</context>'));
      expect(result.compiledText, contains('<task>\nDo this.\n</task>'));
    });

    test('18. Codex Profile uses implementation wrapper', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Add button.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [],
        profile: const CodexProfile(),
      );
      expect(result.compiledText, contains('Please implement the following changes.'));
      expect(result.compiledText, contains('# Implementation Request\n\nAdd button.'));
    });

    test('19. Cursor Profile uses IDE wrapper', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Add dropdown.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [],
        profile: const CursorProfile(),
      );
      expect(result.compiledText, contains('Inspect the current code and preserve existing architecture.'));
    });

    test('20. NotebookLM Profile warns about sources', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Summarize.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [],
        profile: const NotebookLMProfile(),
      );
      expect(result.compiledText, contains('Use only the uploaded/source material when answering.'));
    });

    test('21. Flow Image Profile uses minimal visual structure', () {
      final pack = ContextPack(id: '1', name: 'Lighting', content: 'Cinematic lighting', isBuiltin: false, sortOrder: 0, isArchived: false, createdAt: DateTime.now(), updatedAt: DateTime.now());
      final result = PromptCompilerService.compile(
        promptBody: 'A futuristic city.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [pack],
        profile: const FlowImageProfile(),
        outputFormat: '--ar 16:9',
      );
      expect(result.compiledText, 'A futuristic city.\n\nCinematic lighting\n\n--ar 16:9');
    });

    test('22. Local Model uses shorter wrapper', () {
      final result = PromptCompilerService.compile(
        promptBody: 'Hello.',
        runtimeValues: {},
        variableMetadata: {},
        contextPacks: [],
        profile: const LocalModelProfile(),
      );
      expect(result.compiledText, 'Hello.');
    });
  });
}
