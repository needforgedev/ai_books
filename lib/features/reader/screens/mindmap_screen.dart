import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/core/widgets/radial_glow.dart';
import 'package:ai_books/domain/models/mindmap_node.dart';
import 'package:ai_books/domain/services/mindmap_parser.dart';
import 'package:ai_books/features/reader/widgets/mindmap_outline_view.dart';
import 'package:ai_books/features/reader/widgets/mindmap_view.dart';

/// Full-screen mind map viewer.
///
/// Layout is responsive:
/// - **Phones** (width < 600): vertical outline view (Notion-style).
/// - **Tablets / larger** (width >= 600): horizontal tree with pinch-zoom.
/// Users can toggle between the two modes via the icon in the top bar.
class MindMapScreen extends StatefulWidget {
  const MindMapScreen({
    super.key,
    required this.assetPath,
    required this.bookTitle,
    this.accent = AppColors.primary,
  });

  final String assetPath;
  final String bookTitle;
  final Color accent;

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

enum _ViewMode { outline, tree }

class _MindMapScreenState extends State<MindMapScreen> {
  MindMapNode? _root;
  String? _error;
  _ViewMode? _mode; // null until first layout picks a default

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString(widget.assetPath);
      final markdown = widget.assetPath.toLowerCase().endsWith('.html')
          ? MindMapParser.extractMarkdownFromHtml(raw)
          : raw;
      final root = MindMapParser.parse(markdown);
      if (!mounted) return;
      setState(() => _root = root);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not load mind map');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          // Pick initial mode based on screen width if user hasn't chosen.
          final mode = _mode ?? (isWide ? _ViewMode.tree : _ViewMode.outline);

          return Stack(
            children: [
              // Ambient glow
              Positioned(
                top: -80,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: RadialGlow(
                      color: widget.accent,
                      size: 360,
                      opacity: 0.15,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _TopBar(
                      bookTitle: widget.bookTitle,
                      accent: widget.accent,
                      mode: mode,
                      onBack: () => Navigator.of(context).maybePop(),
                      onToggleMode: () => setState(() {
                        _mode = mode == _ViewMode.outline
                            ? _ViewMode.tree
                            : _ViewMode.outline;
                      }),
                    ),
                    Expanded(
                      child: _buildBody(mode),
                    ),
                    _BottomHint(mode: mode, accent: widget.accent),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(_ViewMode mode) {
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: AppTypography.body.copyWith(color: AppColors.textTertiary),
        ),
      );
    }
    final root = _root;
    if (root == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }
    if (mode == _ViewMode.outline) {
      return MindMapOutlineView(
        root: root,
        accent: widget.accent,
        initialExpandDepth: 1,
      );
    }
    return MindMapView(
      root: root,
      accent: widget.accent,
      initialExpandDepth: 2,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.bookTitle,
    required this.accent,
    required this.mode,
    required this.onBack,
    required this.onToggleMode,
  });

  final String bookTitle;
  final Color accent;
  final _ViewMode mode;
  final VoidCallback onBack;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _CircleIcon(icon: Icons.arrow_back_rounded, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MIND MAP',
                  style: AppTypography.eyebrow.copyWith(color: accent),
                ),
                const SizedBox(height: 2),
                Text(
                  bookTitle,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Mode toggle
          _CircleIcon(
            icon: mode == _ViewMode.outline
                ? Icons.account_tree_rounded
                : Icons.format_list_bulleted_rounded,
            onTap: onToggleMode,
            tint: accent,
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap, this.tint});

  final IconData icon;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, size: 16, color: tint ?? AppColors.textPrimary),
      ),
    );
  }
}

class _BottomHint extends StatelessWidget {
  const _BottomHint({required this.mode, required this.accent});
  final _ViewMode mode;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final chips = mode == _ViewMode.outline
        ? const [
            (Icons.touch_app_rounded, 'Tap to expand'),
            (Icons.swap_vert_rounded, 'Scroll to read'),
          ]
        : const [
            (Icons.touch_app_rounded, 'Tap to expand'),
            (Icons.pan_tool_alt_rounded, 'Drag to pan'),
            (Icons.zoom_in_rounded, 'Pinch to zoom'),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final c in chips)
            _HintChip(icon: c.$1, text: c.$2, accent: accent),
        ],
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({
    required this.icon,
    required this.text,
    required this.accent,
  });

  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accent.withValues(alpha: 0.85)),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTypography.micro.copyWith(
              fontSize: 10,
              color: AppColors.textTertiary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
