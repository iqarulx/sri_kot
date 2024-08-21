import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import '/app/view/app.dart';
import 'provider/localdb.dart';

Future<bool> checklogin() async {
  LocalDbProvider localdb = LocalDbProvider();
  return localdb.checklogin();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MyApp(
      login: await checklogin(),
    ),
  );
}
