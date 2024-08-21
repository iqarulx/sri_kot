import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'billing/app_settings/app_settings.dart';
import 'billing/billing_two.dart';
import 'category/category_listing.dart';
import 'category_discount/category_discount_view.dart';
import 'company/companylisting.dart';
import 'customer/customerlisting.dart';
import 'dashboard/dashboard.dart';
import 'enquiry/enquiry_listing.dart';
import 'estimate/estimate_listing.dart';
import 'invoice/invoice_listing.dart';
import 'product/productlisting.dart';
import 'staff/stafflistting.dart';
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
