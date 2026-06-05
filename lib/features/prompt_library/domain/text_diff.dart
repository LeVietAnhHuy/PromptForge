/// Minimal line-level text diff (LCS-based) for the prompt version diff view.
enum DiffOp { unchanged, added, removed }

class DiffLine {
  final DiffOp op;
  final String text;
  const DiffLine(this.op, this.text);

  @override
  bool operator ==(Object other) =>
      other is DiffLine && other.op == op && other.text == text;

  @override
  int get hashCode => Object.hash(op, text);

  @override
  String toString() => '${op.name}: $text';
}

/// Computes a line-level diff between [oldText] and [newText]. Returns the lines
/// in output order: unchanged lines in place, removed (only in old) and added
/// (only in new) marked accordingly. Uses a standard longest-common-subsequence
/// over lines.
List<DiffLine> diffLines(String oldText, String newText) {
  final a = _splitLines(oldText);
  final b = _splitLines(newText);
  final n = a.length;
  final m = b.length;

  // LCS length table.
  final lcs = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      if (a[i] == b[j]) {
        lcs[i][j] = lcs[i + 1][j + 1] + 1;
      } else {
        lcs[i][j] =
            lcs[i + 1][j] >= lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1];
      }
    }
  }

  final result = <DiffLine>[];
  var i = 0;
  var j = 0;
  while (i < n && j < m) {
    if (a[i] == b[j]) {
      result.add(DiffLine(DiffOp.unchanged, a[i]));
      i++;
      j++;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      result.add(DiffLine(DiffOp.removed, a[i]));
      i++;
    } else {
      result.add(DiffLine(DiffOp.added, b[j]));
      j++;
    }
  }
  while (i < n) {
    result.add(DiffLine(DiffOp.removed, a[i++]));
  }
  while (j < m) {
    result.add(DiffLine(DiffOp.added, b[j++]));
  }
  return result;
}

/// Summary counts for a diff (added / removed lines).
({int added, int removed}) diffStats(List<DiffLine> lines) {
  var added = 0;
  var removed = 0;
  for (final l in lines) {
    if (l.op == DiffOp.added) added++;
    if (l.op == DiffOp.removed) removed++;
  }
  return (added: added, removed: removed);
}

List<String> _splitLines(String text) {
  if (text.isEmpty) return const [];
  return text.replaceAll('\r\n', '\n').split('\n');
}
