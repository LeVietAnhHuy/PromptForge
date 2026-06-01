class PromptCompiler {
  /// Regular expression to match variables in the format {{variable_name}}
  /// Allows letters, numbers, underscores, and hyphens.
  /// Also allows arbitrary whitespace inside the braces, e.g., {{ topic }}.
  static final RegExp _variableRegex = RegExp(r'\{\{\s*([a-zA-Z0-9_-]+)\s*\}\}');

  /// Extracts all unique variables from the given prompt body.
  /// Preserves the order of their first appearance.
  static List<String> extractVariables(String promptBody) {
    final matches = _variableRegex.allMatches(promptBody);
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

  /// Compiles the prompt by replacing each variable with the provided value.
  /// If a variable doesn't have a provided value, it will be left as is or
  /// replaced with empty string depending on requirement. The rules say:
  /// "Empty values should either remain visibly unresolved or show validation."
  /// We will leave them unresolved (as the original placeholder) if missing.
  static String compilePrompt(String promptBody, Map<String, String> values) {
    return promptBody.replaceAllMapped(_variableRegex, (match) {
      if (match.groupCount >= 1) {
        final variableName = match.group(1);
        if (variableName != null && values.containsKey(variableName)) {
          final val = values[variableName]!;
          if (val.isNotEmpty) {
            return val;
          }
        }
      }
      return match.group(0)!; // Leave unchanged if no valid value provided
    });
  }
}
