import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
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

class EstimateListing extends StatefulWidget {
  const EstimateListing({super.key});

  @override
  State<EstimateListing> createState() => _EstimateListingState();
}

class _EstimateListingState extends State<EstimateListing> {
  List<EstimateDataModel> enquiryList = [];
  List<EstimateDataModel> tmpEnquiryList = [];
  TextEditingController searchForm = TextEditingController();
  int? overallTotal;
  int start = 0, end = 10, totalBills = 0;

  @override
  void dispose() {
    enquiryList.clear();
    tmpEnquiryList.clear();
    super.dispose();
  }

  Future<void> getEnquiryTotal() async {
    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    var enquiry = await FireStore().getEstimateTotal(cid: cid);
    var enquiryLength = enquiry["total_estimate"];
    var enquiryTotal = enquiry["total"];

    setState(() {
      overallTotal = enquiryTotal.toInt();
      totalBills = enquiryLength;
    });
  }

  Future<void> getOfflineTotal() async {
    var enquiry = await DatabaseHelper().getEstimateTotal();
    var enquiryLength = enquiry["no_of_estimate"];
    var enquiryTotal = enquiry["total"];

    setState(() {
      overallTotal = double.parse(enquiryTotal).toInt();
      totalBills = enquiryLength;
    });
  }

  List<CategoryDataModel> categoryList = [];

