import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promptforge/features/inbox/presentation/inbox_editor_screen.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

void main() {
  testWidgets('InboxEditorScreen shows Edit/Preview toggle and inline markdown preview', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: InboxEditorScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify segments are present
    expect(find.text('Edit Full Text'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    
    // Enter markdown text
    await tester.enterText(
      find.byType(TextField).at(1), // First is title, second is content
      '# Heading\nHello markdown.',
    );
    await tester.pump();

    // Switch to Preview
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    // Verify MarkdownBody widgets are shown (each block is rendered as MarkdownBody)
    expect(find.byType(MarkdownBody), findsWidgets);
    expect(find.text('Heading'), findsWidgets); // Markdown renders without `#`
    expect(find.text('Hello markdown.'), findsOneWidget);

    // Switch back to Edit
    await tester.tap(find.text('Edit Full Text'));
    await tester.pumpAndSettle();

    // Verify full TextField is back
    expect(find.byType(TextField).at(1), findsOneWidget);
  });

  testWidgets('InboxEditorScreen shows TOC on desktop when multiple headings exist', (tester) async {
    // Set desktop window size for this test
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: InboxEditorScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Enter markdown text with 3 headings
    await tester.enterText(
      find.byType(TextField).at(1),
      '# H1 Title\n\nSome text\n\n## H2 Sub\n\nMore text\n\n### H3 Detail',
    );
    await tester.pump();

    // Switch to Preview
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    // Verify TOC sidebar renders (only on desktop)
    expect(find.text('Contents'), findsOneWidget);
    
    // Verify TOC items render
    expect(find.text('H1 Title'), findsWidgets); // Exists in body and TOC
    expect(find.text('H2 Sub'), findsWidgets);
    expect(find.text('H3 Detail'), findsWidgets);

    // Tap a TOC item
    await tester.tap(find.text('H3 Detail').last); // The last one is typically in the TOC
    await tester.pumpAndSettle();
    
    // Verify we did not enter inline edit mode
    expect(find.byTooltip('Save Block'), findsNothing);

    // Reset view
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
