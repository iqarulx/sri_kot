import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../billing/create/billing_one_inv.dart';
import '../billing/create/billing_two_inv.dart';
import '/gen/assets.gen.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import '/provider/src/file_open.dart' as helper;

class InvoiceListing extends StatefulWidget {
  const InvoiceListing({super.key});

  @override
  State<InvoiceListing> createState() => _InvoiceListingState();
}

class _InvoiceListingState extends State<InvoiceListing> {
  Future? invoiceHandler;

  TextEditingController search = TextEditingController();
  List<InvoiceModel> invoiceList = [];
  List<InvoiceModel> tmpinvoiceList = [];
  int? overallTotal;
  int start = 0, end = 10, totalBills = 0;
  bool isLoad = false;
  bool endOfDocument = false;
  List<CategoryDataModel> categoryList = [];

  Future<void> getInvoiceTotal() async {
    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    var invoice = await FireStore().getInvoiceTotal(cid: cid);
    var invoiceLength = invoice["total_invoice"];
    var invoiceTotal = invoice["total"];

    setState(() {
      overallTotal = invoiceTotal.toInt();
      totalBills = invoiceLength;
    });
  }

  Future getInvoiceList() async {
    try {
      setState(() {
        invoiceList.clear();
        tmpinvoiceList.clear();
        isLoad = false;
        endOfDocument = false;
        start = 0;
        end = 10;
      });

      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
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
      });
      return await FireStore().getInvoice(start: start, end: end).then((data) {
        if (data.isNotEmpty) {
          for (var value in data) {
            InvoiceModel model = InvoiceModel();

            model.docID = value.id;
            model.partyName = value["party_name"];
            model.address = value["address"];
            model.billDate = (value["bill_date"] as Timestamp).toDate();
            model.billNo = value["bill_no"];
            model.state = value["state"];
            model.city = value["city"];
            model.phoneNumber = value["phone_number"];
            model.totalBillAmount = value["total_amount"];
            model.transportName = value["transport_name"];
            model.transportNumber = value["transport_number"];
            model.taxType = value["tax_type"];

            if (model.taxType ?? false) {
              model.gstType = value["gst_type"];
              model.sameState = value["is_same_state"];
              model.taxCalc = value["tax_calc"];
            }
            model.listingProducts = [];
            if (value["products"] != null) {
              for (var productElement in value["products"]) {
                InvoiceProductModel models = InvoiceProductModel();
                models.productID = productElement["product_id"];
                models.productName = productElement["product_name"];
                models.qty = productElement["qty"];
                models.rate = productElement["rate"].toDouble();
                models.total = productElement["total"].toDouble();
                models.unit = productElement["unit"];
                models.categoryID = productElement["category_id"];
                models.discountLock = productElement["discount_lock"];
                models.discount = productElement["discount"];
                if (model.taxType ?? false) {
                  models.hsnCode = productElement["hsn_code"].toString();
                  models.taxValue = productElement["tax_value"];
                }
                models.productType = productElement["discount_lock"] ||
                        productElement["discount"] == null
                    ? ProductType.netRated
                    : ProductType.discounted;
                if (models.productType == ProductType.discounted) {
                  models.discountedPrice =
                      double.parse(productElement["rate"].toString()) -
                          (double.parse(productElement["rate"].toString()) *
                              productElement["discount"] /
                              100);
                } else {
                  models.discountedPrice =
                      double.parse(productElement["rate"].toString());
                }
                setState(() {
                  model.listingProducts!.add(models);
                });
              }
            }
            model.deliveryaddress = value["delivery_address"] ?? "";

            if (value["price"] != null) {
              var calcula = BillingCalCulationModel();
              calcula.discountValue = value["price"]["discount_value"];
              calcula.extraDiscount = value["price"]["extra_discount"];
              calcula.extraDiscountValue =
                  value["price"]["extra_discount_value"];
              calcula.extraDiscountsys = value["price"]["extra_discount_sys"];
              calcula.package = value["price"]["package"];
              calcula.packageValue = value["price"]["package_value"];
              calcula.packagesys = value["price"]["package_sys"];
              calcula.subTotal = value["price"]["sub_total"];
              calcula.roundOff = value["price"]["round_off"];
              calcula.total = value["price"]["total"];

              model.price = calcula;
            }
            setState(() {
              invoiceList.add(model);
            });
          }
          tmpinvoiceList.addAll(invoiceList);
        }
        return invoiceList;
      });
    } catch (e) {
      snackbar(context, false, e.toString());
      throw e.toString();
    }
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
          invoiceHandler = filter(value);
        });
      }
    });
  }

  filter(Map<String, dynamic> search) async {
    setState(() {
      invoiceList.clear();
      tmpinvoiceList.clear();
      isLoad = false;
      endOfDocument = false;
    });

    await FireStore().getAllInvoice().then((value) {
      if (value.isNotEmpty) {
        for (var element in value) {
          InvoiceModel model = InvoiceModel();
          model.docID = element.id;
          model.partyName = element["party_name"];
          model.address = element["address"];
          model.billDate = (element["bill_date"] as Timestamp).toDate();
          model.billNo = element["bill_no"];
          model.phoneNumber = element["phone_number"];
          model.totalBillAmount = element["total_amount"];
          model.transportName = element["transport_name"];
          model.transportNumber = element["transport_number"];
          model.listingProducts = [];
          if (element["products"] != null) {
            for (var productElement in element["products"]) {
              InvoiceProductModel models = InvoiceProductModel();
              models.productID = productElement["product_id"];
              models.productName = productElement["product_name"];
              models.qty = productElement["qty"];
              models.rate = productElement["rate"].toDouble();
              models.total = productElement["total"].toDouble();
              models.unit = productElement["unit"];
              models.categoryID = productElement["category_id"];
              models.discountLock = productElement["discount_lock"];
              models.discount = productElement["discount"];

              setState(() {
                model.listingProducts!.add(models);
              });
            }
          }
          model.deliveryaddress = element["delivery_address"] ?? "";

          if (element.data().containsKey('price') && element["price"] != null) {
            var calcula = BillingCalCulationModel();
            calcula.discountValue = element["price"]["discount_value"];
            calcula.extraDiscount = element["price"]["extra_discount"];
            calcula.extraDiscountValue =
                element["price"]["extra_discount_value"];
            calcula.extraDiscountsys = element["price"]["extra_discount_sys"];
            calcula.package = element["price"]["package"];
            calcula.packageValue = element["price"]["package_value"];
            calcula.packagesys = element["price"]["package_sys"];
            calcula.subTotal = element["price"]["sub_total"];
            calcula.roundOff = element["price"]["round_off"];
            calcula.total = element["price"]["total"];
            model.price = calcula;
          }
          setState(() {
            tmpinvoiceList.add(model);
          });
        }
      }
    });

    List<InvoiceModel> filteredList = tmpinvoiceList.where((enquiry) {
      if (search["search_text"].isNotEmpty) {
        if (enquiry.partyName != null &&
            enquiry.partyName != null &&
            enquiry.partyName!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.phoneNumber != null &&
            enquiry.phoneNumber != null &&
            enquiry.phoneNumber!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.city != null &&
            enquiry.city != null &&
            enquiry.city!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.state != null &&
            enquiry.state!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.billNo != null &&
            enquiry.billNo!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.billNo != null &&
            enquiry.billNo!.toLowerCase().replaceAll(' ', '').contains(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else {
          return false;
        }
      } else if (search["from_date"] != null && search["to_date"] != null) {
        if (enquiry.createdDate != null &&
            enquiry.createdDate!.isAfter(search["from_date"]) &&
            enquiry.createdDate!.isBefore(DateTime(
                search["to_date"].year,
                search["to_date"].month,
                search["to_date"].day,
                23,
                59,
                59,
                999))) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }).toList();
    setState(() {
      invoiceList = filteredList;
    });
  }

  getProducts({required InvoiceModel invoice}) async {
    try {
      loading(context);
      if (invoice.listingProducts!.isEmpty) {
        await FireStore()
            .getInvoiceProductListing(docID: invoice.docID!)
            .then((value) {
          if (value.docs.isNotEmpty) {
            for (var element in value.docs) {
              InvoiceProductModel model = InvoiceProductModel();
              model.productID = element["product_id"];
              model.productName = element["product_name"];
              model.qty = element["qty"];
              model.rate = element["rate"];
              model.total = element["total"];
              model.unit = element["unit"];
              model.docID = element.id;
              model.categoryID = element["category_id"];
              model.discountLock = element["discount_lock"];
              model.discount = element["discount"];
              setState(() {
                invoice.listingProducts!.add(model);
              });
            }
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => InvoiceDetails(
                  invoice: invoice,
                ),
              ),
            ).then((value) {
              if (value != null && value) {
                setState(() {
                  invoiceHandler = getInvoiceList();
                });
              }
            });
          } else {
            Navigator.pop(context);
            snackbar(context, false, "Something went Wrong");
          }
        });
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => InvoiceDetails(
              invoice: invoice,
            ),
          ),
        ).then((value) {
          if (value != null && value) {
            setState(() {
              invoiceHandler = getInvoiceList();
            });
          }
        });
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  downloadInvoiceOverallExcel() async {
    try {
      loading(context);
      await InvoiceExcel(inviceData: invoiceList)
          .createInvoiceExcel()
          .then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          Navigator.pop(context);
          await helper.saveAndLaunchFile(fileData, 'Invoice List.xlsx');
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  downloadOption() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Download Options"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("PDF"),
              onTap: () {
                Navigator.pop(context, "pdf");
              },
            ),
            ListTile(
              title: const Text("Excel"),
              onTap: () {
                Navigator.pop(context, "excel");
              },
            ),
          ],
        ),
      ),
    ).then((value) {
      if (value != null) {
        if (value == "pdf") {
        } else if (value == "excel") {
          downloadInvoiceOverallExcel();
        }
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);

        getInvoiceTotal();
        invoiceHandler = getInvoiceList();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);
          getInvoiceTotal();
          invoiceHandler = getInvoiceList();
        }
      });
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadBills();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadBills() async {
    setState(() {
      isLoad = true;
      start += 10;
      end += 10;
      endOfDocument = false;
    });
    return await FireStore().getInvoice(start: start, end: end).then((value) {
      if (value.isNotEmpty) {
        for (var element in value) {
          InvoiceModel model = InvoiceModel();
          model.docID = element.id;
          model.partyName = element["party_name"];
          model.address = element["address"];
          model.billDate = (element["bill_date"] as Timestamp).toDate();
          model.billNo = element["bill_no"];
          model.phoneNumber = element["phone_number"];
          model.totalBillAmount = element["total_amount"];
          model.transportName = element["transport_name"];
          model.transportNumber = element["transport_number"];
          model.listingProducts = [];
          if (element["products"] != null) {
            for (var productElement in element["products"]) {
              InvoiceProductModel models = InvoiceProductModel();
              models.productID = productElement["product_id"];
              models.productName = productElement["product_name"];
              models.qty = productElement["qty"];
              models.rate = productElement["rate"].toDouble();
              models.total = productElement["total"].toDouble();
              models.unit = productElement["unit"];
              models.categoryID = productElement["category_id"];
              models.discountLock = productElement["discount_lock"];
              models.discount = productElement["discount"];

              setState(() {
                model.listingProducts!.add(models);
              });
            }
          }
          model.deliveryaddress = element["delivery_address"] ?? "";

          if (element.data().containsKey('price') && element["price"] != null) {
            var calcula = BillingCalCulationModel();
            calcula.discountValue = element["price"]["discount_value"];
            calcula.extraDiscount = element["price"]["extra_discount"];
            calcula.extraDiscountValue =
                element["price"]["extra_discount_value"];
            calcula.extraDiscountsys = element["price"]["extra_discount_sys"];
            calcula.package = element["price"]["package"];
            calcula.packageValue = element["price"]["package_value"];
            calcula.packagesys = element["price"]["package_sys"];
            calcula.subTotal = element["price"]["sub_total"];
            calcula.roundOff = element["price"]["round_off"];
            calcula.total = element["price"]["total"];
            model.price = calcula;
          }
          setState(() {
            invoiceList.add(model);
          });
        }
        tmpinvoiceList.addAll(invoiceList);
      } else {
        setState(() {
          isLoad = false;
          endOfDocument = true;
        });
      }
      return invoiceList;
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            return connectionProvider.isConnected
                ? RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    onRefresh: () async {
                      setState(() {
                        invoiceHandler = getInvoiceList();
                      });
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
                        const SizedBox(
                          height: 5,
                        ),
                        FutureBuilder(
                            future: invoiceHandler,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return futureLoading(context);
                              } else if (snapshot.hasError) {
                                return errorDisplay(snapshot);
                              } else {
                                return invoiceList.isNotEmpty
                                    ? ListView.builder(
                                        primary: false,
                                        shrinkWrap: true,
                                        itemCount: invoiceList.length,
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        itemBuilder: (context, index) {
                                          if (invoiceList[index].billNo ==
                                              null) {
                                            return const SizedBox();
                                          } else {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) =>
                                                        InvoiceDetails(
                                                      invoice:
                                                          invoiceList[index],
                                                    ),
                                                  ),
                                                ).then((value) {
                                                  if (value != null && value) {
                                                    setState(() {
                                                      invoiceHandler =
                                                          getInvoiceList();
                                                    });
                                                  }
                                                });
                                              },
                                              onLongPress: () {
                                                billOptions(
                                                    invoiceList[index].billNo ??
                                                        '',
                                                    index);
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                padding:
                                                    const EdgeInsets.all(10),
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
                                                        Text(
                                                          invoiceList[index]
                                                                  .billNo ??
                                                              "",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(invoiceList[
                                                                      index]
                                                                  .billDate!),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                invoiceList[index]
                                                                        .partyName ??
                                                                    "",
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
                                                              Row(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                          Iconsax
                                                                              .location,
                                                                          size:
                                                                              10),
                                                                      Text(
                                                                        invoiceList[index].city ??
                                                                            "",
                                                                        style: Theme.of(context)
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
                                                                          size:
                                                                              10),
                                                                      Text(
                                                                        invoiceList[index].phoneNumber ??
                                                                            "",
                                                                        style: Theme.of(context)
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
                                                                    DateFormat('dd-MM-yyyy hh:mm a').format(invoiceList[index]
                                                                            .createdDate ??
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
                                                        const SizedBox(
                                                            width: 10),
                                                        Text(
                                                          "\u{20B9}${double.parse(invoiceList[index].totalBillAmount ?? "0").roundToDouble().toStringAsFixed(2)}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleLarge!
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                              Icon(Icons.stop_rounded,
                                  color: Colors.red.shade300),
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
                  )
                : noInternet(context);
          },
        ),
      ),
      floatingActionButton: floatingButtons(context),
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
            "No Bill of Supply",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              "You have not create any bill of supply, so first you have create it",
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
          //               CupertinoPageRoute(builder: (context) {
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

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Bill of Supply"),
      actions: [
        IconButton(
          splashRadius: 20,
          tooltip: "Create New Bill of Supply",
          onPressed: () async {
            Navigator.pop(context);
            await LocalDB.getBillingIndex().then((value) async {
              if (value != null) {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) {
                    if (value == 1) {
                      return const BillingOneInv();
                    } else {
                      return const BillingTwoInv();
                    }
                  }),
                );
              }
            });
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          splashRadius: 20,
          tooltip: "Download Excel File",
          onPressed: () {
            downloadInvoiceOverallExcel();
            // downloadOption();
            // downloadExcelData();
          },
          icon: const Icon(Icons.file_download_outlined),
        ),
        IconButton(
            onPressed: () {
              setState(() {
                invoiceHandler = getInvoiceList();
              });
            },
            icon: const Icon(Icons.refresh_rounded)),
      ],
    );
  }

  FloatingActionButton floatingButtons(BuildContext context) {
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

  Padding noDataError(BuildContext context) {
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
            "No Bill of Supply",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              "You have not create any invoice, so first you have create invoice",
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
        ],
      ),
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
                    invoiceHandler = getInvoiceList();
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

  openDialog(InvoiceModel invoiceModel) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Print Options"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Cancel"),
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context, "Original");
              },
              title: const Text("Original"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context, "Duplicate");
              },
              title: const Text("Duplicate"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context, "Triplicate");
              },
              title: const Text("Triplicate"),
            ),
          ],
        ),
      ),
    ).then((result) {
      if (result != null) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => InvoicePdfView(
              title: result,
              invoice: invoiceModel,
            ),
          ),
        );
      }
    });
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
          heightFactor: 0.2,
          child: BillOptions(
            title: title,
            billType: BillType.invoice,
            invoice: invoiceList[index],
          ),
        );
      },
    );
  }
}
