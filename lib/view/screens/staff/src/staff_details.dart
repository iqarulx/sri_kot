import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../ui/src/table_row.dart';
import '/constants/constants.dart';
import '/gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

class StaffDetails extends StatefulWidget {
  final StaffDataModel staffDetails;
  const StaffDetails({super.key, required this.staffDetails});

  @override
  State<StaffDetails> createState() => _StaffDetailsState();
}

class _StaffDetailsState extends State<StaffDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.staffDetails.userName != null &&
                widget.staffDetails.userName!.isNotEmpty
            ? Text("${widget.staffDetails.userName}")
            : const Text(""),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: SizedBox(
                              height: 90,
                              width: 90,
                              child: ClipRRect(
                                clipBehavior: Clip.hardEdge,
                                borderRadius: BorderRadius.circular(50.0),
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  imageUrl: widget.staffDetails.profileImg ??
                                      Strings.profileImg,
                                  fit: BoxFit.cover,
                                  height: 120,
                                  width: 120,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                            },
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            children: [
                              buildTableRow(
                                context,
                                "Staff Name",
                                widget.staffDetails.userName ?? '',
                              ),
                              buildTableRow(
                                context,
                                "Mobile No",
                                widget.staffDetails.phoneNo ?? '',
                              ),
                              buildTableRow(
                                context,
                                "Login Id",
                                widget.staffDetails.userid ?? '',
                              ),
                              buildTableRow(
                                context,
                                "Password",
                                widget.staffDetails.password ?? '',
                              ),
                              buildTableRow(context, "Permissions",
                                  permissionText.join(', ')),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          widget.staffDetails.deviceModel != null &&
                                  widget.staffDetails.deviceModel!.deviceId !=
                                      null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      "Mobile Details",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return DeviceModal(
                                                deviceModel: widget
                                                    .staffDetails.deviceModel!,
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
                                        icon: const Icon(
                                          Iconsax.trash,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          widget.staffDetails.deviceModel != null &&
                                  widget.staffDetails.deviceModel!.deviceId !=
                                      null
                              ? Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(3),
                                  },
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  children: [
                                    buildTableRow(
                                      context,
                                      "Device Name",
                                      widget.staffDetails.deviceModel!
                                              .deviceName ??
                                          '',
                                    ),
                                    buildTableRow(
                                      context,
                                      "Model Name",
                                      widget.staffDetails.deviceModel!
                                              .modelName ??
                                          '',
                                    ),
                                    buildTableRow(
                                      context,
                                      "Device Id",
                                      widget.staffDetails.deviceModel!
                                              .deviceId ??
                                          '',
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade400,
                              surfaceTintColor: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              deleteStaff();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.trash,
                                  size: 15,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              surfaceTintColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              if (currentPage == 0) {
                                pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.edit,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    )
                  ],
                ),
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                var imageResult = await FilePickerProvider()
                                    .showFileDialog(context);
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
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                imageUrl: widget.staffDetails
                                                        .profileImg ??
                                                    Strings.profileImg,
                                                fit: BoxFit.cover,
                                                height: 120,
                                                width: 120,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ))
                                          : Container(
                                              height: 90,
                                              width: 90,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: profileImage!
                                                            .existsSync()
                                                        ? FileImage(
                                                            profileImage!)
                                                        : AssetImage(
                                                            Assets.images
                                                                .noImage.path,
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
                                    labelName: "Staff Name",
                                    formName: "Full Name",
                                    prefixIcon: Icons.person,
                                    validation: (input) {
                                      return FormValidation().commonValidation(
                                        input: input,
                                        isMandatory: true,
                                        formName: "Staff Name",
                                        isOnlyCharter: false,
                                      );
                                    },
                                  ),
                                  InputForm(
                                    controller: phoneNo,
                                    labelName: "Phone Number",
                                    formName: "Phone No",
                                    prefixIcon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validation: (input) {
                                      return FormValidation().phoneValidation(
                                        input: input.toString(),
                                        isMandatory: true,
                                        labelName: "Phone Number",
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
                                                  Icons
                                                      .alternate_email_outlined,
                                                  color: Color(0xff7099c2),
                                                ),
                                              ),
                                              validator: (input) {
                                                return FormValidation()
                                                    .commonValidation(
                                                  input: input,
                                                  isMandatory: true,
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
                                  //   labelName: "User Id",
                                  //   formName: "User Id",
                                  //   prefixIcon: Icons.alternate_email_outlined,
                                  //   keyboardType: TextInputType.text,
                                  // ),
                                  InputForm(
                                    controller: password,
                                    labelName: "Passsword",
                                    formName: "Passsword",
                                    isPasswordForm: true,
                                    prefixIcon: Icons.key,
                                    keyboardType: TextInputType.visiblePassword,
                                    validation: (input) {
                                      return FormValidation()
                                          .passwordValidation(
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
                                  label: allPermissionEnabled
                                      ? const Text("Edit Permission")
                                      : const Text("Add Permission"),
                                  icon: allPermissionEnabled
                                      ? const Icon(
                                          Icons.edit,
                                          size: 16,
                                        )
                                      : const Icon(Icons.add),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
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
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade400,
                              surfaceTintColor: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              FocusManager.instance.primaryFocus!.unfocus();
                              if (currentPage == 1) {
                                pageController.animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.back,
                                  size: 15,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Back",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              surfaceTintColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              updateStaff();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.tick_circle,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* IconButton(
                splashRadius: 20,
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return DeviceModal(
                        deviceModel: widget.staffDetails!.deviceModel!,
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
              */

  deleteDevice() async {
    try {
      loading(context);
      await FireStore()
          .deleteStaffDevice(docID: widget.staffDetails.docID ?? '')
          .then((value) {
        Navigator.pop(context);
        Navigator.pop(context, true);

        snackbar(context, true, "User device deleted");
      });
    } on Exception catch (e) {
      Navigator.pop(context);
      snackbar(context, true, e.toString());
    }
  }

  initFn() {
    setState(() {
      fullName.text = widget.staffDetails.userName ?? "";
      phoneNo.text = widget.staffDetails.phoneNo ?? "";
      List<String> data = widget.staffDetails.userid!.split('@');
      companyID = data[1];
      adminuserid.text = data[0];
      userID.text = data[0];
      password.text = widget.staffDetails.password ?? "";
      product = widget.staffDetails.permission!.product!;
      category = widget.staffDetails.permission!.category!;
      customer = widget.staffDetails.permission!.customer!;
      orders = widget.staffDetails.permission!.orders!;
      estimate = widget.staffDetails.permission!.estimate!;
      billofsupply = widget.staffDetails.permission!.billofsupply!;
      allPermissionEnabled = widget.staffDetails.permission!.product! &&
          widget.staffDetails.permission!.category! &&
          widget.staffDetails.permission!.orders! &&
          widget.staffDetails.permission!.estimate! &&
          widget.staffDetails.permission!.billofsupply! &&
          widget.staffDetails.permission!.orders!;

      if (widget.staffDetails.permission!.product!) {
        permissionText.add("Product");
      }
      if (widget.staffDetails.permission!.category!) {
        permissionText.add("Category");
      }
      if (widget.staffDetails.permission!.customer!) {
        permissionText.add("Customer");
      }
      if (widget.staffDetails.permission!.orders!) {
        permissionText.add("Billing");
      }
      if (widget.staffDetails.permission!.estimate!) {
        permissionText.add("Estimate");
      }
      if (widget.staffDetails.permission!.billofsupply!) {
        permissionText.add("Bill of Supply");
      }
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
            permissionError = "Permission is must";
          });
          snackbar(context, false, "Permission is must");
        } else {
          await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
            if (cid != null) {
              StaffDataModel model = StaffDataModel();
              model.userName = fullName.text;
              model.phoneNo = phoneNo.text;
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
                            staffData: model, docID: widget.staffDetails.docID!)
                        .then((value) {
                      Navigator.pop(context);
                      snackbar(context, true, "Successfully Update Staff");
                    });
                  } else if (staffCheck.docs.isNotEmpty &&
                      staffCheck.docs.first.id == widget.staffDetails.docID) {
                    await FireStore()
                        .updateStaff(
                            staffData: model, docID: widget.staffDetails.docID!)
                        .then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
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
          .deleteImage(widget.staffDetails.profileImg)
          .then((value) async {
        var downloadLink = await Storage().uploadImage(
          fileData: image,
          fileName: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: 'staff',
        );
        StaffDataModel model = StaffDataModel();
        model.profileImg = downloadLink;
        await FireStore()
            .updateProfileStaff(
                staffData: model, docID: widget.staffDetails.docID!)
            .then((value) async {
          setState(() {
            widget.staffDetails.profileImg = downloadLink;
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
      await confirmationDialog(
        context,
        title: "Alert",
        message: "Do you want delete user?",
      ).then((value) async {
        if (value != null && value == true) {
          loading(context);
          await Storage()
              .deleteImage(widget.staffDetails.profileImg)
              .then((value) async {
            await FireStore()
                .deleteStaff(docID: widget.staffDetails.docID!)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context, true);
              snackbar(context, true, "Successfully Deleted");
            });
          });
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
    initFn();
  }

  final PageController pageController = PageController();
  int currentPage = 0;
  List<String> permissionText = [];
  bool allPermissionEnabled = false;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
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
