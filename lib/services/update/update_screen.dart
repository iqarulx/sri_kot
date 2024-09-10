import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sri_kot/utils/src/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({super.key});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  openStore() async {
    if (Platform.isAndroid) {
      final Uri url = Uri.parse(
          'https://play.google.com/store/apps/details?id=com.srisoftwarez.sri_kot');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } else {
      // final Uri url =
      //     Uri.parse('https://apps.apple.com/app/shop-maintenance/id6464564417');
      // if (!await launchUrl(url)) {
      //   throw Exception('Could not launch $url');
      // }
      snackBarCustom(context, false, "iOS currently not supported");
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/update.png',
            height: 250,
            width: 250,
          ),
          Text(
            "App Update Available",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: const Color(0xff003049),
                fontSize: 21,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Please update app in Playstore / Appstore",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: const Color(0xff003049),
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              openStore();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
