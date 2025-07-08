import 'package:flutter/material.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/comment_field.dart';
import 'package:socplus/widgets/expandable_comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentBox extends StatefulWidget {
  final String postId;
  const CommentBox({super.key, required this.postId});

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final commentController = TextEditingController();
  Key key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
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
                child: FutureBuilder(
                  future: PostService.getComments(widget.postId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          !snapshot.data!.success) {
                        return const Center(
                          child: Text("Error loading comments"),
                        );
                      }
                      if (snapshot.data!.body!.isEmpty) {
                        return const Center(
                          child: Text("There are no comments"),
                        );
                      }
                      var comments = snapshot.data!.body!;
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${comments[index].user.name} ${comments[index].user.surname} (@${comments[index].user.username})",
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryFixedDim,
                                  fontSize: 12,
                                ),
                              ),
                              ExpandableComment(
                                text: comments[index].content,
                                trimLines: 3,
                              ),
                              Text(
                                timeago.format(DateTime.parse(comments[index].created)),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
                              ),
                              SizedBox(height: 30),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              CommentField(
                controller: commentController,
                postId: widget.postId,
                onSend: () {
                  setState(() {}); // You don’t need the key jank
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
