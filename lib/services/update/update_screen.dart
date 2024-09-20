import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sri_kot/constants/constants.dart';
import 'package:sri_kot/services/services.dart';
import 'package:sri_kot/utils/src/utilities.dart';
import 'package:sri_kot/view/auth/auth.dart';
import 'package:sri_kot/view/ui/src/modal.dart';
import 'package:sri_kot/view/ui/src/redeem_code_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({super.key});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  redeemCode() async {
    try {
      showDialog(
        context: context,
        builder: (builder) {
          return const Modal(
              title: "Redeem Code",
              content:
                  "If you want to access app previously. A unique code send to admin. You must enter it to access the app.",
              type: ModalType.info);
        },
      ).then((value) async {
        if (value != null) {
          if (value) {
            loading(context);
            await RedeemCode.createRedeemCode().then((value) {
              if (value.isNotEmpty) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (builder) {
                    return RedeemCodeModal(code: value);
                  },
                ).then((popupValue) async {
                  if (popupValue != null) {
                    if (popupValue) {
                      loading(context);
                      await RedeemCode.expireCode(code: value).then((value) {
                        Navigator.pop(context);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (builder) {
                          return const Auth();
                        }));
                      });
                    }
                  }
                });
              }
            });
          }
        }
      });
    } on Exception catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

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
      snackbar(context, false, "iOS currently not supported");
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
                color: Theme.of(context).primaryColor,
                fontSize: 21,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Please update app in Playstore / Appstore",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).primaryColor,
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
              backgroundColor: Theme.of(context).primaryColor,
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
          const SizedBox(
            height: 5,
          ),
          Text(
            "Or",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(
            height: 5,
          ),
          ElevatedButton(
            onPressed: () {
              redeemCode();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
            child: const Text('Redeem Pass'),
          ),
        ],
      ),
    );
  }
}
