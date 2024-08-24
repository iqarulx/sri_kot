import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import '/app/view/app.dart';
import 'provider/localdb.dart';

Future<List> checklogin() async {
  LocalDbProvider localdb = LocalDbProvider();
  return localdb.checklogin();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await checklogin();
  var login = result[0];
  var isSuperAdmin = result[1] == 1 ? true : false;

  runApp(
    MyApp(
      login: login,
      isSuperAdmin: isSuperAdmin,
    ),
  );
}
