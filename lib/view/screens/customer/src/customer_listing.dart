import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import '/constants/constants.dart';
import '/provider/src/file_open.dart' as helper;

PageController customerListingcontroller = PageController();

class CustomerListing extends StatefulWidget {
  const CustomerListing({super.key});

  @override
  State<CustomerListing> createState() => _CustomerListingState();
}

class _CustomerListingState extends State<CustomerListing> {
  List<CustomerDataModel> customerDataList = [];
  List<CustomerDataModel> tmpCustomerDataList = [];

  TextEditingController searchForm = TextEditingController();

  Future getCustomerInfo() async {
    try {
      FireStoreProvider provider = FireStoreProvider();
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

      if (cid != null) {
        final result = await provider.customerListing(cid: cid);
        if (result!.docs.isNotEmpty) {
          setState(() {
            customerDataList.clear();
            tmpCustomerDataList.clear();
          });
          for (var element in result.docs) {
            CustomerDataModel model = CustomerDataModel();
            model.address = element["address"].toString();
            model.mobileNo = element["mobile_no"].toString();
            model.city = element["city"].toString();
            model.customerName = element["customer_name"].toString();
            model.email = element["email"].toString();
            model.state = element["state"]?.toString();
            model.docID = element.id;
            setState(() {
              customerDataList.add(model);
            });
          }
          setState(() {
            tmpCustomerDataList.addAll(customerDataList);
          });
          return customerDataList;
        }
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  downloadExcelData() async {
    try {
      loading(context);
      await CustomerExcel(customerDataList: customerDataList)
          .createCustomerExcel()
          .then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          Navigator.pop(context);
          await helper.saveAndLaunchFile(fileData, 'Customer List.xlsx');
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  searchCustomerFun(String? value) async {
    if (value != null && searchForm.text.isNotEmpty) {
      if (value.isNotEmpty) {
        Iterable<CustomerDataModel> tmpList =
            tmpCustomerDataList.where((element) {
          return element.customerName!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', '')) ||
              element.mobileNo!.toLowerCase().replaceAll(' ', '').startsWith(
                    value.toLowerCase().replaceAll(' ', ''),
                  );
        });
        if (tmpList.isNotEmpty) {
          setState(() {
            customerDataList.clear();
          });
          for (var element in tmpList) {
            setState(() {
              customerDataList.add(element);
            });
          }
        }
      }
    } else {
      setState(() {
        customerDataList.clear();
        customerDataList.addAll(tmpCustomerDataList);
      });
    }
  }

  Future? customerHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);
        customerHandler = getCustomerInfo();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);
          customerHandler = getCustomerInfo();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: appbar(context),
      body: Consumer<ConnectionProvider>(
        builder: (context, connectionProvider, child) {
          return connectionProvider.isConnected
              ? screenView()
              : noInternet(context);
        },
      ),
    );
  }

  FutureBuilder<dynamic> screenView() {
    return FutureBuilder(
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
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: customerDataList.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: SearchForm(
                            controller: searchForm,
                            formName: "Search Customer",
                            prefixIcon: Icons.search,
                            onChanged: (v) {
                              searchCustomerFun(v);
                            },
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              setState(() {
                                customerHandler = getCustomerInfo();
                              });
                            },
                            child: ListView.builder(
                              itemCount: customerDataList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                CustomerDetails(
                                              customeData:
                                                  customerDataList[index],
                                            ),
                                          ),
                                        );
                                      },
                                      leading: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        customerDataList[index]
                                            .customerName
                                            .toString(),
                                      ),
                                      subtitle: Text(
                                        customerDataList[index]
                                            .mobileNo
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: const Icon(
                                          Icons.chevron_right_outlined),
                                    ),
                                    Divider(
                                      height: 0,
                                      color: Colors.grey.shade300,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : EmptyListPage(
                      assetsPath: Assets.emptyList3,
                      title: 'No Customer Data',
                      content:
                          'You have not create any Customer, so first you have create user using add customer button below',
                      addFun: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const AddCustomer(),
                          ),
                        );
                      },
                      refreshFun: () {
                        setState(() {
                          customerHandler = getCustomerInfo();
                        });
                      },
                    ),
            ),
          );
        }
      },
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Customer"),
      actions: [
        Provider.of<ConnectionProvider>(context, listen: false).isConnected
            ? IconButton(
                onPressed: () {
                  final connectionProvider =
                      Provider.of<ConnectionProvider>(context, listen: false);
                  if (connectionProvider.isConnected) {
                    downloadExcelData();
                  }
                },
                splashRadius: 20,
                icon: const Icon(
                  Icons.file_download_outlined,
                ),
              )
            : Container(),
        Provider.of<ConnectionProvider>(context, listen: false).isConnected
            ? IconButton(
                onPressed: () {
                  // openModelBottomSheat(context);

                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const AddCustomer(),
                    ),
                  );
                },
                splashRadius: 20,
                icon: const Icon(
                  Icons.add,
                ),
              )
            : Container()
      ],
    );
  }
}
