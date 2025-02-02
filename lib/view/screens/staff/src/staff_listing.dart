import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '/constants/constants.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            return connectionProvider.isConnected
                ? body()
                : noInternet(context);
          },
        ),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: staffHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureLoading(context);
        } else if (snapshot.hasError) {
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
          return Padding(
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
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  staffHandler = getStaffInfo();
                },
                child:
                    staffDataList.isNotEmpty ? screenView() : noData(context),
              ),
            ),
          );
        }
      },
    );
  }

  ListView screenView() {
    return ListView.builder(
      itemCount: staffDataList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              onTap: () async {
                var result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) =>
                        StaffDetails(staffDetails: staffDataList[index]),
                  ),
                );

                if (result != null) {
                  if (result) {
                    setState(() {
                      staffHandler = getStaffInfo();
                    });
                  }
                }
              },
              leading: ClipOval(
                child: CachedNetworkImage(
                  imageUrl:
                      staffDataList[index].profileImg ?? Strings.productImg,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  fit: BoxFit.cover,
                  width: 45.0,
                  height: 45.0,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              title: Text(
                staffDataList[index].userName ?? "",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: Text(
                staffDataList[index].userid ?? '',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
              ),
              trailing: const Icon(Icons.keyboard_arrow_right_outlined),
            ),
            Divider(
              height: 0,
              color: Colors.grey.shade300,
            ),
          ],
        );
      },
    );
  }

  Padding noData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(
              Assets.emptyList3,
              height: 200,
              width: 200,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "No Staffs",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              "You have not create any staff, so first you have create staff using add staff button below",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
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
                icon: const Icon(Icons.add),
                label: const Text("Add Staff"),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    staffHandler = getStaffInfo();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Staff"),
      actions: [
        IconButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final connectionProvider =
                  Provider.of<ConnectionProvider>(context, listen: false);
              if (connectionProvider.isConnected) {
                AccountValid.accountValid(context);

                staffHandler = getStaffInfo();
                staffListingPageProvider.addListener(changeState);
              }
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final connectionProvider =
                  Provider.of<ConnectionProvider>(context, listen: false);
              connectionProvider.addListener(() {
                if (connectionProvider.isConnected) {
                  AccountValid.accountValid(context);

                  staffHandler = getStaffInfo();
                  staffListingPageProvider.addListener(changeState);
                }
              });
            });
          },
          icon: const Icon(Icons.refresh),
        ),
        Provider.of<ConnectionProvider>(context, listen: false).isConnected
            ? IconButton(
                onPressed: () async {
                  try {
                    loading(context);
                    await LocalService.checkCount(type: ProfileType.staff)
                        .then((value) async {
                      Navigator.pop(context);
                      if (value) {
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
                      } else {
                        snackbar(context, false, "Reached max staff count");
                      }
                    });
                  } on Exception catch (e) {
                    Navigator.pop(context);
                    snackbar(context, false, e.toString());
                  }
                },
                splashRadius: 20,
                icon: const Icon(
                  Icons.add,
                ),
              )
            : Container()
      ],
    );
  }

  Future getStaffInfo() async {
    try {
      FireStore provider = FireStore();

      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      await FireStore().getCompanyDocInfo(cid: cid).then((companyInfo) {
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
            model.profileImg = element["profile_img"] ?? "";

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

            DeviceModel deviceModel = DeviceModel();
            deviceModel.deviceId = element["device"]["device_id"];
            deviceModel.deviceName = element["device"]["device_name"];
            deviceModel.modelName = element["device"]["model_name"];

            model.deviceModel = deviceModel;

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
      snackbar(context, false, e.toString());
      return null;
    }
  }

  Future? staffHandler;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);

        staffHandler = getStaffInfo();
        staffListingPageProvider.addListener(changeState);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);

          staffHandler = getStaffInfo();
          staffListingPageProvider.addListener(changeState);
        }
      });
    });
  }

  List<StaffDataModel> staffDataList = [];
  String? companyUniqueID;
}
