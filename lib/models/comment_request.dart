import 'package:socplus/models/request_interface.dart';

class CommentRequest implements Request{
  final String userId = '';
  final String postId;
  final String? parentCommentId;
  final String content;
  final bool isReply;
  const CommentRequest(this.postId, this.parentCommentId, this.content, this.isReply);

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'postId': postId,
      'parentCommentId': parentCommentId,
      'content': content,
      'isReply': isReply
    };
  }

}