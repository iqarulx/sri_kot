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
  void initState() {
    print(widget.customeData.toMap());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: widget.customeData.customerName != null &&
                  widget.customeData.customerName!.isNotEmpty
              ? Text("${widget.customeData.customerName}")
              : Text("${widget.customeData.mobileNo}"),
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
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx > 0) {
              Navigator.of(context).pop();
            }
          },
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CustomerEdit(customeData: widget.customeData),
              CustomerEnquiry(customerID: widget.customeData.docID),
              CustomerEstimate(customerID: widget.customeData.docID),
            ],
          ),
        ),
      ),
    );
  }
}
