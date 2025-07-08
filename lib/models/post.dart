import 'package:socplus/models/user.dart';

class Post {
  final String id;
  final User user;
  final String text;
  final List<String> images;
  final String created;
  final int visibility;
  const Post(this.id, this.user, this.text, this.images, this.created, this.visibility);
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      json['id'],
      User.fromJson(json['user']),
      json['text'],
      List<String>.from(json['images']),
      json['created'],
      json['visibility']
    );
  }
}