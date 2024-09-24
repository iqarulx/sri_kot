import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/constants/constants.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/view/ui/ui.dart';

class CustomerSearch extends StatefulWidget {
  final bool isConnected;
  const CustomerSearch({super.key, required this.isConnected});

  @override
  State<CustomerSearch> createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<CustomerSearch> {
  List<CustomerDataModel> customerList = [];

  List<CustomerDataModel> customerDataList = [];

  Future getCustomerInfo() async {
    try {
      FireStore provider = FireStore();
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

      if (cid != null) {
        final result = await provider.customerListing(cid: cid);
        if (result!.docs.isNotEmpty) {
          setState(() {
            customerDataList.clear();
          });
          for (var element in result.docs) {
            CustomerDataModel model = CustomerDataModel();
            model.address = element["address"] ?? '';
            model.mobileNo = element["mobile_no"] ?? '';
            model.city = element["city"] ?? '';
            model.customerName = element["customer_name"] ?? '';
            model.email = element["email"] ?? '';
            model.state = element["state"] ?? '';
            model.docID = element.id;
            model.companyID = element["company_id"] ?? '';
            setState(() {
              customerDataList.add(model);
            });
          }
          return customerDataList;
        }
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  Future getOfflineCustomerInfo() async {
    try {
      var localCustomer = await DatabaseHelper().getCustomer();

      if (localCustomer.isNotEmpty) {
        setState(() {
          customerDataList.clear();
        });
        for (var element in localCustomer) {
          CustomerDataModel model = CustomerDataModel();
          model.address = element["address"].toString();
          model.mobileNo = element["mobile_no"].toString();
          model.city = element["city"].toString();
          model.customerName = element["customer_name"].toString();
          model.email = element["email"].toString();
          model.state = element["state"].toString();
          model.docID = element["customer_id"];
          model.companyID = element["company_id"].toString();
          setState(() {
            customerDataList.add(model);
          });
        }
        return customerDataList;
      }

      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  late Future customerHandler;

  @override
  void initState() {
    super.initState();
    if (widget.isConnected) {
      customerHandler = getCustomerInfo();
    } else {
      customerHandler = getOfflineCustomerInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(15),
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
                backgroundColor: Colors.white,
                elevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.transparent,
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
                titleSpacing: 0,
                title: TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search Customer",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              body: FutureBuilder(
                future: customerHandler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return futureLoading(context);
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Center(
                              child: Text(
                                "Failed",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              snapshot.error.toString() == "null"
                                  ? "Something went Wrong"
                                  : snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    customerHandler = getCustomerInfo();
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text(
                                  "Refresh",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          customerHandler = getCustomerInfo();
                        });
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: customerDataList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(context, customerDataList[index]);
                              },
                              leading: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                ),
                              ),
                              title: Text(
                                customerDataList[index].customerName ?? "",
                                // style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                //       color: Colors.black,
                                //     ),
                              ),
                              subtitle: Wrap(
                                spacing: 5,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    "Phone : ${customerDataList[index].mobileNo ?? ""},",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                  Text(
                                    "City : ${customerDataList[index].city ?? ""},",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                  Text(
                                    "Address : ${customerDataList[index].address ?? ""}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
