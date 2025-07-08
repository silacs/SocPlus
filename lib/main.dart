import 'package:flutter/material.dart';
import 'package:socplus/screens/welcome_screen.dart';
import 'package:socplus/screens/widget_tree.dart';
import 'package:socplus/services/auth_service.dart';


import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const SocPlus());
}

class SocPlus extends StatelessWidget {
  const SocPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(future: AuthService.refreshToken, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return WidgetTree();
        } else {
          return WelcomeScreen();
        }
      },),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // pageTransitionsTheme: const PageTransitionsTheme(
        //   builders: <TargetPlatform, PageTransitionsBuilder>{
        //     TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        //   },
        // ),
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
