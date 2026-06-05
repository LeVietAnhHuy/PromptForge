import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_design.dart';
import '../application/llm_model_catalog.dart';
import '../application/recent_models_service.dart';

/// A combobox-style model picker. The closed field shows the current selection;
/// opening it reveals a single dropdown grouped by family (sticky headers,
/// newest family/version first), with legacy models tucked into a collapsed
/// "Legacy (N)" expander per group and a pinned "Recent" group on top.
///
/// While open it behaves as a combobox: typing filters the list live (the
/// buffer shows as an inline chip — there is no visible text field), arrows
/// move the highlight, Enter selects, and Escape clears the buffer then closes.
class ModelPickerField extends ConsumerStatefulWidget {
  final String? providerId;
  final List<LlmModelOption> models;
  final String? selectedModelId;
  final ValueChanged<String> onSelected;
  final String label;

  const ModelPickerField({
    super.key,
    required this.providerId,
    required this.models,
    required this.selectedModelId,
    required this.onSelected,
    this.label = 'Model',
  });

  @override
  ConsumerState<ModelPickerField> createState() => _ModelPickerFieldState();
}

class _ModelPickerFieldState extends ConsumerState<ModelPickerField> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _overlay = OverlayPortalController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'ModelPicker');
  final ScrollController _scrollController = ScrollController();

  String _buffer = '';
  int _highlight = 0;
  double _fieldWidth = 320;
  List<String> _recent = const [];
  final Set<String> _expandedLegacy = {};
  final Map<String, GlobalKey> _rowKeys = {};

  // Flat list of selectable model ids in display order (for arrow nav).
  List<String> _selectableIds = const [];

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  LlmModelOption? _optionById(String id) {
    for (final m in widget.models) {
      if (m.id == id) return m;
    }
    return null;
  }

  GlobalKey _keyFor(String rowId) =>
      _rowKeys.putIfAbsent(rowId, () => GlobalKey());

  Future<void> _open() async {
    final providerId = widget.providerId;
    final recent = providerId != null
        ? await ref.read(recentModelsServiceProvider).getRecent(providerId)
        : const <String>[];
    if (!mounted) return;
    setState(() {
      _buffer = '';
      _recent = recent;
      _expandedLegacy.clear();
      _highlight = _initialHighlight();
    });
    _overlay.show();
    // Focus the overlay so keystrokes are captured immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _scrollHighlightIntoView();
    });
  }

  int _initialHighlight() {
    final idx = _selectableIds.indexOf(widget.selectedModelId ?? '');
    return idx >= 0 ? idx : 0;
  }

  void _close() {
    _overlay.hide();
  }

  void _select(String modelId) {
    final providerId = widget.providerId;
    if (providerId != null) {
      ref.read(recentModelsServiceProvider).record(providerId, modelId);
    }
    widget.onSelected(modelId);
    _close();
  }

  void _move(int delta) {
    if (_selectableIds.isEmpty) return;
    setState(() {
      _highlight = (_highlight + delta).clamp(0, _selectableIds.length - 1);
    });
    _scrollHighlightIntoView();
  }

  void _scrollHighlightIntoView() {
    if (_highlight < 0 || _highlight >= _selectableIds.length) return;
    final id = _selectableIds[_highlight];
    final key = _rowKeys['model:$id'];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          alignment: 0.5,
          duration: AppDesign.motion(context, AppDesign.durationFast));
    }
  }

  void _onBufferChanged() {
    // Reset highlight to the first match whenever the filter changes.
    setState(() => _highlight = 0);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollHighlightIntoView());
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      if (_buffer.isNotEmpty) {
        setState(() => _buffer = '');
        _onBufferChanged();
      } else {
        _close();
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_selectableIds.isNotEmpty &&
          _highlight >= 0 &&
          _highlight < _selectableIds.length) {
        _select(_selectableIds[_highlight]);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      if (_buffer.isNotEmpty) {
        setState(() => _buffer = _buffer.substring(0, _buffer.length - 1));
        _onBufferChanged();
      }
      return KeyEventResult.handled;
    }
    final ch = event.character;
    if (ch != null &&
        ch.length == 1 &&
        ch.codeUnitAt(0) >= 0x20 &&
        ch.codeUnitAt(0) != 0x7f) {
      setState(() => _buffer += ch);
      _onBufferChanged();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  bool _matches(LlmModelOption m) {
    final q = _buffer.toLowerCase().trim();
    if (q.isEmpty) return true;
    return m.displayName.toLowerCase().contains(q) ||
        m.family.toLowerCase().contains(q) ||
        m.id.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = widget.selectedModelId != null
        ? _optionById(widget.selectedModelId!)
        : null;
    final isCustom = widget.selectedModelId == 'custom';

    return OverlayPortal(
      controller: _overlay,
      overlayChildBuilder: _buildOverlay,
      child: CompositedTransformTarget(
        link: _link,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth.isFinite) {
              _fieldWidth = constraints.maxWidth;
            }
            return InkWell(
              borderRadius: AppDesign.borderMd,
              onTap: _open,
              child: InputDecorator(
                isEmpty: false,
                decoration: InputDecoration(
                  labelText: widget.label,
                  border: const OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: isCustom
                          ? const Text('Custom model…')
                          : selected != null
                              ? _selectedLabel(theme, selected)
                              : Text('Select a model',
                                  style: TextStyle(
                                      color:
                                          theme.colorScheme.onSurfaceVariant)),
                    ),
                    Icon(Icons.arrow_drop_down,
                        color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _selectedLabel(ThemeData theme, LlmModelOption m) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(m.displayName, overflow: TextOverflow.ellipsis),
        ),
        if (m.isLegacy) _miniBadge(theme, 'LEGACY'),
        if (m.isPreview) _miniBadge(theme, 'PREVIEW'),
      ],
    );
  }

  Widget _miniBadge(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: AppDesign.spacingSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppDesign.borderSm,
        ),
        child: Text(text,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 9,
                letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final slivers = _buildSlivers(theme);

    return Stack(
      children: [
        // Outside-tap barrier.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Align(
            alignment: Alignment.topLeft,
            child: Focus(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: _onKey,
              child: Material(
                elevation: AppDesign.elevationLg,
                borderRadius: AppDesign.borderMd,
                color: theme.colorScheme.surfaceContainerHigh,
                surfaceTintColor: Colors.transparent,
                child: Container(
                  width: _fieldWidth < 280 ? 280 : _fieldWidth,
                  constraints: const BoxConstraints(maxHeight: 380),
                  decoration: BoxDecoration(
                    borderRadius: AppDesign.borderMd,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBufferBar(theme),
                      Flexible(
                        child: _selectableIds.isEmpty && _buffer.isNotEmpty
                            ? _emptyState(theme)
                            : CustomScrollView(
                                controller: _scrollController,
                                slivers: slivers,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppDesign.spacingLg),
      child: Text('No models match “$_buffer”.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }

  Widget _buildBufferBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingSm),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(Icons.search,
              size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppDesign.spacingSm),
          if (_buffer.isEmpty)
            Expanded(
              child: Text('Type to filter · ↑↓ to move · Enter to select',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            )
          else
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.16),
                    borderRadius: AppDesign.borderSm,
                  ),
                  child: Text(_buffer,
                      style: theme.textTheme.labelMedium?.copyWith(
                          fontFamily: AppDesign.fontMono,
                          color: theme.colorScheme.primary)),
                ),
              ),
            ),
          if (_buffer.isNotEmpty)
            Text('Esc clears',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  // Build the grouped slivers and, as a side effect, the flat selectable order.
  List<Widget> _buildSlivers(ThemeData theme) {
    final slivers = <Widget>[];
    final selectable = <String>[];

    final catalog = widget.models.where((m) => m.id != 'custom').toList();
    final hasCustom = widget.models.any((m) => m.id == 'custom');
    final filtering = _buffer.trim().isNotEmpty;

    // Recent group (only when not filtering).
    if (!filtering && _recent.isNotEmpty) {
      final recentModels = <LlmModelOption>[];
      for (final id in _recent) {
        final m = _optionById(id);
        if (m != null && m.id != 'custom') recentModels.add(m);
      }
      if (recentModels.isNotEmpty) {
        slivers.add(
            _header(theme, 'Recent', recentModels.length, icon: Icons.history));
        slivers.add(_modelSliver(theme, recentModels, selectable));
      }
    }

    // Families, newest first by max release order.
    final families = <String, List<LlmModelOption>>{};
    for (final m in catalog) {
      families.putIfAbsent(m.family, () => []).add(m);
    }
    final orderedFamilies = families.keys.toList()
      ..sort((a, b) {
        int maxOrder(String f) => families[f]!
            .map((m) => m.approximateReleaseOrder)
            .fold<int>(0, (p, e) => e > p ? e : p);
        return maxOrder(b).compareTo(maxOrder(a));
      });

    for (final family in orderedFamilies) {
      final all = families[family]!
        ..sort((a, b) =>
            b.approximateReleaseOrder.compareTo(a.approximateReleaseOrder));
      final current = all.where((m) => !m.isLegacy).where(_matches).toList();
      final legacyAll = all.where((m) => m.isLegacy).toList();
      final legacyMatches = legacyAll.where(_matches).toList();

      if (filtering && current.isEmpty && legacyMatches.isEmpty) continue;

      slivers
          .add(_header(theme, family, current.length + legacyMatches.length));
      if (current.isNotEmpty) {
        slivers.add(_modelSliver(theme, current, selectable));
      }

      if (legacyAll.isNotEmpty) {
        if (filtering) {
          // While filtering, legacy matches are shown inline (auto-expanded).
          if (legacyMatches.isNotEmpty) {
            slivers.add(
                _modelSliver(theme, legacyMatches, selectable, legacy: true));
          }
        } else {
          final expanded = _expandedLegacy.contains(family);
          slivers.add(SliverToBoxAdapter(
            child: _legacyToggle(theme, family, legacyAll.length, expanded),
          ));
          if (expanded) {
            slivers
                .add(_modelSliver(theme, legacyAll, selectable, legacy: true));
          }
        }
      }
    }

    // Custom option pinned at the very bottom.
    if (hasCustom) {
      slivers.add(SliverToBoxAdapter(
        child: _customRow(theme, selectable),
      ));
    }

    _selectableIds = selectable;
    if (_highlight >= _selectableIds.length) {
      _highlight = _selectableIds.isEmpty ? 0 : _selectableIds.length - 1;
    }
    return slivers;
  }

  Widget _header(ThemeData theme, String title, int count, {IconData? icon}) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(
        height: 30,
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(
              horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingXs),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
              ],
              Text(title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Text('$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modelSliver(
      ThemeData theme, List<LlmModelOption> models, List<String> selectable,
      {bool legacy = false}) {
    // Capture the start index so highlight maps to the right entries.
    final rows = <Widget>[];
    for (final m in models) {
      final indexInSelectable = selectable.length;
      selectable.add(m.id);
      rows.add(_modelRow(theme, m, indexInSelectable, legacy: legacy));
    }
    return SliverList(delegate: SliverChildListDelegate(rows));
  }

  Widget _modelRow(ThemeData theme, LlmModelOption m, int selectableIndex,
      {bool legacy = false}) {
    final highlighted = selectableIndex == _highlight;
    final isSelected = m.id == widget.selectedModelId;
    return Container(
      key: _keyFor('model:${m.id}'),
      color: highlighted
          ? theme.colorScheme.primary.withValues(alpha: 0.14)
          : Colors.transparent,
      child: InkWell(
        onTap: () => _select(m.id),
        onHover: (h) {
          if (h && _highlight != selectableIndex) {
            setState(() => _highlight = selectableIndex);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingSm),
          child: Row(
            children: [
              if (legacy)
                Padding(
                  padding: const EdgeInsets.only(right: AppDesign.spacingSm),
                  child: Icon(Icons.subdirectory_arrow_right,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                ),
              Expanded(
                child: Text(
                  m.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: legacy
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              if (m.isLegacy) _miniBadge(theme, 'LEGACY'),
              if (m.isPreview) _miniBadge(theme, 'PREVIEW'),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: AppDesign.spacingSm),
                  child: Icon(Icons.check,
                      size: 16, color: theme.colorScheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legacyToggle(
      ThemeData theme, String family, int count, bool expanded) {
    return InkWell(
      onTap: () {
        setState(() {
          if (expanded) {
            _expandedLegacy.remove(family);
          } else {
            _expandedLegacy.add(family);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingSm),
        child: Row(
          children: [
            Icon(expanded ? Icons.expand_less : Icons.expand_more,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppDesign.spacingSm),
            Text('Legacy ($count)',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _customRow(ThemeData theme, List<String> selectable) {
    final indexInSelectable = selectable.length;
    selectable.add('custom');
    final highlighted = indexInSelectable == _highlight;
    final isSelected = widget.selectedModelId == 'custom';
    return Container(
      key: _keyFor('model:custom'),
      decoration: BoxDecoration(
        color: highlighted
            ? theme.colorScheme.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        border:
            Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: InkWell(
        onTap: () => _select('custom'),
        onHover: (h) {
          if (h && _highlight != indexInSelectable) {
            setState(() => _highlight = indexInSelectable);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDesign.spacingMd, vertical: AppDesign.spacingSm),
          child: Row(
            children: [
              Icon(Icons.edit_note,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppDesign.spacingSm),
              Text('Custom model…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : null)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _HeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
