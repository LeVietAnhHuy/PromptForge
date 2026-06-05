import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_design.dart';
import '../application/llm_model_catalog.dart';
import '../application/recent_models_service.dart';

/// A combobox-style model picker. The closed field shows the current selection;
/// opening it reveals a single dropdown with a "Recent" group, chat/text model
/// families (newest first, expanded by default, each with a collapsed
/// "Legacy (N)" sub-row), then specialized capabilities (Image/Audio/Video/
/// Embedding/Other) as collapsed groups, plus a capability filter-chip row.
///
/// Group headers scroll naturally and are expand/collapse buttons (mouse +
/// keyboard). Typing filters live (buffer shown as an inline chip; matches in a
/// collapsed group auto-expand it). Arrows move focus across headers/models,
/// Enter selects/toggles, Left/Right collapse/expand a focused header, Escape
/// clears the buffer then closes.
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

// --- internal view model ---

class _Group {
  final String id; // 'recent' | 'fam:<family>' | 'cap:<capability>'
  final String title;
  final IconData? icon;
  final List<LlmModelOption> current; // non-legacy (chat) / all (capability)
  final List<LlmModelOption> legacy; // split-out legacy (chat families only)
  final bool supportsLegacySplit;
  final bool collapsedByDefault;

  const _Group({
    required this.id,
    required this.title,
    this.icon,
    required this.current,
    this.legacy = const [],
    this.supportsLegacySplit = false,
    this.collapsedByDefault = false,
  });
}

enum _RowKind { header, model, legacyToggle, custom }

class _Row {
  final _RowKind kind;
  final _Group? group;
  final LlmModelOption? model;
  final bool legacy;
  const _Row(this.kind, {this.group, this.model, this.legacy = false});

  String get focusKey => switch (kind) {
        _RowKind.header => 'h:${group!.id}',
        _RowKind.legacyToggle => 'lt:${group!.id}',
        _RowKind.model => 'm:${model!.id}:${legacy ? 'l' : 'c'}',
        _RowKind.custom => 'custom',
      };
}

