import 'package:flutter/material.dart';
import 'package:socplus/models/comment.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/expandable_comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReplyWidget extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onDelete;
  const ReplyWidget({super.key, required this.comment, this.onDelete});

  @override
  State<ReplyWidget> createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<ReplyWidget> {
  String? userId;
  bool repliesShown = false;
  @override
  void initState() {
    super.initState();
    setUserId();
  }

  void setUserId() async {
    userId = (await AuthService.decodedAccessToken)['sub'];
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${widget.comment.user.name} ${widget.comment.user.surname} (@${widget.comment.user.username})",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondaryFixedDim,
                fontSize: 12,
              ),
            ),
            if (widget.comment.userId == userId)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                onSelected: (value) async {
                  if (value == 'delete') {
                    await AuthService.refreshIfExpired(context);
                    var res = await PostService.deleteComment(
                      widget.comment.id,
                    );
                    if (res.success && context.mounted) {
                      widget.onDelete?.call();
                    } else if (context.mounted) {}
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
              ),
          ],
        ),
        ExpandableComment(text: widget.comment.content, trimLines: 3),
        Text(
          timeago.format(DateTime.parse(widget.comment.created)),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
