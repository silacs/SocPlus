import 'package:flutter/material.dart';

class ExpandableComment extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;

  const ExpandableComment({
    required this.text,
    this.trimLines = 3,
    super.key,
    this.style,
  });

  @override
  State<ExpandableComment> createState() => _ExpandableCommentState();
}

class _ExpandableCommentState extends State<ExpandableComment> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      maxLines: _expanded ? null : widget.trimLines,
      overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      style: widget.style,
    );

    final isLong =
        widget.text.split('\n').length > widget.trimLines ||
        widget.text.length > 150;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textWidget,
          if (isLong)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? "Show less" : "Read more",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
