import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:promptforge/app/theme/theme.dart';
import 'package:promptforge/shared/attachments/attachment_viewer.dart';

ViewerSource _att({
  required String id,
  required String fileName,
  required String mime,
  required String path,
  int? size,
}) {
  return ViewerSource(
    fileName: fileName,
    mimeType: mime,
    sizeBytes: size,
    localPath: path,
  );
}

void main() {
  group('detectAttachmentKind', () {
    test('prefers MIME, falls back to extension', () {
      expect(detectAttachmentKind('a.png', 'image/png'), AttachmentKind.image);
      expect(detectAttachmentKind('logo.svg', 'image/svg+xml'),
          AttachmentKind.svg);
      expect(
          detectAttachmentKind('clip.mp4', 'video/mp4'), AttachmentKind.video);
      expect(
          detectAttachmentKind('song.mp3', 'audio/mpeg'), AttachmentKind.audio);
      expect(detectAttachmentKind('doc.pdf', 'application/pdf'),
          AttachmentKind.pdf);
      expect(detectAttachmentKind('data.csv', 'text/csv'), AttachmentKind.csv);
      expect(detectAttachmentKind('o.json', 'application/json'),
          AttachmentKind.json);
      expect(detectAttachmentKind('m.md', 'text/markdown'),
          AttachmentKind.markdown);
      expect(detectAttachmentKind('main.dart', 'application/octet-stream'),
          AttachmentKind.code);
      expect(
          detectAttachmentKind('page.html', 'text/html'), AttachmentKind.html);
      expect(
          detectAttachmentKind('b.zip', 'application/zip'), AttachmentKind.zip);
      expect(detectAttachmentKind('mystery.bin', 'application/octet-stream'),
          AttachmentKind.unknown);
      // Extension fallback when MIME is generic.
      expect(detectAttachmentKind('photo.jpg', 'application/octet-stream'),
          AttachmentKind.image);
    });
  });

  group('parseDelimited', () {
    test('parses simple CSV', () {
      final rows = parseDelimited('a,b,c\n1,2,3\n', ',', 100);
      expect(rows, [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ]);
    });

    test('handles quoted fields with embedded commas and newlines', () {
      final rows =
          parseDelimited('name,note\n"Doe, Jane","line1\nline2"\n', ',', 100);
      expect(rows[1], ['Doe, Jane', 'line1\nline2']);
    });

    test('handles escaped double quotes', () {
      final rows = parseDelimited('q\n"she said ""hi"""\n', ',', 100);
      expect(rows[1], ['she said "hi"']);
    });

    test('parses TSV with a tab delimiter', () {
      final rows = parseDelimited('a\tb\n1\t2\n', '\t', 100);
      expect(rows, [
        ['a', 'b'],
        ['1', '2'],
      ]);
    });

    test('stops at the row cap', () {
      final text = List.generate(50, (i) => 'r$i').join('\n');
      final rows = parseDelimited('$text\n', ',', 10);
      expect(rows.length, 10);
    });
  });

  testWidgets('viewer shows header, nav, footer, and an external-open action',
      (tester) async {
    // Missing files exercise the synchronous fallback path (no async I/O,
    // which testWidgets' fake-async zone cannot drive).
    final attachments = [
      _att(
          id: 'a1',
          fileName: 'first.bin',
          mime: 'application/octet-stream',
          path: '/nonexistent/first.bin',
          size: 2048),
      _att(
          id: 'a2',
          fileName: 'second.pdf',
          mime: 'application/pdf',
          path: '/nonexistent/second.pdf'),
    ];

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () =>
                  AttachmentViewer.open(context, sources: attachments),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Header + multi-attachment footer. (The filename shows in both the header
    // and the fallback panel, so it matches more than once.)
    expect(find.text('first.bin'), findsWidgets);
    expect(find.text('1 of 2'), findsOneWidget);
    // open_in_new is in both the header action and the fallback's button.
    expect(find.byIcon(Icons.open_in_new), findsWidgets);
    // Missing file degrades to a fallback with an external-open action.
    expect(find.textContaining('no longer available'), findsOneWidget);
    expect(
        find.widgetWithText(FilledButton, 'Open externally'), findsOneWidget);

    // Navigate to the next attachment.
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('second.pdf'), findsWidgets);
    expect(find.text('2 of 2'), findsOneWidget);

    // Close.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('second.pdf'), findsNothing);
  });

  testWidgets('pending (pre-save) sources open in the viewer', (tester) async {
    // Part D: a just-picked file (pending, source path) previews before save.
    // Open on the PDF entry which routes to the synchronous fallback panel.
    final sources = [
      const ViewerSource(
          fileName: 'photo.png',
          mimeType: 'image/png',
          localPath: '/pending/photo.png',
          pending: true),
      const ViewerSource(
          fileName: 'report.pdf',
          mimeType: 'application/pdf',
          localPath: '/pending/report.pdf',
          pending: true),
      const ViewerSource(
          fileName: 'data.csv',
          mimeType: 'text/csv',
          localPath: '/pending/data.csv',
          pending: true),
    ];

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => AttachmentViewer.open(context,
                  sources: sources, initialIndex: 1),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('report.pdf'), findsWidgets);
    expect(find.text('2 of 3'), findsOneWidget);
    expect(
        find.widgetWithText(FilledButton, 'Open externally'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });
}
