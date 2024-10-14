import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '/provider/provider.dart';
import '/view/ui/ui.dart';
import '/services/services.dart';
import '/view/screens/screens.dart';
import '/constants/constants.dart';

var homeKey = GlobalKey<ScaffoldState>();

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  Future? dashboardHandler;
  final GlobalKey<ScaffoldState> homeKey = GlobalKey<ScaffoldState>();
  int bilingTab = 1;
  bool prCustomer = false;
  bool prEnquiry = false;
  bool prEstimate = false;
  bool prProduct = false;
  String? customer;
  String? enquriy;
  String? estimate;
  String? product;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);
        dashboardHandler = initFunction();
      } else {
        dashboardHandler = initFunctionOffline();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);
          dashboardHandler = initFunction();
        } else {
          dashboardHandler = initFunctionOffline();
        }
      });
    });
  }

  @override
  void dispose() {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    connectionProvider.removeListener(() {});
    super.dispose();
  }

  Future<void> initFunction() async {
    await getinfo();
    await Future.wait([
      getCustomerCount(),
      getEnquiryCount(),
      getEstimateCount(),
      getProductCount(),
    ]);
  }

  Future<void> initFunctionOffline() async {
    await getinfo();
    await Future.wait([
      getCustomerCountOffline(),
      getEnquiryCountOffline(),
      getEstimateCountOffline(),
      getProductCountOffline(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeKey,
      backgroundColor: Colors.white,
      drawer: const SideBar(),
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh dashboard on button press
              setState(() {
                dashboardHandler = initFunction();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: () async {
              var isAdmin = await LocalDB.fetchInfo(type: LocalData.isAdmin);

              final value = await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) =>
                      AppSettings(isHome: true, isAdmin: isAdmin),
                ),
              );
              if (value != null) {
                if (value) {
                  final connectionProvider =
                      Provider.of<ConnectionProvider>(context, listen: false);
                  if (connectionProvider.isConnected) {
                    setState(() {
                      dashboardHandler = initFunction();
                    });
                  } else {
                    setState(() {
                      dashboardHandler = initFunctionOffline();
                    });
                  }
                }
              }
            },
            icon: const Icon(CupertinoIcons.gear),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: () async {
          // Refresh on pull down
          setState(() {
            dashboardHandler = initFunction();
          });
        },
        child: FutureBuilder<void>(
          future: dashboardHandler,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return buildDashboardContent();
            }
          },
        ),
      ),
    );
  }

  Widget buildDashboardContent() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              ResponsiveGridList(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                desiredItemWidth: 150,
                minSpacing: 4,
                children: [
                  if (prCustomer)
                    dashboardcard(
                      title: "Customer",
                      subtitle: customer,
                      primaryColor: Colors.blue,
                      icon: Icons.person,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const CustomerListing(),
                          ),
                        );
                      },
                    ),
                  if (prEnquiry)
                    dashboardcard(
                      title: "Enquiry",
                      subtitle: enquriy,
                      primaryColor: Colors.pink.shade400,
                      icon: Icons.business_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const EnquiryListing(),
                          ),
                        );
                      },
                    ),
                  if (prEstimate)
                    dashboardcard(
                      title: "Estimate",
                      subtitle: estimate,
                      primaryColor: Colors.indigo,
                      icon: Icons.business_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const EstimateListing(),
                          ),
                        );
                      },
                    ),
                  if (prProduct)
                    dashboardcard(
                      title: "Product",
                      subtitle: product,
                      primaryColor: const Color(0xff6a994e),
                      icon: Icons.category,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const ProductListing(),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              if (isAdmin)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      ResponsiveGridList(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        desiredItemWidth: 80,
                        minSpacing: 20,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const CompanyListing(),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 50,
                                    maxWidth: 50,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.building_2_fill,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Company",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const InvoiceListing(),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 50,
                                    maxWidth: 50,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.tags,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Bill of Supply",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const UserListing(),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 50,
                                    maxWidth: 50,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.profile_circled,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "User",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const StaffListing(),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 50,
                                    maxWidth: 50,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.person_2_fill,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Staff",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const CategoryListing(),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 50,
                                    maxWidth: 50,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.tag_solid,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Category",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const CategoryDiscountView(),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 50,
                                    maxWidth: 50,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.percent,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Discount",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (prEnquiry || prEstimate)
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    bilingTab == 1
                        ? Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const BillingOne(),
                            ),
                          )
                        : Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const BillingTwo(),
                            ),
                          );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xffE4003A).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Quick Billing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.north_east_outlined,
                            size: 25,
                            color: const Color(0xffE4003A).withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const InvoiceCreation(
                          fromEstimate: false,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 29, 158, 25)
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Quick Invoice",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.north_east_outlined,
                            size: 25,
                            color: const Color.fromARGB(255, 29, 158, 25)
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
      ],
    );
  }

  Widget dashboardcard({
    required String title,
    required String? subtitle,
    required Color primaryColor,
    required IconData icon,
    required void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: primaryColor.withOpacity(0.5),
          image: DecorationImage(
            image: const AssetImage('assets/images/back.png'),
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2), BlendMode.dstATop),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            subtitle != null
                ? Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white54,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                      // style: const TextStyle(
                      //   color: Colors.black,
                      //   fontSize: 18,
                      //   fontWeight: FontWeight.bold,
                      // ),
                    ),
                  )
                : const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future getCustomerCount() async {
    try {
      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStore().getCustomerCount(cid: cid).then((value) {
          if (value != null) {
            setState(() {
              customer = value.count.toString();
            });
          } else {
            setState(() {
              customer = "0";
            });
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future getCustomerCountOffline() async {
    try {
      await LocalService.getOfflineCustomerInfo().then((value) {
        setState(() {
          customer = value.length.toString();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future getEnquiryCount() async {
    try {
      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStore().getEnquiryCount(cid: cid).then((value) {
          if (value != null) {
            setState(() {
              enquriy = value.count.toString();
            });
          } else {
            setState(() {
              enquriy = "0";
            });
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future getEnquiryCountOffline() async {
    try {
      await DatabaseHelper().getEnquiryTotal().then((value) {
        setState(() {
          enquriy = value["no_of_enquiry"].toString();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future getEstimateCount() async {
    try {
      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStore().getEstimateCount(cid: cid).then((value) {
          if (value != null) {
            setState(() {
              estimate = value.count.toString();
            });
          } else {
            setState(() {
              estimate = "0";
            });
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future getEstimateCountOffline() async {
    try {
      await DatabaseHelper().getEstimateTotal().then((value) {
        setState(() {
          estimate = value["no_of_estimate"].toString();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future getProductCount() async {
    try {
      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStore().getProductCount(cid: cid).then((value) {
          if (value != null) {
            setState(() {
              product = value.count.toString();
            });
          } else {
            setState(() {
              product = "0";
            });
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future getProductCountOffline() async {
    try {
      await DatabaseHelper().getProducts().then((value) {
        setState(() {
          product = value.length.toString();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  int getTabSize() {
    // int count = 2;
    // if (MediaQuery.of(context).size.width > 800) {
    //   setState(() {
    //     count = 6;
    //   });
    // } else if (MediaQuery.of(context).size.width > 600) {
    //   setState(() {
    //     count = 4;
    //   });
    // }
    // return count;
    return 4;
  }

  getinfo() async {
    await LocalDB.fetchInfo(type: LocalData.all).then((value) {
      if (value != null) {
        setState(() {
          bilingTab = value["billing"];
          isAdmin = value["isAdmin"];
          prCustomer = value["pr_customer"];
          prEnquiry = value["pr_order"];
          prEstimate = value["pr_estimate"];
          prProduct = value["pr_product"];
        });
      }
    });
  }
}
