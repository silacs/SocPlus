import 'package:socplus/models/request_interface.dart';

class VoteRequest implements Request {
  final String userId = '';
  final String postId;
  final bool? positive;
  const VoteRequest(this.postId, this.positive);

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'postId': postId,
      'positive': positive
    };
  }
}