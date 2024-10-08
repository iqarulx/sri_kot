import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  File? selectedImage;

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
                    userListingcontroller.animateToPage(
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
              title: Text(
                adminPagetitle ?? "",
                style: const TextStyle(color: Colors.black),
              ),
              actions: [
                IconButton(
                  splashRadius: 20,
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return DeviceModal(
                          deviceModel: adminDevice ?? DeviceModel(),
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
                  onPressed: () {
                    deleteAdmin();
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
                          setState(() {
                            selectedImage = imageResult;
                          });
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
                                      borderRadius: BorderRadius.circular(50.0),
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
                                              image:
                                                  FileImage(selectedImage!)))),
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
                            lableName: "User Name",
                            formName: "Full Name",
                            prefixIcon: Icons.person,
                            validation: (input) {
                              return FormValidation().commonValidation(
                                input: input,
                                isMandorty: true,
                                formName: "User Name",
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          InputForm(
                            controller: adminphoneno,
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
                            "User ID",
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
                                isMandorty: true,
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          // InputForm(
                          //   controller: adminuserid,
                          //   lableName: "User Id",
                          //   formName: "User Id",
                          //   prefixIcon: Icons.alternate_email_outlined,
                          //   keyboardType: TextInputType.text,
                          //   // validation: (input) {
                          //   //   return FormValidation().emailValidation(
                          //   //     input: input.toString(),
                          //   //     lableName: "User Id",
                          //   //     isMandorty: true,
                          //   //   );
                          //   // },
                          // ),
                          InputForm(
                            controller: adminpassword,
                            lableName: "Passsword",
                            formName: "Passsword",
                            isPasswordForm: true,
                            prefixIcon: Icons.key,
                            keyboardType: TextInputType.visiblePassword,
                            validation: (input) {
                              return FormValidation().passwordValidation(
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: fillButton(
                context,
                onTap: () {
                  updateUserInfo();
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
      await FireStore().deleteUserDevice(docID: adminDocId ?? '').then((value) {
        Navigator.pop(context);
        snackbar(context, true, "User device deleted");
      });
    } on Exception catch (e) {
      Navigator.pop(context);
      snackbar(context, true, e.toString());
    }
  }

  updateUserInfo() async {
    try {
      loading(context);
      if (formKey.currentState!.validate()) {
        UserAdminModel userData = UserAdminModel();
        userData.adminName = adminuserName.text;
        userData.phoneNo = adminphoneno.text;
        userData.adminLoginId = "${adminuserid.text}@$unqiueId";
        userData.password = adminpassword.text;

        if (selectedImage != null) {
          Storage().deleteImage(adminProfileImage ?? '').then((value) async {
            await Storage()
                .uploadImage(
              fileData: selectedImage!,
              fileName: DateTime.now().millisecondsSinceEpoch.toString(),
              filePath: 'users',
            )
                .then((value) async {
              userData.imageUrl = value;

              await FireStore()
                  .updateUser(docID: docid.toString(), userData: userData)
                  .then((value) async {
                if (value != null) {
                  Navigator.pop(context);
                  snackbar(context, true, "Successfully User Data Updated");
                } else {
                  snackbar(
                      context, false, "Something Went wrong Please try again");
                }
              });
            }).catchError((onError) {
              snackbar(context, false, "Something Went wrong Please try again");
            });
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
          await Storage()
              .deleteImage(adminProfileImage ?? '')
              .then((value) async {
            await FireStore()
                .deleteAdmin(docID: docid ?? "")
                .then((firestoreResult) async {
              Navigator.pop(context);
              setState(() {
                userListingcontroller.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeIn,
                );
              });
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
    docid = adminDocId;
    uid = adminuid;
    List<String> data = adminuserid.text.split('@');
    unqiueId = data[1];
    adminuserid.text = data[0];
  }

  var formKey = GlobalKey<FormState>();
  String? oldEmail;
  String? oldPassword;
  String? uid;
  String? docid;
  String? unqiueId;
  String? imageUrl;
}
