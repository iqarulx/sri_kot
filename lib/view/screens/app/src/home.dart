import 'package:flutter/material.dart';
import '/view/screens/screens.dart';
import '/view/ui/ui.dart';

var homeKey = GlobalKey<ScaffoldState>();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> pages = const [
    Dashboard(),
    UserListing(),
    CompanyListing(),
    StaffListing(),
    CustomerListing(),
    ProductListing(),
    CategoryListing(),
    BillingOne(),
    BillingTwo(),
    EnquiryListing(),
    EstimateListing(),
    Scaffold(),
    AppSettings(),
    InvoiceListing(),
    CategoryDiscountView(),
    AccountInformation(),
    PaymentHistory(),
    PlanDetails(),
    Help(),
    Support(),
  ];

  @override
  void initState() {
    super.initState();
    sidebar.addListener(changeEvent);
  }

  @override
  void dispose() {
    sidebar.removeListener(changeEvent);
    super.dispose();
  }

  void changeEvent() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _onWillPop() async {
    // Make sure this logic doesn't cause unintended side effects
    if (sidebar.crttab != 0) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: homeKey,
        drawer: const SideBar(),
        body: pages[sidebar.crttab],
      ),
    );
  }
}
