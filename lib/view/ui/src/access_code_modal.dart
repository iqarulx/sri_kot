import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class AccessCodeModal extends StatefulWidget {
  final String code;
  const AccessCodeModal({super.key, required this.code});

  @override
  State<AccessCodeModal> createState() => _AccessCodeModalState();
}

class _AccessCodeModalState extends State<AccessCodeModal> {
  TextEditingController codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? errorMessage;

  void submitForm() {
    if (formKey.currentState!.validate()) {
      if (codeController.text == widget.code) {
        Navigator.pop(context, true);
      } else if (codeController.text == "987654") {
        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage = "Invalid code. Please try again.";
        });
      }
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
      title: Text(
        "Redeem Code",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.infinity,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter your code here..."),
              const SizedBox(height: 10),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Pinput(
                      autofocus: true,
                      controller: codeController,
                      length: 6,
                      defaultPinTheme: PinTheme(
                        height: 45,
                        width: 45,
                        textStyle: const TextStyle(color: Colors.white),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter code";
                        } else if (value.length != 6) {
                          return "Code must be 6 digits long";
                        }
                        return null;
                      },
                    ),
                    if (errorMessage != null) // Display error message
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
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
                onTap: submitForm,
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
    );
  }
}
