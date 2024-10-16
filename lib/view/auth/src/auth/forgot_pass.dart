import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/view/ui/ui.dart';
import '/services/services.dart';
import '/utils/utils.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool verified = false;
  bool passwordVisible = false;

  sendPasswordEmail() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    if (_formKey.currentState!.validate()) {
      var user = await FireStore().isUserAvailable(email: email.text);
      if (user) {
        try {
          await EmailOTP.sendOTP(email: email.text).then((value) {
            Navigator.pop(context);
            snackbar(context, true, "OTP has been sent");
            verifyOtp();
          }).catchError((error) {
            Navigator.pop(context);
            snackbar(context, false, error.toString());
          });
        } on Exception catch (e) {
          Navigator.pop(context);
          snackbar(context, false, e.toString());
        }
      }
    }
  }

  verifyOtp() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (builder) {
        return const EmailOtpModal();
      },
    ).then((value) async {
      if (value != null) {
        var result = EmailOTP.verifyOTP(otp: value);
        if (result) {
          snackbar(context, true, "Email verified");
          setState(() {
            verified = true;
          });
        } else {
          snackbar(context, false, "Invalid OTP");
        }
      }
    });
  }

  updatePassword() async {
    FocusManager.instance.primaryFocus!.unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        loading(context);
        await FireStore()
            .updatePassword(email: email.text, password: password.text);
        Navigator.pop(context);
        Navigator.pop(context);
        snackbar(context, true, "Password reset successfully");
      } on Exception catch (e) {
        snackbar(context, false, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Sri KOT",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
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
                          "Get back your password!",
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
                          "Enter your account email.\nYou will receive password reset email!",
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
                                    return "Email is must";
                                  } else if (value.contains(RegExp(r'\s'))) {
                                    return 'White spaces not allowed';
                                  } else {
                                    return null;
                                  }
                                },
                              ),

                              Visibility(
                                visible: verified,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      textInputAction: TextInputAction.done,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: passwordVisible == true
                                          ? false
                                          : true,
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
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (verified) {
                                    updatePassword();
                                  } else {
                                    sendPasswordEmail();
                                  }
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
                                  child: Center(
                                    child: Text(
                                      verified ? "Update Password" : "Send OTP",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
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
