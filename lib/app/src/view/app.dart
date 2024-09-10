import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/services.dart';
import '/app/src/life_cycle/app_lifecycle.dart';
import '/view/screens/screens.dart';
import '/view/admin/admin.dart';
import '/view/auth/src/auth.dart';

class MyApp extends StatelessWidget {
  final bool login;
  final bool isSuperAdmin;
  final bool appUpdate;
  const MyApp({
    super.key,
    required this.login,
    required this.isSuperAdmin,
    required this.appUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sri KOT',
        theme: ThemeData(
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
        home: appUpdate
            ? login
                ? isSuperAdmin
                    ? const AdminHome()
                    : const UserHome()
                : const Auth()
            : const AppUpdateScreen(),
      ),
    );
  }
}
