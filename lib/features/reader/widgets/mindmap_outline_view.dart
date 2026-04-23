import 'package:flutter/material.dart';
import 'package:ai_books/app/theme/app_colors.dart';
import 'package:ai_books/app/theme/app_typography.dart';
import 'package:ai_books/domain/models/mindmap_node.dart';

/// Vertical outline view of a [MindMapNode] tree — reads like a
/// Notion toggle list. Designed for narrow screens (phones) where the
/// horizontal tree gets cramped.
///
/// Pans naturally via a ListView; each expandable node animates its
/// children in/out; indentation + a hair-line rule on the left show
/// hierarchy.
class MindMapOutlineView extends StatefulWidget {
  const MindMapOutlineView({
    super.key,
    required this.root,
    required this.accent,
    this.initialExpandDepth = 1,
  });

  final MindMapNode root;
  final Color accent;
  final int initialExpandDepth;

  @override
  State<MindMapOutlineView> createState() => _MindMapOutlineViewState();
}

class _MindMapOutlineViewState extends State<MindMapOutlineView> {
  final Set<String> _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    _seed(widget.root, 0);
  }

  void _seed(MindMapNode node, int depth) {
    if (depth <= widget.initialExpandDepth) {
      _expanded.add(node.id);
      for (final c in node.children) {
        _seed(c, depth + 1);
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _OutlineNode(
          node: widget.root,
          accent: widget.accent,
          isExpanded: _isExpanded,
          onToggle: _toggle,
        ),
      ],
    );
  }
}

class _OutlineNode extends StatelessWidget {
  const _OutlineNode({
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
    final depth = node.depth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Row(
          node: node,
          expanded: expanded,
          hasChildren: hasChildren,
          accent: accent,
          onTap: hasChildren ? () => onToggle(node) : null,
        ),
        if (expanded && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2, bottom: 4),
            child: Stack(
              children: [
                // Hairline on the left for hierarchy cue
                Positioned(
                  left: 0,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    width: 1.2,
                    color: accent.withValues(
                      alpha: depth == 0 ? 0.35 : 0.18,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final c in node.children)
                        _OutlineNode(
                          node: c,
                          accent: accent,
                          isExpanded: isExpanded,
                          onToggle: onToggle,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.node,
    required this.expanded,
    required this.hasChildren,
    required this.accent,
    required this.onTap,
  });

  final MindMapNode node;
  final bool expanded;
  final bool hasChildren;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final depth = node.depth;

    // Type scale by depth
    final fontSize = depth == 0
        ? 18.0
        : depth == 1
            ? 16.0
            : depth == 2
                ? 14.5
                : 13.5;

    final fontWeight = depth == 0
        ? FontWeight.w700
        : depth == 1
            ? FontWeight.w600
            : FontWeight.w500;

    final textColor = depth <= 1
        ? AppColors.textPrimary
        : AppColors.textPrimary.withValues(alpha: 0.85);

    // Background tint — subtle on deeper nodes
    final bg = depth == 0
        ? accent.withValues(alpha: 0.14)
        : depth == 1
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.transparent;

    final borderColor = depth == 0
        ? accent.withValues(alpha: 0.4)
        : depth == 1
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            10,
            depth == 0 ? 12 : 8,
            10,
            depth == 0 ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disclosure chevron (always takes the same width even when
              // the node is a leaf so rows align cleanly)
              SizedBox(
                width: 22,
                height: 22,
                child: hasChildren
                    ? AnimatedRotation(
                        turns: expanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: accent.withValues(alpha: 0.9),
                        ),
                      )
                    : Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  node.text,
                  style: AppTypography.body.copyWith(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    height: 1.35,
                    color: textColor,
                  ),
                ),
              ),
              if (hasChildren && !expanded) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${node.children.length}',
                    style: AppTypography.micro.copyWith(
                      fontSize: 10.5,
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
