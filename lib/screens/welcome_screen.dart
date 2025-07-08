import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socplus/screens/login_screen.dart';
import 'package:socplus/screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.surface,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarIconBrightness: Brightness.light,
        )
      );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 40,
            children: [
              Text(
                "Welcome to SocPlus",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
              ),
              Text(
                "Sign up to get started, or login if you already have an account.",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (builder) {
                        return SignupScreen();
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("Sign up"),
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (builder) {
                        return LoginScreen();
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("Login"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
