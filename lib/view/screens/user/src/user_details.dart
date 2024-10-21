import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../ui/src/table_row.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';

class UserDetails extends StatefulWidget {
  final UserAdminModel userAdminModel;
  const UserDetails({super.key, required this.userAdminModel});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.userAdminModel.adminName != null &&
                widget.userAdminModel.adminName!.isNotEmpty
            ? Text("${widget.userAdminModel.adminName}")
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
                                  imageUrl: widget.userAdminModel.imageUrl ??
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
                                "Admin Name",
                                widget.userAdminModel.adminName ?? '',
                              ),
                              buildTableRow(
                                context,
                                "Mobile No",
                                widget.userAdminModel.phoneNo ?? '',
                              ),
                              buildTableRow(
                                context,
                                "Login Id",
                                widget.userAdminModel.adminLoginId ?? '',
                              ),
                              buildTableRow(
                                context,
                                "Password",
                                widget.userAdminModel.password ?? '',
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          widget.userAdminModel.deviceModel != null &&
                                  widget.userAdminModel.deviceModel!.deviceId !=
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
                                                    .userAdminModel
                                                    .deviceModel!,
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
                          widget.userAdminModel.deviceModel != null &&
                                  widget.userAdminModel.deviceModel!.deviceId !=
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
                                      widget.userAdminModel.deviceModel!
                                              .deviceName ??
                                          '',
                                    ),
                                    buildTableRow(
                                      context,
                                      "Model Name",
                                      widget.userAdminModel.deviceModel!
                                              .modelName ??
                                          '',
                                    ),
                                    buildTableRow(
                                      context,
                                      "Device Id",
                                      widget.userAdminModel.deviceModel!
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
                              deleteAdmin();
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
                                  updateUserImage(imageResult);
                                }
                              },
                              child: Center(
                                child: SizedBox(
                                  height: 90,
                                  width: 90,
                                  child: Stack(
                                    children: [
                                      selectedImage == null
                                          ? ClipRRect(
                                              clipBehavior: Clip.hardEdge,
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                imageUrl: adminProfileImage ??
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
                                                  image:
                                                      FileImage(selectedImage!),
                                                ),
                                              ),
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
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InputForm(
                                    controller: adminuserName,
                                    labelName: "User Name (*)",
                                    formName: "Full Name",
                                    prefixIcon: Icons.person,
                                    validation: (input) {
                                      return FormValidation().commonValidation(
                                        input: input,
                                        isMandatory: true,
                                        formName: "User Name",
                                        isOnlyCharter: false,
                                      );
                                    },
                                  ),
                                  InputForm(
                                    controller: adminphoneno,
                                    labelName: "Phone Number (*)",
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
                                    "User ID (*)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    controller: adminuserid,
                                    decoration: InputDecoration(
                                      hintText: "User Id",
                                      prefixIcon: const Icon(
                                        Icons.alternate_email_outlined,
                                        color: Color(0xff7099c2),
                                      ),
                                      suffix: Text("@$unqiueId"),
                                    ),
                                    validator: (p0) {
                                      return FormValidation().commonValidation(
                                        input: p0.toString(),
                                        formName: "User ID",
                                        isMandatory: true,
                                        isOnlyCharter: false,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  // InputForm(
                                  //   controller: adminuserid,
                                  //   labelName: "User Id",
                                  //   formName: "User Id",
                                  //   prefixIcon: Icons.alternate_email_outlined,
                                  //   keyboardType: TextInputType.text,
                                  //   // validation: (input) {
                                  //   //   return FormValidation().emailValidation(
                                  //   //     input: input.toString(),
                                  //   //     labelName: "User Id",
                                  //   //     isMandatory: true,
                                  //   //   );
                                  //   // },
                                  // ),
                                  InputForm(
                                    controller: adminpassword,
                                    labelName: "Passsword (*)",
                                    formName: "Passsword",
                                    isPasswordForm: true,
                                    prefixIcon: Icons.key,
                                    keyboardType: TextInputType.visiblePassword,
                                    validation: (input) {
                                      return FormValidation()
                                          .passwordValidation(
                                        input: input.toString(),
                                        minLength: 6,
                                        maxLength: 12,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
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
                              updateUserInfo();
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

  deleteDevice() async {
    try {
      loading(context);
      await FireStore().deleteUserDevice(docID: docid ?? '').then((value) {
        Navigator.pop(context);
        Navigator.pop(context, true);
        snackbar(context, true, "User device deleted");
      });
    } on Exception catch (e) {
      Navigator.pop(context);
      snackbar(context, true, e.toString());
    }
  }

  updateUserImage(File image) async {
    loading(context);
    try {
      await Storage()
          .deleteImage(widget.userAdminModel.imageUrl)
          .then((value) async {
        var downloadLink = await Storage().uploadImage(
          fileData: image,
          fileName: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: 'user',
        );
        Navigator.pop(context);
        setState(() {
          adminProfileImage = downloadLink;
        });
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  updateUserInfo() async {
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      loading(context);
      if (formKey.currentState!.validate()) {
        UserAdminModel userData = UserAdminModel();
        userData.adminName = adminuserName.text;
        userData.phoneNo = adminphoneno.text;
        userData.adminLoginId = "${adminuserid.text}@$unqiueId";
        userData.password = adminpassword.text;
        userData.imageUrl = adminProfileImage;

        if (adminProfileImage!.isNotEmpty) {
          await FireStore()
              .updateUser(docID: docid.toString(), userData: userData)
              .then((value) async {
            if (value != null) {
              Navigator.pop(context);
              Navigator.pop(context, true);

              snackbar(context, true, "Successfully User Data Updated");
            } else {
              snackbar(context, false, "Something Went wrong Please try again");
            }
          });
        } else {
          Navigator.pop(context);
          snackbar(
              context, false, "Image is empty. Please choose another image");
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  deleteAdmin() async {
    try {
      await confirmationDialog(
        context,
        title: "Alert",
        message: "Do you want delete user?",
      ).then((value) async {
        if (value != null && value == true) {
          loading(context);
          await Storage().deleteImage(adminProfileImage).then((value) async {
            await FireStore()
                .deleteAdmin(docID: docid ?? "")
                .then((firestoreResult) async {
              Navigator.pop(context);
              Navigator.pop(context, true);

              snackbar(
                context,
                true,
                "Successfully user deleted",
              );
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
    docid = widget.userAdminModel.docid;
    uid = widget.userAdminModel.uid;
    adminuserName.text = widget.userAdminModel.adminName ?? '';
    adminphoneno.text = widget.userAdminModel.phoneNo ?? '';
    adminpassword.text = widget.userAdminModel.password ?? '';
    adminProfileImage = widget.userAdminModel.imageUrl ?? '';
    List<String> data = widget.userAdminModel.adminLoginId!.split('@');
    unqiueId = data[1];
    adminuserid.text = data[0];
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
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

  var formKey = GlobalKey<FormState>();
  String? oldEmail;
  String? oldPassword;
  String? uid;
  String? docid;
  String? unqiueId;
  String? imageUrl;
}
