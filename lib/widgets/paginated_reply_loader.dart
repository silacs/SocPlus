import 'package:flutter/material.dart';
import 'package:socplus/models/comment.dart';
import 'package:socplus/models/http_response.dart';
import 'package:socplus/models/paginated.dart';
import 'package:socplus/widgets/reply_widget.dart';
class PaginatedReplyLoader extends StatefulWidget {
  final Future<HttpResponse<Paginated<Comment>>> Function(
    String commentId, {
    int page,
    int pageSize
  }) loader;  
  final String commentId;
  final int pageSize;
  const PaginatedReplyLoader({super.key, required this.loader, this.pageSize = 10, required this.commentId});

  @override
  State<PaginatedReplyLoader> createState() => PaginatedReplyLoaderState();
}

class PaginatedReplyLoaderState extends State<PaginatedReplyLoader> {
  final scrollController = ScrollController();
  Paginated<Comment>? comments;
  int page = 1;
  int maxPage = 2;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }
  Future<void> loadPosts() async {
    print(page);
    print(maxPage);
    if (page > maxPage || loading) return;
    setState(() {
      loading = true;
    });
    var res = await widget.loader(widget.commentId, page: page, pageSize: widget.pageSize);
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading comments")));
    }
    setState(() {
      
    });
  }
  Future<void> refresh() async {
    setState(() {
      loading = true;
    });
    page = 1;
    maxPage = 2;
    comments = null;
    var res = await widget.loader(widget.commentId, page: page, pageSize: widget.pageSize);
    setState(() {
      loading = false;
    });
    if (res.success) {
        comments = res.body;
        maxPage = (comments!.total / comments!.pageSize).ceil();
        page++;
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading comments")));
    }
  }
  @override
  Widget build(BuildContext context) {
    if (loading && comments == null) {
      return Center(child: CircularProgressIndicator());
    } else if (comments == null) {
      return Center(child: Text("Error loading replies"),);
    } else if (comments!.data.isEmpty) {
      return Center(child: Text("There are no replies"),);
    } else {
      return GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              controller: scrollController,
              itemCount: comments!.data.length,
              itemBuilder: (context, index) {
                return ReplyWidget(
                  comment: comments!.data[index],
                  onDelete: () {
                    comments!.data.removeAt(index);
                    setState(() {});
                  },
                );
              },
            ),
            if (loading) CircularProgressIndicator(),
            //if (page < maxPage) 
            if (page <= maxPage && !loading) TextButton(onPressed: () => loadPosts(), child: Text("Load More"))
          ],
        ),
      );
    }
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}