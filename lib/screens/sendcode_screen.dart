import 'package:flutter/material.dart';
import 'package:socplus/models/send_code_request.dart';
import 'package:socplus/screens/verify_screen.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/widgets/styled_text_field.dart';

class SendCodeScreen extends StatefulWidget {
  const SendCodeScreen({super.key});

  @override
  State<SendCodeScreen> createState() => _SendCodeScreenState();
}

class _SendCodeScreenState extends State<SendCodeScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send Code")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              StyledTextField(
                label: Text("Email"),
                controller: emailController,
                onChanged: (value) {
                  _formKey.currentState!.validate();
                },
                validator: (value) {
                  if (value != null &&
                      !RegExp(
                        r'^[\w.+-]+@[a-zA-Z\d.-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(value)) {
                    return "Invalid email address";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    var res = await AuthService.sendCode(SendCodeRequest(emailController.text));
                    if (!res.success) return;
                    if (!context.mounted) return;
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return VerifyScreen(email: emailController.text);
                    },));
                  }, child: Text("Send Code"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
