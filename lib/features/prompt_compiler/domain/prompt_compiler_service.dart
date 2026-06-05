import '../../../core/database/database.dart';
import 'target_tool_profile.dart';
import 'variable_resolver.dart' as resolver;

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
  /// Variable syntax `{variable_name}` — shared with the MCP sidecar via
  /// `variable_resolver.dart` so the two never diverge.
  static final RegExp variableRegex = resolver.kVariablePattern;

  /// Extracts all unique variables from the given prompt body, in
  /// first-appearance order. Delegates to the shared resolver.
  static List<String> extractVariables(String promptBody) =>
      resolver.extractVariables(promptBody);

  static PromptCompilerResult compile({
    required String promptBody,
    required Map<String, String> runtimeValues,
    required Map<String, PromptVariable> variableMetadata,
    required List<ContextPack> contextPacks,
    TargetToolProfile? profile,
    String? outputFormat,
    String? targetNotes,
  }) {
    // 1. Process prompt body via the shared resolver. The closure reproduces
    // the original rule exactly: runtime value wins, else default, else (if
    // required) report missing + keep the placeholder, else drop it.
    final substitution = resolver.substituteVariables(promptBody, (varName) {
      final meta = variableMetadata[varName];
      final runtimeVal = runtimeValues[varName] ?? '';
      if (runtimeVal.isNotEmpty) return runtimeVal;
      final defaultValue = meta?.defaultValue;
      if (defaultValue != null && defaultValue.isNotEmpty) return defaultValue;
      final isRequired = meta?.isRequired ?? true;
      return isRequired ? null : ''; // null → missing + keep placeholder
    });
    final compiledPromptBody = substitution.text;
    final missingRequiredVariables = substitution.missing;

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
