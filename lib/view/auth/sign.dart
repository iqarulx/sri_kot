import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_kot/view/auth/forgot_pass.dart';
import '../../model/model.dart';
import '../../services/firebase/firebase_auth_provider.dart';
import '../../services/firebase/firestore_provider.dart';
import '/provider/device_info_provider.dart';
import '../../provider/localdb.dart';
import '../../utils/utlities.dart';
import '/view/screens/homelanding.dart';
import 'registercompany.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  accountHolderLoginFn() async {
    try {
      // auth Handlor
      FirebaseAuthProvider authProvider = FirebaseAuthProvider();
      FireStoreProvider fireStoreProvider = FireStoreProvider();

      // check auth Login Device
      UserCredential? credential = await authProvider.loginAuth(
        context,
        email: email.text,
        password: password.text,
      );

      if (credential != null) {
        var companyData = await fireStoreProvider.getCompanyInfo(
          uid: credential.user!.uid.toString(),
        );

        // Already Register But Not Fully Completed Company Information
        if (companyData!.docs.isNotEmpty) {
          if (companyData.docs.first["info_filled"] == false) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterCompany(
                  uid: credential.user!.uid.toString(),
                  docid: companyData.docs.first.id,
                  companyName:
                      companyData.docs.first["company_name"].toString(),
                  username: companyData.docs.first["user_name"].toString(),
                  email: companyData.docs.first["user_login_id"].toString(),
                  password: companyData.docs.first["password"].toString(),
                ),
              ),
            );
          } else {
            /*
              Company Account Only Access Device in Server
                1. Check Current Requet Device Already Enrolled
                2. Already Entrolled to Store local Db on User Data then Go to Dashboard
              */

            // Collect the Device Information
            DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();

            // Device Information Collected

            DeviceModel deviceDetails = DeviceModel();

            deviceDetails.deviceId = deviceInfo!.deviceId;
            deviceDetails.modelName = deviceInfo.modelName;
            deviceDetails.deviceName = deviceInfo.deviceName;
            deviceDetails.lastlogin = DateTime.now();

            var deviceAccessResult =
                await fireStoreProvider.checkLoginDeviceInfo(
              context,
              uid: credential.user!.uid.toString(),
              deviceData: deviceDetails,
              type: UserType.accountHolder,
            );

            if (deviceAccessResult!.docs.isNotEmpty) {
              await LocalDbProvider()
                  .createNewUser(
                username: companyData.docs.first["user_name"].toString(),
                loginEmail: companyData.docs.first["user_login_id"].toString(),
                uID: companyData.docs.first["uid"].toString(),
                companyID: companyData.docs.first.id.toString(),
                companyUniqueId:
                    companyData.docs.first["company_unique_id"].toString(),
                isAdmin: true,
                prCategory: true,
                prCustomer: true,
                prEstimate: true,
                prOrder: true,
                prProduct: true,
                prBillofSupply: true,
              )
                  .then((value) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeLanding(),
                  ),
                );
              });
            } else {
              if (companyData.docs.first["device.device_id"] != null &&
                  companyData.docs.first["device.model_name"] != null &&
                  companyData.docs.first["device.device_name"] != null) {
                Navigator.pop(context);
                snackBarCustom(
                  context,
                  false,
                  "You're already logged with another device",
                );
              } else {
                // register New Device
                await fireStoreProvider
                    .registerNewDevice(
                  context,
                  type: UserType.accountHolder,
                  docid: companyData.docs.first.id,
                  deviceData: deviceDetails,
                )
                    .then((value) {
                  Navigator.pop(context);
                  accountHolderLoginFn();
                });
              }
            }
          }
        } else {
          Navigator.pop(context);
          snackBarCustom(
              context, false, "Something went wrong please try again later");
        }
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  staffLoginFn() async {
    try {
      await FireStoreProvider()
          .staffLogin(email: email.text, password: password.text)
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          var tmpData = email.text.split('@');

          DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();

          DeviceModel deviceDetails = DeviceModel();
          deviceDetails.deviceId = deviceInfo!.deviceId;
          deviceDetails.modelName = deviceInfo.modelName;
          deviceDetails.deviceName = deviceInfo.deviceName;
          deviceDetails.lastlogin = DateTime.now();

          FireStoreProvider fireStoreProvider = FireStoreProvider();
          var deviceAccessResult = await fireStoreProvider.checkLoginDeviceInfo(
            context,
            uid: value.docs.first["user_login_id"],
            deviceData: deviceDetails,
            type: UserType.staff,
          );

          if (deviceAccessResult!.docs.isNotEmpty) {
            await LocalDbProvider()
                .createNewUser(
              username: value.docs.first["staff_name"],
              loginEmail: value.docs.first["user_login_id"],
              uID: value.docs.first.id,
              companyID: value.docs.first["company_id"],
              companyUniqueId: tmpData[1],
              isAdmin: false,
              prCategory: value.docs.first["permission"]["category"],
              prCustomer: value.docs.first["permission"]["customer"],
              prEstimate: value.docs.first["permission"]["estimate"],
              prOrder: value.docs.first["permission"]["orders"],
              prProduct: value.docs.first["permission"]["product"],
              prBillofSupply: value.docs.first["permission"]["billofsupply"],
            )
                .then((value) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeLanding(),
                ),
              );
            });
          } else {
            if (value.docs.first["device.device_id"] != null &&
                value.docs.first["device.model_name"] != null &&
                value.docs.first["device.device_name"] != null) {
              Navigator.pop(context);
              snackBarCustom(
                context,
                false,
                "You're already logged with another device",
              );
            } else {
              await fireStoreProvider
                  .registerNewDevice(
                context,
                type: UserType.staff,
                docid: value.docs.first.id,
                deviceData: deviceDetails,
              )
                  .then((value) {
                Navigator.pop(context);
                staffLoginFn();
              });
            }
          }
        } else {
          adminLoginFn();
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  bool validateEmail(String email) {
    // Regular expression pattern for email validation
    const pattern =
        r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.)+[a-zA-Z]{2,}$';

    // Creating a RegExp object from the pattern
    final regExp = RegExp(pattern);

    // Matching the email against the pattern
    return regExp.hasMatch(email);
  }

  adminLoginFn() async {
    try {
      await FireStoreProvider()
          .adminLogin(email: email.text, password: password.text)
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          var tmpData = email.text.split('@');

          DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();

          DeviceModel deviceDetails = DeviceModel();
          deviceDetails.deviceId = deviceInfo!.deviceId;
          deviceDetails.modelName = deviceInfo.modelName;
          deviceDetails.deviceName = deviceInfo.deviceName;
          deviceDetails.lastlogin = DateTime.now();

          FireStoreProvider fireStoreProvider = FireStoreProvider();
          var deviceAccessResult = await fireStoreProvider.checkLoginDeviceInfo(
            context,
            uid: value.docs.first["user_login_id"],
            deviceData: deviceDetails,
            type: UserType.admin,
          );

          if (deviceAccessResult!.docs.isNotEmpty) {
            await LocalDbProvider()
                .createNewUser(
              username: value.docs.first["admin_name"],
              loginEmail: value.docs.first["user_login_id"],
              uID: value.docs.first.id,
              companyID: value.docs.first["company_id"],
              companyUniqueId: tmpData[1],
              isAdmin: false,
              prCategory: true,
              prCustomer: true,
              prEstimate: true,
              prOrder: true,
              prProduct: true,
              prBillofSupply: true,
            )
                .then((value) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeLanding(),
                ),
              );
            });
          } else {
            if (value.docs.first["device.device_id"] != null &&
                value.docs.first["device.model_name"] != null &&
                value.docs.first["device.device_name"] != null) {
              Navigator.pop(context);
              snackBarCustom(
                context,
                false,
                "You're already logged with another device",
              );
            } else {
              await fireStoreProvider
                  .registerNewDevice(
                context,
                type: UserType.admin,
                docid: value.docs.first.id,
                deviceData: deviceDetails,
              )
                  .then((value) {
                Navigator.pop(context);
                adminLoginFn();
              });
            }
          }
        } else {
          Navigator.pop(context);
          snackBarCustom(context, false, "User Details Not Found");
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  Future loginValidationFn() async {
    try {
      loading(context);
      if (_formKey.currentState!.validate()) {
        if (validateEmail(email.text)) {
          accountHolderLoginFn();
        } else {
          staffLoginFn();
        }
      } else {
        Navigator.pop(context);
        snackBarCustom(context, false, "Fill Correct Form Details");
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Welcome back!",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Sign in to your account",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: email,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: "Email Address",
                                  filled: true,
                                  fillColor: Color(0xfff1f5f9),
                                  prefixIcon: Icon(
                                    Icons.person,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "User ID is Must";
                                  } else if (value.contains(RegExp(r'\s'))) {
                                    return 'White spaces not allowed';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Password",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: password,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText:
                                    passwordVisible == true ? false : true,
                                decoration: InputDecoration(
                                  fillColor: const Color(0xfff1f5f9),
                                  filled: true,
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Password",
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                  ),
                                  suffixIcon: passwordVisible == true
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              passwordVisible = false;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.remove_red_eye,
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () {
                                            setState(() {
                                              passwordVisible = true;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.visibility_off,
                                          ),
                                        ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Password is Must";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              // // isAlreadyLogin == false
                              // SizedBox(
                              //   child: Column(
                              //     crossAxisAlignment:
                              //         CrossAxisAlignment.start,
                              //     children: [
                              //       const SizedBox(
                              //         height: 10,
                              //       ),
                              //       const Text(
                              //         "Auth Token",
                              //         style: TextStyle(
                              //           color: Colors.black,
                              //           fontWeight: FontWeight.w500,
                              //           fontSize: 14,
                              //         ),
                              //       ),
                              //       const SizedBox(
                              //         height: 5,
                              //       ),
                              //       TextFormField(
                              //         // controller: token,
                              //         textInputAction: TextInputAction.done,
                              //         decoration: const InputDecoration(
                              //           hintText: "Token",
                              //           filled: true,
                              //           fillColor: Color(0xfff1f5f9),
                              //           prefixIcon: Icon(
                              //             Icons.key,
                              //           ),
                              //           border: OutlineInputBorder(
                              //             borderSide: BorderSide.none,
                              //           ),
                              //         ),
                              //         validator: (value) {
                              //           if (value!.isEmpty) {
                              //             return "Token is Must";
                              //           } else if (value
                              //               .contains(RegExp(r'\s'))) {
                              //             return 'White spaces not allowed';
                              //           } else {
                              //             return null;
                              //           }
                              //         },
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // : const SizedBox(),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (builder) =>
                                                const ForgotPass()));
                                  },
                                  child: const Text(
                                    "Forgot Password?",
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  loginValidationFn();
                                  // loginAuth();
                                  // loading(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15,
                                  ),
                                  width: double.infinity,
                                  child: const Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     // loginauth();
                              //     setState(() {
                              //       authPage.animateToPage(
                              //         1,
                              //         duration:
                              //             const Duration(milliseconds: 600),
                              //         curve: Curves.easeIn,
                              //       );
                              //     });
                              //   },
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(5),
                              //       color: Theme.of(context)
                              //           .primaryColor
                              //           .withOpacity(0.2),
                              //     ),
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 10,
                              //       vertical: 15,
                              //     ),
                              //     width: double.infinity,
                              //     child: Center(
                              //       child: Text(
                              //         "Register",
                              //         style: TextStyle(
                              //           color: Theme.of(context).primaryColor,
                              //           fontSize: 20,
                              //           fontWeight: FontWeight.w800,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 40,
                      right: 40,
                      top: 110,
                      bottom: 15,
                    ),
                    width: double.infinity,
                    //color: Colors.grey.shade100,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: "By clicking the button above, you agree to our ",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                        ),
                        children: [
                          TextSpan(
                            text: "Terms of Use ",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "and ",
                            style: TextStyle(
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: "Privacy Policy.",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "App Version (1.0.1)",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
