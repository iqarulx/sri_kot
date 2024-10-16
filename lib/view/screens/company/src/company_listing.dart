import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';

class CompanyListing extends StatefulWidget {
  const CompanyListing({super.key});

  @override
  State<CompanyListing> createState() => _CompanyListingState();
}

class _CompanyListingState extends State<CompanyListing> {
  TextEditingController name = TextEditingController();
  TextEditingController companyName = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController gstno = TextEditingController();
  TextEditingController userid = TextEditingController();
  TextEditingController password = TextEditingController();

  File? uploadCompanyPic;
  File? uploadProfilePic;

  String? oldEmail;
  String? oldPassword;
  var companyFormKey = GlobalKey<FormState>();
  var profileFormKey = GlobalKey<FormState>();
  String? companyLogo;
  String? profileImg;
  bool taxType = true;
  int invoiceCount = 0;
  String city = "";
  String state = "";

  Future getCompanyInfo() async {
    try {
      FireStore provider = FireStore();
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        final result = await provider.getCompanyDocInfo(cid: cid);

        if (result!.exists) {
          int dbInvoiceCount = await FireStore().getInvoiceCount();
          setState(() {
            invoiceCount = dbInvoiceCount;
          });
          setState(() {
            name.text = result["user_name"].toString();
            companyName.text = result["company_name"].toString();
            address.text = result["address"].toString();
            pincode.text = result["pincode"].toString();
            mobileNo.text = result["contact"]["mobile_no"].toString();
            phoneNo.text = result["contact"]["phone_no"].toString();
            gstno.text = result["gst_no"] ?? "";
            userid.text = result["user_login_id"].toString();
            password.text = result["password"].toString();
            oldEmail = result["user_login_id"].toString();
            oldPassword = result["password"].toString();
            companyLogo = result["company_logo"];
            profileImg = result["profile_img"];
            taxType = result["tax_type"] ?? false;
            profileImg = result["profile_img"];
            state = result["state"];
            city = result["city"];
          });
          return result;
        }
      }

      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  submit() async {
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (companyCurrentPage == 1) {
        if (companyFormKey.currentState!.validate()) {
          loading(context);
          await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
            if (cid != null) {
              ProfileModel profileModel = ProfileModel();
              profileModel.username = name.text;
              profileModel.companyName = companyName.text;
              profileModel.address = address.text;
              profileModel.pincode = pincode.text;
              profileModel.contact = {
                "mobile_no": mobileNo.text,
                "phone_no": phoneNo.text,
              };
              if (gstno.text.isNotEmpty) {
                profileModel.gstno = gstno.text;
              }
              profileModel.userLoginId = userid.text;
              profileModel.password = password.text;
              profileModel.taxType = taxType;
              await FireStore()
                  .updateCompany(docId: cid, companyData: profileModel)
                  .then((value) async {
                await FirebaseAuthProvider()
                    .updateUserLogin(
                  email: userid.text,
                  password: password.text,
                  oldEmail: oldEmail ?? "",
                  oldPassword: oldPassword ?? "",
                )
                    .then((value) async {
                  if (uploadCompanyPic != null) {
                    await Storage()
                        .deleteImage(companyLogo ?? '')
                        .then((value) async {
                      await Storage()
                          .uploadImage(
                        fileData: uploadCompanyPic!,
                        fileName:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        filePath: "company",
                      )
                          .then((downloadLink) async {
                        if (downloadLink != null && downloadLink.isNotEmpty) {
                          await FireStore()
                              .updateCompanyPic(
                                  docId: cid, imageLink: downloadLink)
                              .then((value) async {
                            Navigator.pop(context);
                            snackbar(
                              context,
                              true,
                              "Successfully Updated Company Information",
                            );
                          });
                        } else {
                          Navigator.pop(context);
                          snackbar(context, false, "Something went Wrong");
                        }
                      });
                    });
                  } else {
                    Navigator.pop(context);
                    snackbar(
                      context,
                      true,
                      "Successfully Updated Company Information",
                    );
                  }
                });
              });
            } else {
              Navigator.pop(context);
              snackbar(context, false, "Something went Wrong");
            }
          });
        }
      } else {
        loading(context);
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            ProfileModel profileModel = ProfileModel();
            profileModel.username = name.text;
            profileModel.companyName = companyName.text;
            profileModel.address = address.text;
            profileModel.pincode = pincode.text;
            profileModel.contact = {
              "mobile_no": mobileNo.text,
              "phone_no": phoneNo.text,
            };
            if (gstno.text.isNotEmpty) {
              profileModel.gstno = gstno.text;
            }
            profileModel.userLoginId = userid.text;
            profileModel.password = password.text;
            await FireStore()
                .updateCompany(docId: cid, companyData: profileModel)
                .then((value) async {
              await FirebaseAuthProvider()
                  .updateUserLogin(
                email: userid.text,
                password: password.text,
                oldEmail: oldEmail ?? "",
                oldPassword: oldPassword ?? "",
              )
                  .then((value) async {
                if (uploadProfilePic != null) {
                  if (profileImg != null) {
                    await Storage().deleteImage(profileImg ?? '');
                  }
                  await Storage()
                      .uploadImage(
                    fileData: uploadProfilePic!,
                    fileName: DateTime.now().millisecondsSinceEpoch.toString(),
                    filePath: "company",
                  )
                      .then((downloadLink) async {
                    if (downloadLink != null && downloadLink.isNotEmpty) {
                      print(cid);
                      await FireStore().updateProfilePic(
                          docId: cid, imageLink: downloadLink);
                    } else {
                      Navigator.pop(context);
                      snackbar(context, false, "Something went Wrong");
                    }
                  });
                }
                Navigator.pop(context);
                snackbar(
                  context,
                  true,
                  "Successfully Updated Company Information",
                );
                setState(() {
                  companyHandler = getCompanyInfo();
                });
              });
            });
          } else {
            Navigator.pop(context);
            snackbar(context, false, "Something went Wrong");
          }
        });
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  Future? companyHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);
        companyHandler = getCompanyInfo();
        companyPageController.addListener(() {
          setState(() {
            companyCurrentPage = companyPageController.page!.round();
          });
        });
        profilePageController.addListener(() {
          setState(() {
            profileCurrentPage = profilePageController.page!.round();
          });
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);
          companyHandler = getCompanyInfo();
        }
      });
    });
  }

  final PageController companyPageController = PageController();
  int companyCurrentPage = 0;

  final PageController profilePageController = PageController();
  int profileCurrentPage = 0;

  @override
  void dispose() {
    companyPageController.dispose();
    profilePageController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Company"),
          actions: [
            IconButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final connectionProvider =
                      Provider.of<ConnectionProvider>(context, listen: false);
                  if (connectionProvider.isConnected) {
                    AccountValid.accountValid(context);
                    companyHandler = getCompanyInfo();
                  }
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final connectionProvider =
                      Provider.of<ConnectionProvider>(context, listen: false);
                  connectionProvider.addListener(() {
                    if (connectionProvider.isConnected) {
                      AccountValid.accountValid(context);
                      companyHandler = getCompanyInfo();
                    }
                  });
                });
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: "Company Info",
              ),
              Tab(
                text: "Profile Info",
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx > 0) {
              Navigator.of(context).pop();
            }
          },
          child: Consumer<ConnectionProvider>(
            builder: (context, connectionProvider, child) {
              return connectionProvider.isConnected
                  ? screenView()
                  : noInternet(context);
            },
          ),
        ),
      ),
    );
  }

  FutureBuilder<dynamic> screenView() {
    return FutureBuilder(
      future: companyHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureLoading(context);
        } else if (snapshot.hasError) {
          return error(snapshot, context);
        } else {
          return TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
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
                    controller: companyPageController,
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
                                Center(
                                  child: SizedBox(
                                    height: 90,
                                    width: 90,
                                    child: ClipRRect(
                                      clipBehavior: Clip.hardEdge,
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        imageUrl:
                                            companyLogo ?? Strings.profileImg,
                                        fit: BoxFit.cover,
                                        height: 120,
                                        width: 120,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(3),
                                  },
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  children: [
                                    _buildTableRow(
                                      context,
                                      "Company Name",
                                      companyName.text,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "Address",
                                      address.text,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "City",
                                      city,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "State",
                                      state,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "Pincode",
                                      pincode.text,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "Mobile No",
                                      mobileNo.text,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "Phone No",
                                      phoneNo.text,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "Gst No",
                                      gstno.text,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "Tax Type",
                                      taxType ? "Regular" : "Composite",
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
                                  onPressed: () {},
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
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    surfaceTintColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    companyPageController.animateToPage(
                                      1,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                    setState(() {
                                      companyCurrentPage = 1;
                                    });
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
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            var imageResult =
                                                await FilePickerProvider()
                                                    .showFileDialog(context);
                                            if (imageResult != null) {
                                              setState(() {
                                                uploadCompanyPic = imageResult;
                                              });
                                            }
                                          },
                                          child: Center(
                                            child: SizedBox(
                                              height: 90,
                                              width: 90,
                                              child: Stack(
                                                children: [
                                                  uploadCompanyPic == null
                                                      ? ClipRRect(
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50.0),
                                                          child:
                                                              CachedNetworkImage(
                                                            placeholder: (context,
                                                                    url) =>
                                                                const Center(
                                                                    child:
                                                                        CircularProgressIndicator()),
                                                            imageUrl: companyLogo ??
                                                                Strings
                                                                    .profileImg,
                                                            fit: BoxFit.cover,
                                                            height: 120,
                                                            width: 120,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                          ))
                                                      : Container(
                                                          height: 90,
                                                          width: 90,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey.shade300,
                                                            shape:
                                                                BoxShape.circle,
                                                            image:
                                                                DecorationImage(
                                                              image: uploadCompanyPic!
                                                                      .existsSync()
                                                                  ? FileImage(
                                                                      uploadCompanyPic!)
                                                                  : AssetImage(
                                                                      Assets
                                                                          .images
                                                                          .noImage
                                                                          .path,
                                                                    ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .yellow.shade800,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          width: 2,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Form(
                                          key: companyFormKey,
                                          child: Column(
                                            children: [
                                              InputForm(
                                                controller: companyName,
                                                labelName: "Company Name (*)",
                                                formName: "Company Full Name",
                                                prefixIcon:
                                                    Icons.business_outlined,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .commonValidation(
                                                    input: input,
                                                    isMandatory: true,
                                                    formName: "Company Name",
                                                    isOnlyCharter: false,
                                                  );
                                                },
                                              ),
                                              InputForm(
                                                controller: address,
                                                labelName: "Address (*)",
                                                formName: "Company Address",
                                                prefixIcon:
                                                    Icons.place_outlined,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .addressValidation(
                                                          input ?? '', false);
                                                },
                                              ),
                                              InputForm(
                                                onTap: () {
                                                  chooseState();
                                                },
                                                prefixIcon:
                                                    Icons.place_outlined,
                                                labelName: "State",
                                                controller:
                                                    TextEditingController(
                                                        text: state),
                                                formName: "State",
                                                readOnly: true,
                                                suffixIcon: const Icon(
                                                    Icons.arrow_drop_down),
                                                validation: (input) {
                                                  return FormValidation()
                                                      .commonValidation(
                                                    input: input,
                                                    isMandatory: true,
                                                    formName: "State",
                                                    isOnlyCharter: false,
                                                  );
                                                },
                                              ),
                                              InputForm(
                                                onTap: () {
                                                  chooseCity();
                                                },
                                                prefixIcon:
                                                    Icons.place_outlined,
                                                labelName: "City",
                                                controller:
                                                    TextEditingController(
                                                        text: city),
                                                formName: "City",
                                                readOnly: true,
                                                suffixIcon: const Icon(
                                                    Icons.arrow_drop_down),
                                                validation: (input) {
                                                  return FormValidation()
                                                      .commonValidation(
                                                    input: input,
                                                    isMandatory: true,
                                                    formName: "City",
                                                    isOnlyCharter: false,
                                                  );
                                                },
                                              ),
                                              InputForm(
                                                controller: pincode,
                                                labelName: "Pincode (*)",
                                                formName: "Pincode",
                                                prefixIcon:
                                                    Icons.near_me_outlined,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .pincodeValidation(
                                                    input: input.toString(),
                                                    isMandatory: true,
                                                  );
                                                },
                                              ),
                                              InputForm(
                                                controller: mobileNo,
                                                labelName: "Mobile No (*)",
                                                formName: "Mobile Number",
                                                prefixIcon:
                                                    Icons.phone_outlined,
                                                keyboardType:
                                                    TextInputType.phone,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .phoneValidation(
                                                    input: input.toString(),
                                                    isMandatory: true,
                                                    labelName: "Mobile Number",
                                                  );
                                                },
                                              ),
                                              InputForm(
                                                controller: phoneNo,
                                                labelName: "Phone No",
                                                formName: "Phone Number",
                                                prefixIcon:
                                                    Icons.phone_outlined,
                                                keyboardType:
                                                    TextInputType.phone,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .phoneValidation(
                                                    input: input.toString(),
                                                    isMandatory: false,
                                                    labelName: "Phone Number",
                                                  );
                                                },
                                              ),
                                              InputForm(
                                                controller: gstno,
                                                labelName: taxType
                                                    ? "GST No (Regular Tax)"
                                                    : "GST No (Composite Tax)",
                                                formName: "GST Number",
                                                enabled: invoiceCount == 0
                                                    ? true
                                                    : false,
                                                prefixIcon: Iconsax.buildings,
                                                keyboardType:
                                                    TextInputType.text,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .gstValidation(
                                                    input: input.toString(),
                                                    isMandatory: false,
                                                  );
                                                },
                                              ),
                                              DropDownForm(
                                                enabled: invoiceCount == 0
                                                    ? true
                                                    : false,
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
                                                value: taxType == false
                                                    ? 'Composite'
                                                    : 'Regular',
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
                                                      style: TextStyle(
                                                          color: Colors.grey),
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
                                              ),
                                              if (invoiceCount != 0)
                                                Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "You can't edit your GST No and Tax Type\nBecause you made $invoiceCount invoices",
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                                        companyPageController.animateToPage(
                                          0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                        setState(() {
                                          companyCurrentPage = 0;
                                        });
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        surfaceTintColor:
                                            Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        submit();
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
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
                    controller: profilePageController,
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
                                Center(
                                  child: SizedBox(
                                    height: 90,
                                    width: 90,
                                    child: ClipRRect(
                                      clipBehavior: Clip.hardEdge,
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        imageUrl:
                                            profileImg ?? Strings.profileImg,
                                        fit: BoxFit.cover,
                                        height: 120,
                                        width: 120,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(3),
                                  },
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  children: [
                                    _buildTableRow(
                                      context,
                                      "User Name",
                                      name.text,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "User id",
                                      userid.text,
                                    ),
                                    _buildTableRow(
                                      context,
                                      "Password",
                                      password.text,
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
                                  onPressed: () {},
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
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    surfaceTintColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    profilePageController.animateToPage(
                                      1,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                    setState(() {
                                      profileCurrentPage = 1;
                                    });
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
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            var imageResult =
                                                await FilePickerProvider()
                                                    .showFileDialog(context);
                                            if (imageResult != null) {
                                              setState(() {
                                                uploadProfilePic = imageResult;
                                              });
                                            }
                                          },
                                          child: Center(
                                            child: SizedBox(
                                              height: 90,
                                              width: 90,
                                              child: Stack(
                                                children: [
                                                  uploadProfilePic == null
                                                      ? ClipRRect(
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50.0),
                                                          child:
                                                              CachedNetworkImage(
                                                            placeholder: (context,
                                                                    url) =>
                                                                const Center(
                                                                    child:
                                                                        CircularProgressIndicator()),
                                                            imageUrl: profileImg ??
                                                                Strings
                                                                    .profileImg,
                                                            fit: BoxFit.cover,
                                                            height: 120,
                                                            width: 120,
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                          ),
                                                        )
                                                      : Container(
                                                          height: 90,
                                                          width: 90,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image:
                                                                      DecorationImage(
                                                                    image: uploadProfilePic!
                                                                            .existsSync()
                                                                        ? FileImage(
                                                                            uploadProfilePic!)
                                                                        : AssetImage(
                                                                            Assets.images.noImage.path,
                                                                          ),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                        ),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .yellow.shade800,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          width: 2,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Form(
                                          key: profileFormKey,
                                          child: Column(
                                            children: [
                                              InputForm(
                                                controller: name,
                                                labelName: "User Name (*)",
                                                formName: "Full Name",
                                                prefixIcon: Icons.person,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .commonValidation(
                                                    input: input,
                                                    isMandatory: true,
                                                    formName: "Full Name",
                                                    isOnlyCharter: false,
                                                  );
                                                },
                                              ),
                                              InputForm(
                                                controller: userid,
                                                labelName: "User Id (*)",
                                                formName: "User Id",
                                                prefixIcon: Icons
                                                    .alternate_email_outlined,
                                                keyboardType:
                                                    TextInputType.text,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .emailValidation(
                                                    input: input.toString(),
                                                    labelName: "Email",
                                                    isMandatory: true,
                                                  );
                                                },
                                              ),
                                              InputForm(
                                                controller: password,
                                                labelName: "Passsword (*)",
                                                formName: "Passsword",
                                                isPasswordForm: true,
                                                prefixIcon: Icons.key,
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                validation: (input) {
                                                  return FormValidation()
                                                      .passwordValidation(
                                                    input: input.toString(),
                                                    minLength: 6,
                                                    maxLength: 13,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                                        profilePageController.animateToPage(
                                          0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                        setState(() {
                                          profileCurrentPage = 0;
                                        });
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        surfaceTintColor:
                                            Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        submit();
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
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

  Center error(AsyncSnapshot<dynamic> snapshot, BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                "Failed",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              snapshot.error.toString() == "null"
                  ? "Something went Wrong"
                  : snapshot.error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    companyHandler = getCompanyInfo();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  "Refresh",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
