import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/view/admin/admin.dart';
import '/services/services.dart';
import '/utils/utils.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future loginValidationFn() async {
    try {
      loading(context);

      if (_formKey.currentState!.validate()) {
        final emailInput = email.text;
        const emailPattern = r"^[a-zA-Z0-9._%+-]+@srisoftwarez\.com$";
        final regex = RegExp(emailPattern);

        if (regex.hasMatch(emailInput)) {
          Navigator.pop(context);
          superadminLogin();
        } else {
          Navigator.pop(context);
          snackBarCustom(context, false, "Only admin can login");
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

  superadminLogin() async {
    try {
      loading(context);

      FirebaseAuthProvider authProvider = FirebaseAuthProvider();

      UserCredential? credential = await authProvider.loginAuth(
        context,
        email: email.text,
        password: password.text,
      );

      Navigator.pop(context);
      snackBarCustom(context, true, 'Logged as Admin');
      await LocalDB.superAdminLogin().then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
        );
      });
    } catch (e) {
      Navigator.pop(context);
      print(e);
      rethrow;
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
                          "Admin Login!",
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
                          "Sign in to your admin account\nTo register a new company",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
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
