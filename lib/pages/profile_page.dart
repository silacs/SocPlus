import 'package:flutter/material.dart';
import 'package:socplus/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(onPressed: () {
        AuthService.logOut(context);
      }, child: Text("Log out")),
    );
  }
}