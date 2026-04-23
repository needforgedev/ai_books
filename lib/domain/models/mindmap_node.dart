/// A single node in a mind map tree.
///
/// The outline format we consume is the markmap flavour of Markdown
/// (headings `#`/`##`/`###` + indented `- bullets`) — see
/// [MindMapParser] for the parser that turns text into these nodes.
class MindMapNode {
  MindMapNode({
    required this.text,
    required this.depth,
    List<MindMapNode>? children,
  }) : children = children ?? <MindMapNode>[];

  /// Plain text (markdown formatting stripped).
  final String text;

  /// 0 = root, increases with each level.
  final int depth;

  final List<MindMapNode> children;

  /// Unique id derived from position — stable across rebuilds.
  String get id {
    return '${depth}_${text.hashCode}_${children.length}';
  }

  bool get isLeaf => children.isEmpty;
}
