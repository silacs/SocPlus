import 'package:socplus/models/request_interface.dart';

class RefreshRequest implements Request {
  final String refreshToken;
  const RefreshRequest(this.refreshToken);
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken
    };
  }

}