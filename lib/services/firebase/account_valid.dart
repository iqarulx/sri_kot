import 'package:flutter/material.dart';
import 'package:sri_kot/constants/constants.dart';
import 'package:sri_kot/services/database/localdb.dart';
import 'package:sri_kot/services/firebase/firestore_provider.dart';
import 'package:sri_kot/utils/src/utilities.dart';

import '../../view/auth/auth.dart';
import '../sql/sql.dart';

class AccountValid {
  static Future accountValid(context) async {
    try {
      var result = await FireStoreProvider().checkExpiry(
          uid: await LocalDB.fetchInfo(type: LocalData.companyid),
          type: UserType.staff);
      if (!result) {
        await LocalDB.logout().then((result) {
          final dbHelper = DatabaseHelper();
          dbHelper.clearCategory();
          dbHelper.clearCustomer();
          dbHelper.clearProducts();
          dbHelper.clearBillRecords();
          snackbar(context, false, "Company expired. Please renew your plan");
          if (result) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Auth(),
              ),
            );
          }
        });
      }
    } on Exception catch (e) {
      print(e);
    }
  }
}
