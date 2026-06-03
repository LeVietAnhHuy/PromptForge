enum MarkdownBlockType {
  heading,
  paragraph,
  list,
  code,
  blockquote,
  hr,
  empty
}

class MarkdownBlock {
  final String id;
  final int startLine;
  final int endLine;
  final String rawText;
  final MarkdownBlockType type;

  MarkdownBlock({
    required this.id,
    required this.startLine,
    required this.endLine,
    required this.rawText,
    required this.type,
  });

  MarkdownBlock copyWith({
    String? id,
    int? startLine,
    int? endLine,
    String? rawText,
    MarkdownBlockType? type,
  }) {
    return MarkdownBlock(
      id: id ?? this.id,
      startLine: startLine ?? this.startLine,
      endLine: endLine ?? this.endLine,
      rawText: rawText ?? this.rawText,
      type: type ?? this.type,
    );
  }
}

class MarkdownTocItem {
  final String id;
  final String text;
  final int level;
  final String blockId;

  MarkdownTocItem({
    required this.id,
    required this.text,
    required this.level,
    required this.blockId,
  });
}

class MarkdownBlockParser {
  List<MarkdownBlock> parse(String text) {
    if (text.isEmpty) {
      return [];
    }

    final lines = text.split('\n');
    final blocks = <MarkdownBlock>[];
    
    int currentLineIdx = 0;
    
    while (currentLineIdx < lines.length) {
      final line = lines[currentLineIdx];
      
      // Blank line
      if (line.trim().isEmpty) {
        blocks.add(MarkdownBlock(
          id: DateTime.now().microsecondsSinceEpoch.toString() + '_$currentLineIdx',
          startLine: currentLineIdx,
          endLine: currentLineIdx,
          rawText: line,
          type: MarkdownBlockType.empty,
        ));
        currentLineIdx++;
        continue;
      }
      
      // Fenced code block
      if (line.trim().startsWith('```')) {
        int start = currentLineIdx;
        currentLineIdx++;
        while (currentLineIdx < lines.length && !lines[currentLineIdx].trim().startsWith('```')) {
          currentLineIdx++;
        }
        if (currentLineIdx < lines.length) {
          currentLineIdx++; // consume closing fence
        }
        blocks.add(_createBlock(lines, start, currentLineIdx - 1, MarkdownBlockType.code));
        continue;
      }

      // Heading
      if (line.startsWith('#')) {
        blocks.add(_createBlock(lines, currentLineIdx, currentLineIdx, MarkdownBlockType.heading));
        currentLineIdx++;
        continue;
      }

      // Horizontal Rule
      final trimmed = line.trim();
      if (trimmed == '---' || trimmed == '***' || trimmed == '___') {
        blocks.add(_createBlock(lines, currentLineIdx, currentLineIdx, MarkdownBlockType.hr));
        currentLineIdx++;
        continue;
      }

      // Blockquote
      if (line.trim().startsWith('>')) {
        int start = currentLineIdx;
        while (currentLineIdx < lines.length && lines[currentLineIdx].trim().startsWith('>')) {
          currentLineIdx++;
        }
        blocks.add(_createBlock(lines, start, currentLineIdx - 1, MarkdownBlockType.blockquote));
        continue;
      }

      // List (bullet or numbered)
      final isListLine = (String l) {
        final t = l.trim();
        if (t.startsWith('- ') || t.startsWith('* ') || t.startsWith('+ ')) return true;
        return RegExp(r'^\d+\.\s').hasMatch(t);
      };

      if (isListLine(line)) {
        int start = currentLineIdx;
        while (currentLineIdx < lines.length && (isListLine(lines[currentLineIdx]) || (lines[currentLineIdx].startsWith(' ') || lines[currentLineIdx].startsWith('\t')))) {
          // Continue if it's a list item or indented line (part of list)
          // Stop on blank lines or new block types
          if (lines[currentLineIdx].trim().isEmpty) break;
          currentLineIdx++;
        }
        blocks.add(_createBlock(lines, start, currentLineIdx - 1, MarkdownBlockType.list));
        continue;
      }

      // Paragraph (consecutive non-empty lines that don't match other blocks)
      int start = currentLineIdx;
      while (currentLineIdx < lines.length) {
        final l = lines[currentLineIdx];
        if (l.trim().isEmpty) break;
        if (l.startsWith('#') || l.trim().startsWith('```') || l.trim().startsWith('>') || isListLine(l) || ['---', '***', '___'].contains(l.trim())) break;
        currentLineIdx++;
      }
      blocks.add(_createBlock(lines, start, currentLineIdx - 1, MarkdownBlockType.paragraph));
    }

    return blocks;
  }

  List<MarkdownTocItem> extractToc(List<MarkdownBlock> blocks) {
    final toc = <MarkdownTocItem>[];
    
    // Track seen ids to handle duplicate headings
    final seenIds = <String, int>{};

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (block.type == MarkdownBlockType.heading) {
        final text = block.rawText.trim();
        int level = 0;
        while (level < text.length && text[level] == '#') {
          level++;
        }
        
        if (level > 0 && level <= 4) { // Only H1-H4
          final title = text.substring(level).trim();
          if (title.isNotEmpty) {
            String baseId = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
            if (baseId.isEmpty) baseId = 'heading';
            
            seenIds[baseId] = (seenIds[baseId] ?? -1) + 1;
            final uniqueId = seenIds[baseId]! > 0 ? '$baseId-${seenIds[baseId]}' : baseId;

            toc.add(MarkdownTocItem(
              id: uniqueId,
              text: title,
              level: level,
              blockId: block.id,
            ));
          }
        }
      }
    }
    return toc;
  }

  MarkdownBlock _createBlock(List<String> lines, int start, int end, MarkdownBlockType type) {
    final sublist = lines.sublist(start, end + 1);
    return MarkdownBlock(
      id: DateTime.now().microsecondsSinceEpoch.toString() + '_$start',
      startLine: start,
      endLine: end,
      rawText: sublist.join('\n'),
      type: type,
    );
  }
}
