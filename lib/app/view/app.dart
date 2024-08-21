import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sri_kot/app/life_cycle/app_lifecycle.dart';
import 'package:sri_kot/view/auth/landing.dart';
import 'package:sri_kot/view/screens/homelanding.dart';

import '../../bloc/login.dart';

class MyApp extends StatelessWidget {
  final bool login;
  const MyApp({super.key, required this.login});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sri KOT',
        theme: ThemeData(
          // primaryColor: const Color(0xff59C1BD),
          primaryColor: const Color(0xff003049),
          useMaterial3: false,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            backgroundColor: Color(0xff003049),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xfff1f5f9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: LoginScreen(),
      ),
    );
  }
}
