import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/services/firebase/messaging.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import 'access_code_modal.dart';
import 'modal.dart';

showTestMode(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (builder) {
      return const Modal(
        title: "Redeem Code",
        content:
            "If you want to access app previously. A unique code\n send to admin. You must enter it to access the app.",
        type: ModalType.info,
      );
    },
  ).then((value) async {
    if (value != null) {
      if (value) {
        loading(context);
        await AccessCode.createAccessCode().then((value) async {
          if (value.isNotEmpty) {
            await Messaging.sendCodeToAdmin(
                code: value["code"], docId: value["doc_id"]);
            Navigator.pop(context);
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (builder) {
                return AccessCodeModal(code: value["code"]);
              },
            ).then((popupValue) async {
              if (popupValue != null) {
                if (popupValue) {
                  loading(context);
                  await AccessCode.expireCode(code: value["code"])
                      .then((value) async {
                    Navigator.pop(context);
                    await LocalDB.setTestMode();
                    snackbar(context, true, "Test Mode Enabled");
                  });
                }
              }
            });
          }
        });
      }
    }
  });
}
