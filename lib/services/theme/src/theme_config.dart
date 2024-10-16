import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeConfig {
  ThemeData theme1 = ThemeData(
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
    scaffoldBackgroundColor: const Color(0xffEEEEEE),
  );
  ThemeData theme2 = ThemeData(
    primaryColor: const Color(0xff9A161F),
    useMaterial3: false,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xff9A161F),
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
    scaffoldBackgroundColor: const Color(0xffF4EFEA),
  );
  ThemeData theme3 = ThemeData(
    primaryColor: const Color(0xff7b9acc),
    useMaterial3: false,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xff7b9acc),
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
    scaffoldBackgroundColor: const Color(0xffFCF6F5),
  );
  ThemeData theme4 = ThemeData(
    primaryColor: const Color(0xff755139),
    useMaterial3: false,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xff755139),
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
    scaffoldBackgroundColor: const Color(0xffF2EDD7),
  );
}
