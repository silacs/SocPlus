import 'package:flutter/material.dart';
import 'package:socplus/models/login_request.dart';
import 'package:socplus/screens/sendcode_screen.dart';
import 'package:socplus/screens/widget_tree.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/widgets/password_field.dart';
import 'package:socplus/widgets/styled_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final key = GlobalKey<FormState>();

  String? usernameError;
  String? passwordError;
  bool needsVerification = false;
  bool pending = false;

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Form(
            key: key,
            child: Column(
              spacing: 10,
              children: [
                SizedBox(height: 40),
                StyledTextField(
                  label: Text("Username or email"),
                  controller: usernameController,
                  onChanged: (value) {
                    var needsRevalidation = usernameError != null || passwordError != null;
                    usernameError = null;
                    passwordError = null;
                    if (needsRevalidation) key.currentState!.validate();
                  },
                  validator: (value) {
                    if (value != null && value == '') {
                      return 'This value cannot be empty';
                    } else {
                      return usernameError;
                    }
                  },
                ),
                if(needsVerification) TextButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SendCodeScreen();
                  },));
                }, child: Text("Click here to verify")),
                PasswordField(
                  label: Text("Password"),
                  controller: passwordController,
                  onChanged: (value) {
                    passwordError = null;
                    key.currentState!.validate();
                  },
                  validator: (value) {
                    if (value != null && value == '') {
                      return "This value cannot be empty";
                    } else {
                      return passwordError;
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      onPressed: pending ? null : () async {
                        if (!key.currentState!.validate()) return;
                        setState(() {
                          pending = true;
                        });
                        final res = await AuthService.login(
                          LoginRequest(
                            usernameController.text,
                            passwordController.text,
                          ),
                        );
                        if (mounted) {
                          setState(() {
                            pending = false;
                          });
                        }
                        if (!res.success) {
                          passwordError = res.error!.errors['Credentials']?[0];
                          usernameError = res.error!.errors['Username']?[0];
                          if (usernameError != null) {
                            setState(() {
                              needsVerification = true;
                            });
                          }
                        } else {
                          var prefs = await SharedPreferences.getInstance();
                          prefs.setString('accessToken', res.body!.accessToken);
                          prefs.setString(
                            'refreshToken',
                            res.body!.refreshToken,
                          );
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) {
                                  return WidgetTree();
                                },
                              ),
                              (route) => false,
                            );
                          }
                        }
                        key.currentState!.validate();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("Login"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
