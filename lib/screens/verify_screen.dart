import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socplus/models/send_code_request.dart';
import 'package:socplus/models/verify_request.dart';
import 'package:socplus/screens/login_screen.dart';
import 'package:socplus/services/auth_service.dart';
import 'package:socplus/widgets/styled_text_field.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  const VerifyScreen({super.key, required this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final key = GlobalKey<FormState>();
  int seconds = 60;
  Timer? timer;

  final TextEditingController codeController = TextEditingController();
  String? codeError;

  @override
  void dispose() {
    super.dispose();
    codeController.dispose();
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Form(
            key: key,
            child: Column(
              spacing: 10,
              children: [
                SizedBox(height: 20),
                StyledTextField(
                  controller: codeController,
                  label: Text("Code"),
                  errorText: codeError,
                  onChanged: (value) {
                    codeError = null;
                    key.currentState!.validate();
                  },
                  validator: (value) {
                    if (value == null) return null;
                    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                      return 'The code must be 6 digits';
                    }
                    return codeError;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed:
                          seconds > 0
                              ? null
                              : () async {
                                var res = await AuthService.sendCode(
                                  SendCodeRequest(widget.email),
                                );
                                if (!res.success && context.mounted) {
                                  if (res.error?.errors['Email']?[0] == null) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(SnackBar(content: Text("")));
                                  } else {
                                    codeError = res.error!.errors['Email'][0];
                                    key.currentState!.validate();
                                  }
                                }
                                seconds = 60;
                                timer = Timer.periodic(Duration(seconds: 1), (
                                  timer,
                                ) {
                                  if (seconds > 0) {
                                    setState(() {
                                      seconds--;
                                    });
                                  } else {
                                    timer.cancel();
                                  }
                                });
                              },
                      child: Text(
                        "Resend Code ${seconds > 0 ? "($seconds)" : ''}",
                      ),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (!key.currentState!.validate()) return;
                        var res = await AuthService.verify(
                          VerifyRequest(widget.email, codeController.text),
                        );
                        if (res.success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Successfully verified email"),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          Timer(Duration(seconds: 3), () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                              (route) => route.isFirst,
                            );
                          });
                        } else {
                          codeError = res.error?.errors['Code']?[0];
                          codeError =
                              codeError ?? res.error?.errors['Email']?[0];
                          key.currentState!.validate();
                          setState(() {});
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text("Verify"),
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
