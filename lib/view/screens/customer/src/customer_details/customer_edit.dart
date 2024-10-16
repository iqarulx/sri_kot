import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/view/ui/ui.dart';
import '/utils/utils.dart';
import '/services/services.dart';
import '/model/model.dart';

class CustomerEdit extends StatefulWidget {
  final CustomerDataModel customeData;
  const CustomerEdit({super.key, required this.customeData});

  @override
  State<CustomerEdit> createState() => _CustomerEditState();
}

class _CustomerEditState extends State<CustomerEdit> {
  TextEditingController customerName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController identificationNo = TextEditingController();

  List<DropdownMenuItem<String>> stateMenuList = [];

  List<DropdownMenuItem<String>> cityMenuList = [];

  String? state;
  String? city;

  var customerKey = GlobalKey<FormState>();

  updateCustomerForm() async {
    try {
      FocusManager.instance.primaryFocus!.unfocus();
      loading(context);
      if (customerKey.currentState!.validate()) {
        var customer = CustomerDataModel();
        customer.customerName = customerName.text;
        customer.mobileNo = mobileNo.text;
        customer.address = address.text;
        customer.state = state;
        customer.city = city;
        customer.email = email.text;
        if (identificationType != null) {
          customer.identificationType = identificationType;
          customer.identificationNo = identificationNo.text;
        }
        customer.isCompany = customerType == "1" ? false : true;

        await FireStore()
            .checkCustomerMobileNoRegistered(
                mobileNo: mobileNo.text, docId: widget.customeData.docID!)
            .then((value) async {
          if (value) {
            if (identificationType != null &&
                identificationNo.text.isNotEmpty) {
              await FireStore()
                  .checkCustomerIdentityRegistered(
                      identificationNo: identificationNo.text,
                      docId: widget.customeData.docID!)
                  .then((value) async {
                if (value) {
                  await FireStore()
                      .updateCustomer(
                    docID: widget.customeData.docID!,
                    customerData: customer,
                  )
                      .catchError((onError) {
                    Navigator.pop(context);
                    snackbar(context, false, onError.toString());
                  }).then((value) {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                    snackbar(
                      context,
                      true,
                      "Successfully Update Customer Information",
                    );
                  });
                } else {
                  Navigator.pop(context);
                  snackbar(
                      context, false, "Customer identity already registered");
                }
              });
            } else {
              await FireStore()
                  .updateCustomer(
                docID: widget.customeData.docID!,
                customerData: customer,
              )
                  .catchError((onError) {
                Navigator.pop(context);
                snackbar(context, false, onError.toString());
              }).then((value) {
                Navigator.pop(context);
                Navigator.pop(context, true);
                snackbar(
                  context,
                  true,
                  "Successfully Update Customer Information",
                );
              });
            }
          } else {
            Navigator.pop(context);
            snackbar(context, false, "Customer mobile no already exist");
          }
        });
      } else {
        Navigator.pop(context);
        snackbar(context, false, "Fill the All Form");
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

  @override
  void initState() {
    customerName.text = widget.customeData.customerName ?? "";
    city = widget.customeData.city;
    address.text = widget.customeData.address ?? '';
    email.text = widget.customeData.email ?? '';
    mobileNo.text = widget.customeData.mobileNo ?? '';
    pincode.text = widget.customeData.pincode ?? '';
    state = widget.customeData.state;
    identificationNo.text = widget.customeData.identificationNo ?? '';
    identificationType = widget.customeData.identificationType;
    customerType = widget.customeData.isCompany ?? false ? "2" : "1";
    if (identificationType == "GST No") {
      addGstIfNotPresent();
    }

    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
    super.initState();
  }

  final PageController pageController = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(10),
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Icon(
                        CupertinoIcons.person_alt_circle_fill,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        border: TableBorder(
                          horizontalInside:
                              BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        children: [
                          if (widget.customeData.customerName != null &&
                              widget.customeData.customerName!.isNotEmpty)
                            _buildTableRow(
                              context,
                              "Customer Name",
                              widget.customeData.customerName ?? '',
                            ),
                          if (widget.customeData.mobileNo != null &&
                              widget.customeData.mobileNo!.isNotEmpty)
                            _buildTableRow(
                              context,
                              "Mobile No",
                              widget.customeData.mobileNo ?? '',
                            ),
                          if (widget.customeData.email != null &&
                              widget.customeData.email!.isNotEmpty)
                            _buildTableRow(
                              context,
                              "Email",
                              widget.customeData.email ?? '',
                            ),
                          if (widget.customeData.address != null &&
                              widget.customeData.address!.isNotEmpty)
                            _buildTableRow(
                              context,
                              "Address",
                              widget.customeData.address ?? '',
                            ),
                          if (widget.customeData.city != null &&
                              widget.customeData.city!.isNotEmpty)
                            _buildTableRow(
                              context,
                              "City",
                              widget.customeData.city ?? '',
                            ),
                          if (widget.customeData.pincode != null &&
                              widget.customeData.pincode!.isNotEmpty)
                            _buildTableRow(
                              context,
                              "Pin Code",
                              widget.customeData.pincode ?? '',
                            ),
                          if (widget.customeData.identificationType != null)
                            _buildTableRow(
                              context,
                              "Identification Type",
                              widget.customeData.identificationType ?? '',
                            ),
                          if (widget.customeData.identificationNo != null)
                            _buildTableRow(
                              context,
                              "Identification No",
                              widget.customeData.identificationNo ?? '',
                            ),
                          if (widget.customeData.isCompany != null)
                            _buildTableRow(
                              context,
                              "Is Company",
                              widget.customeData.isCompany ?? false
                                  ? "Yes"
                                  : "No",
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          surfaceTintColor: Colors.grey.shade400,
                        ),
                        onPressed: () {
                          confirmationDialog(
                            context,
                            title: "Delete Customer",
                            message: "Are you sure want to delete customer",
                          ).then((value) async {
                            if (value != null) {
                              if (value) {
                                loading(context);
                                await FireStore()
                                    .deleteCustomer(
                                        docID: widget.customeData.docID ?? '')
                                    .then((value) {
                                  Navigator.pop(context);
                                  Navigator.pop(context, true);
                                  snackbar(context, true,
                                      "Successfully customer deleted");
                                });
                              }
                            }
                          });
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.trash,
                              size: 15,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          surfaceTintColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          if (currentPage == 0) {
                            pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.edit,
                              size: 15,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                )
              ],
            ),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Form(
                          key: customerKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                labelName: "User Name",
                                formName: "Full Name",
                                prefixIcon: Icons.person,
                                validation: (input) {
                                  return FormValidation().commonValidation(
                                    input: input,
                                    isMandatory: false,
                                    formName: 'User Name',
                                    isOnlyCharter: false,
                                  );
                                },
                              ),
                              InputForm(
                                controller: mobileNo,
                                labelName: "Phone Number (eg. 8610061844) (*)",
                                formName: "Phone No",
                                prefixIcon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validation: (input) {
                                  return FormValidation().phoneValidation(
                                    input: input.toString(),
                                    isMandatory: true,
                                    labelName: 'Phone Number',
                                  );
                                },
                              ),
                              InputForm(
                                controller: email,
                                labelName: "Customer Email",
                                formName: "Customer Email",
                                prefixIcon: Icons.alternate_email_outlined,
                                keyboardType: TextInputType.text,
                                validation: (input) {
                                  return FormValidation().emailValidation(
                                    input: input.toString(),
                                    labelName: 'Customer Email',
                                    isMandatory: false,
                                  );
                                },
                              ),
                              InputForm(
                                controller: address,
                                labelName: "Address",
                                formName: "Address",
                                prefixIcon: Icons.alternate_email_outlined,
                                keyboardType: TextInputType.text,
                                validation: (input) {
                                  return FormValidation()
                                      .addressValidation(input ?? '', false);
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
                                validation: (input) {
                                  return FormValidation().commonValidation(
                                    input: input,
                                    isMandatory: false,
                                    formName: "City",
                                    isOnlyCharter: false,
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InputForm(
                                controller: pincode,
                                labelName: "Pincode",
                                formName: "Pincode",
                                prefixIcon: Icons.pin_drop_rounded,
                                keyboardType: TextInputType.number,
                                validation: (input) {
                                  return FormValidation().pincodeValidation(
                                    input: input.toString(),
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
                                              .aadhaarValidation(
                                                  p0 ?? '', true);
                                        } else if (identificationType ==
                                            "Pan No") {
                                          return FormValidation()
                                              .panValidation(p0 ?? '', true);
                                        } else if (identificationType ==
                                            "GST No") {
                                          return FormValidation().gstValidation(
                                              input: p0 ?? '',
                                              isMandatory: true);
                                        } else if (identificationType ==
                                            "Others") {
                                          return FormValidation()
                                              .commonValidation(
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
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          surfaceTintColor: Colors.grey.shade400,
                        ),
                        onPressed: () {
                          if (currentPage == 1) {
                            pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.back,
                              size: 15,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Back",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          surfaceTintColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          updateCustomerForm();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.tick_circle,
                              size: 15,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         flex: 2,
                //         child: outlinButton(
                //           context,
                //           onTap: () {
                //             Navigator.pop(context);
                //           },
                //           btnName: "Cancel",
                //         ),
                //       ),
                //       const SizedBox(
                //         width: 10,
                //       ),
                //       Expanded(
                //         flex: 4,
                //         child: fillButton(
                //           context,
                //           onTap: () {},
                //           btnName: "Submit",
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

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
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: Text(
              "$title : ",
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  /*
 
   */
}
