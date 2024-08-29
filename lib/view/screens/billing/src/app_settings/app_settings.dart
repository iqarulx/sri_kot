import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '/gen/assets.gen.dart';
import '/services/services.dart';
import '/view/screens/screens.dart';
import '/constants/enum.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  int crtBillingTab = 1;
  initFn() async {
    await LocalDbProvider().getBillingIndex().then((value) async {
      if (value != null) {
        setState(() {
          crtBillingTab = value;
        });
      } else {
        await LocalDbProvider().changeBilling(1);
        setState(() {
          crtBillingTab = 1;
        });
      }
    });
  }

  syncNow() async {
    await showModalBottomSheet(
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return const Backup();
        }).then((value) {
      if (value != null) {
        syncNowData();
      }
    });
  }

  Future<void> syncNowData() async {
    final cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
    final result = await FireStoreProvider().getFiles(cid: cid);

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Paths for each file type
    final paths = <String, List<Map<String, String>>>{};

    // Step 1: Clear files in the directory
    final folder = Directory(directory.path);
    if (await folder.exists()) {
      final files = folder.listSync(recursive: true);
      for (var file in files) {
        if (file is File) {
          await file.delete();
        }
      }
    }

    // Helper function to create a folder if it doesn't exist
    Future<void> createFolder(String folderName) async {
      final path = Directory('${directory.path}/$folderName');
      if (!await path.exists()) {
        await path.create();
      }
    }

    // Step 2: Create folders and download files
    for (var type in result.keys) {
      final folderName = type;
      await createFolder(folderName);

      paths[type] = [];

      for (var file in result[type]!) {
        final id = file['id']!;
        final url = file['url'];
        final filePath = url != null && url.isNotEmpty
            ? '${directory.path}/$folderName/$id'
            : '';

        if (url != null && url.isNotEmpty) {
          // Download the file
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);

            // Save path info
            paths[type]!.add({'id': id, 'path': filePath});
          } else {
            print('Failed to download file from $url');
            // Save path info with empty path
            paths[type]!.add({'id': id, 'path': ''});
          }
        } else {
          // URL is empty or null, save only the ID with empty path
          paths[type]!.add({'id': id, 'path': ''});
        }
      }
    }

    // Step 3: Save the JSON file
    final jsonFile = File('${directory.path}/file_paths.json');
    final jsonString = jsonEncode(paths);
    await jsonFile.writeAsString(jsonString);

    print('Sync completed and JSON file saved.');
  }

  @override
  void initState() {
    super.initState();
    initFn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECECEC),
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("App Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Billing Page",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              crtBillingTab = 1;
                              LocalDbProvider().changeBilling(1);
                            });
                          },
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: crtBillingTab == 1
                                  ? Colors.grey.shade100
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Center(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Assets.billing2.image(
                                          height: 240,
                                          fit: BoxFit.contain,
                                        )),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: crtBillingTab == 1
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: crtBillingTab == 1
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              crtBillingTab = 2;
                              LocalDbProvider().changeBilling(2);
                            });
                          },
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: crtBillingTab == 2
                                  ? Colors.grey.shade100
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Assets.billing1.image(
                                        height: 240,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: crtBillingTab == 2
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: crtBillingTab == 2
                                        ? const Center(
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Sync Now",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      syncNow();
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xff003049),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.cloud_upload,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Sync Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
