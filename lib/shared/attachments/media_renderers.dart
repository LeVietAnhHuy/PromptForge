import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../app/theme/app_design.dart';

/// Shared in-viewer error panel used when a media backend fails to load a file.
class MediaErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onOpenExternally;
  const MediaErrorPanel(
      {super.key, required this.message, required this.onOpenExternally});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: AppDesign.spacingMd),
            Text('Could not play this file', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppDesign.spacingXs),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppDesign.spacingLg),
            FilledButton.icon(
              onPressed: onOpenExternally,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open externally'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline PDF viewer (pdfrx / pdfium): continuous page scrolling, a page
/// indicator + jump-to-page, and zoom controls.
class PdfRenderer extends StatefulWidget {
  final String path;
  final VoidCallback onOpenExternally;
  const PdfRenderer(
      {super.key, required this.path, required this.onOpenExternally});

  @override
  State<PdfRenderer> createState() => _PdfRendererState();
}

class _PdfRendererState extends State<PdfRenderer> {
  final PdfViewerController _controller = PdfViewerController();
  final TextEditingController _pageField = TextEditingController();
  bool _ready = false;

  @override
  void dispose() {
    _pageField.dispose();
    super.dispose();
  }

  void _jump(String value) {
    final n = int.tryParse(value.trim());
    if (n == null || !_ready) return;
    final clamped = n.clamp(1, _controller.pageCount);
    _controller.goToPage(pageNumber: clamped);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _controlsBar(theme),
        const Divider(height: 1),
        Expanded(
          child: ColoredBox(
            color: Colors.black,
            child: PdfViewer.file(
              widget.path,
              controller: _controller,
              params: PdfViewerParams(
                onViewerReady: (_, __) {
                  if (mounted) setState(() => _ready = true);
                },
                errorBannerBuilder: (context, error, stackTrace, documentRef) =>
                    MediaErrorPanel(
                        message: '$error',
                        onOpenExternally: widget.onOpenExternally),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlsBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spacingSm, vertical: AppDesign.spacingXs),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: _ready && (_controller.pageNumber ?? 1) > 1
                ? () => _controller.goToPage(
                    pageNumber: (_controller.pageNumber ?? 1) - 1)
                : null,
          ),
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed:
                _ready && (_controller.pageNumber ?? 1) < _controller.pageCount
                    ? () => _controller.goToPage(
                        pageNumber: (_controller.pageNumber ?? 1) + 1)
                    : null,
          ),
          const SizedBox(width: AppDesign.spacingSm),
          if (_ready)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final page = _controller.pageNumber ?? 1;
                return Text('Page $page / ${_controller.pageCount}',
                    style: theme.textTheme.labelMedium);
              },
            )
          else
            Text('Loading…', style: theme.textTheme.labelMedium),
          const Spacer(),
          SizedBox(
            width: 56,
            child: TextField(
              controller: _pageField,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Go',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              ),
              onSubmitted: _jump,
            ),
          ),
          const SizedBox(width: AppDesign.spacingSm),
          IconButton(
            tooltip: 'Zoom out',
            icon: const Icon(Icons.zoom_out),
            onPressed: _ready ? () => _controller.zoomDown() : null,
          ),
          IconButton(
            tooltip: 'Zoom in',
            icon: const Icon(Icons.zoom_in),
            onPressed: _ready ? () => _controller.zoomUp() : null,
          ),
        ],
      ),
    );
  }
}

/// Inline video player (media_kit / libmpv) with the package's default controls
/// (play/pause, seek, volume, fullscreen).
class VideoRenderer extends StatefulWidget {
  final String path;
  final VoidCallback onOpenExternally;
  const VideoRenderer(
      {super.key, required this.path, required this.onOpenExternally});

  @override
  State<VideoRenderer> createState() => _VideoRendererState();
}

class _VideoRendererState extends State<VideoRenderer> {
  late final Player _player;
  late final VideoController _controller;
  StreamSubscription<String>? _errorSub;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _errorSub = _player.stream.error.listen((e) {
      if (mounted) setState(() => _error = e);
    });
    _player.open(Media(widget.path));
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MediaErrorPanel(
          message: _error!, onOpenExternally: widget.onOpenExternally);
    }
    return ColoredBox(
      color: Colors.black,
      child: Video(controller: _controller),
    );
  }
}

/// Inline audio player (media_kit / libmpv): a compact transport with seek and
/// volume.
class AudioRenderer extends StatefulWidget {
  final String path;
  final String fileName;
  final VoidCallback onOpenExternally;
  const AudioRenderer(
      {super.key,
      required this.path,
      required this.fileName,
      required this.onOpenExternally});

  @override
  State<AudioRenderer> createState() => _AudioRendererState();
}

class _AudioRendererState extends State<AudioRenderer> {
  late final Player _player;
  final _subs = <StreamSubscription>[];
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  double _volume = 100;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _subs.addAll([
      _player.stream.position.listen((p) {
        if (mounted) setState(() => _position = p);
      }),
      _player.stream.duration.listen((d) {
        if (mounted) setState(() => _duration = d);
      }),
      _player.stream.playing.listen((p) {
        if (mounted) setState(() => _playing = p);
      }),
      _player.stream.volume.listen((v) {
        if (mounted) setState(() => _volume = v);
      }),
      _player.stream.error.listen((e) {
        if (mounted) setState(() => _error = e);
      }),
    ]);
    _player.open(Media(widget.path));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MediaErrorPanel(
          message: _error!, onOpenExternally: widget.onOpenExternally);
    }
    final theme = Theme.of(context);
    final max = _duration.inMilliseconds.toDouble();
    final value = _position.inMilliseconds
        .clamp(0, max <= 0 ? 0 : max.toInt())
        .toDouble();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.audiotrack,
                  size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: AppDesign.spacingMd),
              Text(widget.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: AppDesign.spacingMd),
              Row(
                children: [
                  IconButton.filled(
                    iconSize: 32,
                    icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                    onPressed: () => _player.playOrPause(),
                  ),
                  const SizedBox(width: AppDesign.spacingSm),
                  Expanded(
                    child: Slider(
                      value: max <= 0 ? 0 : value,
                      max: max <= 0 ? 1 : max,
                      onChanged: max <= 0
                          ? null
                          : (v) =>
                              _player.seek(Duration(milliseconds: v.round())),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(_position), style: theme.textTheme.labelSmall),
                  Text(_fmt(_duration), style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: AppDesign.spacingMd),
              Row(
                children: [
                  Icon(Icons.volume_up,
                      size: 18, color: theme.colorScheme.onSurfaceVariant),
                  Expanded(
                    child: Slider(
                      value: _volume.clamp(0, 100),
                      max: 100,
                      onChanged: (v) => _player.setVolume(v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
