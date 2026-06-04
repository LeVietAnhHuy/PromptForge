import 'package:flutter_test/flutter_test.dart';
import 'package:promptforge/features/inbox/domain/markdown_block_parser.dart';

void main() {
  group('MarkdownBlockParser', () {
    final parser = MarkdownBlockParser();

    test('splits headings into blocks', () {
      const text = '# Heading 1\n## Heading 2';
      final blocks = parser.parse(text);
      expect(blocks.length, 2);
      expect(blocks[0].type, MarkdownBlockType.heading);
      expect(blocks[0].rawText, '# Heading 1');
      expect(blocks[1].type, MarkdownBlockType.heading);
      expect(blocks[1].rawText, '## Heading 2');
    });

    test('splits paragraphs into blocks', () {
      const text = 'Para 1 Line 1\nPara 1 Line 2\n\nPara 2';
      final blocks = parser.parse(text);
      expect(blocks.length, 3);
      expect(blocks[0].type, MarkdownBlockType.paragraph);
      expect(blocks[0].rawText, 'Para 1 Line 1\nPara 1 Line 2');
      expect(blocks[1].type, MarkdownBlockType.empty);
      expect(blocks[2].type, MarkdownBlockType.paragraph);
      expect(blocks[2].rawText, 'Para 2');
    });

    test('splits bullet lists into one list block', () {
      const text = '- Item 1\n- Item 2\n  - Subitem';
      final blocks = parser.parse(text);
      expect(blocks.length, 1);
      expect(blocks[0].type, MarkdownBlockType.list);
      expect(blocks[0].rawText, text);
    });

    test('preserves fenced code block as one block', () {
      const text = '```dart\nfinal x = 1;\n```';
      final blocks = parser.parse(text);
      expect(blocks.length, 1);
      expect(blocks[0].type, MarkdownBlockType.code);
      expect(blocks[0].rawText, text);
    });

    test('handles blockquotes', () {
      const text = '> Quote\n> Quote line 2';
      final blocks = parser.parse(text);
      expect(blocks.length, 1);
      expect(blocks[0].type, MarkdownBlockType.blockquote);
      expect(blocks[0].rawText, text);
    });

    test('handles empty content', () {
      const text = '';
      final blocks = parser.parse(text);
      expect(blocks.isEmpty, true);
    });

    group('TOC Extraction', () {
      test('Extracts H1, H2, H3 headings', () {
        const text = '# Title\nPara\n## Section 1\n### Subsection';
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
        const text = 'Para\n- List\n```\ncode\n```\n# Heading';
        final blocks = parser.parse(text);
        final toc = parser.extractToc(blocks);
        
        expect(toc.length, 1);
        expect(toc[0].text, 'Heading');
      });

      test('Handles duplicate headings with unique IDs', () {
        const text = '# Duplicate\n## Duplicate\n### Duplicate';
        final blocks = parser.parse(text);
        final toc = parser.extractToc(blocks);
        
        expect(toc.length, 3);
        expect(toc[0].id, 'duplicate');
        expect(toc[1].id, 'duplicate-1');
        expect(toc[2].id, 'duplicate-2');
      });

      test('Handles empty headings', () {
        const text = '# \n##';
        final blocks = parser.parse(text);
        final toc = parser.extractToc(blocks);
        
        expect(toc.isEmpty, true);
      });
    });

    group('Deterministic Block IDs', () {
      test('Block IDs are stable across repeated parses', () {
        const text = '# Title\nParagraph\n## Section\n```\ncode\n```';
        final blocks1 = parser.parse(text);
        final blocks2 = parser.parse(text);

        expect(blocks1.length, blocks2.length);
        for (int i = 0; i < blocks1.length; i++) {
          expect(blocks1[i].id, blocks2[i].id);
        }
      });

      test('Block IDs use line number and type', () {
        const text = '# Heading\nParagraph';
        final blocks = parser.parse(text);

        expect(blocks[0].id, 'block_0_heading');
        expect(blocks[1].id, 'block_1_paragraph');
      });

      test('TOC blockId matches heading block ID', () {
        const text = '# Title\nPara\n## Section 1\n### Sub';
        final blocks = parser.parse(text);
        final toc = parser.extractToc(blocks);

        // Each TOC item's blockId should match a heading block's id
        final headingIds = blocks
            .where((b) => b.type == MarkdownBlockType.heading)
            .map((b) => b.id)
            .toSet();

        for (final item in toc) {
          expect(headingIds.contains(item.blockId), true,
            reason: 'TOC item "${item.text}" blockId "${item.blockId}" not found in heading blocks');
        }
      });

      test('TOC blockId is stable across reparses', () {
        const text = '# Alpha\n## Beta\n### Gamma';
        final toc1 = parser.extractToc(parser.parse(text));
        final toc2 = parser.extractToc(parser.parse(text));

        expect(toc1.length, toc2.length);
        for (int i = 0; i < toc1.length; i++) {
          expect(toc1[i].id, toc2[i].id);
          expect(toc1[i].blockId, toc2[i].blockId);
        }
      });
    });
  });
}
