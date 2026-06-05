import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:promptforge/app/theme/theme.dart';
import 'package:promptforge/shared/attachments/attachment_viewer.dart';
import 'package:promptforge/shared/attachments/media_capability.dart';
import 'package:promptforge/shared/attachments/media_renderers.dart';

void main() {
  group('detectAttachmentKind routing', () {
    test('video/* → video, audio/* → audio, pdf → pdf', () {
      expect(detectAttachmentKind('clip.mp4', 'video/mp4'),
          AttachmentKind.video);
      expect(detectAttachmentKind('voice.m4a', 'audio/mp4'),
          AttachmentKind.audio);
      expect(detectAttachmentKind('doc.pdf', 'application/pdf'),
          AttachmentKind.pdf);
    });

    test('falls back to extension when mime is generic', () {
      expect(
          detectAttachmentKind('movie.mov', 'application/octet-stream'),
          // .mov isn't in the audio set; generic mime + unknown ext → unknown,
          // but a .pdf extension is recognized without a pdf mime.
          isNot(AttachmentKind.audio));
      expect(detectAttachmentKind('report.pdf', 'application/octet-stream'),
          AttachmentKind.pdf);
    });
  });

  group('media backend unavailable → graceful fallback (no crash)', () {
    setUp(() => mediaBackendReady = false);
    // Don't leave the global flag flipped for other suites.
    tearDown(() => mediaBackendReady = false);

    testWidgets('VideoRenderer shows the error panel + open-externally',
        (tester) async {
      var opened = false;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: VideoRenderer(
            path: '/nonexistent/clip.mp4',
            onOpenExternally: () => opened = true,
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Could not play this file'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Open externally'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Open externally'));
      expect(opened, isTrue);
    });

    testWidgets('AudioRenderer shows the error panel instead of a player',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: AudioRenderer(
            path: '/nonexistent/voice.m4a',
            fileName: 'voice.m4a',
            onOpenExternally: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Could not play this file'), findsOneWidget);
      // No transport (play button) was built because the backend is down.
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });
  });
}
