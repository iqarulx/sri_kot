import 'package:flutter/material.dart';

import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  TextEditingController customerName = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController identificationNo = TextEditingController();

  var addCustomerKey = GlobalKey<FormState>();

  String? city;
  String? state;
  List<DropdownMenuItem<String>> stateMenuList = [];
  List<DropdownMenuItem<String>> cityMenuList = [];

  checkValidation() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (addCustomerKey.currentState!.validate()) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            var customerData = CustomerDataModel();
            customerData.companyID = cid;
            customerData.address = address.text;
            customerData.companyName = customerData.city = city;
            customerData.customerName = customerName.text;
            customerData.email = email.text;
            customerData.mobileNo = mobileNo.text;
            customerData.state = state;
            if (identificationType != null) {
              customerData.identificationType = identificationType;
              customerData.identificationNo = identificationNo.text;
            }
            customerData.isCompany = customerType == "1" ? false : true;
            Navigator.pop(context);
            await FireStore()
                .checkCustomerMobileNoRegistered(mobileNo: mobileNo.text)
                .then((value) async {
              if (value) {
                if (identificationType != null &&
                    identificationNo.text.isNotEmpty) {
                  await FireStore()
                      .checkCustomerIdentityRegistered(
                          identificationNo: identificationNo.text)
                      .then((value) async {
                    if (value) {
                      await FireStore()
                          .registerCustomer(customerData: customerData)
                          .then((value) {
                        Navigator.pop(context);
                        if (value.id.isNotEmpty) {
                          Navigator.pop(context, true);
                          snackbar(context, true,
                              "Successfully Created New Customer");
                        } else {
                          snackbar(
                              context, false, "Failed to Create New Customer");
                        }
                      });
                    } else {
                      Navigator.pop(context);
                      snackbar(context, false,
                          "Customer identity already registered");
                    }
                  });
                } else {
                  await FireStore()
                      .registerCustomer(customerData: customerData)
                      .then((value) {
                    Navigator.pop(context);
                    if (value.id.isNotEmpty) {
                      Navigator.pop(context, true);
                      snackbar(
                          context, true, "New Customer Created Successfully");
                    } else {
                      snackbar(context, false, "Failed to Create New Customer");
                    }
                  });
                }
              } else {
                Navigator.pop(context);
                snackbar(context, false, "Customer mobile no already exist");
              }
            });
          } else {
            Navigator.pop(context);
            snackbar(context, false, "Company Details Not Fetch");
          }
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  chooseState() async {
    await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (builder) {
        return const FractionallySizedBox(
          heightFactor: 0.9,
          child: StateSearch(),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          state = value;
          setState(() {});
        }
      },
    );
  }

  chooseCity() async {
    if (state != null) {
      await showModalBottomSheet(
        backgroundColor: Colors.white,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (builder) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: CitySearch(
              state: state!,
            ),
          );
        },
      ).then(
        (value) {
          if (value != null) {
            city = value;
            setState(() {});
          }
        },
      );
    }
  }

  String customerType = "1";
  List<DropdownMenuItem<String>> identificationTypeList = [
    const DropdownMenuItem(
      value: null,
      child: Text(
        "Select identification type",
        style: TextStyle(color: Colors.grey),
      ),
    ),
    const DropdownMenuItem(
      value: "Adhaar No",
      child: Text("Adhaar No"),
    ),
    const DropdownMenuItem(
      value: "Pan No",
      child: Text("Pan No"),
    ),
    const DropdownMenuItem(
      value: "Others",
      child: Text("Others"),
    ),
  ];

  String? identificationType;
  bool isGstAdded = false;

  addGstIfNotPresent() {
    if (!isGstAdded) {
      identificationTypeList.add(const DropdownMenuItem(
        value: "GST No",
        child: Text("GST No"),
      ));
      isGstAdded = true;
    }
  }

  void removeGstIfPresent() {
    if (isGstAdded) {
      setState(() {
        if (identificationType == "GST No") {
          identificationType = null;
        }
        identificationTypeList.removeWhere((item) => item.value == "GST No");
        isGstAdded = false;
      });
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
        title: const Text("Add Customer"),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: addCustomerKey,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Customer Type",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Customer'),
                              value: '1',
                              toggleable: true,
                              groupValue: customerType,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    customerType = value;
                                    removeGstIfPresent();
                                  });
                                }
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Company'),
                              value: '2',
                              groupValue: customerType,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    customerType = value;
                                    addGstIfNotPresent();
                                  });
                                }
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InputForm(
                    controller: customerName,
                    labelName:
                        customerType == "1" ? "Customer Name" : "Company Name",
                    formName:
                        customerType == "1" ? "Customer Name" : "Company Name",
                    prefixIcon: Icons.person,
                    validation: (p0) {
                      return FormValidation().commonValidation(
                        input: p0,
                        isMandatory: false,
                        formName: customerType == "1"
                            ? "Customer Name"
                            : "Company Name",
                        isOnlyCharter: false,
                      );
                    },
                  ),
                  InputForm(
                    controller: mobileNo,
                    labelName: "Mobile No (*)",
                    formName: "Mobile Number",
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validation: (p0) {
                      return FormValidation().phoneValidation(
                        input: p0.toString(),
                        isMandatory: true,
                        labelName: 'Mobile Number',
                      );
                    },
                  ),
                  InputForm(
                    controller: email,
                    labelName: "Email",
                    formName: "Email Address",
                    prefixIcon: Icons.alternate_email,
                    keyboardType: TextInputType.emailAddress,
                    validation: (p0) {
                      return FormValidation().emailValidation(
                        input: p0.toString(),
                        labelName: "Email Address",
                        isMandatory: false,
                      );
                    },
                  ),
                  InputForm(
                    controller: address,
                    labelName: "Address",
                    formName: "Address",
                    prefixIcon: Icons.pin_drop_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validation: (p0) {
                      return FormValidation().commonValidation(
                        input: p0,
                        isMandatory: false,
                        formName: 'Address',
                        isOnlyCharter: false,
                      );
                    },
                  ),
                  InputForm(
                    onTap: () {
                      chooseState();
                    },
                    labelName: "State",
                    controller: TextEditingController(text: state),
                    formName: "State",
                    readOnly: true,
                    prefixIcon: Icons.map_outlined,
                    validation: (input) {
                      return FormValidation().commonValidation(
                        input: input,
                        isMandatory: false,
                        formName: "State",
                        isOnlyCharter: false,
                      );
                    },
                  ),
                  InputForm(
                    onTap: () {
                      chooseCity();
                    },
                    labelName: "City",
                    controller: TextEditingController(text: city),
                    formName: "City",
                    readOnly: true,
                    prefixIcon: Icons.explore_outlined,
                    validation: (input) {
                      return FormValidation().commonValidation(
                        input: input,
                        isMandatory: false,
                        formName: "City",
                        isOnlyCharter: false,
                      );
                    },
                  ),
                  InputForm(
                    controller: pincode,
                    labelName: "Pin code",
                    formName: "Pin code",
                    prefixIcon: Icons.pin_drop_rounded,
                    keyboardType: TextInputType.number,
                    validation: (p0) {
                      return FormValidation().pincodeValidation(
                        input: p0 ?? '',
                        isMandatory: false,
                      );
                    },
                  ),
                  DropDownForm(
                    formName: "Identification",
                    onChange: (v) {
                      setState(() {
                        identificationType = v;
                      });
                    },
                    labelName: "Identification Type",
                    value: identificationType,
                    isMandatory: false,
                    listItems: identificationTypeList,
                  ),
                  if (identificationType != null)
                    Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        InputForm(
                          controller: identificationNo,
                          labelName: identificationType,
                          formName: identificationType ?? '',
                          prefixIcon: Icons.shield_rounded,
                          keyboardType: TextInputType.text,
                          validation: (p0) {
                            if (identificationType == "Adhaar No") {
                              return FormValidation()
                                  .aadhaarValidation(p0 ?? '', true);
                            } else if (identificationType == "Pan No") {
                              return FormValidation()
                                  .panValidation(p0 ?? '', true);
                            } else if (identificationType == "GST No") {
                              return FormValidation().gstValidation(
                                  input: p0 ?? '', isMandatory: true);
                            } else if (identificationType == "Others") {
                              return FormValidation().commonValidation(
                                formName: "Identity",
                                isOnlyCharter: false,
                                input: p0 ?? '',
                                isMandatory: true,
                              );
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: 65,
          child: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: outlinButton(
                      context,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      btnName: "Cancel",
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 4,
                    child: fillButton(
                      context,
                      onTap: () {
                        checkValidation();
                      },
                      btnName: "Submit",
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
