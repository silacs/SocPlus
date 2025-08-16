import 'package:flutter/material.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/paginated_post_loader.dart';

class SearchScreen extends StatelessWidget {
  final String keywords;
  const SearchScreen({super.key, required this.keywords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search"),),
      body: PaginatedPostLoader(
        loader: PostService.search,
        keywords: keywords,
        ) 
    );
  }
}