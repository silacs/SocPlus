import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About"),),
      body: Center(child: Text("App made by Giorgi Silagadze for TBC Techschool")),
    );
  }
}