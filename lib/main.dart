import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'in_app_purchase/purchase.dart';
import 'in_app_purchase/revenuecat.dart';
import 'services/services.dart';

Future<List> checklogin() async {
  LocalDbProvider localdb = LocalDbProvider();
  return localdb.checklogin();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Purchase.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await checklogin();
  var login = result[0];
  var isSuperAdmin = result[1] == 1 ? true : false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RevenuecatProvider()),
      ],
      child: MyApp(
        login: login,
        isSuperAdmin: isSuperAdmin,
      ),
    ),
  );
}
