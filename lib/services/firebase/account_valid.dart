import 'dart:async';

import 'package:flutter/cupertino.dart';
import '/view/auth/auth.dart';
import '/constants/constants.dart';
import '/log/log.dart';
import '/services/services.dart';
import '/utils/src/utilities.dart';
import '/purchase/purchase.dart';
import '/view/screens/screens.dart';

class AccountValid {
  static Future accountValid(context) async {
    try {
      bool userExist = await FireStore().checkUser();
      if (userExist) {
        bool freeTrialResult = await LocalService.checkTrialEnd(
            uid: await LocalDB.fetchInfo(type: LocalData.companyid));
        bool isAdmin = await LocalDB.fetchInfo(type: LocalData.isAdmin);

        if (freeTrialResult) {
          snackbar(
              context, false, "Free trial expired. Please purchase a plan");

          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => const Purchase(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => const UserHome(),
              ),
            );
          }
        } else {
          var result = await FireStore().checkExpiry(
              uid: await LocalDB.fetchInfo(type: LocalData.companyid),
              type: UserType.staff);
          if (!result) {
            snackbar(context, false, "Company expired. Please renew your plan");
            if (isAdmin) {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => const Purchase(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => const UserHome(),
                ),
              );
            }
          }
        }
      } else {
        snackbar(context, false, "Security reasons for logout");

        await LocalDB.logout().then((result) async {
          final dbHelper = DatabaseHelper();
          dbHelper.clearCategory();
          dbHelper.clearCustomer();
          dbHelper.clearProducts();
          dbHelper.clearBillRecords();

          if (result) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => const Auth(),
              ),
            );
          }
        });
      }
    } on Exception catch (e) {
      Log.addLog("${DateTime.now()} : ${e.toString()}");
    }
  }
}
