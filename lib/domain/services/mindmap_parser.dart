import 'package:ai_books/domain/models/mindmap_node.dart';

/// Parses the markmap-flavour outline bundled inside a mind map HTML file
/// into a [MindMapNode] tree that our native viewer can render.
class MindMapParser {
  MindMapParser._();

  /// Extract the `<script type="text/template">` block from a markmap HTML
  /// export and return its raw outline. Returns empty string if not found.
  static String extractMarkdownFromHtml(String html) {
    // The script block carries the outline; everything else is chrome.
    final re = RegExp(
      r'''<script\s+type=['"]text/template['"][^>]*>([\s\S]*?)</script>''',
      caseSensitive: false,
    );
    final match = re.firstMatch(html);
    return match?.group(1)?.trim() ?? '';
  }

  /// Parse a markmap-style outline into a tree.
  ///
  /// Rules:
  /// - `# foo` → root (depth 0)
  /// - `## foo` → depth 1
  /// - `### foo` → depth 2
  /// - `- foo` (at any indentation) → indented further by (leading-spaces / 2)
  /// - Front matter (`---` fenced block) is ignored
  /// - `**bold**`, `*italic*`, `` `code` `` markers are stripped from text
  static MindMapNode parse(String source) {
    final lines = source.split('\n');

    // Skip front matter fence (`---` … `---`) if present.
    var cursor = 0;
    if (_lineTrimmed(lines, 0) == '---') {
      cursor = 1;
      while (cursor < lines.length && _lineTrimmed(lines, cursor) != '---') {
        cursor++;
      }
      if (cursor < lines.length) cursor++;
    }

    // Use an implicit stack keyed by parsed "level" (a synthesised integer
    // increasing with nesting). Headings map to low levels, bullets to
    // higher levels offset by indentation.
    const bulletLevelOffset = 100;
    final stack = <_StackFrame>[];
    MindMapNode? root;

    for (var i = cursor; i < lines.length; i++) {
      final raw = lines[i];
      final trimmed = raw.trimLeft();
      if (trimmed.isEmpty) continue;

      int level;
      String rawText;

      if (trimmed.startsWith('# ')) {
        level = 1;
        rawText = trimmed.substring(2);
      } else if (trimmed.startsWith('## ')) {
        level = 2;
        rawText = trimmed.substring(3);
      } else if (trimmed.startsWith('### ')) {
        level = 3;
        rawText = trimmed.substring(4);
      } else if (trimmed.startsWith('#### ')) {
        level = 4;
        rawText = trimmed.substring(5);
      } else if (trimmed.startsWith('- ')) {
        final leading = raw.length - raw.trimLeft().length;
        // Every 2 leading spaces = one more level of bullet nesting.
        level = bulletLevelOffset + (leading ~/ 2);
        rawText = trimmed.substring(2);
      } else {
        // Non-outline line (paragraph continuation, comment, etc.) — ignore.
        continue;
      }

      final text = _strip(rawText);
      if (text.isEmpty) continue;

      // Pop any stack frames whose level is >= ours — they can't be parents.
      while (stack.isNotEmpty && stack.last.level >= level) {
        stack.removeLast();
      }

      final parentDepth = stack.isEmpty ? -1 : stack.last.node.depth;
      final node = MindMapNode(text: text, depth: parentDepth + 1);

      if (stack.isEmpty) {
        // First real node — becomes root.
        root = node;
      } else {
        stack.last.node.children.add(node);
      }
      stack.add(_StackFrame(level: level, node: node));
    }

    return root ?? MindMapNode(text: 'Empty mind map', depth: 0);
  }

  static String? _lineTrimmed(List<String> lines, int i) {
    if (i < 0 || i >= lines.length) return null;
    return lines[i].trim();
  }

  /// Strip common inline markdown so the node text renders cleanly.
  static String _strip(String input) {
    var s = input.trim();
    // Bold **foo** / __foo__
    s = s.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!);
    s = s.replaceAllMapped(RegExp(r'__(.+?)__'), (m) => m.group(1)!);
    // Italic *foo* / _foo_
    s = s.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1)!);
    s = s.replaceAllMapped(RegExp(r'(?<!\w)_(.+?)_(?!\w)'), (m) => m.group(1)!);
    // Inline code `foo`
    s = s.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m.group(1)!);
    // Collapse whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}

class _StackFrame {
  _StackFrame({required this.level, required this.node});
  final int level;
  final MindMapNode node;
}
