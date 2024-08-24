import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '/constants/enum.dart';
import '/gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

PageController staffListingcontroller = PageController();
StaffListingPageProvider staffListingPageProvider = StaffListingPageProvider();

class StaffListing extends StatefulWidget {
  const StaffListing({super.key});

  @override
  State<StaffListing> createState() => _StaffListingState();
}

class _StaffListingState extends State<StaffListing> {
  List<StaffDataModel> staffDataList = [];
  String? companyUniqueID;

  Future getStaffInfo() async {
    try {
      FireStoreProvider provider = FireStoreProvider();

      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      await FireStoreProvider().getCompanyDocInfo(cid: cid).then((companyInfo) {
        if (companyInfo != null && companyInfo.exists) {
          setState(() {
            companyUniqueID = companyInfo['company_unique_id'];
          });
        }
      });
      if (cid != null) {
        setState(() {
          staffDataList.clear();
        });
        final result = await provider.getStaffListing(
          cid: cid,
        );

        if (result != null && result.docs.isNotEmpty) {
          for (var element in result.docs) {
            StaffDataModel model = StaffDataModel();
            model.userName = element["staff_name"] ?? "";
            model.phoneNo = element["phone_no"] ?? "";
            model.userid = element["user_login_id"] ?? "";
            model.password = element["password"] ?? "";

            var directory = await getApplicationDocumentsDirectory();
            model.profileImg = path.join(
              directory.path,
              'staff',
              element.id,
            );

            model.docID = element.id;
            StaffPermissionModel permissionModel = StaffPermissionModel();
            permissionModel.product = element["permission"]["product"];
            permissionModel.category = element["permission"]["category"];
            permissionModel.customer = element["permission"]["customer"];
            permissionModel.orders = element["permission"]["orders"];
            permissionModel.estimate = element["permission"]["estimate"];
            permissionModel.billofsupply =
                element["permission"]["billofsupply"];
            model.permission = permissionModel;
            setState(() {
              staffDataList.add(model);
            });
          }

          return staffDataList;
        }
      } else {
        return null;
      }
    } catch (e) {
      log.e(e.toString());
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  late Future staffHandler;

  changeState() {
    if (mounted) {
      setState(() {
        staffHandler = getStaffInfo();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    staffListingPageProvider.addListener(changeState);
  }

  @override
  void initState() {
    super.initState();
    staffHandler = getStaffInfo();
    staffListingPageProvider.addListener(changeState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            homeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Staff"),
        actions: [
          IconButton(
            onPressed: () async {
              await addStaffForm(
                context,
                companyID: companyUniqueID ?? "",
              ).then((value) {
                if (value != null && value == true) {
                  setState(() {
                    staffHandler = getStaffInfo();
                  });
                }
              });
            },
            splashRadius: 20,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: staffHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: staffListingcontroller,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        staffHandler = getStaffInfo();
                      },
                      child: ListView.builder(
                        itemCount: staffDataList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                onTap: () {
                                  setState(() {
                                    crtStaffData = staffDataList[index];
                                    staffListingcontroller.animateToPage(
                                      1,
                                      duration:
                                          const Duration(milliseconds: 600),
                                      curve: Curves.linear,
                                    );
                                  });
                                },
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                    image: staffDataList[index].profileImg ==
                                            null
                                        ? null
                                        : DecorationImage(
                                            image: File(staffDataList[index]
                                                        .profileImg!)
                                                    .existsSync()
                                                ? FileImage(
                                                    File(staffDataList[index]
                                                        .profileImg!),
                                                  )
                                                : AssetImage(
                                                    Assets.images.noImage.path,
                                                  ),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                title:
                                    Text(staffDataList[index].userName ?? ""),
                                subtitle: Text(
                                  "${staffDataList[index].userid}",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing:
                                    const Icon(Icons.chevron_right_outlined),
                              ),
                              Divider(
                                height: 0,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const StaffDetails(),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        "Failed",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      snapshot.error.toString() == "null"
                          ? "Something went Wrong"
                          : snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            staffHandler = getStaffInfo();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          "Refresh",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return futureLoading(context);
          }
        },
      ),
    );
  }
}
