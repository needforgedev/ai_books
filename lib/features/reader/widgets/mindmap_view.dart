import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/mindmap_node.dart';

/// Interactive native mind map renderer.
///
/// Uses [InteractiveViewer] for pan + pinch-zoom, and a recursive layout
/// of pill-shaped nodes with fork connectors. Each node is tappable to
/// expand/collapse its children.
class MindMapView extends StatefulWidget {
  const MindMapView({
    super.key,
    required this.root,
    required this.accent,
    this.initialExpandDepth = 2,
  });

  final MindMapNode root;
  final Color accent;

  /// How many levels to expand initially (0 = only root, 1 = root + its
  /// immediate children, etc.).
  final int initialExpandDepth;

  @override
  State<MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends State<MindMapView> {
  final TransformationController _tc = TransformationController();
  final Set<String> _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    _seedExpansion(widget.root, 0);
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _seedExpansion(MindMapNode node, int depth) {
    if (depth < widget.initialExpandDepth) {
      _expanded.add(node.id);
      for (final c in node.children) {
        _seedExpansion(c, depth + 1);
      }
    }
  }

  bool _isExpanded(MindMapNode n) => _expanded.contains(n.id);

  void _toggle(MindMapNode n) {
    setState(() {
      if (_expanded.contains(n.id)) {
        _expanded.remove(n.id);
      } else {
        _expanded.add(n.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _tc,
      minScale: 0.35,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(600),
      constrained: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 48, 32),
        child: _NodeSubtree(
          node: widget.root,
          accent: widget.accent,
          isExpanded: _isExpanded,
          onToggle: _toggle,
        ),
      ),
    );
  }
}

// ============================================================================
// Subtree — one node + its (optionally visible) children laid out horizontally
// ============================================================================

class _NodeSubtree extends StatelessWidget {
  const _NodeSubtree({
    required this.node,
    required this.accent,
    required this.isExpanded,
    required this.onToggle,
  });

  final MindMapNode node;
  final Color accent;
  final bool Function(MindMapNode) isExpanded;
  final void Function(MindMapNode) onToggle;

  @override
  Widget build(BuildContext context) {
    final expanded = isExpanded(node);
    final hasChildren = node.children.isNotEmpty;
    final showChildren = expanded && hasChildren;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _NodeChip(
          node: node,
          accent: accent,
          expanded: expanded,
          hasChildren: hasChildren,
          onTap: hasChildren ? () => onToggle(node) : null,
        ),
        if (showChildren) ...[
          _ForkConnector(accent: accent, depth: node.depth),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < node.children.length; i++) ...[
                _NodeSubtree(
                  node: node.children[i],
                  accent: accent,
                  isExpanded: isExpanded,
                  onToggle: onToggle,
                ),
                if (i != node.children.length - 1)
                  const SizedBox(height: 14),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// Node chip
// ============================================================================

class _NodeChip extends StatelessWidget {
  const _NodeChip({
    required this.node,
    required this.accent,
    required this.expanded,
    required this.hasChildren,
    required this.onTap,
  });

  final MindMapNode node;
  final Color accent;
  final bool expanded;
  final bool hasChildren;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final depth = node.depth;

    // Style scales with depth — root is boldest, leaves are softest.
    final fontSize = depth == 0
        ? 18.0
        : depth == 1
            ? 15.0
            : depth == 2
                ? 13.5
                : 12.5;

    final fontWeight = depth <= 1 ? FontWeight.w600 : FontWeight.w500;

    final bg = depth == 0
        ? accent.withValues(alpha: 0.2)
        : depth == 1
            ? accent.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04);

    final borderColor = depth == 0
        ? accent.withValues(alpha: 0.55)
        : depth == 1
            ? accent.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.1);

    final textColor = depth <= 1
        ? AppColors.textPrimary
        : AppColors.textPrimary.withValues(alpha: 0.85);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: EdgeInsets.symmetric(
          horizontal: depth == 0 ? 18 : 14,
          vertical: depth == 0 ? 14 : 10,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(depth == 0 ? 14 : 999),
          border: Border.all(color: borderColor, width: depth == 0 ? 1.2 : 1),
          boxShadow: depth == 0
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 24,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasChildren) ...[
              AnimatedRotation(
                turns: expanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: accent.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                node.text,
                style: AppTypography.body.copyWith(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  height: 1.3,
                  color: textColor,
                ),
              ),
            ),
            if (hasChildren && !expanded) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${node.children.length}',
                  style: AppTypography.micro.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Fork connector between a parent and its children column
// ============================================================================

class _ForkConnector extends StatelessWidget {
  const _ForkConnector({required this.accent, required this.depth});

  final Color accent;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final color = accent.withValues(
      alpha: depth == 0 ? 0.55 : depth == 1 ? 0.4 : 0.25,
    );
    return SizedBox(
      width: 32,
      height: 2,
      child: CustomPaint(
        painter: _ForkPainter(color: color),
      ),
    );
  }
}

class _ForkPainter extends CustomPainter {
  _ForkPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Smooth horizontal curve from left edge to right edge.
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..cubicTo(
        size.width * 0.5, size.height / 2,
        size.width * 0.5, size.height / 2,
        size.width, size.height / 2,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ForkPainter old) => old.color != color;
}
