import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';

loading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                "Please wait...",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

snackbar(context, bool isSuccess, String msg) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      content: Row(
        children: [
          Icon(
            isSuccess
                ? CupertinoIcons.checkmark_circle
                : CupertinoIcons.clear_circled,
            color: Colors.white,
          ),
          const SizedBox(
            width: 8,
          ),
          Flexible(
            child: Text(
              msg.toString(),
            ),
          ),
        ],
      ),
    ),
  );
}

downloadFileSnackBarCustom(context,
    {required bool isSuccess, required String msg, required String path}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      content: Text(
        msg.toString(),
      ),
      action: SnackBarAction(
        textColor: Colors.white,
        label: "Open",
        onPressed: () async {
          try {
            await OpenFile.open(path);
          } catch (e) {
            rethrow;
          }
        },
      ),
    ),
  );
}
