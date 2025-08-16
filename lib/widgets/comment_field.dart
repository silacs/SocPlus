import 'package:flutter/material.dart';
import 'package:socplus/models/comment.dart';
import 'package:socplus/models/comment_request.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/styled_text_area.dart';

class CommentField extends StatefulWidget {
  final TextEditingController controller;
  final String postId;
  final VoidCallback? onSend;
  final Comment? parentComment;
  const CommentField({
    super.key,
    required this.controller,
    this.onSend,
    required this.postId, this.parentComment,
  });

  @override
  State<CommentField> createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  bool pending = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: StyledTextArea(
              controller: widget.controller,
              hint: widget.parentComment != null ? "Replying to ${widget.parentComment!.user.name}" : null,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
        FilledButton(
          onPressed:
              widget.controller.text.isEmpty || pending
                  ? null
                  : () async {
                    if (widget.controller.text.isEmpty) return;
                    await AuthService.refreshIfExpired(context);
                    setState(() {
                      pending = true;
                    });
                    var res = await PostService.addComment(
                      CommentRequest(
                        widget.postId,
                        widget.parentComment?.id,
                        widget.controller.text,
                        widget.parentComment != null,
                      ),
                    );
                    setState(() {
                      pending = false;
                    });
                    if (res.success) {
                      widget.controller.text = '';
                      widget.onSend?.call();
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error posting comment")),
                      );
                    }
                  },
          style: FilledButton.styleFrom(
            padding: EdgeInsets.all(16),
            minimumSize: Size(54, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Icon(Icons.send_rounded),
        ),
      ],
    );
  }
}
