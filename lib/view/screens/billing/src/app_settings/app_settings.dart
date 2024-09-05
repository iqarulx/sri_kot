import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/src/utilities.dart';
import '/view/ui/ui.dart';
import '/provider/provider.dart';
import '/gen/assets.gen.dart';
import '/services/services.dart';
import '/constants/constants.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  int crtBillingTab = 1;
  String? lastSynced;

  initFn() async {
    await LocalDB.getBillingIndex().then((value) async {
      if (value != null) {
        setState(() {
          crtBillingTab = value;
        });
      } else {
        await LocalDB.changeBilling(1);
        setState(() {
          crtBillingTab = 1;
        });
      }
    });

    await LocalDB.getLastSync().then((value) async {
      if (value != null) {
        lastSynced = await LocalService.parseDate(value);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initFn();
  }

  syncNow() async {
    loading(context);
    // Check initial connection and perform actions
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    if (connectionProvider.isConnected) {
      FireStoreProvider firebase = FireStoreProvider();
      await firebase
          .productListing(
              cid: await LocalDB.fetchInfo(type: LocalData.companyid))
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          LocalService.syncProducts(
            productData: value.docs,
            cid: await LocalDB.fetchInfo(type: LocalData.companyid),
          );
        }
      });

      await firebase
          .categoryListing(
              cid: await LocalDB.fetchInfo(type: LocalData.companyid))
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          LocalService.syncCategory(
            categoryData: value.docs,
            cid: await LocalDB.fetchInfo(
              type: LocalData.companyid,
            ),
          );
        }
      });

      await firebase
          .customerListing(
              cid: await LocalDB.fetchInfo(type: LocalData.companyid))
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          LocalService.syncCustomer(
            customerData: value.docs,
            cid: await LocalDB.fetchInfo(type: LocalData.companyid),
          );
        }
      });

      Navigator.pop(context);
      await LocalDB.setLastSync().then((value) {
        snackbar(context, true, "Successfully data synced");
        initFn();
      });
    } else {
      Navigator.pop(context);
      snackbar(context, false, "You need internet to sync your data");
    }
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
                              LocalDB.changeBilling(1);
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
                              LocalDB.changeBilling(2);
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
                // const Divider(),
                // const SizedBox(
                //   height: 10,
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: GestureDetector(
                //     onTap: () {
                //       syncNow();
                //     },
                //     child: Container(
                //       height: 40,
                //       decoration: BoxDecoration(
                //         color: const Color(0xff003049),
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       child: const Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(
                //             CupertinoIcons.cloud_upload,
                //             color: Colors.white,
                //           ),
                //           SizedBox(
                //             width: 5,
                //           ),
                //           Text(
                //             "Sync Now",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: GestureDetector(
                //     onTap: () async {
                //       await FastCachedImageConfig.clearAllCachedImages();
                //       snackBarCustom(context, true, "Cache cleared");
                //     },
                //     child: Container(
                //       height: 40,
                //       decoration: BoxDecoration(
                //         color: const Color(0xff003049),
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       child: const Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(
                //             CupertinoIcons.trash,
                //             color: Colors.white,
                //           ),
                //           SizedBox(
                //             width: 5,
                //           ),
                //           Text(
                //             "Clear cache",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () async {
              loading(context);
              await LocalService.syncNow().then((value) {
                Navigator.pop(context);
                if (value) {
                  snackbar(context, true, "Successfully bills are uploaded");
                } else {
                  snackbar(context, false, "An error occured");
                }
              });
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.cloud_upload,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Upload Local Bills",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.forward),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              syncNow();
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.arrow_3_trianglepath,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sync Now",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text("Last Sync : ${lastSynced ?? '--:--:--'}",
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.forward),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return const Modal(
                    title: "Clear Cache",
                    content:
                        "If you clear cache your local data will be removed! Are you sure want to clear?",
                    type: ModalType.danger,
                  );
                },
              ).then((value) async {
                if (value != null) {
                  if (value) {
                    final dbHelper = DatabaseHelper();
                    dbHelper.clearCategory();
                    dbHelper.clearCustomer();
                    dbHelper.clearProducts();
                    snackbar(context, true, "Cache cleared");
                  }
                }
              });
            },
            child: Container(
              height: 60,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.trash,
                          size: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Clear Cache",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(CupertinoIcons.forward),
                ],
              ),
            ),
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          // GestureDetector(
          //   onTap: () async {
          //     await showModalBottomSheet(
          //       backgroundColor: Colors.white,
          //       useSafeArea: true,
          //       shape: RoundedRectangleBorder(
          //         side: BorderSide.none,
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       isScrollControlled: true,
          //       context: context,
          //       builder: (builder) {
          //         return const DeletedItems();
          //       },
          //     ).then((onValue) {
          //       if (onValue != null) {}
          //     });
          //   },
          //   child: Container(
          //     height: 60,
          //     padding: const EdgeInsets.all(10),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: Row(
          //             children: [
          //               const Icon(
          //                 CupertinoIcons.refresh,
          //                 size: 30,
          //               ),
          //               const SizedBox(
          //                 width: 10,
          //               ),
          //               Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     "Recover Deleted Items",
          //                     style: Theme.of(context)
          //                         .textTheme
          //                         .titleSmall!
          //                         .copyWith(
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                   ),
          //                 ],
          //               ),
          //             ],
          //           ),
          //         ),
          //         const Icon(CupertinoIcons.forward),
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // GestureDetector(
          //   onTap: () async {
          //     await showModalBottomSheet(
          //       backgroundColor: Colors.white,
          //       useSafeArea: true,
          //       shape: RoundedRectangleBorder(
          //         side: BorderSide.none,
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       isScrollControlled: true,
          //       context: context,
          //       builder: (builder) {
          //         return const Backup();
          //       },
          //     ).then((onValue) {
          //       if (onValue != null) {}
          //     });
          //   },
          //   child: Container(
          //     height: 60,
          //     padding: const EdgeInsets.all(10),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: Row(
          //             children: [
          //               const Icon(
          //                 CupertinoIcons.cloud_upload,
          //                 size: 30,
          //               ),
          //               const SizedBox(
          //                 width: 10,
          //               ),
          //               Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     "Upload Backup",
          //                     style: Theme.of(context)
          //                         .textTheme
          //                         .titleSmall!
          //                         .copyWith(
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                   ),
          //                 ],
          //               ),
          //             ],
          //           ),
          //         ),
          //         const Icon(CupertinoIcons.forward),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
