import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_kot/services/firebase/firestore.dart';
import 'package:sri_kot/utils/src/utilities.dart';
import 'package:sri_kot/view/ui/src/toast.dart';

class CustomCityAlert extends StatefulWidget {
  final String state;
  const CustomCityAlert({super.key, required this.state});

  @override
  State<CustomCityAlert> createState() => _CustomCityAlertState();
}

class _CustomCityAlertState extends State<CustomCityAlert> {
  TextEditingController city = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add custom city",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: city,
                cursorColor: Theme.of(context).primaryColor,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "Custom City",
                  filled: true,
                  fillColor: Color(0xfff1f5f9),
                  prefixIcon: Icon(
                    CupertinoIcons.location_solid,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "City is must";
                  } else if (value.contains(RegExp(r'\s'))) {
                    return 'White spaces not allowed';
                  }
                  return null;
                },
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
                        FocusManager.instance.primaryFocus!.unfocus();
                        if (formKey.currentState!.validate()) {
                          loading(context);
                          await FireStore()
                              .addCustomCity(
                            state: widget.state,
                            city: city.text,
                          )
                              .then((value) {
                            if (value) {
                              Navigator.pop(context);
                              Navigator.pop(context, true);
                              showToast(context,
                                  content: "City added",
                                  isSuccess: true,
                                  top: false);
                            } else {
                              Navigator.pop(context);
                              showToast(context,
                                  content: "City already exist",
                                  isSuccess: false,
                                  top: false);
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
        ),
      ),
    );
  }
}