  Future getEstimateInfo() async {
    try {
      setState(() {
        enquiryList.clear();
        tmpEnquiryList.clear();
        isLoad = false;
        endOfDocument = false;
        start = 0;
        end = 10;
      });
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        await FireStore().categoryListing(cid: cid).then((value) {
          if (value != null && value.docs.isNotEmpty) {
            for (var categorylist in value.docs) {
              CategoryDataModel model = CategoryDataModel();
              model.categoryName = categorylist["category_name"].toString();
              model.postion = categorylist["postion"];
              model.tmpcatid = categorylist.id;
              model.discount = categorylist["discount"];
              setState(() {
                categoryList.add(model);
              });
            }
          }
        });
        var enquiry = await FireStore()
            .getEstimate(cid: cid, start: start, end: end, isLimitPage: true);
        if (enquiry.isNotEmpty) {
          for (var value in enquiry) {
            var calc = BillingCalCulationModel();
            calc.discountValue = value["price"]["discount_value"];
            calc.extraDiscount = value["price"]["extra_discount"];
            calc.roundOff = value["price"]["round_off"];
            calc.extraDiscountValue = value["price"]["extra_discount_value"];
            calc.extraDiscountsys = value["price"]["extra_discount_sys"];
            calc.package = value["price"]["package"];
            calc.packageValue = value["price"]["package_value"];
            calc.packagesys = value["price"]["package_sys"];
            calc.subTotal = value["price"]["sub_total"];
            calc.total = value["price"]["total"];

            CustomerDataModel? customer = CustomerDataModel();
            if (value["customer"] != null) {
              customer.docID = value["customer"]["customer_id"];
              customer.address = value["customer"]["address"];
              customer.state = value["customer"]["state"];
              customer.city = value["customer"]["city"];
              customer.customerName = value["customer"]["customer_name"];
              customer.email = value["customer"]["email"];
              customer.mobileNo = value["customer"]["mobile_no"];
            } else {
              customer = null;
            }

            List<ProductDataModel> tmpProducts = [];

            setState(() {
              tmpProducts.clear();
            });

            await FireStore()
                .getEstimateProducts(docid: value.id)
                .then((products) {
              if (products != null && products.docs.isNotEmpty) {
                for (var product in products.docs) {
                  Map<String, dynamic> p =
                      product.data() as Map<String, dynamic>;
                  var productDataModel = ProductDataModel();
                  productDataModel.categoryid = product["category_id"];
                  productDataModel.categoryName = product["category_name"];
                  productDataModel.price = product["price"];
                  productDataModel.productId = product["product_id"];
                  productDataModel.productName = product["product_name"];
                  productDataModel.qty = product["qty"];
                  productDataModel.productCode = product["product_code"] ?? "";
                  productDataModel.productType = product["discount_lock"] ||
                          (p.containsKey('discount')
                              ? product["discount"] != null
                              : false)
                      ? ProductType.netRated
                      : ProductType.discounted;
                  productDataModel.hsnCode =
                      (p.containsKey('hsn_code') ? product["hsn_code"] : null);
                  productDataModel.taxValue =
                      (p.containsKey('tax_value') ? product["hsn_code"] : null);

                  productDataModel.discountLock = product["discount_lock"];
                  if (productDataModel.categoryid != null &&
                      productDataModel.categoryid!.isNotEmpty) {
                    var getCategoryid = categoryList.indexWhere((elements) =>
                        elements.tmpcatid == productDataModel.categoryid);
                    productDataModel.discount =
                        categoryList[getCategoryid].discount;
                  }
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
                  docID: value.id,
                  createddate: DateTime.parse(
                    value["created_date"].toDate().toString(),
                  ),
                  enquiryid: value["estimate_id"],
                  estimateid: value["estimate_id"],
                  price: calc,
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

        enquiryList.sort((a, b) {
          int numA = int.parse(a.estimateid.toString().substring(7));
          int numB = int.parse(b.estimateid.toString().substring(7));
          return numB.compareTo(numA);
        });

        return enquiry;
      }
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  Future getOfflineEstimateInfo() async {
    try {
      overallTotal = 0;

      setState(() {
        enquiryList.clear();
        tmpEnquiryList.clear();
      });

      var localEnquiry = await DatabaseHelper()
          .getEstimate(start: start, end: end, limitApplied: true);
      for (var data in localEnquiry) {
        var calcula = BillingCalCulationModel();
        var price = jsonDecode(data['price']) as Map<String, dynamic>;
        calcula.discountValue = price["discount_value"];
        calcula.extraDiscount = price["extra_discount"];
        calcula.extraDiscountValue = price["extra_discount_value"];
        calcula.extraDiscountsys = price["extra_discount_sys"];
        calcula.package = price["package"];
        calcula.packageValue = price["package_value"];
        calcula.packagesys = price["package_sys"];
        calcula.subTotal = price["sub_total"];
        calcula.total = price["total"];
        calcula.roundOff = price["round_off"];

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

      return enquiryList
          .sort((a, b) => b.createddate!.compareTo(a.createddate!));
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  downloadExcelData() async {
    try {
      loading(context);
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

      var enquiry = await FireStore().getAllEstimate(cid: cid);
      for (var enquiryData in enquiry) {
        var calc = BillingCalCulationModel();
        calc.discountValue = enquiryData["price"]["discount_value"];
        calc.extraDiscount = enquiryData["price"]["extra_discount"];
        calc.roundOff = enquiryData["price"]["round_off"];
        calc.extraDiscountValue = enquiryData["price"]["extra_discount_value"];
        calc.extraDiscountsys = enquiryData["price"]["extra_discount_sys"];
        calc.package = enquiryData["price"]["package"];
        calc.packageValue = enquiryData["price"]["package_value"];
        calc.packagesys = enquiryData["price"]["package_sys"];
        calc.subTotal = enquiryData["price"]["sub_total"];
        calc.total = enquiryData["price"]["total"];
        calc.netratedTotal = enquiryData["price"]["netrated_total"];
        calc.discountedTotal = enquiryData["price"]["discounted_total"];
        calc.netPlusDisTotal = enquiryData["price"]["net_plus_dis_total"];
        calc.discounts = enquiryData["price"]["discounts"];

        CustomerDataModel? customer = CustomerDataModel();
        if (enquiryData["customer"] != null) {
          customer.docID = enquiryData["customer"]["customer_id"];
          customer.address = enquiryData["customer"]["address"];
          customer.state = enquiryData["customer"]["state"];
          customer.city = enquiryData["customer"]["city"];
          customer.customerName = enquiryData["customer"]["customer_name"];
          customer.email = enquiryData["customer"]["email"];
          customer.mobileNo = enquiryData["customer"]["mobile_no"];
        } else {
          customer = null;
        }

        List<ProductDataModel> tmpProducts = [];

        setState(() {
          tmpProducts.clear();
        });

        await FireStore()
            .getEstimateProducts(docid: enquiryData.id)
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
              productDataModel.productType =
                  product["discount_lock"] || product["discount"] == null
                      ? ProductType.netRated
                      : ProductType.discounted;
              if (productDataModel.productType == ProductType.discounted) {
                productDataModel.discountedPrice =
                    double.parse(product["price"].toString()) -
                        (double.parse(product["price"].toString()) *
                            product["discount"] /
                            100);
              } else {
                productDataModel.discountedPrice =
                    double.parse(product["price"].toString());
              }

              setState(() {
                tmpProducts.add(productDataModel);
              });
            }
          }
        });

        setState(() {
          tmpEnquiryList.add(
            EstimateDataModel(
              docID: enquiryData.id,
              createddate: DateTime.parse(
                enquiryData["created_date"].toDate().toString(),
              ),
              enquiryid: enquiryData['estimate_id'],
              estimateid: enquiryData["estimate_id"],
              price: calc,
              customer: customer,
              products: tmpProducts,
              dataType: DataTypes.cloud,
            ),
          );
        });
      }

      await EnquiryExcel(enquiryData: tmpEnquiryList, isEstimate: true)
          .createCustomerExcel()
          .then((value) async {
        Navigator.pop(context);
        showToast(context,
            content: "Xls file downloaded", isSuccess: true, top: false);
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          await helper.saveAndLaunchFile(fileData, 'Estimate List.xlsx');
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  Future? estimateHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);
        getEnquiryTotal();
        estimateHandler = getEstimateInfo();
      } else {
        estimateHandler = getOfflineEstimateInfo();
        getOfflineTotal();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);
          getEnquiryTotal();
          estimateHandler = getEstimateInfo();
        } else {
          estimateHandler = getOfflineEstimateInfo();
          getOfflineTotal();
        }
      });
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadBills();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      floatingActionButton: floatingButton(context),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            return RefreshIndicator(
              color: Theme.of(context).primaryColor,
              onRefresh: () async {
                if (connectionProvider.isConnected) {
                  setState(() {
                    estimateHandler = getEstimateInfo();
                  });
                } else {
                  setState(() {
                    estimateHandler = getOfflineEstimateInfo();
                  });
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(8),
                controller: _scrollController,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                "($totalBills Bills)",
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
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder(
                      future: estimateHandler,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return futureLoading(context);
                        } else if (snapshot.hasError) {
                          return errorDisplay(snapshot);
                        } else {
                          return enquiryList.isNotEmpty
                              ? ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: enquiryList.length,
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemBuilder: (context, index) {
                                    if (enquiryList[index].estimateid == null) {
                                      return const SizedBox();
                                    } else {
                                      return GestureDetector(
                                        onTap: () {
                                          // if (enquiryList[index].dataType ==
                                          //     DataTypes.cloud) {
                                          setState(() {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    EstimateDetails(
                                                  cid: enquiryList[index]
                                                          .docID ??
                                                      enquiryList[index]
                                                          .referenceId ??
                                                      '',
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value != null &&
                                                  value == true) {
                                                if (connectionProvider
                                                    .isConnected) {
                                                  setState(() {
                                                    estimateHandler =
                                                        getEstimateInfo();
                                                  });
                                                } else {
                                                  setState(() {
                                                    estimateHandler =
                                                        getOfflineEstimateInfo();
                                                  });
                                                }
                                              }
                                            });
                                          });
                                          // } else {
                                          //   snackbar(context, false,
                                          //       "Please upload the data to view details");
                                          // }
                                        },
                                        onLongPress: () {
                                          billOptions(
                                              enquiryList[index].estimateid !=
                                                      null
                                                  ? enquiryList[index]
                                                      .estimateid!
                                                  : enquiryList[index]
                                                              .referenceId !=
                                                          null
                                                      ? enquiryList[index]
                                                          .referenceId!
                                                      : "Choose an option",
                                              index);
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 18,
                                                        width: 18,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade300,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "${index + 1}",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        connectionProvider
                                                                .isConnected
                                                            ? enquiryList[index]
                                                                    .estimateid ??
                                                                ''
                                                            : enquiryList[index]
                                                                    .referenceId ??
                                                                "",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(enquiryList[
                                                                    index]
                                                                .createddate ??
                                                            DateTime.now()),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: 10),
                                                        if (enquiryList[index]
                                                                    .customer !=
                                                                null &&
                                                            enquiryList[index]
                                                                    .customer!
                                                                    .customerName !=
                                                                null &&
                                                            enquiryList[index]
                                                                .customer!
                                                                .customerName!
                                                                .isNotEmpty)
                                                          Text(
                                                            "${enquiryList[index].customer!.customerName}",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleLarge!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        const SizedBox(
                                                            height: 5),
                                                        if (enquiryList[index]
                                                                    .customer
                                                                    ?.city !=
                                                                null ||
                                                            enquiryList[index]
                                                                    .customer
                                                                    ?.mobileNo !=
                                                                null)
                                                          Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                      Iconsax
                                                                          .location,
                                                                      size: 10),
                                                                  Text(
                                                                    enquiryList[index]
                                                                            .customer
                                                                            ?.city ??
                                                                        "",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                      Iconsax
                                                                          .call,
                                                                      size: 10),
                                                                  Text(
                                                                    enquiryList[index]
                                                                            .customer
                                                                            ?.mobileNo ??
                                                                        "",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Iconsax
                                                                    .calendar,
                                                                size: 10),
                                                            Text(
                                                              DateFormat(
                                                                      'dd-MM-yyyy hh:mm a')
                                                                  .format(enquiryList[
                                                                              index]
                                                                          .createddate ??
                                                                      DateTime
                                                                          .now()),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "\u{20B9}${enquiryList[index].price?.total ?? ""}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                )
                              : noData(context);
                        }
                      }),

                  // FutureBuilder(
                  //   future: estimateHandler,
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return futureLoading(context);
                  //     } else if (snapshot.hasError) {
                  //       return errorDisplay(snapshot);
                  //     } else {
                  //       return enquiryList.isNotEmpty
                  //           ? ListView.builder(
                  //               primary: false,
                  //               shrinkWrap: true,
                  //               padding: const EdgeInsets.only(bottom: 20),
                  //               itemCount: enquiryList.length,
                  //               itemBuilder: (context, index) {
                  //                 return GestureDetector(
                  //                   onTap: () {
                  //                     // if (enquiryList[index].dataType ==
                  //                     //     DataTypes.cloud) {
                  //                     setState(() {
                  //                       Navigator.push(
                  //                         context,
                  //                         CupertinoPageRoute(
                  //                           builder: (context) =>
                  //                               EstimateDetails(
                  //                             cid: enquiryList[index].docID ??
                  //                                 enquiryList[index]
                  //                                     .referenceId ??
                  //                                 '',
                  //                           ),
                  //                         ),
                  //                       ).then((value) {
                  //                         if (value != null && value == true) {
                  //                           if (connectionProvider
                  //                               .isConnected) {
                  //                             setState(() {
                  //                               estimateHandler =
                  //                                   getEstimateInfo();
                  //                             });
                  //                           } else {
                  //                             setState(() {
                  //                               estimateHandler =
                  //                                   getOfflineEstimateInfo();
                  //                             });
                  //                           }
                  //                         }
                  //                       });
                  //                     });
                  //                     // } else {
                  //                     //   snackbar(context, false,
                  //                     //       "Please upload the data to view details");
                  //                     // }
                  //                   },
                  //                   onLongPress: () {
                  //                     billOptions(
                  //                         enquiryList[index].estimateid != null
                  //                             ? enquiryList[index].estimateid!
                  //                             : enquiryList[index]
                  //                                         .referenceId !=
                  //                                     null
                  //                                 ? enquiryList[index]
                  //                                     .referenceId!
                  //                                 : "Choose an option",
                  //                         index);
                  //                   },
                  //                   child: Container(
                  //                     padding: const EdgeInsets.all(10),
                  //                     decoration: BoxDecoration(
                  //                       color: Colors.white,
                  //                       border: index > 0
                  //                           ? const Border(
                  //                               top: BorderSide(
                  //                                 width: 0.5,
                  //                                 color: Color(0xffE0E0E0),
                  //                               ),
                  //                             )
                  //                           : null,
                  //                     ),
                  //                     child: Row(
                  //                       children: [
                  //                         Container(
                  //                           height: 40,
                  //                           width: 40,
                  //                           decoration: BoxDecoration(
                  //                             color: Colors.grey.shade300,
                  //                             shape: BoxShape.circle,
                  //                           ),
                  //                           child: Center(
                  //                             child: Text(
                  //                               "${index + 1}",
                  //                               style: const TextStyle(
                  //                                 color: Colors.grey,
                  //                                 fontSize: 15,
                  //                                 fontWeight: FontWeight.bold,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                         const SizedBox(
                  //                           width: 10,
                  //                         ),
                  //                         Expanded(
                  //                           child: Column(
                  //                             mainAxisSize: MainAxisSize.min,
                  //                             crossAxisAlignment:
                  //                                 CrossAxisAlignment.start,
                  //                             children: [
                  //                               RichText(
                  //                                 text: TextSpan(
                  //                                   children: [
                  //                                     const TextSpan(
                  //                                       text: "ESTIMATE ID - ",
                  //                                       style: TextStyle(
                  //                                         fontWeight:
                  //                                             FontWeight.bold,
                  //                                         color: Colors.black,
                  //                                       ),
                  //                                     ),
                  //                                     TextSpan(
                  //                                       text: connectionProvider
                  //                                               .isConnected
                  //                                           ? enquiryList[index]
                  //                                               .estimateid
                  //                                           : enquiryList[index]
                  //                                                   .referenceId ??
                  //                                               "",
                  //                                       style: TextStyle(
                  //                                         fontWeight:
                  //                                             FontWeight.bold,
                  //                                         color: enquiryList[
                  //                                                         index]
                  //                                                     .estimateid ==
                  //                                                 null
                  //                                             ? Colors.red
                  //                                             : Colors.black,
                  //                                       ),
                  //                                     ),
                  //                                   ],
                  //                                 ),
                  //                               ),
                  //                               const SizedBox(
                  //                                 height: 3,
                  //                               ),
                  //                               RichText(
                  //                                 textAlign: TextAlign.center,
                  //                                 text: TextSpan(
                  //                                   text:
                  //                                       "CUSTOMER - ",
                  //                                   style: const TextStyle(
                  //                                     color: Colors.black87,
                  //                                     fontSize: 13,
                  //                                   ),
                  //                                   children: [
                  //                                     TextSpan(
                  //                                       text:
                  //                                           "${enquiryList[index].customer != null && enquiryList[index].customer!.customerName != null ? enquiryList[index].customer!.customerName : ""}",
                  //                                       style: const TextStyle(
                  //                                         color: Colors.black,
                  //                                         fontWeight:
                  //                                             FontWeight.bold,
                  //                                       ),
                  //                                     ),
                  //                                     if (enquiryList[index]
                  //                                                 .customer!
                  //                                                 .customerName !=
                  //                                             null &&
                  //                                         enquiryList[index]
                  //                                             .customer!
                  //                                             .customerName!
                  //                                             .isEmpty)
                  //                                       TextSpan(
                  //                                         text: enquiryList[
                  //                                                     index]
                  //                                                 .customer!
                  //                                                 .mobileNo ??
                  //                                             '',
                  //                                         style:
                  //                                             const TextStyle(
                  //                                           fontSize: 13,
                  //                                           fontWeight:
                  //                                               FontWeight.bold,
                  //                                         ),
                  //                                       )
                  //                                   ],
                  //                                 ),
                  //                               ),
                  //                               Text(
                  //                                 "DATE - ${DateFormat('dd-MM-yyyy hh:mm a').format(enquiryList[index].createddate!)}",
                  //                                 style: const TextStyle(
                  //                                   fontSize: 13,
                  //                                 ),
                  //                               ),
                  //                             ],
                  //                           ),
                  //                         ),
                  //                         Center(
                  //                           child: Text(
                  //                             "Rs.${enquiryList[index].price!.total}",
                  //                           ),
                  //                         ),
                  //                         Container(
                  //                           padding: const EdgeInsets.all(10),
                  //                           child: const Center(
                  //                             child: Icon(
                  //                               Icons.arrow_forward_ios,
                  //                               size: 18,
                  //                               color: Color(0xff6B6B6B),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 );
                  //               },
                  //             )
                  //           : noData(context);
                  //     }
                  //   },
                  // ),

                  Visibility(
                    visible: isLoad,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: endOfDocument,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop_rounded, color: Colors.red.shade300),
                        Text("End of Document",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Colors.red.shade300,
                                    fontWeight: FontWeight.bold))
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  loadBills() async {
    setState(() {
      isLoad = true;
      start += 10;
      end += 10;
      endOfDocument = false;
    });
    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    if (cid != null) {
      var enquiry = await FireStore()
          .getEstimate(cid: cid, start: start, end: end, isLimitPage: true);
      if (enquiry.isNotEmpty) {
        for (var enquiryData in enquiry) {
          var calc = BillingCalCulationModel();
          calc.discountValue = enquiryData["price"]["discount_value"];
          calc.extraDiscount = enquiryData["price"]["extra_discount"];
          calc.roundOff = enquiryData["price"]["round_off"];
          calc.extraDiscountValue =
              enquiryData["price"]["extra_discount_value"];
          calc.extraDiscountsys = enquiryData["price"]["extra_discount_sys"];
          calc.package = enquiryData["price"]["package"];
          calc.packageValue = enquiryData["price"]["package_value"];
          calc.packagesys = enquiryData["price"]["package_sys"];
          calc.subTotal = enquiryData["price"]["sub_total"];
          calc.total = enquiryData["price"]["total"];
          calc.netratedTotal = enquiryData["price"]["netrated_total"];
          calc.discountedTotal = enquiryData["price"]["discounted_total"];
          calc.netPlusDisTotal = enquiryData["price"]["net_plus_dis_total"];
          calc.discounts = enquiryData["price"]["discounts"];

          var customer = CustomerDataModel();
          if (enquiryData["customer"] != null) {
            customer.docID = enquiryData["customer"]["customer_id"] ?? '';
            customer.address = enquiryData["customer"]["address"] ?? '';
            customer.state = enquiryData["customer"]["state"] ?? '';
            customer.city = enquiryData["customer"]["city"] ?? '';
            customer.customerName =
                enquiryData["customer"]["customer_name"] ?? '';
            customer.email = enquiryData["customer"]["email"] ?? '';
            customer.mobileNo = enquiryData["customer"]["mobile_no"] ?? '';
          }

          List<ProductDataModel> tmpProducts = [];

          setState(() {
            tmpProducts.clear();
          });

          await FireStore()
              .getEstimateProducts(docid: enquiryData.id)
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
                productDataModel.productCode = product["product_code"];
                productDataModel.discountLock = product["discount_lock"];
                productDataModel.docid = product.id;
                productDataModel.name = product["name"];
                productDataModel.productContent = product["product_content"];
                productDataModel.productImg = product["product_img"];
                productDataModel.qrCode = product["qr_code"];
                productDataModel.videoUrl = product["video_url"];
                productDataModel.productType =
                    product["discount_lock"] || product["discount"] == null
                        ? ProductType.netRated
                        : ProductType.discounted;
                if (productDataModel.productType == ProductType.discounted) {
                  productDataModel.discountedPrice =
                      double.parse(product["price"].toString()) -
                          (double.parse(product["price"].toString()) *
                              product["discount"] /
                              100);
                } else {
                  productDataModel.discountedPrice =
                      double.parse(product["price"].toString());
                }
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
                enquiryid: enquiryData["estimate_id"],
                estimateid: enquiryData["estimate_id"],
                price: calc,
                customer: customer,
                products: tmpProducts,
                dataType: DataTypes.cloud,
              ),
            );
          });
        }
      } else {
        setState(() {
          isLoad = false;
          endOfDocument = true;
        });
      }
      setState(() {
        tmpEnquiryList.addAll(enquiryList);
      });

      return enquiry;
    }
  }

  final ScrollController _scrollController = ScrollController();

  bool isLoad = false;
  bool endOfDocument = false;

  filter(Map<String, dynamic> search) async {
    setState(() {
      enquiryList.clear();
      tmpEnquiryList.clear();
      isLoad = false;
      endOfDocument = false;
    });

    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

    if (cid != null) {
      var enquiry = await FireStore().getAllEstimate(cid: cid);
      for (var enquiryData in enquiry) {
        var calc = BillingCalCulationModel();
        calc.discountValue = enquiryData["price"]["discount_value"];
        calc.extraDiscount = enquiryData["price"]["extra_discount"];
        calc.roundOff = enquiryData["price"]["round_off"];
        calc.extraDiscountValue = enquiryData["price"]["extra_discount_value"];
        calc.extraDiscountsys = enquiryData["price"]["extra_discount_sys"];
        calc.package = enquiryData["price"]["package"];
        calc.packageValue = enquiryData["price"]["package_value"];
        calc.packagesys = enquiryData["price"]["package_sys"];
        calc.subTotal = enquiryData["price"]["sub_total"];
        calc.total = enquiryData["price"]["total"];
        calc.netratedTotal = enquiryData["price"]["netrated_total"];
        calc.discountedTotal = enquiryData["price"]["discounted_total"];
        calc.netPlusDisTotal = enquiryData["price"]["net_plus_dis_total"];
        calc.discounts = enquiryData["price"]["discounts"];

        CustomerDataModel? customer = CustomerDataModel();
        if (enquiryData["customer"] != null) {
          customer.docID = enquiryData["customer"]["customer_id"];
          customer.address = enquiryData["customer"]["address"];
          customer.state = enquiryData["customer"]["state"];
          customer.city = enquiryData["customer"]["city"];
          customer.customerName = enquiryData["customer"]["customer_name"];
          customer.email = enquiryData["customer"]["email"];
          customer.mobileNo = enquiryData["customer"]["mobile_no"];
        } else {
          customer = null;
        }

        List<ProductDataModel> tmpProducts = [];

        setState(() {
          tmpProducts.clear();
        });

        await FireStore()
            .getEstimateProducts(docid: enquiryData.id)
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
              productDataModel.productType =
                  product["discount_lock"] || product["discount"] == null
                      ? ProductType.netRated
                      : ProductType.discounted;
              if (productDataModel.productType == ProductType.discounted) {
                productDataModel.discountedPrice =
                    double.parse(product["price"].toString()) -
                        (double.parse(product["price"].toString()) *
                            product["discount"] /
                            100);
              } else {
                productDataModel.discountedPrice =
                    double.parse(product["price"].toString());
              }

              setState(() {
                tmpProducts.add(productDataModel);
              });
            }
          }
        });

        setState(() {
          tmpEnquiryList.add(
            EstimateDataModel(
              docID: enquiryData.id,
              createddate: DateTime.parse(
                enquiryData["created_date"].toDate().toString(),
              ),
              enquiryid: enquiryData['estimate_id'],
              estimateid: enquiryData["estimate_id"],
              price: calc,
              customer: customer,
              products: tmpProducts,
              dataType: DataTypes.cloud,
            ),
          );
        });
      }
    }

