import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/services.dart';
import '/view/auth/auth.dart';
import '/services/firebase/messaging.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/utils/utils.dart';

class RegisterCompany extends StatefulWidget {
  final String docid;
  final String companyName;
  final String username;
  final String email;
  final String password;
  const RegisterCompany({
    super.key,
    required this.docid,
    required this.companyName,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterCompany> createState() => _RegisterCompanyState();
}

class _RegisterCompanyState extends State<RegisterCompany> {
  //***************** UI *********************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    key: companyKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Company Profile",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        companyNameField(context),
                        const SizedBox(
                          height: 10,
                        ),
                        companyUniqueIdField(context),
                        const SizedBox(
                          height: 10,
                        ),
                        userNameField(context),
                        const SizedBox(
                          height: 10,
                        ),
                        addressField(context),
                        const SizedBox(
                          height: 10,
                        ),
                        stateField(),
                        const SizedBox(
                          height: 10,
                        ),
                        cityField(),
                        const SizedBox(
                          height: 10,
                        ),
                        pincodeField(context),
                        const SizedBox(
                          height: 10,
                        ),
                        mobileNoField(),
                        phoneNoField(),
                        gstNoField(),
                        const SizedBox(
                          height: 10,
                        ),
                        taxTypeField(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: submit(context),
    );
  }

  BottomAppBar submit(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    register();
                  },
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DropDownForm taxTypeField() {
    return DropDownForm(
      formName: "Tax Type",
      onChange: (v) {
        if (v == 'Composite') {
          setState(() {
            taxType = false;
          });
        } else if (v == 'Regular') {
          setState(() {
            taxType = true;
          });
        }
      },
      labelName: "Tax Type",
      value: taxType == null
          ? taxType == false
              ? 'Composite'
              : 'Regular'
          : null,
      validator: (p0) {
        if (p0 == null) {
          return "Tax type is must";
        }
        return null;
      },
      listItems: const [
        DropdownMenuItem(
          value: null,
          child: Text(
            "Select tax type",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        DropdownMenuItem(
          value: "Regular",
          child: Text("Regular"),
        ),
        DropdownMenuItem(
          value: "Composite",
          child: Text("Composite"),
        ),
      ],
    );
  }

  InputForm gstNoField() {
    return InputForm(
      labelName: "GST No",
      controller: gst,
      formName: "GST No",
      validation: (input) {
        return FormValidation().gstValidation(
          input: input ?? '',
          isMandatory: true,
        );
      },
    );
  }

  InputForm phoneNoField() {
    return InputForm(
      labelName: "Phone No",
      controller: phoneno,
      formName: "Phone No",
      keyboardType: TextInputType.number,
      validation: (input) {
        return FormValidation().phoneValidation(
          input: input ?? '',
          isMandatory: true,
          labelName: "Phone No",
        );
      },
    );
  }

  InputForm mobileNoField() {
    return InputForm(
      labelName: "Mobile No",
      controller: mobileno,
      formName: "Mobile No",
      keyboardType: TextInputType.number,
      validation: (input) {
        return FormValidation().phoneValidation(
          input: input ?? '',
          isMandatory: true,
          labelName: "Mobile No",
        );
      },
    );
  }

  SizedBox pincodeField(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pincode",
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
            controller: pincode,
            cursorColor: Theme.of(context).primaryColor,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              fillColor: Color(0xfff1f5f9),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              hintText: "Pincode",
              prefixIcon: Icon(
                Icons.near_me_outlined,
              ),
            ),
            validator: (value) {
              return FormValidation().commonValidation(
                input: value,
                isMandatory: true,
                formName: "Pincode",
                isOnlyCharter: false,
              );
            },
          ),
        ],
      ),
    );
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

  InputForm cityField() {
    return InputForm(
      onTap: () {
        chooseCity();
      },
      labelName: "City",
      controller: TextEditingController(text: city),
      formName: "City",
      readOnly: true,
      suffixIcon: const Icon(Icons.arrow_drop_down),
      validation: (input) {
        return FormValidation().commonValidation(
          input: input,
          isMandatory: true,
          formName: "City",
          isOnlyCharter: false,
        );
      },
    );
  }

  InputForm stateField() {
    return InputForm(
      onTap: () {
        chooseState();
      },
      labelName: "State",
      controller: TextEditingController(text: state),
      formName: "State",
      readOnly: true,
      suffixIcon: const Icon(Icons.arrow_drop_down),
      validation: (input) {
        return FormValidation().commonValidation(
          input: input,
          isMandatory: true,
          formName: "State",
          isOnlyCharter: false,
        );
      },
    );
  }

  SizedBox addressField(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Address",
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
            maxLines: 5,
            controller: address,
            cursorColor: Theme.of(context).primaryColor,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              fillColor: Color(0xfff1f5f9),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              hintText: "Address",
              prefixIcon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
                child: Icon(
                  Icons.place_outlined,
                ),
              ),
            ),
            validator: (value) {
              return FormValidation().commonValidation(
                input: value,
                isMandatory: true,
                formName: "Address",
                isOnlyCharter: false,
              );
            },
          ),
        ],
      ),
    );
  }

  SizedBox userNameField(BuildContext context) {
    return SizedBox(
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
            controller: username,
            cursorColor: Theme.of(context).primaryColor,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              fillColor: Color(0xfff1f5f9),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              hintText: "User Full Name",
              prefixIcon: Icon(
                Icons.business_outlined,
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "User Name is must";
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    );
  }

  SizedBox companyUniqueIdField(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Company Unique ID",
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
            controller: companyUniqueId,
            cursorColor: Theme.of(context).primaryColor,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              fillColor: Color(0xfff1f5f9),
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              hintText: "Company UnqiueId",
              prefixIcon: Icon(
                Icons.alternate_email_outlined,
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value!.isEmpty) {
                return "Company Unqiue ID is must";
              } else if (value.length < 8) {
                return "Company Unqiue ID should be minimum 8 characters";
              } else if (value.isNotEmpty && value.startsWith('@')) {
                return "Please Remove @ symbol";
              } else if (RegExp(r"(?=.*[a-z])(?=.*[A-Z])\w+").hasMatch(value)) {
                return "Only use lowercase";
              } else if (value.contains(RegExp(r'\s'))) {
                return 'White spaces not allowed';
              } else {
                return null;
              }
            },
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "Example: @${widget.companyName}, @${widget.companyName}0123",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "Note: Company Unique ID is one time creation, Once Create its not changeable",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  SizedBox companyNameField(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            controller: companyname,
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
                Icons.business_outlined,
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Company Name is must";
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      centerTitle: false,
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        "Register Your Company",
        style: TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //***************** Rigister *********************

  register() async {
    try {
      FocusManager.instance.primaryFocus!.unfocus();

      if (companyKey.currentState!.validate()) {
        loading(context);
        FireStore fireStore = FireStore();

        ProfileModel model = ProfileModel();
        model.docId = widget.docid;
        model.username = username.text;
        model.address = address.text;
        model.city = city;
        model.companyName = companyname.text;
        model.deviceLimit = 1;
        model.gstno = gst.text;
        model.contact = {
          "mobile_no": mobileno.text,
          "phone_no": phoneno.text,
        };
        model.taxType = taxType;
        model.pincode = pincode.text;
        model.state = state;
        model.filled = true;
        model.password = widget.password;
        model.companyUniqueID = companyUniqueId.text;

        DeviceModel deviceData = DeviceModel();
        deviceData.deviceId = null;
        deviceData.modelName = null;
        deviceData.deviceName = null;
        deviceData.lastlogin = DateTime.now();
        deviceData.deviceType = null;
        model.device = deviceData.toMap();

        model.companyLogo = null;
        model.invoiceEntry = false;
        model.created = DateTime.now();
        model.freeTrial = {"opened": null, "ends_in": null};
        model.maxStaffCount = 0;
        model.maxUserCount = 0;
        model.plan = PlanTypes.free.name;
        model.expiryDate = DateTime.now().add(const Duration(days: 365));
        model.hsn = {"common_hsn": false, "common_hsn_value": null};
        model.userType = "normal";
        model.profileImg = null;

        await fireStore
            .updateCompanyInfo(profileInfo: model)
            .then((value) async {
          Navigator.pop(context);
          snackbar(context, true, "Successfully company registred");
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const Auth(),
            ),
          );

          await Messaging.sendNewCompanyAdmin(
              docId: widget.docid, companyName: widget.companyName);
        });
      }
    } on Exception catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    companyname.text = widget.companyName;
    username.text = widget.username;
  }

  //***************** State / City *********************

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
            state: state,
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

  //***************** Variables *********************

  TextEditingController username = TextEditingController();
  TextEditingController companyname = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phoneno = TextEditingController();
  TextEditingController mobileno = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController gst = TextEditingController();
  TextEditingController companyUniqueId = TextEditingController();
  String city = "";
  String state = "";
  bool? taxType;
  var companyKey = GlobalKey<FormState>();
}
