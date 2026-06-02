import '../../../core/database/database.dart';
import 'target_tool_profile.dart';

class PromptCompilerResult {
  final String compiledText;
  final List<String> missingRequiredVariables;
  final int characterCount;
  final String targetProfileId;
  final String targetProfileName;

  PromptCompilerResult({
    required this.compiledText,
    required this.missingRequiredVariables,
    required this.characterCount,
    required this.targetProfileId,
    required this.targetProfileName,
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

  static PromptCompilerResult compile({
    required String promptBody,
    required Map<String, String> runtimeValues,
    required Map<String, PromptVariable> variableMetadata,
    required List<ContextPack> contextPacks,
    TargetToolProfile? profile,
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

    final targetProfile = profile ?? const GenericProfile();
    final compilerContext = CompilerContext(
      compiledPromptBody: compiledPromptBody,
      contextPacks: contextPacks,
      outputFormat: outputFormat,
      targetNotes: targetNotes,
    );

    final compiledText = targetProfile.format(compilerContext);

    return PromptCompilerResult(
      compiledText: compiledText,
      missingRequiredVariables: missingRequiredVariables.toSet().toList(), // deduplicate missing list
      characterCount: compiledText.length,
      targetProfileId: targetProfile.id,
      targetProfileName: targetProfile.name,
    );
  }
}
