import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../../../../provider/provider.dart';
import '../../../../ui/ui.dart';

class Backup extends StatefulWidget {
  const Backup({super.key});

  @override
  State<Backup> createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  File? file;
  int numberOfLogs = 0;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        appBar: appbar(context),
        bottomNavigationBar: bottomAppbar(context),
        body: ListView(
          children: [
            GestureDetector(
              onTap: () async {
                if (file == null) {
                  FilePickerProviderExcel().uploadSql().then((value) async {
                    if (value != null) {
                      final fileContent = await value.readAsString();
                      final logCount = fileContent.split('\n').length;

                      setState(() {
                        file = value;
                        numberOfLogs = logCount;
                      });
                    }
                  });
                } else {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return const Modal(
                        title: "Replace File",
                        content: "Are you want to replace file?",
                        type: ModalType.danger,
                      );
                    },
                  ).then((value) {
                    if (value != null) {
                      if (value) {
                        setState(() {
                          file = null;
                          numberOfLogs = 0;
                        });

                        FilePickerProviderExcel()
                            .uploadSql()
                            .then((value) async {
                          if (value != null) {
                            final fileContent = await value.readAsString();
                            final logCount = fileContent.split('\n').length;

                            setState(() {
                              file = value;
                              numberOfLogs = logCount;
                            });
                          }
                        });
                      }
                    }
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        file == null
                            ? CupertinoIcons.cloud_upload
                            : CupertinoIcons.checkmark_alt_circle,
                        size: 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        file == null ? "Upload File" : "File Uploaded",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (file != null)
                        Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Click tab to replace file",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (file != null)
              Center(
                  child: Text("Number of logs: $numberOfLogs",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.black))),
          ],
        ),
      ),
    );
  }

  BottomAppBar bottomAppbar(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.all(5),
      color: Colors.white,
      child: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff2F4550),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "Backup Now",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              splashRadius: 20,
              constraints: const BoxConstraints(
                maxWidth: 40,
                maxHeight: 40,
                minWidth: 40,
                minHeight: 40,
              ),
              padding: const EdgeInsets.all(0),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        "Backup Data",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
