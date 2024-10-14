import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'provider/provider.dart';
import 'services/services.dart';

Future<bool> checklogin() async {
  return LocalDB.checklogin();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await checklogin();
  var login = result;
  final appUpdate = await UpdateService.isUpdateAvailable();
  var currentTheme = await LocalDB.getTheme();
  if (currentTheme == null) {
    await LocalDB.setTheme(theme: 'original');
  }
  changeThemeApp.toggletab(await LocalDB.getTheme() ?? 'original');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConnectionProvider(),
        )
      ],
      child: MyApp(
        login: login,
        appUpdate: appUpdate,
      ),
    ),
  );
}
