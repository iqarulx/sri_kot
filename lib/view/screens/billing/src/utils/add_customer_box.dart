import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';

class AddCustomerBox extends StatefulWidget {
  final bool isEdit;
  final CustomerDataModel? customerData;
  final String? docId;
  final bool isInvoice;
  const AddCustomerBox(
      {super.key,
      required this.isEdit,
      this.customerData,
      this.docId,
      required this.isInvoice});

  @override
  State<AddCustomerBox> createState() => _AddCustomerBoxState();
}

class _AddCustomerBoxState extends State<AddCustomerBox> {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(15),
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.84,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  iconTheme: const IconThemeData(color: Colors.black),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarIconBrightness: Brightness.dark,
                    statusBarColor: Colors.transparent,
                  ),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    splashRadius: 20,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                  titleSpacing: 0,
                  title: const Text(
                    "Add New Customer",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                bottomNavigationBar: SizedBox(
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
                body: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: addCustomerKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          InputForm(
                            controller: customerName,
                            labelName: "Name",
                            formName: "Customer Name",
                            prefixIcon: Icons.person,
                            validation: (p0) {
                              return FormValidation().commonValidation(
                                input: p0,
                                isMandatory: widget.isInvoice ? true : false,
                                formName: 'Customer Name',
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          InputForm(
                            autofocus: true,
                            controller: mobileNo,
                            labelName: "Mobile No",
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
                            prefixIcon: Icons.place_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validation: (p0) {
                              return FormValidation()
                                  .addressValidation(p0 ?? '', false);
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
                                isMandatory: widget.isInvoice ? true : false,
                                formName: "State",
                                isOnlyCharter: false,
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
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
                                isMandatory: widget.isInvoice ? true : false,
                                formName: "City",
                                isOnlyCharter: false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            customerData.city = city;
            customerData.customerName = customerName.text;
            customerData.email = email.text;
            customerData.mobileNo = mobileNo.text;

            if (widget.isEdit) {
              // await FireStore()
              //     .checkCustomerAlreadyRegistered(mobileNo: mobileNo.text)
              //     .then((value) async {
              await FireStore()
                  .updateCustomer(
                      docID: widget.customerData!.docID ?? '',
                      customerData: customerData)
                  .then((value) {
                Navigator.pop(context);
                CustomerDataModel cusdata = CustomerDataModel();
                cusdata.companyID = cid;
                cusdata.address = address.text;
                cusdata.city = city;
                cusdata.customerName = customerName.text;
                cusdata.email = email.text;
                cusdata.mobileNo = mobileNo.text;
                cusdata.state = state;
                cusdata.docID = widget.customerData!.docID;

                Navigator.pop(context, cusdata);

                showToast(
                  context,
                  top: false,
                  isSuccess: true,
                  content: "Successfully Created New Customer",
                );
                // });
              });
            } else {
              await FireStore()
                  .checkCustomerMobileNoRegistered(mobileNo: mobileNo.text)
                  .then((value) async {
                if (value) {
                  await FireStore()
                      .registerCustomer(customerData: customerData)
                      .then((value) {
                    Navigator.pop(context);
                    if (value.id.isNotEmpty) {
                      CustomerDataModel cusdata = CustomerDataModel();
                      cusdata.companyID = cid;
                      cusdata.address = address.text;
                      cusdata.city = city;
                      cusdata.customerName = customerName.text;
                      cusdata.email = email.text;
                      cusdata.mobileNo = mobileNo.text;
                      cusdata.docID = value.id;
                      cusdata.state = state;

                      Navigator.pop(context, cusdata);

                      showToast(
                        context,
                        top: false,
                        isSuccess: true,
                        content: "Successfully Created New Customer",
                      );
                    } else {
                      Navigator.pop(context);
                      showToast(
                        context,
                        top: false,
                        isSuccess: true,
                        content: "Failed to Create New Customer",
                      );
                    }
                  });
                } else {
                  Navigator.pop(context);
                  showToast(
                    context,
                    top: false,
                    isSuccess: false,
                    content: "This mobile number is already registered",
                  );
                }
              });
            }
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

  @override
  void initState() {
    initFun();
    super.initState();
  }

  initFun() {
    if (widget.isEdit) {
      setState(() {
        customerName.text = widget.customerData!.customerName ?? '';
        mobileNo.text = widget.customerData!.mobileNo ?? '';
        email.text = widget.customerData!.email ?? '';
        address.text = widget.customerData!.address ?? '';
      });

      if (widget.customerData!.state != null &&
          widget.customerData!.city != null) {
        if (widget.customerData!.state!.isNotEmpty &&
            widget.customerData!.city!.isNotEmpty) {
          setState(() {
            state = widget.customerData!.state;
            city = widget.customerData!.city;
          });
        }
      }
    }
  }

  TextEditingController customerName = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  var addCustomerKey = GlobalKey<FormState>();
  String? city;
  String? state;
  List<DropdownMenuItem<String>> stateMenuList = [];
  List<DropdownMenuItem<String>> cityMenuList = [];
}
