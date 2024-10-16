import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/view/ui/src/test_mode.dart';
import '/view/ui/ui.dart';
import '/view/auth/auth.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/screens/screens.dart';
import '../register/register.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
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
                                    return "Email is must";
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
                                    return "Password is must";
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
                              //             return "Token is must";
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
                                  login();
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
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => const Register(),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15,
                                  ),
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.building_2_fill,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Register Company",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                    "App Version $currentVersion",
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

  //***************** Check Login *********************
  login() async {
    try {
      if (_formKey.currentState!.validate()) {
        FocusManager.instance.primaryFocus!.unfocus();
        if (email.text == "activatetestmode" &&
            password.text == "Testmode@987654") {
          showTestMode(context);
        } else {
          if (validateEmail(email.text)) {
            superAdminLogin();
          } else {
            staffLogin();
          }
        }
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  bool validateEmail(String email) {
    const pattern =
        r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.)+[a-zA-Z]{2,}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  //***************** Login Functions *********************

  superAdminLogin() async {
    try {
      loading(context); // Show loading dialog

      FireStore fireStore = FireStore();
      var company = await fireStore.getCompany(email: email.text);

      if (company.docs.isNotEmpty) {
        if (company.docs.first["info_filled"] == false) {
          Navigator.pop(context); // Close loading dialog
          snackbar(context, false,
              "Company info not filled. Contact administrator for further assistance");
        } else {
          bool isTestMode = await LocalDB.checkTestMode();
          DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();
          DeviceModel deviceDetails = DeviceModel(
            deviceId: deviceInfo!.deviceId,
            modelName: deviceInfo.modelName,
            deviceName: deviceInfo.deviceName,
            lastlogin: DateTime.now(),
          );

          var deviceAccessResult = await fireStore.checkLoginDeviceInfo(
            context,
            uid: company.docs.first["user_login_id"],
            deviceData: deviceDetails,
            type: UserType.accountHolder,
          );

          if (deviceAccessResult!.docs.isNotEmpty || isTestMode) {
            await LocalDB.createNewUser(
              username: company.docs.first["user_name"].toString(),
              loginEmail: company.docs.first["user_login_id"].toString(),
              uID: company.docs.first.id.toString(),
              companyID: company.docs.first.id.toString(),
              companyUniqueId:
                  company.docs.first["company_unique_id"].toString(),
              companyAddress: company.docs.first["address"].toString(),
              companyName: company.docs.first["company_name"].toString(),
              isAdmin: true,
              prCategory: true,
              prCustomer: true,
              prEstimate: true,
              prOrder: true,
              prProduct: true,
              prBillofSupply: true,
            ).then((value) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => const UserHome(),
                ),
              );
            });
          } else {
            Navigator.pop(context);
            if (company.docs.first["device.device_id"] != null) {
              snackbar(context, false,
                  "You're already logged in with another device");
            } else {
              await fireStore
                  .registerNewDevice(
                context,
                type: UserType.accountHolder,
                docid: company.docs.first.id,
                deviceData: deviceDetails,
              )
                  .then((value) {
                superAdminLogin();
              });
            }
          }
        }
      } else {
        Navigator.pop(context); // Close loading dialog
        snackbar(context, false, "User not found");
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      snackbar(context, false, e.toString());
    }
  }

  staffLogin() async {
    try {
      loading(context); // Show loading dialog
      FireStore fireStore = FireStore();

      var value = await fireStore.staffLogin(
          email: email.text, password: password.text);
      if (value != null && value.docs.isNotEmpty) {
        var tmpData = email.text.split('@');
        bool isTestMode = await LocalDB.checkTestMode();
        DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();
        DeviceModel deviceDetails = DeviceModel(
          deviceId: deviceInfo!.deviceId,
          modelName: deviceInfo.modelName,
          deviceName: deviceInfo.deviceName,
          lastlogin: DateTime.now(),
        );

        var deviceAccessResult = await fireStore.checkLoginDeviceInfo(
          context,
          uid: value.docs.first["user_login_id"],
          deviceData: deviceDetails,
          type: UserType.staff,
        );

        if (deviceAccessResult!.docs.isNotEmpty || isTestMode) {
          await LocalDB.createNewUser(
            username: value.docs.first["staff_name"],
            loginEmail: value.docs.first["user_login_id"],
            uID: value.docs.first.id,
            companyID: value.docs.first["company_id"],
            companyAddress: value.docs.first["address"].toString(),
            companyName: value.docs.first["company_name"].toString(),
            companyUniqueId: tmpData[1],
            isAdmin: false,
            prCategory: value.docs.first["permission"]["category"],
            prCustomer: value.docs.first["permission"]["customer"],
            prEstimate: value.docs.first["permission"]["estimate"],
            prOrder: value.docs.first["permission"]["orders"],
            prProduct: value.docs.first["permission"]["product"],
            prBillofSupply: value.docs.first["permission"]["billofsupply"],
          ).then((value) {
            Navigator.pop(context); // Close loading dialog
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => const UserHome(),
              ),
            );
          });
        } else {
          Navigator.pop(context); // Close loading dialog
          if (value.docs.first["device.device_id"] != null) {
            snackbar(
                context, false, "You're already logged in with another device");
          } else {
            await fireStore
                .registerNewDevice(
              context,
              type: UserType.staff,
              docid: value.docs.first.id,
              deviceData: deviceDetails,
            )
                .then((value) {
              staffLogin();
            });
          }
        }
      } else {
        Navigator.pop(context);
        adminLogin();
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      snackbar(context, false, e.toString());
    }
  }

  adminLogin() async {
    try {
      loading(context); // Show loading dialog
      FireStore fireStore = FireStore();

      var value = await fireStore.adminLogin(
          email: email.text, password: password.text);
      if (value != null && value.docs.isNotEmpty) {
        var tmpData = email.text.split('@');
        bool isTestMode = await LocalDB.checkTestMode();
        DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();
        DeviceModel deviceDetails = DeviceModel(
          deviceId: deviceInfo!.deviceId,
          modelName: deviceInfo.modelName,
          deviceName: deviceInfo.deviceName,
          lastlogin: DateTime.now(),
        );

        var deviceAccessResult = await fireStore.checkLoginDeviceInfo(
          context,
          uid: value.docs.first["user_login_id"],
          deviceData: deviceDetails,
          type: UserType.admin,
        );

        if (deviceAccessResult!.docs.isNotEmpty || isTestMode) {
          await LocalDB.createNewUser(
            username: value.docs.first["admin_name"],
            loginEmail: value.docs.first["user_login_id"],
            uID: value.docs.first.id,
            companyID: value.docs.first["company_id"],
            companyUniqueId: tmpData[1],
            companyAddress: value.docs.first["address"].toString(),
            companyName: value.docs.first["company_name"].toString(),
            isAdmin: false,
            prCategory: true,
            prCustomer: true,
            prEstimate: true,
            prOrder: true,
            prProduct: true,
            prBillofSupply: true,
          ).then((value) {
            Navigator.pop(context); // Close loading dialog
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => const UserHome(),
              ),
            );
          });
        } else {
          Navigator.pop(context); // Close loading dialog
          if (value.docs.first["device.device_id"] != null) {
            snackbar(
                context, false, "You're already logged in with another device");
          } else {
            await fireStore
                .registerNewDevice(
              context,
              type: UserType.admin,
              docid: value.docs.first.id,
              deviceData: deviceDetails,
            )
                .then((value) {
              adminLogin(); // Recursive call to log in again
            });
          }
        }
      } else {
        Navigator.pop(context); // Close loading dialog
        snackbar(context, false, "User Details Not Found");
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      snackbar(context, false, e.toString());
    }
  }

  //***************** Version Intialization *********************

  @override
  void initState() {
    initVersion();
    super.initState();
  }

  initVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
    });
  }

  //***************** Variables *********************
  String currentVersion = "";
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
}
