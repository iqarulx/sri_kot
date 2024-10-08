import 'package:flutter/material.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import 'registercompany.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  bool passwordvissable = true;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController company = TextEditingController();

  Future registerAuth() async {
    if (_formKey.currentState!.validate()) {
      loading(context);
      try {
        await FirebaseAuthProvider()
            .createSinginAccount(
          context,
          email: email.text,
          password: password.text,
        )
            .then((value) async {
          if (value != null && value.user != null) {
            ProfileModel profileData = ProfileModel();
            profileData.companyName = company.text;
            profileData.deviceLimit = 1;
            profileData.uid = value.user!.uid;
            profileData.userLoginId = email.text;
            profileData.username = name.text;
            profileData.filled = false;
            profileData.password = password.text;
            await FireStore()
                .registerCompany(context, profileInfo: profileData)
                .then((value) {
              if (value != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterCompany(
                      uid: value.toString(),
                      docid: value.toString(),
                      companyName: company.text,
                      username: name.text,
                      email: email.text,
                      password: password.text,
                    ),
                  ),
                );
              }
            });
          } else {
            Navigator.pop(context);
          }
        }).catchError((onError) {
          Navigator.pop(context);
          snackbar(context, false, onError.toString());
        });
      } catch (e) {
        Navigator.pop(context);
        snackbar(context, false, e.toString());
      }
    } else {
      snackbar(context, false, "Fill Correct Form Details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Register a company"),
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
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Register!",
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
                          "Sign up to your account",
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
                                "User Name",
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
                                controller: name,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  hintText: "Full Name",
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
                                  return FormValidation().commonValidation(
                                    input: value,
                                    isMandorty: true,
                                    formName: "User Name",
                                    isOnlyCharter: true,
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Company Name",
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
                                controller: company,
                                cursorColor: Theme.of(context).primaryColor,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  fillColor: Color(0xfff1f5f9),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Company Full Name",
                                  prefixIcon: Icon(
                                    Icons.home_work,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Company Name is Must";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
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
                                    Icons.mail,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Email is Must";
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
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText:
                                    passwordvissable == true ? false : true,
                                decoration: InputDecoration(
                                  fillColor: const Color(0xfff1f5f9),
                                  filled: true,
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Password",
                                  prefixIcon: const Icon(
                                    Icons.vpn_key,
                                  ),
                                  suffixIcon: passwordvissable == true
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              passwordvissable = false;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.remove_red_eye,
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () {
                                            setState(() {
                                              passwordvissable = true;
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
                              const SizedBox(
                                height: 15,
                              ),
                              GestureDetector(
                                onTap: () {
                                  registerAuth();
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         const RegisterCompany(
                                  //       companyName: '',
                                  //       docid: '',
                                  //       uid: '',
                                  //     ),
                                  //   ),
                                  // );
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
                                      "Register",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
