import 'package:flutter/material.dart';
import 'account_info/account_information.dart';
import 'billing/app_settings/app_settings.dart';
import 'billing/billing_two.dart';
import 'category/category_listing.dart';
import 'category_discount/category_discount_view.dart';
import 'company/companylisting.dart';
import 'customer/customerlisting.dart';
import 'dashboard/dashboard.dart';
import 'enquiry/enquiry_listing.dart';
import 'estimate/estimate_listing.dart';
import 'help/help.dart';
import 'invoice/invoice_listing.dart';
import 'payment/payment_history.dart';
import 'plan_details/plan_details.dart';
import 'product/productlisting.dart';
import 'staff/stafflistting.dart';
import 'support/support.dart';
import 'user/userlisting.dart';
import '../ui/sidebar.dart';
import 'billing/billing_one.dart';

var homeKey = GlobalKey<ScaffoldState>();

class HomeLanding extends StatefulWidget {
  const HomeLanding({super.key});

  @override
  State<HomeLanding> createState() => _HomeLandingState();
}

class _HomeLandingState extends State<HomeLanding> {
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
