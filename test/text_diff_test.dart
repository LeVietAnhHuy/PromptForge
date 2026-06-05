import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/features/prompt_library/domain/text_diff.dart';

void main() {
  group('diffLines', () {
    test('identical text yields all-unchanged', () {
      final d = diffLines('a\nb\nc', 'a\nb\nc');
      expect(d.every((l) => l.op == DiffOp.unchanged), isTrue);
      expect(diffStats(d), (added: 0, removed: 0));
    });

    test('detects an added line', () {
      final d = diffLines('a\nb', 'a\nx\nb');
      expect(d, [
        const DiffLine(DiffOp.unchanged, 'a'),
        const DiffLine(DiffOp.added, 'x'),
        const DiffLine(DiffOp.unchanged, 'b'),
      ]);
      expect(diffStats(d), (added: 1, removed: 0));
    });

    test('detects a removed line', () {
      final d = diffLines('a\nb\nc', 'a\nc');
      expect(d, [
        const DiffLine(DiffOp.unchanged, 'a'),
        const DiffLine(DiffOp.removed, 'b'),
        const DiffLine(DiffOp.unchanged, 'c'),
      ]);
      expect(diffStats(d), (added: 0, removed: 1));
    });

    test('detects a changed line as remove + add', () {
      final d = diffLines('hello world', 'hello there');
      expect(diffStats(d), (added: 1, removed: 1));
    });

    test('handles empty old (all added) and empty new (all removed)', () {
      expect(diffStats(diffLines('', 'a\nb')), (added: 2, removed: 0));
      expect(diffStats(diffLines('a\nb', '')), (added: 0, removed: 2));
    });

    test('normalizes CRLF', () {
      final d = diffLines('a\r\nb', 'a\nb');
      expect(d.every((l) => l.op == DiffOp.unchanged), isTrue);
    });
  });
}
