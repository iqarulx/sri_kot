import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

class StaffDetails extends StatefulWidget {
  const StaffDetails({super.key});

  @override
  State<StaffDetails> createState() => _StaffDetailsState();
}

class _StaffDetailsState extends State<StaffDetails> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            AppBar(
              iconTheme: const IconThemeData(
                color: Colors.black54,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                splashRadius: 20,
                onPressed: () {
                  setState(() {
                    staffListingcontroller.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                    );
                  });
                },
                icon: const Icon(
                  Icons.arrow_back_outlined,
                ),
              ),
              title: const Text(
                "Staff Name",
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                IconButton(
                  splashRadius: 20,
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return DeviceModal(
                          deviceModel: crtStaffData!.deviceModel!,
                        );
                      },
                    ).then((value) {
                      if (value != null) {
                        if (!value) {
                          deleteDevice();
                        }
                      }
                    });
                  },
                  icon: const Icon(CupertinoIcons.device_phone_portrait),
                ),
                IconButton(
                  splashRadius: 20,
                  onPressed: () async {
                    await confirmationDialog(
                      context,
                      title: "Alert",
                      message: "Do you want delete Staff?",
                    ).then((value) {
                      if (value != null && value == true) {
                        deleteStaff();
                      }
                    });
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        var imageResult =
                            await FilePickerProvider().showFileDialog(context);
                        if (imageResult != null) {
                          updateStaffImage(imageResult);
                        }
                      },
                      child: Center(
                        child: SizedBox(
                          height: 90,
                          width: 90,
                          child: Stack(
                            children: [
                              profileImage == null
                                  ? ClipRRect(
                                      clipBehavior: Clip.hardEdge,
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        imageUrl: crtStaffData!.profileImg ??
                                            Strings.profileImg,
                                        fit: BoxFit.cover,
                                        height: 120,
                                        width: 120,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ))
                                  : Container(
                                      height: 90,
                                      width: 90,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: profileImage!.existsSync()
                                                ? FileImage(profileImage!)
                                                : AssetImage(
                                                    Assets.images.noImage.path,
                                                  ),
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade800,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: staffKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputForm(
                            controller: fullName,
                            lableName: "Staff Name",
                            formName: "Full Name",
                            prefixIcon: Icons.person,
                            validation: (input) {
                              return FormValidation().commonValidation(
                                input: input,
                                isMandorty: true,
                                formName: "Staff Name",
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          InputForm(
                            controller: phoneNO,
                            lableName: "Phone Number",
                            formName: "Phone No",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validation: (input) {
                              return FormValidation().phoneValidation(
                                input: input.toString(),
                                isMandorty: true,
                                lableName: "Phone Number",
                              );
                            },
                          ),
                          const Text(
                            "Staff Login ID",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color(0xfff1f5f9),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: userID,
                                      decoration: const InputDecoration(
                                        hintText: "User ID",
                                        prefixIcon: Icon(
                                          Icons.alternate_email_outlined,
                                          color: Color(0xff7099c2),
                                        ),
                                      ),
                                      validator: (input) {
                                        return FormValidation()
                                            .commonValidation(
                                          input: input,
                                          isMandorty: true,
                                          formName: "userid",
                                          isOnlyCharter: false,
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    height: 55,
                                    decoration: const BoxDecoration(
                                      color: Color(0xfff1f5f9),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Center(
                                      child: Text("@$companyID"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // InputForm(
                          //   controller: userID,
                          //   lableName: "User Id",
                          //   formName: "User Id",
                          //   prefixIcon: Icons.alternate_email_outlined,
                          //   keyboardType: TextInputType.text,
                          // ),
                          InputForm(
                            controller: password,
                            lableName: "Passsword",
                            formName: "Passsword",
                            isPasswordForm: true,
                            prefixIcon: Icons.key,
                            keyboardType: TextInputType.visiblePassword,
                            validation: (input) {
                              return FormValidation().passwordValidation(
                                input: input.toString(),
                                minLength: 6,
                                maxLength: 13,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Staff Permission",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextButton.icon(
                          onPressed: () {
                            accessAlertBox();
                          },
                          label: const Text("Add Permission"),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    if (!product &&
                        !category &&
                        !customer &&
                        !orders &&
                        !estimate &&
                        permissionError != null)
                      Center(
                        child: Text(
                          permissionError ?? "",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.red,
                                  ),
                        ),
                      ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        // for (var i = 0;
                        //     i < appAccessList.length;
                        //     i++)

                        if (product)
                          Chip(
                            label: const Text(
                              "Product",
                            ),
                            onDeleted: () {
                              setState(() {
                                product = false;
                              });
                            },
                          ),
                        if (category)
                          Chip(
                            label: const Text(
                              "Category",
                            ),
                            onDeleted: () {
                              setState(() {
                                category = false;
                              });
                            },
                          ),
                        if (customer)
                          Chip(
                            label: const Text(
                              "Customer",
                            ),
                            onDeleted: () {
                              setState(() {
                                customer = false;
                              });
                            },
                          ),
                        if (orders)
                          Chip(
                            label: const Text(
                              "Orders",
                            ),
                            onDeleted: () {
                              setState(() {
                                orders = false;
                              });
                            },
                          ),
                        if (estimate)
                          Chip(
                            label: const Text(
                              "Estimate",
                            ),
                            onDeleted: () {
                              setState(() {
                                estimate = false;
                              });
                            },
                          ),
                        if (billofsupply)
                          Chip(
                            label: const Text(
                              "Bill of Supply",
                            ),
                            onDeleted: () {
                              setState(() {
                                billofsupply = false;
                              });
                            },
                          ),
                        // Container(
                        //   padding:
                        //       const EdgeInsets.symmetric(
                        //     horizontal: 10,
                        //     vertical: 6,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey.shade300,
                        //     borderRadius:
                        //         BorderRadius.circular(100),
                        //   ),
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Text(
                        //         appAccessList[i].toString(),
                        //         style: const TextStyle(
                        //           color: Colors.black,
                        //           fontSize: 13,
                        //           fontWeight:
                        //               FontWeight.bold,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                    if (!product &&
                        !category &&
                        !customer &&
                        !orders &&
                        !estimate)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("No Permission"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: fillButton(
                context,
                onTap: () {
                  updateStaff();
                },
                btnName: "Change",
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: GestureDetector(
            //     onTap: () {
            //       // loginauth();
            //       // loading(context);
            //     },
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(5),
            //         color: Theme.of(context).primaryColor,
            //       ),
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 10,
            //         vertical: 15,
            //       ),
            //       width: double.infinity,
            //       child: const Center(
            //         child: Text(
            //           "Change",
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 15,
            //             fontWeight: FontWeight.w800,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  deleteDevice() async {
    try {
      loading(context);
      await FireStore()
          .deleteStaffDevice(docID: crtStaffData!.docID ?? '')
          .then((value) {
        Navigator.pop(context);
        snackbar(context, true, "User device deleted");
      });
    } on Exception catch (e) {
      Navigator.pop(context);
      snackbar(context, true, e.toString());
    }
  }

  initFn() {
    setState(() {
      fullName.text = crtStaffData!.userName ?? "";
      phoneNO.text = crtStaffData!.phoneNo ?? "";
      List<String> data = crtStaffData!.userid!.split('@');
      companyID = data[1];
      adminuserid.text = data[0];
      userID.text = data[0];
      password.text = crtStaffData!.password ?? "";
      product = crtStaffData!.permission!.product!;
      category = crtStaffData!.permission!.category!;
      customer = crtStaffData!.permission!.customer!;
      orders = crtStaffData!.permission!.orders!;
      estimate = crtStaffData!.permission!.estimate!;
      billofsupply = crtStaffData!.permission!.billofsupply!;
    });
  }

  accessAlertBox() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AddPermission(
          product: product,
          category: category,
          customer: customer,
          orders: orders,
          estimate: estimate,
          billofsupply: billofsupply,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          product = value["product"];
          category = value["category"];
          customer = value["customer"];
          orders = value["orders"];
          estimate = value["estimate"];
          billofsupply = value["billofsupply"];
        });
      }
    });
  }

  updateStaff() async {
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (staffKey.currentState!.validate()) {
        loading(context);

        if (!product && !category && !customer && !orders && !estimate) {
          Navigator.pop(context);
          setState(() {
            permissionError = "Permission is Must";
          });
          snackbar(context, false, "Permission is Must");
        } else {
          await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
            if (cid != null) {
              StaffDataModel model = StaffDataModel();
              model.userName = fullName.text;
              model.phoneNo = phoneNO.text;
              model.userid = "${userID.text}@$companyID";
              model.password = password.text;
              StaffPermissionModel permissionModel = StaffPermissionModel();
              permissionModel.product = product;
              permissionModel.category = category;
              permissionModel.customer = customer;
              permissionModel.orders = orders;
              permissionModel.estimate = estimate;
              permissionModel.billofsupply = billofsupply;

              model.permission = permissionModel;
              await FireStore()
                  .checkStaffAlreadyExist(loginID: model.userid!)
                  .then((staffCheck) async {
                if (staffCheck != null) {
                  if (staffCheck.docs.isEmpty) {
                    await FireStore()
                        .updateStaff(
                            staffData: model, docID: crtStaffData!.docID!)
                        .then((value) {
                      Navigator.pop(context);
                      snackbar(context, true, "Successfully Update Staff");
                    });
                  } else if (staffCheck.docs.isNotEmpty &&
                      staffCheck.docs.first.id == crtStaffData!.docID) {
                    await FireStore()
                        .updateStaff(
                            staffData: model, docID: crtStaffData!.docID!)
                        .then((value) {
                      Navigator.pop(context);
                      snackbar(context, true, "Successfully Update Staff");
                    });
                  } else {
                    Navigator.pop(context);
                    snackbar(context, false, "Staff Login ID Already Exists");
                  }
                } else {
                  Navigator.pop(context);
                }
              });
            } else {
              Navigator.pop(context);
              snackbar(context, false, "Company Details Not Fetch");
            }
          });
        }
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  updateStaffImage(File image) async {
    loading(context);
    try {
      await Storage()
          .deleteImage(crtStaffData!.profileImg ?? '')
          .then((value) async {
        var downloadLink = await Storage().uploadImage(
          fileData: image,
          fileName: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: 'staff',
        );
        StaffDataModel model = StaffDataModel();
        model.profileImg = downloadLink;
        await FireStore()
            .updateProfileStaff(staffData: model, docID: crtStaffData!.docID!)
            .then((value) async {
          setState(() {
            crtStaffData!.profileImg = downloadLink;
            profileImage = null;
          });

          Navigator.pop(context);
          snackbar(context, true, "Successfully Update Staff");
          // });
        });
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  deleteStaff() async {
    try {
      loading(context);
      await Storage()
          .deleteImage(crtStaffData!.profileImg ?? '')
          .then((value) async {
        await FireStore()
            .deleteStaff(docID: crtStaffData!.docID!)
            .then((value) {
          Navigator.pop(context);
          setState(() {
            staffListingcontroller.animateToPage(
              0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
            );
            staffListingPageProvider.toggletab(true);
          });
          snackbar(context, true, "Successfully Deleted");
        });
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    initFn();
  }

  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNO = TextEditingController();
  TextEditingController userID = TextEditingController();
  TextEditingController password = TextEditingController();
  String? companyID;
  var staffKey = GlobalKey<FormState>();
  bool product = false;
  bool category = false;
  bool customer = false;
  bool orders = false;
  bool estimate = false;
  bool billofsupply = false;
  File? profileImage;
  String? permissionError;
}
