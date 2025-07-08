import 'package:flutter/material.dart';
import 'package:socplus/models/vote_request.dart';
import 'package:socplus/models/votes.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/comment_box.dart';

class PostActionBar extends StatefulWidget {
  final String postId;
  const PostActionBar({super.key, required this.postId});

  @override
  State<PostActionBar> createState() => _PostActionBarState();
}

class _PostActionBarState extends State<PostActionBar> {
  bool disliked = false;
  bool liked = false;
  Votes? _votes;
  @override
  void initState() {
    super.initState();
    getVotes();
  }

  void getVotes() async {
    var res = await PostService.getVotes(widget.postId);
    if (res.success && mounted) {
      setState(() {
        _votes = res.body;
        if (_votes!.userVote != null) {
          _votes!.userVote! ?  liked = true : disliked = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
              child: Row(
                children: [
                  if (_votes != null) Text(_votes!.goodVotes.toString()),
                  SizedBox.square(dimension: 10,),
                  InkWell(
                    onTap: () async {
                      await AuthService.refreshIfExpired(context);
                      var res = await PostService.addVote(
                        VoteRequest(widget.postId, liked ? null : true),
                      );
                      if (!res.success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error liking post")),
                        );
                      } else {
                        setState(() {
                          if (liked) {
                            liked = false;
                            _votes!.goodVotes--;
                            return;
                          }
                          _votes!.goodVotes++;
                          if (disliked) _votes!.badVotes--;
                          disliked = false;
                          liked = true;
                        });
                      }
                    },
                    child: Icon(
                      liked ? Icons.thumb_up : Icons.thumb_up_off_alt_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  VerticalDivider(),
                  InkWell(
                    onTap: () async {
                      await AuthService.refreshIfExpired(context);
                      var res = await PostService.addVote(
                        VoteRequest(widget.postId, disliked ? null : false),
                      );
                      if (!res.success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error disliking post")),
                        );
                      } else {
                        setState(() {
                          if (disliked) {
                            disliked = false;
                            _votes!.badVotes--;
                            return;
                          }
                          _votes!.badVotes++;
                          if (liked) _votes!.goodVotes--;
                          liked = false;
                          disliked = true;
                        });
                      }
                    },
                    child: Icon(
                      disliked
                          ? Icons.thumb_down
                          : Icons.thumb_down_off_alt_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  SizedBox.square(dimension: 10,),
                  if (_votes != null) Text(_votes!.badVotes.toString()),
                ],
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            final comments = CommentBox(postId: widget.postId);
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return comments;
              },
            );
          },
          child: Icon(Icons.comment),
        ),
      ],
    );
  }
}
