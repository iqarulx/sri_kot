import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sri_kot/batch/src/batch_1010.dart';
import 'package:url_launcher/url_launcher.dart';
import '/purchase/purchase.dart';
import '/utils/utils.dart';
import '/provider/provider.dart';
import '/gen/assets.gen.dart';
import '/services/services.dart';
import '../../auth/src/auth/auth.dart';
import '/view/screens/screens.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  // int crttab = 0;
  bool accountSelect = false;
  bool isopen = false;

  String? name;
  String? email;

  int bilingTab = 1;

  bool? prCategory;
  bool? prCustomer;
  bool? prEstimate;
  bool? prOrder;
  bool? prProduct;
  bool? isAdmin;
  bool? billofSupply;
  bool? invoiceEntry;
  DateTime? endsIn;
  File? profileImg;
  String? currentVersion;
  String? estimateCount;
  String? enquiryCount;
  bool? testMode;

  changeEvent() {
    if (mounted) {
      setState(() {});
    }
  }

  getinfo() async {
    await LocalDB.fetchInfo(type: LocalData.all).then((value) {
      if (value != null) {
        setState(() {
          name = value["user_name"];
          email = value["login_email"];
          bilingTab = value["billing"];
          prCategory = value["pr_category"];
          prCustomer = value["pr_customer"];
          prEstimate = value["pr_estimate"];
          prOrder = value["pr_order"];
          prProduct = value["pr_product"];
          isAdmin = value["isAdmin"];
        });
      }
    });

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
    });

    var helper = DatabaseHelper();
    var dbEnquiryCount = await helper.countEnquiries();
    var dbEstimateCount = await helper.countEstimate();
    setState(() {
      estimateCount = dbEstimateCount.toString();
      enquiryCount = dbEnquiryCount.toString();
    });

    testMode = await LocalDB.checkTestMode();

    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    if (connectionProvider.isConnected) {
      FireStore fireStore = FireStore();
      var result = await fireStore.getInvoiceAvailable(
          uid: await LocalDB.fetchInfo(type: LocalData.companyid) ?? '');
      setState(() {
        invoiceEntry = result;
      });

      await LocalService.updateLogin(
          uid: await LocalDB.fetchInfo(type: LocalData.companyid) ?? '');
    }
  }

  Future isInFreeTrial() async {
    return await LocalService.checkTrialEnd(
        uid: await LocalDB.fetchInfo(type: LocalData.companyid));
  }

  @override
  void initState() {
    super.initState();
    getinfo();
    AccountValid.accountValid(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // setState(() {
              //   accountSelect = !accountSelect;
              // });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Theme.of(context).primaryColor,
              child: SafeArea(
                left: false,
                bottom: false,
                child: Row(
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: profileImg != null && profileImg!.existsSync()
                              ? FileImage(profileImg!)
                              : AssetImage(Assets.images.user.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            email ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () {
                        // setState(() {
                        //   accountSelect = !accountSelect;
                        // });
                      },
                      icon: Icon(
                        accountSelect == false
                            ? Icons.expand_more_outlined
                            : Icons.expand_less_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            // visible: accountSelect ? false : true,
            visible: true,
            child: Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    menuTitle(data: "General"),
                    // menuView(
                    //   context,
                    //   icon: Icons.category,
                    //   lable: "Dashboard",
                    //   index: 0,
                    // ),
                    isAdmin != null && isAdmin == true
                        ? menuView(
                            context,
                            icon: Icons.person,
                            lable: "User",
                            index: 1,
                          )
                        : const SizedBox(),
                    isAdmin != null && isAdmin == true
                        ? menuView(
                            context,
                            icon: Icons.business,
                            lable: "Company",
                            index: 2,
                          )
                        : const SizedBox(),
                    isAdmin != null && isAdmin == true
                        ? menuView(
                            context,
                            icon: Icons.people,
                            lable: "Staff",
                            index: 3,
                          )
                        : const SizedBox(),

                    prCustomer != null && prCustomer == true
                        ? menuView(
                            context,
                            icon: Icons.groups,
                            lable: "Customer",
                            index: 4,
                            leadingIcon: Icons.add,
                            // leadingFun: () {
                            //   final connectionProvider =
                            //       Provider.of<ConnectionProvider>(context,
                            //           listen: false);
                            //   if (connectionProvider.isConnected) {
                            //     Navigator.pop(context);
                            //     Navigator.push(
                            //       context,
                            //       CupertinoPageRoute(
                            //         builder: (context) => const AddCustomer(),
                            //       ),
                            //     );
                            //   }
                            // },
                          )
                        : const SizedBox(),
                    prCategory != null && prCategory == true ||
                            prProduct != null && prProduct == true
                        ? breakBar()
                        : const SizedBox(),
                    prCategory != null && prCategory == true ||
                            prProduct != null && prProduct == true
                        ? menuTitle(data: "Items")
                        : const SizedBox(),
                    prCategory != null && prCategory == true
                        ? menuView(
                            context,
                            icon: Icons.sell,
                            lable: "Category",
                            index: 5,
                          )
                        : const SizedBox(),
                    prProduct != null && prProduct == true
                        ? menuView(
                            context,
                            icon: Icons.style,
                            lable: "Product",
                            index: 6,
                            leadingIcon: Icons.add,
                            // leadingFun: () {
                            //   final connectionProvider =
                            //       Provider.of<ConnectionProvider>(context,
                            //           listen: false);
                            //   if (connectionProvider.isConnected) {
                            //     Navigator.pop(context);
                            //     Navigator.push(
                            //       context,
                            //       CupertinoPageRoute(
                            //         builder: (context) => const ProductDetails(
                            //           edit: false,
                            //           title: 'Create Product',
                            //         ),
                            //       ),
                            //     );
                            //   }
                            // },
                          )
                        : const SizedBox(),
                    prCategory != null && prCategory == true
                        ? menuView(
                            context,
                            icon: Icons.percent,
                            lable: "Discount",
                            index: 7,
                          )
                        : const SizedBox(),
                    // multimenuuiDesign(
                    //   title: "Stock",
                    //   icon: Icons.inventory_outlined,
                    //   listData: [
                    //     SideMultiMenuList(
                    //       index: 12,
                    //       title: "Stock Adjustment",
                    //       icon: Icons.inventory_outlined,
                    //     ),
                    //     SideMultiMenuList(
                    //       index: 13,
                    //       title: "Stock Report",
                    //       icon: Icons.inventory_outlined,
                    //     ),
                    //   ],
                    // ),
                    prOrder != null && prOrder == true ||
                            prOrder != null && prOrder == true
                        ? breakBar()
                        : const SizedBox(),
                    prOrder != null && prOrder == true ||
                            prOrder != null && prOrder == true
                        ? menuTitle(data: "Billing")
                        : const SizedBox(),
                    prOrder != null && prOrder == true
                        ? menuView(
                            context,
                            icon: Icons.calculate,
                            lable: "Quick Billing",
                            index: 8,
                          )
                        : const SizedBox(),
                    prOrder != null && prOrder == true
                        ? menuView(
                            context,
                            icon: Icons.article,
                            lable: "Enquiry",
                            index: 9,
                          )
                        : const SizedBox(),
                    prEstimate != null && prEstimate == true
                        ? menuView(
                            context,
                            icon: Icons.article,
                            lable: "Estimate",
                            index: 10,
                          )
                        : const SizedBox(),
                    invoiceEntry != null && invoiceEntry == true
                        ? menuView(
                            context,
                            icon: Icons.article,
                            lable: "Bill of Supply",
                            index: 11,
                          )
                        : const SizedBox(),
                    (prOrder != null && prOrder == true) ||
                            (prEstimate != null && prEstimate == true)
                        ? estimateCount != "0" || enquiryCount != "0"
                            ? GestureDetector(
                                onTap: () async {
                                  final connectionProvider =
                                      Provider.of<ConnectionProvider>(context,
                                          listen: false);
                                  if (connectionProvider.isConnected) {
                                    if (estimateCount != "0" &&
                                        enquiryCount != "0") {
                                      confirmationDialog(context,
                                              title: "Upload offline bills",
                                              message:
                                                  "You need a strong internet connection to upload bills")
                                          .then((value) async {
                                        if (value != null) {
                                          if (value) {
                                            loading(context);
                                            await LocalService.syncNow()
                                                .then((value) {
                                              Navigator.pop(context);
                                              if (value) {
                                                showToast(context,
                                                    isSuccess: false,
                                                    content:
                                                        "Successfully bills are uploaded",
                                                    top: false);
                                              } else {
                                                showToast(context,
                                                    isSuccess: false,
                                                    content: "An error occured",
                                                    top: false);
                                              }
                                            });
                                          }
                                        }
                                      });
                                    } else {
                                      showToast(context,
                                          isSuccess: false,
                                          content:
                                              "No bills are available to upload",
                                          top: false);
                                    }
                                  } else {
                                    showToast(context,
                                        isSuccess: false,
                                        content:
                                            "You need internet to upload bills",
                                        top: false);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Badge(
                                      label: Text(
                                          "${int.parse(estimateCount ?? '0') + int.parse(enquiryCount ?? "0")}"),
                                      textStyle:
                                          const TextStyle(color: Colors.white),
                                      child: Container(
                                        height: 40,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              CupertinoIcons.cloud_upload,
                                              size: 19,
                                              color: Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Upload Local Bills",
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                          ],
                                        ),
                                      )),
                                ),
                              )
                            : const SizedBox()
                        : const SizedBox(),

                    breakBar(), menuTitle(data: "Settings"),
                    // isAdmin != null && isAdmin == true
                    //     ? menuView(
                    //         context,
                    //         icon: Icons.manage_accounts,
                    //         lable: "Account Settings",
                    //         index: 11,
                    //       )
                    //     : const SizedBox(),
                    menuView(
                      context,
                      icon: Icons.settings,
                      lable: "App Settings",
                      index: 12,
                    ),
                    menuView(
                      context,
                      icon: CupertinoIcons.color_filter,
                      lable: "App Theme",
                      index: 21,
                    ),
                    isAdmin != null && isAdmin == true
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              breakBar(),
                              menuTitle(data: "Account"),
                              menuView(
                                context,
                                icon: Icons.person,
                                lable: "Account Information",
                                index: 13,
                              ),
                              menuView(
                                context,
                                icon: Icons.shopping_bag_outlined,
                                lable: "Purchase",
                                index: 14,
                              ),
                              menuView(
                                context,
                                icon: Icons.credit_card,
                                lable: "Payment History",
                                index: 15,
                              ),
                              menuView(
                                context,
                                icon: Icons.support_agent,
                                lable: "Support",
                                index: 16,
                              ),
                              FutureBuilder(
                                future: isInFreeTrial(),
                                builder: (builder, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  }
                                  if (snapshot.data) {
                                    planUpgrade(context);
                                  } else {
                                    return Container();
                                  }
                                  return Container();
                                },
                              ),
                            ],
                          )
                        : Container(),
                    isAdmin != null && isAdmin == true
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              breakBar(),
                              menuTitle(data: "Help"),
                              menuView(
                                context,
                                icon: Icons.shield_outlined,
                                lable: "Privacy Policy",
                                index: 17,
                              ),
                              menuView(
                                context,
                                icon: Icons.rule,
                                lable: "Terms and Conditions",
                                index: 18,
                              ),
                              menuView(
                                context,
                                icon: Icons.credit_card,
                                lable: "Refund Policy",
                                index: 19,
                              ),
                            ],
                          )
                        : Container(),
                    testMode ?? false
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                breakBar(),
                                menuTitle(data: "Test"),
                                menuView(
                                  context,
                                  icon: Icons.shield_outlined,
                                  lable: "Test Entry",
                                  index: 20,
                                ),
                                menuView(
                                  context,
                                  icon: Icons.shield_outlined,
                                  lable: "Batch",
                                  index: 22,
                                )
                              ])
                        : const SizedBox(),
                    GestureDetector(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (builder) {
                            return const Modal(
                              title: "Alert",
                              content: "Do you want logout this account?",
                              type: ModalType.danger,
                            );
                          },
                        ).then((value) async {
                          if (value != null && value == true) {
                            loading(context);
                            await FireStore().deleteDeviceLogout();

                            await LocalDB.logout().then((result) async {
                              final dbHelper = DatabaseHelper();
                              dbHelper.clearCategory();
                              dbHelper.clearCustomer();
                              dbHelper.clearProducts();
                              dbHelper.clearBillRecords();

                              if (result) {
                                Navigator.pop(context);
                                Navigator.pop(context);

                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => const Auth(),
                                  ),
                                );
                              }
                            });
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.power_settings_new,
                                size: 19,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onDoubleTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (builder) {
                return const ShowLog();
              }));
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "App Version - $currentVersion",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget breakBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Divider(
        height: 15,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget menuTitle({required String data}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        data,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget menuView(
    context, {
    required IconData icon,
    required String lable,
    required int index,
    IconData? leadingIcon,
    Function()? leadingFun,
  }) {
    Widget route = const UserHome();
    switch (index) {
      case 0:
        route = const UserHome();
      case 1:
        route = const UserListing();
      case 2:
        route = const CompanyListing();
      case 3:
        route = const StaffListing();
      case 4:
        route = const CustomerListing();
      case 5:
        route = const CategoryListing();
      case 6:
        route = const ProductListing();
      case 7:
        route = const CategoryDiscountView();
      case 8:
        bilingTab == 1
            ? route = const BillingOne()
            : route = const BillingTwo();
      case 9:
        route = const EnquiryListing();
      case 10:
        route = const EstimateListing();
      case 11:
        route = const InvoiceListing();
      case 12:
        route = AppSettings(isHome: false, isAdmin: isAdmin ?? false);
      case 13:
        route = const AccountInformation();
      case 14:
        route = const Purchase();
      case 15:
        route = const PurchaseHistory();
      case 16:
        route = const Support();

      case 21:
        route = const ThemeChange();
      case 22:
        route = const Update1110();

      default:
        route = const UserHome();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () async {
          if (index != 17 && index != 18 && index != 19) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => route,
              ),
            );
          } else if (index == 12) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => route,
              ),
            );
          } else {
            if (index == 17) {
              final Uri url =
                  Uri.parse('https://srisoftwarez.com/privacypolicy.php');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            } else if (index == 18) {
              final Uri url =
                  Uri.parse('https://srisoftwarez.com/termscondition.php');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            } else {
              final Uri url =
                  Uri.parse('https://srisoftwarez.com/refundpolicy.php');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            // color: Theme.of(context).primaryColor.withOpacity(0.15),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: Center(
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(
                width: 0,
              ),
              Text(
                lable,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              leadingFun != null && leadingIcon != null
                  ? IconButton(
                      onPressed: leadingFun,
                      splashRadius: 20,
                      icon: Icon(
                        leadingIcon,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}



/*
  getcrtTabindex<int>(List<SideMultiMenuList> listData) {
    return listData.indexWhere((element) => element.index == crttab);
  }

  selectMenu(int index) async {
    if (crtpage == 7 || crtpage == 10) {
      if (crtpage == 7 && cartdata.isNotEmpty) {
        var data = await confirmationAlertbox(
          context,
          "Waring",
          "Do you Confirm to exit this page and clear the Cart?",
        );

        if (data != null && data == true) {
          setState(() {
            crtpage = index;
            action.toggletab(index);
            Navigator.pop(context);
          });
        }
      } else if (crtpage == 10 && getcountcart() > 0) {
        var data = await confirmationAlertbox(
          context,
          "Waring",
          "Do you Confirm to exit this page and clear the Cart?",
        );

        if (data != null && data == true) {
          setState(() {
            crttab = index;
            action.toggletab(index);
            Navigator.pop(context);
          });
        }
      } else {
        setState(() {
          isopen = true;
          crtpage = index;
          action.toggletab(index);
          Navigator.pop(context);
        });
      }
    } else {
      setState(() {
        crtpage = index;
        action.toggletab(index);
        Navigator.pop(context);
      });
    }
  }

  multimenuuiDesign({
    required String title,
    required IconData icon,
    required List<SideMultiMenuList> listData,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: ExpansionPanelList(
        expandedHeaderPadding: const EdgeInsets.all(0),
        elevation: 0,
        expansionCallback: (panelIndex, isExpanded) {
          setState(() {
            switch (panelIndex) {
              case 0:
                isopen = isExpanded ? false : true;
                break;
              default:
            }
          });
        },
        children: [
          ExpansionPanel(
            backgroundColor: Colors.transparent,
            canTapOnHeader: true,
            isExpanded: isopen,
            headerBuilder: (context, isExpanded) {
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Icon(
                        icon,
                        size: 19,
                        color: getcrtTabindex(listData) > -1
                            ? Theme.of(context).primaryColor
                            : const Color(0xff1E232C),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: getcrtTabindex(listData) > -1
                              ? Theme.of(context).primaryColor
                              : const Color(0xff1E232C),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            body: SizedBox(
              child: Column(
                children: [
                  for (var tabs in listData)
                    InkWell(
                      onTap: () {
                        // selectMenu(tabs.index);

                        setState(() {
                          crttab = tabs.index;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      hoverColor: crttab == tabs.index
                          ? Colors.transparent
                          : Colors.grey.shade200,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 5,
                          left: 10,
                          right: 10,
                        ),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // color:crtpage == index ? const Color(0xfffee6e9) : Colors.transparent,
                          color: crttab == tabs.index
                              ? Theme.of(context).primaryColor.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 25,
                              width: 25,
                              child: Icon(
                                tabs.icon,
                                size: 19,
                                color: crttab == tabs.index
                                    ? Theme.of(context).primaryColor
                                    : const Color(0xff1E232C),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                tabs.title,
                                style: TextStyle(
                                  color: crttab == tabs.index
                                      ? Theme.of(context).primaryColor
                                      : const Color(0xff1E232C),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
      ),
    );
  }

*/