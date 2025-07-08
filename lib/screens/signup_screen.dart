import 'package:flutter/material.dart';
import 'package:socplus/models/signup_request.dart';
import 'package:socplus/screens/verify_screen.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/widgets/password_field.dart';
import 'package:socplus/widgets/styled_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  String? usernameError;
  String? emailError;
  bool passwordsShown = false;
  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  String? lengthValidator(String? value, String name, {bool required = true}) {
    if ((value == null || value == "")) {
      return required ? "This value is required" : null;
    }
    if (value.length < 2) {
      return "$name should be longer than 2 characters";
    } else if (value.length > 100) {
      return "$name should be shorter than 100 characters";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledTextField(
                  controller: nameController,
                  label: Text("Name"),
                  validator: (value) => lengthValidator(value, "Name"),
                ),
                StyledTextField(
                  controller: surnameController,
                  label: Text("Surname"),
                  validator: (value) => lengthValidator(value, "Surname"),
                ),
                StyledTextField(
                  controller: usernameController,
                  label: Text("Username"),
                  onChanged: (value) {
                    if (usernameError != null) {
                      usernameError = null;
                      formKey.currentState!.validate();
                    }
                  },
                  validator: (value) {
                    return lengthValidator(value, "Username") ?? usernameError;
                  },
                ),
                StyledTextField(
                  controller: emailController,
                  label: Text("Email"),
                  onChanged: (value) {
                    if (emailError != null) {  
                      emailError = null;
                      formKey.currentState!.validate();
                    }
                  },
                  validator: (value) {
                    if (value != null &&
                        !RegExp(
                          r'^[\w.+-]+@[a-zA-Z\d.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(value)) {
                      return "Invalid email address";
                    } else {
                      return emailError;
                    }
                  },
                ),
                PasswordField(
                  label: Text("Password"),
                  controller: passwordController,
                  validator: (value) => lengthValidator(value, "Password"),
                ),
                PasswordField(
                  label: Text("Repeat Password"),
                  controller: repeatPasswordController,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Passwords do not match";
                    } else {
                      return null;
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        usernameError = null;
                        emailError = null;
                        if (!formKey.currentState!.validate()) return;
                        var response = await AuthService.signup(
                          SignupRequest(
                            nameController.text,
                            surnameController.text,
                            emailController.text,
                            usernameController.text,
                            passwordController.text,
                          ),
                        );
                        if (response.success && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) {
                                return VerifyScreen(
                                  email: emailController.text,
                                );
                              },
                            ),
                          );
                        } else {
                          usernameError = response.error?.errors['Username']?[0];
                          emailError = response.error?.errors['Email']?[0];
                          formKey.currentState!.validate();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text("Signup"),
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
