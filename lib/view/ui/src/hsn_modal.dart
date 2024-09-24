import 'package:flutter/material.dart';
import 'package:sri_kot/constants/constants.dart';
import 'package:sri_kot/utils/utils.dart';
import 'package:sri_kot/view/ui/ui.dart';

import '../../../services/services.dart';

class HsnModal extends StatefulWidget {
  const HsnModal({super.key});

  @override
  State<HsnModal> createState() => _HsnModalState();
}

class _HsnModalState extends State<HsnModal> {
  String? option;
  bool? commonSelected;
  TextEditingController hsn = TextEditingController();
  var formKey = GlobalKey<FormState>();

  Future? hsnHandler;

  @override
  void initState() {
    hsnHandler = getHSN();
    super.initState();
  }

  getHSN() async {
    try {
      await LocalService.getHSN().then((value) {
        if (value.isNotEmpty) {
          if (value["common_hsn"]) {
            setState(() {
              option = "1";
              commonSelected = true;
            });

            if (value["common_hsn_value"] != null) {
              setState(() {
                hsn.text = value["common_hsn_value"];
              });
            }
          } else {
            setState(() {
              option = "2";
            });
          }
        }
      });
    } on Exception catch (e) {
      showToast(context, content: e.toString(), isSuccess: false, top: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      title: const Text("HSN Option"),
      actions: [
        FutureBuilder(
          future: hsnHandler,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Common HSN'),
                      value: '1',
                      groupValue: option,
                      onChanged: (value) {
                        setState(() {
                          option = value;
                          commonSelected = true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (commonSelected ?? false)
                      TextFormField(
                        controller: hsn,
                        cursorColor: Theme.of(context).primaryColor,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Enter HSN",
                          filled: true,
                          fillColor: Color(0xfff1f5f9),
                          prefixIcon: Icon(
                            Icons.numbers,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "HSN is Must";
                          } else if (value.contains(RegExp(r'\s'))) {
                            return 'White spaces not allowed';
                          }
                          return null;
                        },
                      ),
                    RadioListTile<String>(
                      title: const Text('Individual HSN'),
                      value: '2',
                      groupValue: option,
                      onChanged: (value) {
                        setState(() {
                          option = value;
                          commonSelected = false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context, false);
                            },
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xffF2F2F2),
                              ),
                              child: const Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Color(0xff575757),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                showDialog(
                                  context: context,
                                  builder: (builder) {
                                    return const Modal(
                                        title: "HSN Change",
                                        content:
                                            "Your common hsn value applied for your all products! Are you sure want to change HSN?",
                                        type: ModalType.danger);
                                  },
                                ).then((value) async {
                                  if (value != null) {
                                    if (value) {
                                      loading(context);
                                      await LocalService.updateHSN(hsn.text,
                                              value:
                                                  option == "1" ? true : false)
                                          .then(
                                        (value) {
                                          Navigator.pop(context);
                                          Navigator.pop(context, true);
                                        },
                                      );
                                    }
                                  }
                                });
                              }
                            },
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: const Center(
                                child: Text(
                                  "Confirm",
                                  style: TextStyle(
                                    color: Color(0xffF4F4F9),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
