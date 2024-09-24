import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_kot/services/services.dart';
import 'package:sri_kot/utils/src/utilities.dart';
import 'package:sri_kot/view/ui/ui.dart';
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
        appBar: AppBar(
          title: const Text("Customer Name"),
          actions: [
            IconButton(
              onPressed: () {
                confirmationDialog(
                  context,
                  title: "Delete Customer",
                  message: "Are you sure want to delete customer",
                ).then((value) async {
                  if (value != null) {
                    if (value) {
                      loading(context);
                      await FireStore()
                          .deleteCustomer(docID: widget.customeData.docID ?? '')
                          .then((value) {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                        snackbar(
                            context, true, "Successfully customer deleted");
                      });
                    }
                  }
                });
              },
              icon: const Icon(
                CupertinoIcons.trash,
                size: 18,
              ),
            )
          ],
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
