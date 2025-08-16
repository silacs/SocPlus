import 'package:flutter/material.dart';
import 'package:socplus/models/comment.dart';
import 'package:socplus/models/http_response.dart';
import 'package:socplus/models/paginated.dart';
import 'package:socplus/widgets/comment_widget.dart';

class PaginatedCommentLoader extends StatefulWidget {
  final Future<HttpResponse<Paginated<Comment>>> Function(
    String postId, {
    int page,
    int pageSize,
  })
  loader;
  final String postId;
  final int pageSize;
  final void Function(Comment comment) onReply;
  const PaginatedCommentLoader({
    super.key,
    required this.loader,
    this.pageSize = 10,
    required this.postId,
    required this.onReply,
  });

  @override
  State<PaginatedCommentLoader> createState() => PaginatedCommentLoaderState();
}

class PaginatedCommentLoaderState extends State<PaginatedCommentLoader> {
  final scrollController = ScrollController();
  Paginated<Comment>? comments;
  int page = 1;
  int maxPage = 2;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadPosts();
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          scrollController.position.pixels != 0) {
        loadPosts();
      }
    });
  }

  Future<void> loadPosts() async {
    if (page > maxPage || loading) return;
    setState(() {
      loading = true;
    });
    var res = await widget.loader(
      widget.postId,
      page: page,
      pageSize: widget.pageSize,
    );
    setState(() {
      loading = false;
    });
    if (res.success) {
      if (comments == null) {
        comments = res.body;
        maxPage = (comments!.total / comments!.pageSize).ceil();
      } else {
        comments!.data = [...comments!.data, ...res.body!.data];
      }
      page++;
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading comments")));
    }
  }

  Future<void> refresh() async {
    setState(() {
      loading = true;
    });
    page = 1;
    maxPage = 2;
    comments = null;
    var res = await widget.loader(
      widget.postId,
      page: page,
      pageSize: widget.pageSize,
    );
    setState(() {
      loading = false;
    });
    if (res.success) {
      comments = res.body;
      maxPage = (comments!.total / comments!.pageSize).ceil();
      page++;
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading comments")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading && comments == null) {
      return Center(child: CircularProgressIndicator());
    } else if (comments == null) {
      return Center(child: Text("Error loading comments"));
    } else if (comments!.data.isEmpty) {
      return Center(child: Text("There are no comments"));
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: comments!.data.length,
              itemBuilder: (context, index) {
                return CommentWidget(
                  comment: comments!.data[index],
                  onDelete: () {
                    comments!.data.removeAt(index);
                    setState(() {});
                  },
                  onReply: (Comment comment) {
                    widget.onReply.call(comment);
                  },
                );
              },
            ),
          ),
          if (loading) CircularProgressIndicator(),
        ],
      );
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
