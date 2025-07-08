import 'package:socplus/models/request_interface.dart';

class LoginRequest implements Request {
  final String email;
  final String password;
  LoginRequest(this.email, this.password);
  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

}