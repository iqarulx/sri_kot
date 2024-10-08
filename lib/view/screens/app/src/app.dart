import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        ],
      ),
      body: RefreshIndicator(
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
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        GridView(
          primary: false,
          shrinkWrap: true,
          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //   crossAxisCount: getTabSize(),
          //   mainAxisSpacing: 10,
          //   crossAxisSpacing: 10,
          //   childAspectRatio: (1 / 1.12),
          // ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (MediaQuery.of(context).size.width ~/ 150).toInt(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: (1 / 1.12),
          ),
          children: [
            if (prCustomer)
              dashboardcard(
                title: "Customer",
                subtitle: customer,
                primaryColor: const Color(0xff4895ef),
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
                primaryColor: const Color(0xffB284BE),
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
                primaryColor: const Color(0xff3d348b),
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
        if (prEnquiry || prEstimate)
          GestureDetector(
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
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  const Text(
                    "Quick Billing",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  //   decoration: BoxDecoration(
                  //     color: Theme.of(context).primaryColor,
                  //     borderRadius: BorderRadius.circular(3),
                  //   ),
                  //   child: const Text(
                  //     "PRO",
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                  const Spacer(),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.north_east_outlined,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              // style: const TextStyle(
              //   color: Colors.black,
              //   fontSize: 25,
              //   fontWeight: FontWeight.bold,
              // ),
            ),
            const SizedBox(
              height: 8,
            ),
            subtitle != null
                ? Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    // style: const TextStyle(
                    //   color: Colors.black,
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.bold,
                    // ),
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
