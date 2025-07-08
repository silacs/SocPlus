import 'package:socplus/models/request_interface.dart';

class SignupRequest implements Request {
  final String name;
  final String surname;
  final String email;
  final String username;
  final String password;
  const SignupRequest(this.name, this.surname, this.email, this.username, this.password);
  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'username': username,
      'password': password,
    };
  }
}