import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socplus/models/post.dart' as post_model;
import 'package:socplus/services/post_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/widgets/post_action_bar.dart';

class Post extends StatefulWidget {
  final post_model.Post post;
  final VoidCallback? onDelete;
  const Post({super.key, required this.post, this.onDelete});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  bool liked = false;
  bool disliked = false;
  String? userId;
  bool deleted = false;

  @override
  void initState() {
    super.initState();
    setUserId();
  }

  void setUserId() async {
    var id = (await AuthService.decodedAccessToken)['sub'];
    if (!mounted) return;
    setState(() {
      userId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return deleted
        ? SizedBox.shrink()
        : Container(
          margin: EdgeInsets.all(5),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.post.user.name} ${widget.post.user.surname}',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.secondaryFixedDim,
                        ),
                      ),
                      if (userId != null && widget.post.user.id != userId)
                        TextButton(onPressed: () {}, child: Text("Follow")),
                      if (userId != null && widget.post.user.id == userId) ...[
                        Spacer(flex: 1),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onSelected: (value) async {
                            if (value == 'delete') {
                              var res = await PostService.deletePost(
                                widget.post.id,
                              );
                              if (res.success) {
                                setState(() {
                                  deleted = true;
                                });
                                widget.onDelete?.call();
                              } else if (!res.success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error deleting post"),
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                        ),
                      ],
                    ],
                  ),
                  Text(
                    timeago.format(DateTime.parse(widget.post.created)),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SelectableText(
                    widget.post.text,
                    style: TextStyle(fontSize: 20),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.post.images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          widget.post.images.length < 3 &&
                                  widget.post.images.isNotEmpty
                              ? widget.post.images.length
                              : 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio:
                          widget.post.images.length < 3 &&
                                  widget.post.images.isNotEmpty
                              ? 16 / 9
                              : 1 / 1,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SizedBox(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height,
                                child: CachedNetworkImage(
                                  width: double.infinity,
                                  imageUrl:
                                      '${PostService.baseUrl}/image/${widget.post.images[index]}',
                                  fit: BoxFit.fitWidth,
                                  placeholder:
                                      (context, url) => Shimmer.fromColors(
                                        baseColor:Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: double.infinity,
                                        ),
                                      ),
                                ),
                              );
                            },
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: '${PostService.baseUrl}/image/${widget.post.images[index]}',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  PostActionBar(postId: widget.post.id),
                ],
              ),
            ),
          ),
        );
  }
}
