import 'package:socplus/models/request_interface.dart';

class VerifyRequest implements Request {
  final String email;
  final String code;
  VerifyRequest(this.email, this.code);
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code
    };
  }
}