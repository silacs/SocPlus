import 'package:flutter/material.dart';
import 'package:socplus/models/http_response.dart';
import 'package:socplus/models/paginated.dart';
import 'package:socplus/models/post.dart';
import 'package:socplus/widgets/post.dart' as post_widget;
class PaginatedPostLoader extends StatefulWidget {
  final Future<HttpResponse<Paginated<Post>>> Function({
    BuildContext? context,
    int page,
    int pageSize,
    String keywords
  }) loader;  
  final String? keywords;
  final int pageSize;
  const PaginatedPostLoader({super.key, required this.loader, this.pageSize = 10, this.keywords});

  @override
  State<PaginatedPostLoader> createState() => _PaginatedPostLoaderState();
}

class _PaginatedPostLoaderState extends State<PaginatedPostLoader> {
  final scrollController = ScrollController();
  Paginated<Post>? posts;
  int page = 1;
  int maxPage = 2;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadPosts();
    scrollController.addListener(() {
      if (scrollController.position.atEdge && scrollController.position.pixels != 0) {
        loadPosts();
      }
    });
  }
  Future<void> loadPosts() async {
    if (page > maxPage || loading) return;
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    var res = await widget.loader(context: context, keywords: widget.keywords ?? '', page: page, pageSize: widget.pageSize);
    if (mounted) {
      setState(() {
        loading = false;
      });
    } 
    if (res.success) {
      if (posts == null) {
        posts = res.body;
        maxPage = (posts!.total / posts!.pageSize).ceil();
      } else {
        posts!.data = [...posts!.data, ...res.body!.data];
      }
      page++;
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading posts")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && posts == null) {
      return Center(child: CircularProgressIndicator());
    } else if (posts == null) {
      return Center(child: Text("Error loading posts"),);
    } else if (posts!.data.isEmpty) {
      return Center(child: Text("There are no posts"),);
    } else {
      return RefreshIndicator(
      onRefresh: () async {
        posts = null;
        page = 1;
        maxPage = 2;
        loadPosts();
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: posts!.data.length,
              itemBuilder: (context, index) {
                final post = posts!.data[index];
                return post_widget.Post(
                  key: ValueKey(post.id),
                  post: post,
                    onDelete: () {
                      posts!.data.removeAt(index);
                      setState(() {});
                    },
                  );
              },
            ),
          ),
          if (loading) CircularProgressIndicator()
        ],
      )
    );
    }
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}