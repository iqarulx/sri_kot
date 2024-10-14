import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../../theme/theme_change.dart';
import '/theme/theme.dart';
import '/services/services.dart';
import '/app/src/life_cycle/app_lifecycle.dart';
import '/view/screens/screens.dart';
import '../../../view/auth/src/auth/auth.dart';

ChangeThemeApp changeThemeApp = ChangeThemeApp();

class MyApp extends StatefulWidget {
  final bool login;
  final bool appUpdate;
  const MyApp({
    super.key,
    required this.login,
    required this.appUpdate,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData appTheme = AppThemeUI().theme1;
  getcurrentTheme() {
    setState(() {
      if (changeThemeApp.theme.toString().toLowerCase() == "theme1") {
        appTheme = AppThemeUI().theme1;
      } else if (changeThemeApp.theme.toString().toLowerCase() == "theme2") {
        appTheme = AppThemeUI().theme2;
      } else if (changeThemeApp.theme.toString().toLowerCase() == "theme3") {
        appTheme = AppThemeUI().theme3;
      } else if (changeThemeApp.theme.toString().toLowerCase() == "theme4") {
        appTheme = AppThemeUI().theme4;
      } else {
        appTheme = AppThemeUI().theme1;
      }
    });
  }

  @override
  void initState() {
    getcurrentTheme();
    changeThemeApp.addListener(themeChanger);
    super.initState();
  }

  @override
  void dispose() {
    changeThemeApp.addListener(themeChanger);
    super.dispose();
  }

  themeChanger() {
    if (mounted) {
      getcurrentTheme();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: ToastificationWrapper(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sri KOT',
          theme: appTheme,
          home: widget.appUpdate
              ? widget.login
                  ? const UserHome()
                  : const Auth()
              : const AppUpdateScreen(),
        ),
      ),
    );
  }
}
