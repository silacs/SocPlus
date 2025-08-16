import 'package:flutter/material.dart';
import 'package:socplus/models/comment.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/comment_field.dart';
import 'package:socplus/widgets/paginated_comment_loader.dart';

class CommentBox extends StatefulWidget {
  final String postId;
  final BuildContext scaffoldContext;
  const CommentBox({
    super.key,
    required this.postId,
    required this.scaffoldContext,
  });

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final commentController = TextEditingController();
  final _key = GlobalKey<PaginatedCommentLoaderState>();
  Comment? parentComment;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        parentComment = null;
      }),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FractionallySizedBox(
          heightFactor: 0.7,
          widthFactor: 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: PaginatedCommentLoader(
                    key: _key,
                    loader: PostService.getComments,
                    postId: widget.postId,
                    onReply: (Comment comment) {
                      setState(() {
                        parentComment = comment;
                      });
                    },
                  ),
                ),
                CommentField(
                  controller: commentController,
                  postId: widget.postId,
                  parentComment: parentComment,
                  onSend: () {
                    setState(() {
                      _key.currentState!.refresh();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