    List<EstimateDataModel> filteredList = tmpEnquiryList.where((enquiry) {
      if (search["search_text"].isNotEmpty) {
        if (enquiry.customer != null &&
            enquiry.customer!.customerName != null &&
            enquiry.customer!.customerName!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(
                    search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.customer != null &&
            enquiry.customer!.mobileNo != null &&
            enquiry.customer!.mobileNo!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(
                    search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.customer != null &&
            enquiry.customer!.city != null &&
            enquiry.customer!.city!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.customer != null &&
            enquiry.customer!.state != null &&
            enquiry.customer!.state!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.enquiryid != null &&
            enquiry.enquiryid!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.enquiryid != null &&
            enquiry.enquiryid!
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else {
          return false;
        }
      } else if (search["from_date"] != null && search["to_date"] != null) {
        if (enquiry.createddate != null &&
            enquiry.createddate!.isAfter(search["from_date"]) &&
            enquiry.createddate!.isBefore(DateTime(
                search["to_date"].year,
                search["to_date"].month,
                search["to_date"].day,
                23,
                59,
                59,
                999 // Set time to 23:59:59.999 (last millisecond of the day)
                ))) {
          return true;
        } else {
          return false;
        }
      } else if (search["customer"]["doc_id"] != null) {
        if (enquiry.customer != null &&
            enquiry.customer!.docID == search["customer"]["doc_id"]) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }).toList();
    setState(() {
      enquiryList = filteredList;
    });
  }

  FloatingActionButton floatingButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () {
        billFilters();
      },
      child: const Icon(Icons.filter_list_outlined),
    );
  }

  billFilters() async {
    await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (builder) {
        return const FractionallySizedBox(
          heightFactor: 0.9,
          child: BillingFilters(),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          estimateHandler = filter(value);
        });
      }
    });
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
                    estimateHandler = getEstimateInfo();
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
            "No Estimate",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              "You have not create any estimate, so first you have create estimate",
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
          //         Navigator.push(
          //           context,
          //           CupertinoPageRoute(builder: (context) {
          //             return const EnquiryListing();
          //           }),
          //         );
          //       },
          //       icon: const Icon(Icons.add),
          //       label: const Text("Add Estimate"),
          //     ),
          //     TextButton.icon(
          //       onPressed: () {
          //         setState(() {
          //           estimateHandler = getEstimateInfo();
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

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Estimate"),
      actions: [
        IconButton(
          tooltip: "Add Estimate",
          onPressed: () async {
            Navigator.pop(context);
            await LocalDB.getBillingIndex().then((value) async {
              if (value != null) {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) {
                    if (value == 1) {
                      return const BillingOne();
                    } else {
                      return const BillingTwo();
                    }
                  }),
                );
              }
            });
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final connectionProvider =
                  Provider.of<ConnectionProvider>(context, listen: false);
              if (connectionProvider.isConnected) {
                AccountValid.accountValid(context);

                estimateHandler = getEstimateInfo();
              } else {
                estimateHandler = getOfflineEstimateInfo();
              }
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final connectionProvider =
                  Provider.of<ConnectionProvider>(context, listen: false);
              connectionProvider.addListener(() {
                if (connectionProvider.isConnected) {
                  AccountValid.accountValid(context);

                  estimateHandler = getEstimateInfo();
                } else {
                  estimateHandler = getOfflineEstimateInfo();
                }
              });
            });
          },
          icon: const Icon(Icons.refresh),
        ),
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

  duplicateEstimate(EstimateDataModel estimateData) async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    try {
      if (connectionProvider.isConnected) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStore()
                .duplicateEstimate(docID: estimateData.docID!, cid: cid)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context, true);
              snackbar(context, true, "Successfully Estimate Duplicated");
            });
          }
        });
      } else {
        await LocalService.duplicateEstimate(
                referenceId: estimateData.referenceId!)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Estimate Duplicated");
        });
      }
    } catch (e) {
      Navigator.pop(context);
      throw e.toString();
    }
  }

  billOptions(String title, int index) async {
    await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (builder) {
        return FractionallySizedBox(
          heightFactor: 0.4,
          child: BillOptions(
            title: title,
            billType: BillType.estimate,
            estimate: enquiryList[index],
          ),
        );
      },
    );
  }

  var companyData = ProfileModel();
}
