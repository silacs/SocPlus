import 'package:socplus/models/request_interface.dart';

class SendCodeRequest implements Request {
  final String email;

  SendCodeRequest(this.email);
  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email
    };
  }

}