import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '/view/ui/ui.dart';
import 'signin.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "Sri KOT",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          actions: [
            quickLinks(context),
          ],
        ),
        backgroundColor: Colors.white,
        body: const Signin(),
      ),
    );
  }

  IconButton quickLinks(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (builder) {
            return const PolicyDialog();
          },
        ).then((value) async {
          if (value != null) {
            if (value == 1) {
              final Uri url =
                  Uri.parse('https://srisoftwarez.com/privacypolicy.php');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            } else if (value == 2) {
              final Uri url =
                  Uri.parse('https://srisoftwarez.com/termscondition.php');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            } else {
              final Uri url =
                  Uri.parse('https://srisoftwarez.com/refundpolicy.php');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            }
          }
        });
      },
      icon: const Icon(
        CupertinoIcons.square_grid_2x2,
        color: Colors.black,
      ),
    );
  }
}
