import 'package:flutter/material.dart';
import 'package:sri_kot/gen/assets.gen.dart';
import '../../admin.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/view/auth/src/auth.dart';
import '/view/ui/ui.dart';

SideBarEvent sidebar = SideBarEvent();

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  changeEvent() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    sidebar.addListener(changeEvent);
  }

  @override
  void initState() {
    super.initState();
    sidebar.addListener(changeEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                          image: AssetImage(Assets.images.user.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Srisoftwarez",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            "contact@srisoftwarez.com",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
                    menuView(
                      context,
                      icon: Icons.category,
                      lable: "Dashboard",
                      index: 0,
                    ),
                    menuView(
                      context,
                      icon: Icons.person,
                      lable: "Add Company",
                      index: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await confirmationDialog(context,
                      title: "Alert",
                      message: "Do you want logout this account ?")
                  .then((value) async {
                if (value != null && value == true) {
                  await LocalDbProvider().logout().then((result) {
                    if (result) {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
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
                margin: const EdgeInsets.only(top: 25),
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

          // Visibility(
          //   visible: accountSelect,
          //   child: Expanded(
          //     child: Column(
          //       children: [
          //         Expanded(
          //           child: SingleChildScrollView(
          //             padding: const EdgeInsets.all(10),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 planUpgrade(context),
          //                 menuView(
          //                   context,
          //                   icon: Icons.person,
          //                   lable: "Account Information",
          //                   index: -1,
          //                 ),
          //                 menuView(
          //                   context,
          //                   icon: Icons.credit_card,
          //                   lable: "Payment History",
          //                   index: -1,
          //                 ),
          //                 menuView(
          //                   context,
          //                   icon: Icons.card_giftcard,
          //                   lable: "Plan Details",
          //                   index: -1,
          //                 ),
          //                 menuView(
          //                   context,
          //                   icon: Icons.help,
          //                   lable: "Help",
          //                   index: -1,
          //                 ),
          //                 menuView(
          //                   context,
          //                   icon: Icons.support_agent,
          //                   lable: "Support",
          //                   index: -1,
          //                 ),
          //                 menuView(
          //                   context,
          //                   icon: Icons.quiz,
          //                   lable: "FAQ",
          //                   index: -1,
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Container(
          //             height: 40,
          //             width: double.infinity,
          //             decoration: BoxDecoration(
          //               color: Colors.grey.shade300,
          //               borderRadius: BorderRadius.circular(5),
          //             ),
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Icon(
          //                   Icons.power_settings_new,
          //                   size: 19,
          //                   color: Colors.grey.shade700,
          //                 ),
          //                 const SizedBox(
          //                   width: 15,
          //                 ),
          //                 Text(
          //                   "Logout",
          //                   style: TextStyle(
          //                     color: Colors.grey.shade700,
          //                     fontSize: 15,
          //                     fontWeight: FontWeight.w500,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Container(
            padding: const EdgeInsets.only(
              left: 3,
              right: 3,
              bottom: 5,
              top: 8,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Privacy Policy",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                  ),
                ),
                Text(
                  "Term & Conditions",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "App Version - 1.0.1",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
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

  // getcrtTabindex<int>(List<SideMultiMenuList> listData) {
  //   return listData.indexWhere((element) => element.index == crttab);
  // }

  // selectMenu(int index) async {
  //   if (crtpage == 7 || crtpage == 10) {
  //     if (crtpage == 7 && cartdata.isNotEmpty) {
  //       var data = await confirmationAlertbox(
  //         context,
  //         "Waring",
  //         "Do you Confirm to exit this page and clear the Cart?",
  //       );

  //       if (data != null && data == true) {
  //         setState(() {
  //           crtpage = index;
  //           action.toggletab(index);
  //           Navigator.pop(context);
  //         });
  //       }
  //     } else if (crtpage == 10 && getcountcart() > 0) {
  //       var data = await confirmationAlertbox(
  //         context,
  //         "Waring",
  //         "Do you Confirm to exit this page and clear the Cart?",
  //       );

  //       if (data != null && data == true) {
  //         setState(() {
  //           crttab = index;
  //           action.toggletab(index);
  //           Navigator.pop(context);
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         isopen = true;
  //         crtpage = index;
  //         action.toggletab(index);
  //         Navigator.pop(context);
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       crtpage = index;
  //       action.toggletab(index);
  //       Navigator.pop(context);
  //     });
  //   }
  // }

  // multimenuuiDesign({
  //   required String title,
  //   required IconData icon,
  //   required List<SideMultiMenuList> listData,
  // }) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(5),
  //     child: ExpansionPanelList(
  //       expandedHeaderPadding: const EdgeInsets.all(0),
  //       elevation: 0,
  //       expansionCallback: (panelIndex, isExpanded) {
  //         setState(() {
  //           switch (panelIndex) {
  //             case 0:
  //               isopen = isExpanded ? false : true;
  //               break;
  //             default:
  //           }
  //         });
  //       },
  //       children: [
  //         ExpansionPanel(
  //           backgroundColor: Colors.transparent,
  //           canTapOnHeader: true,
  //           isExpanded: isopen,
  //           headerBuilder: (context, isExpanded) {
  //             return Padding(
  //               padding: const EdgeInsets.only(left: 10),
  //               child: Row(
  //                 children: [
  //                   SizedBox(
  //                     height: 30,
  //                     width: 30,
  //                     child: Icon(
  //                       icon,
  //                       size: 19,
  //                       color: getcrtTabindex(listData) > -1
  //                           ? Theme.of(context).primaryColor
  //                           : const Color(0xff1E232C),
  //                     ),
  //                   ),
  //                   const SizedBox(
  //                     width: 10,
  //                   ),
  //                   Expanded(
  //                     child: Text(
  //                       title,
  //                       style: TextStyle(
  //                         color: getcrtTabindex(listData) > -1
  //                             ? Theme.of(context).primaryColor
  //                             : const Color(0xff1E232C),
  //                         fontSize: 15,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //           body: SizedBox(
  //             child: Column(
  //               children: [
  //                 for (var tabs in listData)
  //                   InkWell(
  //                     onTap: () {
  //                       // selectMenu(tabs.index);

  //                       setState(() {
  //                         crttab = tabs.index;
  //                       });
  //                     },
  //                     borderRadius: BorderRadius.circular(8),
  //                     hoverColor: crttab == tabs.index
  //                         ? Colors.transparent
  //                         : Colors.grey.shade200,
  //                     child: Container(
  //                       margin: const EdgeInsets.only(
  //                         top: 5,
  //                         left: 10,
  //                         right: 10,
  //                       ),
  //                       padding: const EdgeInsets.all(10),
  //                       decoration: BoxDecoration(
  //                         // color:crtpage == index ? const Color(0xfffee6e9) : Colors.transparent,
  //                         color: crttab == tabs.index
  //                             ? Theme.of(context).primaryColor.withOpacity(0.15)
  //                             : Colors.transparent,
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           SizedBox(
  //                             height: 25,
  //                             width: 25,
  //                             child: Icon(
  //                               tabs.icon,
  //                               size: 19,
  //                               color: crttab == tabs.index
  //                                   ? Theme.of(context).primaryColor
  //                                   : const Color(0xff1E232C),
  //                             ),
  //                           ),
  //                           const SizedBox(
  //                             width: 10,
  //                           ),
  //                           Expanded(
  //                             child: Text(
  //                               tabs.title,
  //                               style: TextStyle(
  //                                 color: crttab == tabs.index
  //                                     ? Theme.of(context).primaryColor
  //                                     : const Color(0xff1E232C),
  //                                 fontSize: 15,
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget menuView(
    context, {
    required IconData icon,
    required String lable,
    required int index,
    IconData? leadingIcon,
    Function()? leadingFun,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          setState(() {
            sidebar.toggletab(index);
            adminHomeKey.currentState!.closeDrawer();
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: sidebar.crttab == index
                ? Theme.of(context).primaryColor.withOpacity(0.15)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: Center(
                  child: Icon(
                    icon,
                    color: sidebar.crttab == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade800,
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
                  color: sidebar.crttab == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade800,
                  fontSize: 14,
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
