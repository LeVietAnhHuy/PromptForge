import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/features/inbox/domain/markdown_block_parser.dart';

void main() {
  group('MarkdownBlockParser', () {
    final parser = MarkdownBlockParser();

    test('splits headings into blocks', () {
      final text = '# Heading 1\n## Heading 2';
      final blocks = parser.parse(text);
      expect(blocks.length, 2);
      expect(blocks[0].type, MarkdownBlockType.heading);
      expect(blocks[0].rawText, '# Heading 1');
      expect(blocks[1].type, MarkdownBlockType.heading);
      expect(blocks[1].rawText, '## Heading 2');
    });

    test('splits paragraphs into blocks', () {
      final text = 'Para 1 Line 1\nPara 1 Line 2\n\nPara 2';
      final blocks = parser.parse(text);
      expect(blocks.length, 3);
      expect(blocks[0].type, MarkdownBlockType.paragraph);
      expect(blocks[0].rawText, 'Para 1 Line 1\nPara 1 Line 2');
      expect(blocks[1].type, MarkdownBlockType.empty);
      expect(blocks[2].type, MarkdownBlockType.paragraph);
      expect(blocks[2].rawText, 'Para 2');
    });

    test('splits bullet lists into one list block', () {
      final text = '- Item 1\n- Item 2\n  - Subitem';
      final blocks = parser.parse(text);
      expect(blocks.length, 1);
      expect(blocks[0].type, MarkdownBlockType.list);
      expect(blocks[0].rawText, text);
    });

    test('preserves fenced code block as one block', () {
      final text = '```dart\nfinal x = 1;\n```';
      final blocks = parser.parse(text);
      expect(blocks.length, 1);
      expect(blocks[0].type, MarkdownBlockType.code);
      expect(blocks[0].rawText, text);
    });

    test('handles blockquotes', () {
      final text = '> Quote\n> Quote line 2';
      final blocks = parser.parse(text);
      expect(blocks.length, 1);
      expect(blocks[0].type, MarkdownBlockType.blockquote);
      expect(blocks[0].rawText, text);
    });

    test('handles empty content', () {
      final text = '';
      final blocks = parser.parse(text);
      expect(blocks.isEmpty, true);
    });

    group('TOC Extraction', () {
      test('Extracts H1, H2, H3 headings', () {
        final text = '# Title\nPara\n## Section 1\n### Subsection';
        final blocks = parser.parse(text);
        final toc = parser.extractToc(blocks);
        
        expect(toc.length, 3);
        expect(toc[0].level, 1);
        expect(toc[0].text, 'Title');
        expect(toc[1].level, 2);
        expect(toc[1].text, 'Section 1');
        expect(toc[2].level, 3);
        expect(toc[2].text, 'Subsection');
      });

      test('Ignores non-heading blocks', () {
        final text = 'Para\n- List\n```\ncode\n```\n# Heading';
        final blocks = parser.parse(text);
        final toc = parser.extractToc(blocks);
        
        expect(toc.length, 1);
        expect(toc[0].text, 'Heading');
      });

      test('Handles duplicate headings with unique IDs', () {
        final text = '# Duplicate\n## Duplicate\n### Duplicate';
        final blocks = parser.parse(text);
        final toc = parser.extractToc(blocks);
        
        expect(toc.length, 3);
        expect(toc[0].id, 'duplicate');
        expect(toc[1].id, 'duplicate-1');
        expect(toc[2].id, 'duplicate-2');
      });

      test('Handles empty headings', () {
        final text = '# \n##';
        final blocks = parser.parse(text);
        final toc = parser.extractToc(blocks);
        
        expect(toc.isEmpty, true);
      });
    });
  });
}
