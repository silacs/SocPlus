import 'package:flutter/material.dart';
import 'package:socplus/models/post.dart';
import 'package:socplus/widgets/post.dart' as post_widget;
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/services/post_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Post> posts = [];
  late String accessToken = '';
  bool loadingPosts = false;
  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  void loadPosts() async {
    setState(() {
      loadingPosts = true;
    });
    accessToken = (await AuthService.accessToken)!;
    var posts = await PostService.getPosts();
    loadingPosts = false;
    if (posts.success) this.posts = posts.body!;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          setState(() {
            loadingPosts = true;
          });
          var posts = await PostService.getPosts();
          if (posts.success) {
            setState(() {
              loadingPosts = false;
              this.posts = posts.body!;
            });
          }
        },
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return post_widget.Post(
              key: ValueKey(post.id),
              post: post,
              onDelete: () {
                posts.remove(post);
              },
            );
          },
        ),
      );
    } else if (loadingPosts) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Text("There are no posts");
    }
  }
}
