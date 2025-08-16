import 'package:flutter/material.dart';
import 'package:socplus/services/post_service.dart';
import 'package:socplus/widgets/paginated_post_loader.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedPostLoader(loader: PostService.getPosts);
  }
}