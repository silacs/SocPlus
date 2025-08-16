import 'package:flutter/material.dart';
import 'package:socplus/models/comment.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/expandable_comment.dart';
import 'package:socplus/widgets/paginated_reply_loader.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onDelete;
  final void Function(Comment comment) onReply;
  const CommentWidget({super.key, required this.comment, this.onDelete, required this.onReply});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
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
    return GestureDetector(
      onTap: () {
        widget.onReply.call(widget.comment);
      },
      child: Column(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    repliesShown = !repliesShown;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    repliesShown
                        ? Icon(Icons.expand_less)
                        : Icon(Icons.expand_more),
                    repliesShown ? Text("Hide Replies") : Text("Show Replies"),
                  ],
                ),
              ),
              if (repliesShown) Container(
                padding: EdgeInsets.only(left: 10),
                child: PaginatedReplyLoader(loader: PostService.getReplies, commentId: widget.comment.id),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
