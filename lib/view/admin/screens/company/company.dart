import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_kot/model/model.dart';
import 'package:sri_kot/services/local/local_service.dart';
import 'package:sri_kot/utils/utlities.dart';
import 'package:sri_kot/view/ui/commonwidget.dart';
import '../../../../services/firebase/firestore_provider.dart';
import '../../utils/show_modal.dart';

class Company extends StatefulWidget {
  final String uid;

  const Company({super.key, required this.uid});

  @override
  State<Company> createState() => _CompanyState();
}

class _CompanyState extends State<Company> {
  Future? companyDetailsHanlder;
  ProfileModel companyData = ProfileModel();
  DeviceModel deviceData = DeviceModel();
  List<UserAdminModel> userData = [];
  int totalUsers = 0;
  List<StaffDataModel> staffData = [];
  int totalStaff = 0;
  DateTime? opened, created, lastLogin;
  String? uid;
  bool invoiceEntry = false;

  @override
  void initState() {
    companyDetailsHanlder = companyDetails();
    super.initState();
  }

  Future companyDetails() async {
    try {
      FireStoreProvider provider = FireStoreProvider();
      final result = await provider.getCompanyDetails(uid: widget.uid);

      if (result.isNotEmpty) {
        if (result["company_id"].isNotEmpty) {
          setState(() {
            uid = result["company_id"];
          });
        }
        if (result["company"].isNotEmpty) {
          var data = result["company"];
          setState(() {
            companyData.address = data["address"];
            companyData.pincode = data["pincode"];
            companyData.city = data["city"];
            companyData.state = data["state"];
            companyData.companyName = data["company_name"];
            companyData.companyLogo = data["company_logo"];
            companyData.contact = {
              "phone_no": data["contact"]["phone_no"],
              "mobile_no": data["contact"]["mobile_no"]
            };
            companyData.userLoginId = data["user_login_id"];
            companyData.password = data["password"];
            deviceData.deviceName = data["device"]["device_name"];
            deviceData.modelName = data["device"]["model_name"];
            deviceData.deviceId = data["device"]["device_id"];
            deviceData.lastlogin = data["device"]["last_login"]?.toDate();
            created = data["created"]?.toDate();
            opened = data["opened"]?.toDate();
            invoiceEntry = data["invoice_entry"];
          });

          var user = result["user"];
          setState(() {
            totalUsers = user.length;
          });
          for (var item in user) {
            UserAdminModel userAdminModel = UserAdminModel();
            userAdminModel.adminName = item["admin_name"];
            userAdminModel.phoneNo = item["phone_no"];
            userAdminModel.imageUrl = item["image_url"];

            setState(() {
              userData.add(userAdminModel);
            });
          }

          var staff = result["staff"];
          setState(() {
            totalStaff = staff.length;
          });
          for (var item in staff) {
            StaffDataModel staffDataModel = StaffDataModel();
            staffDataModel.userName = item["staff_name"];
            staffDataModel.phoneNo = item["phone_no"];
            staffDataModel.profileImg = item["profile_img"];

            setState(() {
              staffData.add(staffDataModel);
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: body(),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: companyDetailsHanlder,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    companyData.companyName ?? '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "UserId : ${companyData.userLoginId ?? '---'}",
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Password : ${companyData.password ?? '---'}",
                                  )
                                ],
                              ),
                            ),
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                companyData.companyLogo ??
                                    "https://img.icons8.com/?size=160&id=95101&format=png",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Contact Details",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Phone : ${companyData.contact!["phone_no"]}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Mobile: ${companyData.contact!["mobile_no"]}",
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Address",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Address : ${companyData.address}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "City: ${companyData.city}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "State: ${companyData.state}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Pincode: ${companyData.pincode}",
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Device Details",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Model Name : ${deviceData.modelName ?? '---'}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Device Name: ${deviceData.deviceName ?? '---'}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Device Id: ${deviceData.deviceId ?? '---'}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Last Login: ${deviceData.lastlogin != null ? DateFormat('dd-MM-yyyy hh:mm:ss a').format(deviceData.lastlogin!) : '---'}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                deleteDevice();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xff003049),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.delete_simple,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Delete Device",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "App Usage",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Created : ${created != null ? DateFormat('dd-MM-yyyy hh:mm:ss a').format(created!) : '---'}",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Opened : ${opened != null ? DateFormat('dd-MM-yyyy hh:mm:ss a').format(opened!) : '---'}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "User Details ($totalUsers)",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: totalUsers,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          userData[index].imageUrl ??
                                              "https://img.icons8.com/?size=160&id=95101&format=png",
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userData[index].adminName ?? '---',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            userData[index].phoneNo ?? '---',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider()
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Staff Details ($totalStaff)",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: totalStaff,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          staffData[index].profileImg ??
                                              "https://img.icons8.com/?size=160&id=95101&format=png",
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            staffData[index].userName ?? '---',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            staffData[index].phoneNo ?? '---',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider()
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Change Settings",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Text(
                                "Invoice Entry",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: CupertinoSwitch(
                                value: invoiceEntry,
                                onChanged: (value) async {
                                  setState(() {
                                    invoiceEntry = value;
                                  });
                                  await LocalService.updateInvoice(
                                    uid: uid ?? '',
                                    invoiceEntry: value,
                                  ).then((value) {
                                    snackBarCustom(
                                      context,
                                      true,
                                      "Invoice Updated",
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  deleteDevice() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const ShowModal(
        title: "Delete Device",
        content: "This action can't be undone. Are you sure want to delete?",
      ),
    ).then((value) async {
      if (value != null) {
        if (value) {
          futureLoading(context);
          await LocalService.deleteDevice(uid: uid ?? '').then((value) {
            Navigator.pop(context);
            snackBarCustom(context, true, "Device Deleted");
          }).catchError((error) {
            Navigator.pop(context);
            snackBarCustom(context, false, error.toString());
          });
        }
      }
    });
  }
}