class _ModelPickerFieldState extends ConsumerState<ModelPickerField> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _overlay = OverlayPortalController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'ModelPicker');
  final ScrollController _scrollController = ScrollController();

  String _buffer = '';
  int _focusIndex = 0;
  double _fieldWidth = 320;
  List<String> _recent = const [];
  ModelCapability? _capabilityFilter; // null = All
  final Set<String> _collapsed = {}; // group ids currently collapsed
  final Set<String> _legacyExpanded = {}; // family group ids w/ legacy shown
  final Map<String, GlobalKey> _rowKeys = {};

  List<_Row> _rows = const [];

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

  GlobalKey _keyFor(String focusKey) =>
      _rowKeys.putIfAbsent(focusKey, () => GlobalKey());

  bool get _filtering => _buffer.trim().isNotEmpty;

  Future<void> _open() async {
    final providerId = widget.providerId;
    final recent = providerId != null
        ? await ref.read(recentModelsServiceProvider).getRecent(providerId)
        : const <String>[];
    if (!mounted) return;
    setState(() {
      _buffer = '';
      _capabilityFilter = null;
      _recent = recent;
      _legacyExpanded.clear();
      // Collapse capability groups by default; chat families stay open.
      _collapsed
        ..clear()
        ..addAll(
            _buildGroups().where((g) => g.collapsedByDefault).map((g) => g.id));
      _rows = _buildRows();
      _focusIndex = _initialFocusIndex();
    });
    _overlay.show();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _scrollFocusedIntoView();
    });
  }

  int _initialFocusIndex() {
    final sel = widget.selectedModelId;
    if (sel != null) {
      final idx = _rows
          .indexWhere((r) => r.kind == _RowKind.model && r.model!.id == sel);
      if (idx >= 0) return idx;
    }
    return _rows.indexWhere(
        (r) => r.kind == _RowKind.model || r.kind == _RowKind.custom);
  }

  void _close() => _overlay.hide();

  void _select(String modelId) {
    final providerId = widget.providerId;
    if (providerId != null) {
      ref.read(recentModelsServiceProvider).record(providerId, modelId);
    }
    widget.onSelected(modelId);
    _close();
  }

  void _rebuild({int? focus}) {
    setState(() {
      _rows = _buildRows();
      if (focus != null) {
        _focusIndex = focus.clamp(0, _rows.isEmpty ? 0 : _rows.length - 1);
      } else if (_focusIndex >= _rows.length) {
        _focusIndex = _rows.isEmpty ? 0 : _rows.length - 1;
      }
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollFocusedIntoView());
  }

  void _move(int delta) {
    if (_rows.isEmpty) return;
    setState(() {
      _focusIndex = (_focusIndex + delta).clamp(0, _rows.length - 1);
    });
    _scrollFocusedIntoView();
  }

  void _scrollFocusedIntoView() {
    if (_focusIndex < 0 || _focusIndex >= _rows.length) return;
    final ctx = _rowKeys[_rows[_focusIndex].focusKey]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          alignment: 0.5,
          duration: AppDesign.motion(context, AppDesign.durationFast));
    }
  }

  void _toggleGroup(_Group g) {
    setState(() {
      if (_collapsed.contains(g.id)) {
        _collapsed.remove(g.id);
      } else {
        _collapsed.add(g.id);
      }
    });
    _rebuild();
  }

  void _setGroupCollapsed(_Group g, bool collapsed) {
    if (_filtering) return; // collapse state ignored while filtering
    if (collapsed == _collapsed.contains(g.id)) return;
    setState(() {
      if (collapsed) {
        _collapsed.add(g.id);
      } else {
        _collapsed.remove(g.id);
      }
    });
    _rebuild();
  }

  void _toggleLegacy(_Group g) {
    setState(() {
      if (_legacyExpanded.contains(g.id)) {
        _legacyExpanded.remove(g.id);
      } else {
        _legacyExpanded.add(g.id);
      }
    });
    _rebuild();
  }

  void _activateFocused() {
    if (_focusIndex < 0 || _focusIndex >= _rows.length) return;
    final row = _rows[_focusIndex];
    switch (row.kind) {
      case _RowKind.header:
        _toggleGroup(row.group!);
      case _RowKind.legacyToggle:
        _toggleLegacy(row.group!);
      case _RowKind.model:
        _select(row.model!.id);
      case _RowKind.custom:
        _select('custom');
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      if (_buffer.isNotEmpty) {
        setState(() => _buffer = '');
        _rebuild(focus: 0);
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
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowLeft) {
      final expand = key == LogicalKeyboardKey.arrowRight;
      if (_focusIndex >= 0 && _focusIndex < _rows.length) {
        final row = _rows[_focusIndex];
        if (row.kind == _RowKind.header) {
          _setGroupCollapsed(row.group!, !expand);
        } else if (row.kind == _RowKind.legacyToggle) {
          final on = _legacyExpanded.contains(row.group!.id);
          if (expand != on) _toggleLegacy(row.group!);
        }
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _activateFocused();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      if (_buffer.isNotEmpty) {
        setState(() => _buffer = _buffer.substring(0, _buffer.length - 1));
        _rebuild(focus: 0);
      }
      return KeyEventResult.handled;
    }
    final ch = event.character;
    if (ch != null &&
        ch.length == 1 &&
        ch.codeUnitAt(0) >= 0x20 &&
        ch.codeUnitAt(0) != 0x7f) {
      setState(() => _buffer += ch);
      _rebuild(focus: 0);
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

  // --- grouping ---

  List<_Group> _buildGroups() {
    final catalog = widget.models.where((m) => m.id != 'custom').toList();
    final groups = <_Group>[];

    // Recent (only at "All", no text filter).
    if (!_filtering && _capabilityFilter == null && _recent.isNotEmpty) {
      final recentModels = <LlmModelOption>[];
      for (final id in _recent) {
        final m = _optionById(id);
        if (m != null && m.id != 'custom') recentModels.add(m);
      }
      if (recentModels.isNotEmpty) {
        groups.add(_Group(
          id: 'recent',
          title: 'Recent',
          icon: Icons.history,
          current: recentModels,
        ));
      }
    }

    // Chat families, newest first.
    if (_capabilityFilter == null ||
        _capabilityFilter == ModelCapability.chat) {
      final chat =
          catalog.where((m) => capabilityOf(m) == ModelCapability.chat);
      final families = <String, List<LlmModelOption>>{};
      for (final m in chat) {
        families.putIfAbsent(m.family, () => []).add(m);
      }
      final ordered = families.keys.toList()
        ..sort((a, b) {
          int maxOrder(String f) => families[f]!
              .map((m) => m.approximateReleaseOrder)
              .fold<int>(0, (p, e) => e > p ? e : p);
          return maxOrder(b).compareTo(maxOrder(a));
        });
      for (final fam in ordered) {
        final all = families[fam]!
          ..sort((a, b) =>
              b.approximateReleaseOrder.compareTo(a.approximateReleaseOrder));
        groups.add(_Group(
          id: 'fam:$fam',
          title: fam,
          current: all.where((m) => !m.isLegacy).toList(),
          legacy: all.where((m) => m.isLegacy).toList(),
          supportsLegacySplit: true,
        ));
      }
    }

    // Capability buckets, collapsed by default, at the bottom.
    const capOrder = [
      ModelCapability.image,
      ModelCapability.audio,
      ModelCapability.video,
      ModelCapability.embedding,
      ModelCapability.other,
    ];
    const capIcons = {
      ModelCapability.image: Icons.image_outlined,
      ModelCapability.audio: Icons.audiotrack_outlined,
      ModelCapability.video: Icons.movie_outlined,
      ModelCapability.embedding: Icons.scatter_plot_outlined,
      ModelCapability.other: Icons.category_outlined,
    };
    for (final cap in capOrder) {
      if (_capabilityFilter != null && _capabilityFilter != cap) continue;
      final models = catalog.where((m) => capabilityOf(m) == cap).toList()
        ..sort((a, b) =>
            b.approximateReleaseOrder.compareTo(a.approximateReleaseOrder));
      if (models.isEmpty) continue;
      groups.add(_Group(
        id: 'cap:${cap.name}',
        title: cap.label,
        icon: capIcons[cap],
        current: models,
        collapsedByDefault: true,
      ));
    }

    return groups;
  }

  bool _expanded(_Group g) =>
      _filtering || _capabilityFilter != null || !_collapsed.contains(g.id);

  List<_Row> _buildRows() {
    final rows = <_Row>[];
    for (final g in _buildGroups()) {
      final current = g.current.where(_matches).toList();
      final legacyMatches = g.legacy.where(_matches).toList();
      // While filtering, drop groups with no matches entirely.
      if (_filtering && current.isEmpty && legacyMatches.isEmpty) continue;

      rows.add(_Row(_RowKind.header, group: g));
      if (!_expanded(g)) continue;

      for (final m in current) {
        rows.add(_Row(_RowKind.model, group: g, model: m));
      }
      if (g.supportsLegacySplit && g.legacy.isNotEmpty) {
        if (_filtering) {
          for (final m in legacyMatches) {
            rows.add(_Row(_RowKind.model, group: g, model: m, legacy: true));
          }
        } else {
          rows.add(_Row(_RowKind.legacyToggle, group: g));
          if (_legacyExpanded.contains(g.id)) {
            for (final m in g.legacy) {
              rows.add(_Row(_RowKind.model, group: g, model: m, legacy: true));
            }
          }
        }
      }
    }

    if (widget.models.any((m) => m.id == 'custom')) {
      rows.add(const _Row(_RowKind.custom));
    }
    return rows;
  }

  // --- build ---

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
        Flexible(child: Text(m.displayName, overflow: TextOverflow.ellipsis)),
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
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return Stack(
      children: [
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
                  width: _fieldWidth < 300 ? 300 : _fieldWidth,
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: BoxDecoration(
                    borderRadius: AppDesign.borderMd,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildChips(theme),
                      _buildBufferBar(theme),
                      Flexible(
                        child: _rows.isEmpty
                            ? _emptyState(theme)
                            : Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.zero,
                                  itemCount: _rows.length,
                                  itemBuilder: (context, i) =>
                                      _buildRow(theme, _rows[i], i),
                                ),
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

  Widget _buildChips(ThemeData theme) {
    final present = <ModelCapability>{
      for (final m in widget.models.where((m) => m.id != 'custom'))
        capabilityOf(m)
    };
    final caps = [
      ModelCapability.chat,
      ModelCapability.image,
      ModelCapability.audio,
      ModelCapability.video,
      ModelCapability.embedding,
      ModelCapability.other,
    ].where(present.contains).toList();

    Widget chip(String label, ModelCapability? cap) {
      final selected = _capabilityFilter == cap;
      return Padding(
        padding: const EdgeInsets.only(right: AppDesign.spacingSm),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) {
            setState(() => _capabilityFilter = cap);
            _rebuild(focus: 0);
          },
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.spacingSm, vertical: AppDesign.spacingSm),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            chip('All', null),
            for (final c in caps) chip(c.label, c),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppDesign.spacingLg),
      child: Text(
          _filtering ? 'No models match “$_buffer”.' : 'No models available.',
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
              child: Text(
                  'Type to filter · ↑↓ move · ←→ collapse · Enter select',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildRow(ThemeData theme, _Row row, int index) {
    final focused = index == _focusIndex;
    final key = _keyFor(row.focusKey);
    switch (row.kind) {
      case _RowKind.header:
        return _headerRow(theme, row.group!, focused, key);
      case _RowKind.legacyToggle:
        return _legacyToggleRow(theme, row.group!, focused, key);
      case _RowKind.model:
        return _modelRow(theme, row.model!, focused, row.legacy, key);
      case _RowKind.custom:
        return _customRow(theme, focused, key);
    }
  }

  Widget _headerRow(ThemeData theme, _Group g, bool focused, Key key) {
    final expanded = _expanded(g);
    final count = g.current.length + g.legacy.length;
    final lockedOpen = _filtering || _capabilityFilter != null;
    return Container(
      key: key,
      color: focused
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: InkWell(
        onTap: lockedOpen ? null : () => _toggleGroup(g),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDesign.spacingSm, vertical: AppDesign.spacingSm),
          child: Row(
            children: [
              Icon(
                lockedOpen
                    ? Icons.remove
                    : (expanded ? Icons.expand_more : Icons.chevron_right),
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppDesign.spacingXs),
              if (g.icon != null) ...[
                Icon(g.icon, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: AppDesign.spacingSm),
              ],
              Expanded(
                child: Text(g.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700)),
              ),
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

  Widget _legacyToggleRow(ThemeData theme, _Group g, bool focused, Key key) {
    final expanded = _legacyExpanded.contains(g.id);
    return Container(
      key: key,
      color: focused
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: () => _toggleLegacy(g),
        child: Padding(
          padding: const EdgeInsets.only(
              left: AppDesign.spacingLg,
              right: AppDesign.spacingMd,
              top: AppDesign.spacingSm,
              bottom: AppDesign.spacingSm),
          child: Row(
            children: [
              Icon(expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppDesign.spacingSm),
              Text('Legacy (${g.legacy.length})',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modelRow(
      ThemeData theme, LlmModelOption m, bool focused, bool legacy, Key key) {
    final isSelected = m.id == widget.selectedModelId;
    return Container(
      key: key,
      color: focused
          ? theme.colorScheme.primary.withValues(alpha: 0.14)
          : Colors.transparent,
      child: InkWell(
        onTap: () => _select(m.id),
        onHover: (h) {
          if (h) {
            final idx = _rows.indexWhere((r) =>
                r.kind == _RowKind.model &&
                r.model?.id == m.id &&
                r.legacy == legacy);
            if (idx >= 0 && idx != _focusIndex) {
              setState(() => _focusIndex = idx);
            }
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
              left: legacy ? AppDesign.spacingXl : AppDesign.spacingLg,
              right: AppDesign.spacingMd,
              top: AppDesign.spacingSm,
              bottom: AppDesign.spacingSm),
          child: Row(
            children: [
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

  Widget _customRow(ThemeData theme, bool focused, Key key) {
    final isSelected = widget.selectedModelId == 'custom';
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: focused
            ? theme.colorScheme.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        border:
            Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: InkWell(
        onTap: () => _select('custom'),
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
