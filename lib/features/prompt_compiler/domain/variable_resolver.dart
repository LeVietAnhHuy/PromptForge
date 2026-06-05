/// Pure, dependency-free variable resolution shared by the in-app prompt
/// compiler and the standalone MCP sidecar.
///
/// This file must stay free of Flutter and Drift imports so it can be compiled
/// into the `dart compile exe` sidecar (`bin/promptforge_mcp.dart`). The app's
/// `PromptCompilerService` and the sidecar both build on these primitives so the
/// substitution rules can never diverge.
library;

/// App variable syntax: `{name}` — letters/digits/underscore, must start with a
/// letter or underscore. (Doubled `{{name}}` resolves to the inner `name`.)
final RegExp kVariablePattern = RegExp(r'\{([A-Za-z_][A-Za-z0-9_]*)\}');

/// Unique variable names in [body], in first-appearance order.
List<String> extractVariables(String body) {
  final seen = <String>{};
  final ordered = <String>[];
  for (final m in kVariablePattern.allMatches(body)) {
    final name = m.group(1);
    if (name != null && seen.add(name)) ordered.add(name);
  }
  return ordered;
}

/// Result of [substituteVariables]: the rendered [text] plus the names that
/// [resolve] reported as missing (their `{placeholder}` was kept verbatim).
class SubstitutionResult {
  final String text;
  final List<String> missing;
  const SubstitutionResult(this.text, this.missing);
}

/// Replaces each `{name}` in [body] with `resolve(name)`.
///
/// If [resolve] returns null, the name is recorded as missing and its original
/// `{name}` placeholder is left in place. Returning an empty string substitutes
/// nothing (used for optional variables that should simply vanish). Missing
/// names are de-duplicated and returned in first-appearance order.
SubstitutionResult substituteVariables(
  String body,
  String? Function(String name) resolve,
) {
  final missing = <String>[];
  final missingSeen = <String>{};
  final text = body.replaceAllMapped(kVariablePattern, (match) {
    final name = match.group(1)!;
    final value = resolve(name);
    if (value == null) {
      if (missingSeen.add(name)) missing.add(name);
      return match.group(0)!; // keep `{name}`
    }
    return value;
  });
  return SubstitutionResult(text, missing);
}
