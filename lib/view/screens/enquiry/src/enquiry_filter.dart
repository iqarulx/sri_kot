import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../provider/provider.dart';
import '../../../ui/ui.dart';
import '/constants/constants.dart';
import '/services/services.dart';

class EnquiryFilter extends StatefulWidget {
  const EnquiryFilter({super.key});

  @override
  State<EnquiryFilter> createState() => _EnquiryFilterState();
}

class _EnquiryFilterState extends State<EnquiryFilter> {
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  List<DropdownMenuItem> customerList = [];
  String? customerId;
  Future getCustomerInfo() async {
    try {
      FireStore provider = FireStore();
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        if (cid != null) {
          final result = await provider.customerListing(cid: cid);
          if (result!.docs.isNotEmpty) {
            setState(() {
              customerList.clear();
            });
            for (var element in result.docs) {
              setState(() {
                customerList.add(
                  DropdownMenuItem(
                    value: element.id,
                    child: Text(
                      "${element["customer_name"].toString()} - (${element["mobile_no"].toString()})",
                    ),
                  ),
                );
              });
            }

            return customerList;
          }
        }
      } else {
        setState(() {
          customerList.clear();
        });
        var list = await LocalService.getOfflineCustomerInfo();
        if (list.isNotEmpty) {
          for (var element in list) {
            setState(() {
              customerList.add(
                DropdownMenuItem(
                  value: element.docID,
                  child: Text(
                    "${element.customerName} - (${element.mobileNo.toString()})",
                  ),
                ),
              );
            });
          }
        }
      }

      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<DateTime?> datePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    return picked;
  }

  fromDatePicker() async {
    final DateTime? picked = await datePicker();
    if (picked != null) {
      setState(() {
        fromDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  toDatePicker() async {
    final DateTime? picked = await datePicker();

    if (picked != null) {
      setState(() {
        toDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  applyNow() {
    // Prepare a map to hold the result
    Map<String, dynamic> result = {};

    // If a customer is selected, add CustomerID to the result
    if (customerId != null) {
      result['CustomerID'] = customerId;
    }

    // If fromDate is selected, add it to the result
    if (fromDate.text.isNotEmpty) {
      result['FromDate'] = DateTime.parse(fromDate.text);
    }

    // If toDate is selected, add it to the result
    if (toDate.text.isNotEmpty) {
      result['ToDate'] = DateTime.parse(toDate.text);
    }

    // Check if the result map is not empty before popping the context
    if (result.isNotEmpty) {
      Navigator.pop(context, result);
    } else {
      // If no valid input is selected, show a toast message
      showToast(context,
          content: "Please select at least one option",
          isSuccess: false,
          top: false);
    }
  }

  @override
  void initState() {
    super.initState();
    getCustomerInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center(
          //   child: Container(
          //     height: 4,
          //     width: 40, // Adjust width as needed
          //     decoration: BoxDecoration(
          //       color: Colors.grey[400],
          //       borderRadius: BorderRadius.circular(4),
          //     ),
          //     margin: const EdgeInsets.symmetric(vertical: 8.0),
          //   ),
          // ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Enquiry Fillter",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.black,
                      ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xfff1f5f9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    splashRadius: 20,
                    constraints: const BoxConstraints(
                      maxWidth: 40,
                      maxHeight: 40,
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: const EdgeInsets.all(0),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "From Date",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: fromDate,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "Form Date",
                    ),
                    onTap: () => fromDatePicker(),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(
                    "To Date",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: toDate,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "To Date",
                    ),
                    onTap: () => toDatePicker(),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(
                    "Choose Customer",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.black54),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  DropdownButtonFormField(
                    menuMaxHeight: 400,
                    value: customerId,
                    isExpanded: true,
                    items: customerList,
                    onChanged: (onChanged) {
                      setState(() {
                        customerId = onChanged;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Choose Customer",
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  GestureDetector(
                    onTap: () {
                      applyNow();
                    },
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          "Apply Now",
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
