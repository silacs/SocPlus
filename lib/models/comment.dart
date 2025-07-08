import 'package:socplus/models/user.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String? parentCommentId;
  final String content;
  final bool isReply;
  final String created;
  final User user;
  const Comment(
    this.id,
    this.postId,
    this.userId,
    this.parentCommentId,
    this.content,
    this.isReply,
    this.created,
    this.user,
  );
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      json['id'],
      json['postId'],
      json['userId'],
      json['parentCommentId'],
      json['content'],
      json['isReply'],
      json['created'],
      User.fromJson(json['user']),
    );
  }
}
