import '../../../core/database/database.dart';

class PromptCompilerResult {
  final String compiledText;
  final List<String> missingRequiredVariables;
  final int characterCount;

  PromptCompilerResult({
    required this.compiledText,
    required this.missingRequiredVariables,
    required this.characterCount,
  });
}

class PromptCompilerService {
  /// Regular expression to match variables in the format {variable_name}
  /// Letters, numbers, underscore. Must start with letter or underscore. No spaces.
  static final RegExp variableRegex = RegExp(r'\{([A-Za-z_][A-Za-z0-9_]*)\}');

  /// Extracts all unique variables from the given prompt body.
  /// Preserves the order of their first appearance.
  static List<String> extractVariables(String promptBody) {
    final matches = variableRegex.allMatches(promptBody);
    final variables = <String>{};

    for (final match in matches) {
      if (match.groupCount >= 1) {
        final variableName = match.group(1);
        if (variableName != null) {
          variables.add(variableName);
        }
      }
    }

    return variables.toList();
  }

  /// Compiles the prompt by replacing variables, injecting context packs, and output requirements.
  static PromptCompilerResult compile({
    required String promptBody,
    required Map<String, String> runtimeValues,
    required Map<String, PromptVariable> variableMetadata,
    required List<ContextPack> contextPacks,
    String? outputFormat,
    String? targetNotes,
  }) {
    final missingRequiredVariables = <String>[];
    
    // 1. Process prompt body
    final compiledPromptBody = promptBody.replaceAllMapped(variableRegex, (match) {
      final varName = match.group(1)!;
      final meta = variableMetadata[varName];
      final isRequired = meta?.isRequired ?? true;
      final defaultValue = meta?.defaultValue;
      
      final runtimeVal = runtimeValues[varName] ?? '';
      
      String finalValue = '';
      
      if (runtimeVal.isNotEmpty) {
        finalValue = runtimeVal;
      } else if (defaultValue != null && defaultValue.isNotEmpty) {
        finalValue = defaultValue;
      } else {
        if (isRequired) {
          missingRequiredVariables.add(varName);
          return match.group(0)!; // Keep {variable} placeholder if missing & required
        } else {
          return ''; // Remove if optional and missing
        }
      }
      
      return finalValue;
    });

    // 2. Assemble sections
    final buffer = StringBuffer();

    // Context Packs Section
    if (contextPacks.isNotEmpty) {
      buffer.writeln('# Context Packs\n');
      for (final pack in contextPacks) {
        buffer.writeln('## ${pack.name}\n');
        buffer.writeln('${pack.content}\n');
      }
      buffer.writeln('---');
      buffer.writeln();
    }

    // Prompt Section
    if (contextPacks.isNotEmpty || (outputFormat != null && outputFormat.isNotEmpty) || (targetNotes != null && targetNotes.isNotEmpty)) {
      buffer.writeln('# Prompt\n');
    }
    buffer.writeln(compiledPromptBody);

    // Output Requirements Section
    final hasOutputFormat = outputFormat != null && outputFormat.trim().isNotEmpty;
    final hasTargetNotes = targetNotes != null && targetNotes.trim().isNotEmpty;
    
    if (hasOutputFormat || hasTargetNotes) {
      buffer.writeln('\n\n# Output Requirements\n');
      if (hasOutputFormat) {
        buffer.writeln(outputFormat);
      }
      if (hasTargetNotes) {
        if (hasOutputFormat) buffer.writeln();
        buffer.writeln(targetNotes);
      }
    }

    final compiledText = buffer.toString().trim();

    return PromptCompilerResult(
      compiledText: compiledText,
      missingRequiredVariables: missingRequiredVariables.toSet().toList(), // deduplicate missing list
      characterCount: compiledText.length,
    );
  }
}
