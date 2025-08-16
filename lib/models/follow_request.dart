import 'package:socplus/models/request_interface.dart';

class FollowRequest implements Request {
  final String userId;

  const FollowRequest({required this.userId});
  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId
    };
  }
}