import 'package:flutter/material.dart';
import '/model/model.dart';
import '/view/screens/screens.dart';

class CustomerDetails extends StatefulWidget {
  final CustomerDataModel customeData;
  const CustomerDetails({super.key, required this.customeData});

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xffEEEEEE),
        appBar: AppBar(
          title: const Text("Customer Name"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: "Info",
              ),
              Tab(
                text: "Enquiry",
              ),
              Tab(
                text: "Estimate",
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CustomerEdit(customeData: widget.customeData),
            CustomerEnquiry(customerID: widget.customeData.docID),
            CustomerEstimate(customerID: widget.customeData.docID),
          ],
        ),
      ),
    );
  }
}
