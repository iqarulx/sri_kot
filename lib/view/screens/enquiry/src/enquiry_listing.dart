import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
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

class EnquiryListing extends StatefulWidget {
  const EnquiryListing({super.key});

  @override
  State<EnquiryListing> createState() => _EnquiryListingState();
}

class _EnquiryListingState extends State<EnquiryListing> {
  List<EstimateDataModel> enquiryList = [];
  List<EstimateDataModel> tmpEnquiryList = [];
  TextEditingController searchForm = TextEditingController();
  int? overallTotal;

  Future getEnquiryInfo() async {
    try {
      overallTotal = 0;

      setState(() {
        enquiryList.clear();
      });

      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        var enquiry = await FireStore().getEnquiry(cid: cid);
        if (enquiry != null && enquiry.docs.isNotEmpty) {
          for (var enquiryData in enquiry.docs) {
            var calcula = BillingCalCulationModel();
            calcula.discount = enquiryData["price"]["discount"];
            calcula.discountValue = enquiryData["price"]["discount_value"];
            calcula.discountsys = enquiryData["price"]["discount_sys"];
            calcula.extraDiscount = enquiryData["price"]["extra_discount"];
            calcula.roundOff = enquiryData["price"]["round_off"];
            calcula.extraDiscountValue =
                enquiryData["price"]["extra_discount_value"];
            calcula.extraDiscountsys =
                enquiryData["price"]["extra_discount_sys"];
            calcula.package = enquiryData["price"]["package"];
            calcula.packageValue = enquiryData["price"]["package_value"];
            calcula.packagesys = enquiryData["price"]["package_sys"];
            calcula.subTotal = enquiryData["price"]["sub_total"];
            calcula.total = enquiryData["price"]["total"];

            // Add the total to overallTotal
            if (calcula.total != null) {
              overallTotal = (overallTotal ?? 0) + calcula.total!.toInt();
            }

            CustomerDataModel? customer = CustomerDataModel();
            if (enquiryData["customer"] != null) {
              customer.address = enquiryData["customer"]["customer_id"] ?? "";
              customer.address = enquiryData["customer"]["address"] ?? "";
              customer.state = enquiryData["customer"]["state"] ?? "";
              customer.city = enquiryData["customer"]["city"] ?? "";
              customer.customerName =
                  enquiryData["customer"]["customer_name"] ?? "";
              customer.email = enquiryData["customer"]["email"] ?? "";
              customer.mobileNo = enquiryData["customer"]["mobile_no"] ?? "";
            }

            List<ProductDataModel> tmpProducts = [];

            setState(() {
              tmpProducts.clear();
            });

            await FireStore()
                .getEnquiryProducts(docid: enquiryData.id)
                .then((products) {
              if (products != null && products.docs.isNotEmpty) {
                for (var product in products.docs) {
                  var productDataModel = ProductDataModel();
                  productDataModel.categoryid = product["category_id"];
                  productDataModel.categoryName = product["category_name"];
                  productDataModel.price = product["price"];

                  productDataModel.productId = product["product_id"];
                  productDataModel.productName = product["product_name"];
                  productDataModel.qty = product["qty"];
                  productDataModel.productCode = product["product_code"] ?? "";
                  productDataModel.discountLock = product["discount_lock"];
                  productDataModel.docid = product.id;
                  productDataModel.name = product["name"];
                  productDataModel.productContent = product["product_content"];
                  productDataModel.productImg = product["product_img"];
                  productDataModel.qrCode = product["qr_code"];
                  productDataModel.videoUrl = product["video_url"];

                  setState(() {
                    tmpProducts.add(productDataModel);
                  });
                }
              }
            });

            setState(() {
              enquiryList.add(
                EstimateDataModel(
                  docID: enquiryData.id,
                  createddate: DateTime.parse(
                    enquiryData["created_date"].toDate().toString(),
                  ),
                  enquiryid: enquiryData['enquiry_id'],
                  estimateid: enquiryData["estimate_id"],
                  price: calcula,
                  customer: customer,
                  products: tmpProducts,
                  dataType: DataTypes.cloud,
                ),
              );
            });
          }
        }
        setState(() {
          tmpEnquiryList.addAll(enquiryList);
        });
        return enquiry;
      }
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  Future getOfflineEnquiryInfo() async {
    try {
      overallTotal = 0;

      setState(() {
        enquiryList.clear();
      });

      var localEnquiry = await DatabaseHelper().getEnquiry();
      for (var data in localEnquiry) {
        var calcula = BillingCalCulationModel();
        var price = jsonDecode(data['price']) as Map<String, dynamic>;
        calcula.discount = price["discount"];
        calcula.discountValue = price["discount_value"];
        calcula.discountsys = price["discount_sys"];
        calcula.extraDiscount = price["extra_discount"];
        calcula.extraDiscountValue = price["extra_discount_value"];
        calcula.extraDiscountsys = price["extra_discount_sys"];
        calcula.package = price["package"];
        calcula.packageValue = price["package_value"];
        calcula.packagesys = price["package_sys"];
        calcula.subTotal = price["sub_total"];
        calcula.total = price["total"];
        calcula.roundOff = price["round_off"];

        if (calcula.total != null) {
          overallTotal = (overallTotal ?? 0) + calcula.total!.toInt();
        }
        CustomerDataModel? customer = CustomerDataModel();
        if (data["customer"] != null) {
          var customerData =
              jsonDecode(data['customer']) as Map<String, dynamic>;
          customer.address = customerData["address"] ?? "";
          customer.state = customerData["state"] ?? "";
          customer.city = customerData["city"] ?? "";
          customer.customerName = customerData["customer_name"] ?? "";
          customer.email = customerData["email"] ?? "";
          customer.mobileNo = customerData["mobile_no"] ?? "";
        }

        List<ProductDataModel> tmpProducts = [];

        setState(() {
          tmpProducts.clear();
        });

        if (data["products"] != null) {
          var productData = jsonDecode(data['products']) as List<dynamic>;
          for (var product in productData) {
            var productDataModel = ProductDataModel();
            productDataModel.categoryid = product["category_id"];
            productDataModel.categoryName = product["category_name"];
            productDataModel.price = product["price"];
            productDataModel.productId = product["product_id"];
            productDataModel.productName = product["product_name"];
            productDataModel.qty = product["qty"];
            productDataModel.productCode = product["product_code"] ?? "";
            productDataModel.discountLock = product["discount_lock"];
            productDataModel.docid = product["product_id"];
            productDataModel.name = product["name"];
            productDataModel.productContent = product["product_content"];
            productDataModel.productImg = product["product_img"];
            productDataModel.qrCode = product["qr_code"];
            productDataModel.videoUrl = product["video_url"];
            setState(() {
              tmpProducts.add(productDataModel);
            });
          }
        }

        enquiryList.add(
          EstimateDataModel(
            docID: null,
            createddate: DateTime.parse(
              data['created_date'],
            ),
            enquiryid: null,
            estimateid: null,
            price: calcula,
            customer: customer,
            products: tmpProducts,
            dataType: DataTypes.local,
            referenceId: data["reference_id"],
          ),
        );
      }
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  searchEnquiryFun(String? value) async {
    if (value != null && searchForm.text.isNotEmpty) {
      if (value.isNotEmpty) {
        setState(() {
          enquiryList.clear();
        });
        Iterable<EstimateDataModel> tmpList = tmpEnquiryList.where((element) {
          if (element.customer != null &&
              element.customer!.customerName != null &&
              element.customer!.customerName!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.customer != null &&
              element.customer!.mobileNo != null &&
              element.customer!.mobileNo!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.customer != null &&
              element.customer!.city != null &&
              element.customer!.city!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.customer != null &&
              element.customer!.state != null &&
              element.customer!.state!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.customer != null &&
              element.enquiryid!
                  .toLowerCase()
                  .replaceAll(' ', '')
                  .startsWith(value.toLowerCase().replaceAll(' ', ''))) {
            return true;
          } else if (element.enquiryid!
              .toLowerCase()
              .contains(value.toLowerCase())) {
            return true;
          } else {
            return false;
          }
        });
        if (tmpList.isNotEmpty) {
          setState(() {
            enquiryList.addAll(tmpList);
          });
        }
      }
    } else {
      setState(() {
        enquiryList.clear();
        enquiryList.addAll(tmpEnquiryList);
      });
    }
  }

  filtersEnquiryFun(
    DateTime? fromDate,
    DateTime? toDate,
    String? customerID,
  ) async {
    Iterable<EstimateDataModel> tmpList = tmpEnquiryList.where((element) {
      final createdDate = element.createddate!;

      if (fromDate == null && toDate == null && customerID != null) {
        return element.customer!.docID == customerID;
      }

      if (fromDate != null && toDate == null) {
        return createdDate.isAfter(fromDate) &&
            element.customer!.docID == customerID;
      }

      if (fromDate == null && toDate != null) {
        return createdDate.isBefore(toDate) &&
            element.customer!.docID == customerID;
      }

      if (fromDate != null && toDate != null) {
        return createdDate.isAfter(fromDate) &&
            createdDate.isBefore(toDate) &&
            (customerID == null || element.customer!.docID == customerID);
      }

      return false;
    });

    if (tmpList.isNotEmpty) {
      setState(() {
        enquiryList.clear();
        enquiryList.addAll(tmpList);
      });
    }
  }

  String? selectedText;

  showFilterSheet() async {
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const EnquiryFilter();
      },
    ).then((result) {
      if (result != null) {
        filtersEnquiryFun(
          result["FromDate"],
          result["ToDate"],
          result["CustomerID"],
        );
      }
    });
  }

  downloadExcelData() async {
    try {
      loading(context);
      await EnquiryExcel(enquiryData: enquiryList, isEstimate: false)
          .createCustomerExcel()
          .then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          Navigator.pop(context);
          await helper.saveAndLaunchFile(fileData, 'Estimate Listing.xlsx');
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  Future? enquiryHandler;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);

        enquiryHandler = getEnquiryInfo();
      } else {
        enquiryHandler = getOfflineEnquiryInfo();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);

          enquiryHandler = getEnquiryInfo();
        } else {
          enquiryHandler = getOfflineEnquiryInfo();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      floatingActionButton: floatingButtons(context),
      body: Consumer<ConnectionProvider>(
        builder: (context, connectionProvider, child) {
          return body(connectionProvider);
        },
      ),
    );
  }

  FutureBuilder<dynamic> body(ConnectionProvider connectionProvider) {
    return FutureBuilder(
      future: enquiryHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureLoading(context);
        } else if (snapshot.hasError) {
          return errorDisplay(snapshot);
        } else {
          return enquiryList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Overall Bill Total",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "(${enquiryList.length} Bills)",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "\u{20B9}${overallTotal ?? 0}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                              ],
                            ),
                          ),
                          searchField(),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  if (connectionProvider.isConnected) {
                                    enquiryHandler = getEnquiryInfo();
                                  } else {
                                    enquiryHandler = getOfflineEnquiryInfo();
                                  }
                                });
                              },
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 70),
                                itemCount: enquiryList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      // if (enquiryList[index].dataType == DataTypes.cloud) {
                                      setState(() {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                EnquiryDetails(
                                              cid: enquiryList[index].docID ??
                                                  enquiryList[index]
                                                      .referenceId ??
                                                  '',
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null && value == true) {
                                            setState(() {
                                              if (connectionProvider
                                                  .isConnected) {
                                                enquiryHandler =
                                                    getEnquiryInfo();
                                              } else {
                                                enquiryHandler =
                                                    getOfflineEnquiryInfo();
                                              }
                                            });
                                          }
                                        });
                                        // crtlistview =
                                        //     orderlist[index];
                                      });
                                      // } else {
                                      // snackbar(context, false,
                                      // "Please upload the data to view details");
                                      // }
                                    },
                                    onLongPress: () {
                                      showDialog(
                                          context: context,
                                          builder: (builder) {
                                            return BillListOptions(
                                              title: enquiryList[index]
                                                          .enquiryid !=
                                                      null
                                                  ? enquiryList[index]
                                                      .enquiryid!
                                                  : enquiryList[index]
                                                              .referenceId !=
                                                          null
                                                      ? enquiryList[index]
                                                          .referenceId!
                                                      : "Choose an option",
                                            );
                                          }).then((value) {
                                        if (value != null) {
                                          if (value == "1") {
                                            sharePDF(enquiryList[index]);
                                          } else if (value == "2") {
                                            printEnquiry(enquiryList[index]);
                                          } else if (value == "3") {
                                            setState(() {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      EnquiryDetails(
                                                    cid: enquiryList[index]
                                                            .docID ??
                                                        '',
                                                  ),
                                                ),
                                              ).then((value) {
                                                if (value != null &&
                                                    value == true) {
                                                  setState(() {
                                                    if (connectionProvider
                                                        .isConnected) {
                                                      enquiryHandler =
                                                          getEnquiryInfo();
                                                    } else {
                                                      enquiryHandler =
                                                          getOfflineEnquiryInfo();
                                                    }
                                                  });
                                                }
                                              });
                                              // crtlistview =
                                              //     orderlist[index];
                                            });
                                          } else if (value == "4") {
                                            deleteEnquiry(
                                                enquiryList[index].docID ?? '',
                                                enquiryList[index]
                                                        .referenceId ??
                                                    '');
                                          }
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: index > 0
                                            ? const Border(
                                                top: BorderSide(
                                                  width: 0.5,
                                                  color: Color(0xffE0E0E0),
                                                ),
                                              )
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${enquiryList.length - index}",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: "ORDERID - ",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: connectionProvider
                                                                .isConnected
                                                            ? enquiryList[index]
                                                                .enquiryid
                                                            : enquiryList[index]
                                                                    .referenceId ??
                                                                "",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: enquiryList[
                                                                          index]
                                                                      .enquiryid ==
                                                                  null
                                                              ? Colors.red
                                                              : Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  "CUSTOMER - ${enquiryList[index].customer != null && enquiryList[index].customer!.customerName != null ? enquiryList[index].customer!.customerName : ""}",
                                                  // "CUSTOMER - ${enquiryList[index].customer!.customerName ?? ""}",
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  "DATE - ${DateFormat('dd-MM-yyyy hh:mm a').format(enquiryList[index].createddate!)}",
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              "Rs.${enquiryList[index].price!.total}",
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            child: const Center(
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 18,
                                                color: Color(0xff6B6B6B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : noData(context);
        }
      },
    );
  }

  Center errorDisplay(AsyncSnapshot<dynamic> snapshot) {
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
                    enquiryHandler = getEnquiryInfo();
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
  }

  Padding noData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(
              Assets.emptyList3,
              height: 200,
              width: 200,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            "No Enquiry",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              "You have not create any enquiry, so first you have create enquiry",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     TextButton.icon(
          //       onPressed: () async {
          //         await LocalDB
          //             .getBillingIndex()
          //             .then((value) async {
          //           if (value != null) {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(builder: (context) {
          //                 if (value == 1) {
          //                   return const BillingOne(
          //                     isEdit: true,
          //                     enquiryData: null,
          //                   );
          //                 } else {
          //                   return const BillingTwo(
          //                     isEdit: true,
          //                     enquiryData: null,
          //                   );
          //                 }
          //               }),
          //             );
          //           }
          //         });
          //       },
          //       icon: const Icon(Icons.add),
          //       label: const Text("Add Enquiry"),
          //     ),
          //     TextButton.icon(
          //       onPressed: () {
          //         setState(() {
          //           enquiryHandler = getEnquiryInfo();
          //         });
          //       },
          //       icon: const Icon(Icons.refresh),
          //       label: const Text("Refresh"),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Container searchField() {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
        bottom: 5,
      ),
      child: InputForm(
        controller: searchForm,
        formName: "Search Enquiry",
        prefixIcon: Icons.search,
        onChanged: (value) {
          searchEnquiryFun(value);
        },
      ),
    );
  }

  FloatingActionButton floatingButtons(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () async {
        await showFilterSheet();
      },
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list_outlined),
          SizedBox(
            width: 10,
          ),
          Text("Filter"),
        ],
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Enquiry"),
      actions: [
        IconButton(
          tooltip: "Download Excel File",
          onPressed: () {
            downloadExcelData();
          },
          icon: const Icon(Icons.file_download_outlined),
        ),
      ],
    );
  }

  deleteEnquiry(String docId, String referenceId) async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await FireStore().deleteEnquiry(docID: docId).then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Deleted");
        });
      } else {
        await LocalService.deleteEnquiry(referenceId: referenceId)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Deleted");
        });
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  sharePDF(EstimateDataModel estimateData) async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStore()
                .getCompanyDocInfo(cid: cid)
                .then((companyInfo) async {
              if (companyInfo != null) {
                setState(() {
                  companyData.companyName = companyInfo["company_name"];
                  companyData.address = companyInfo["address"];
                  companyData.contact = companyInfo["contact"];
                });

                var pdfAlignment = await LocalDB.getPdfAlignment();

                var pdf = EnquiryPdf(
                  estimateData: estimateData,
                  type: PdfType.enquiry,
                  companyInfo: companyData,
                  pdfAlignment: pdfAlignment,
                );
                await pdf.showA4PDf().then((dataResult) async {
                  await Printing.sharePdf(
                    bytes: dataResult,
                  ).then((value) {
                    Navigator.pop(context);
                  });
                });
                // var dataResult = await pdf.create3InchPDF();
              } else {
                Navigator.pop(context);
              }
            });
          } else {
            Navigator.pop(context);
          }
        });
      } else {
        var companyName = await LocalDB.fetchInfo(type: LocalData.companyName);
        var address = await LocalDB.fetchInfo(type: LocalData.companyAddress);
        setState(() {
          companyData.companyName = companyName;
          companyData.address = address;
        });
        var pdfAlignment = await LocalDB.getPdfAlignment();

        var pdf = EnquiryPdf(
          estimateData: estimateData,
          type: PdfType.enquiry,
          companyInfo: companyData,
          pdfAlignment: pdfAlignment,
        );
        await pdf.showA4PDf().then((dataResult) async {
          await Printing.sharePdf(
            bytes: dataResult,
          ).then((value) {
            Navigator.pop(context);
          });
        });
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  printEnquiry(EstimateDataModel estimateData) async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStore().getCompanyDocInfo(cid: cid).then((companyInfo) {
              if (companyInfo != null) {
                setState(() {
                  companyData.companyName = companyInfo["company_name"];
                  companyData.address = companyInfo["address"];
                  companyData.contact = companyInfo["contact"];
                });

                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => PrintView(
                      estimateData: estimateData,
                      companyInfo: companyData,
                    ),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            });
          } else {
            Navigator.pop(context);
          }
        });
      } else {
        var companyName = await LocalDB.fetchInfo(type: LocalData.companyName);
        var address = await LocalDB.fetchInfo(type: LocalData.companyAddress);
        // add contact
        setState(() {
          companyData.companyName = companyName;
          companyData.address = address;
          // add also
        });

        Navigator.pop(context);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PrintView(
              estimateData: estimateData,
              companyInfo: companyData,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  var companyData = ProfileModel();
}
