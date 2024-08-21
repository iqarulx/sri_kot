import 'package:file_service/file_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_kot/gen/assets.gen.dart';
import 'package:sri_kot/services/firebase/firestore_provider.dart';
import 'package:sri_kot/utils/utlities.dart';
import '../../../../provider/localdb.dart';

import '../../homelanding.dart';

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
    try {
      print("Siii");
      // snackBarCustom(context, true, "File sync started");
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      var result = await FireStoreProvider().getFiles(cid: cid);
      // await FileService.clearDirectory();

      if (result.isNotEmpty) {
        print("Hiii");

        for (var item in result) {
          var url = item["url"] ?? '';
          var typeString = item["type"] ?? 'none';
          var id = item["id"];

          Type type;
          switch (typeString) {
            case "user":
              type = Type.user;
              break;
            case "company":
              type = Type.company;
              break;
            case "staff":
              type = Type.staff;
              break;
            case "product":
              type = Type.product;
              break;
            default:
              type = Type.none;
          }
          print("$url $type $id");

          // await FileService.syncFiles(fileUrl: url, type: type, id: id);
        }
      }
      snackBarCustom(context, true, "File Sync Completed");
    } catch (e) {
      print('Error in syncNow: $e');
    }
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
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
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
