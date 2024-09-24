import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sri_kot/gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/provider/src/invoice_excel_creation.dart';
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
  final _scrollController = ScrollController();

  TextEditingController search = TextEditingController();

  List<InvoiceModel> invoiceList = [];
  List<InvoiceModel> fullInvoiceList = [];
  List<InvoiceModel> tmpinvoiceList = [];

  int countItems = 10;
  int currentPage = 1;
  int? overallTotal;

  Future getInvoiceList() async {
    try {
      overallTotal = 0;

      setState(() {
        countItems = 10;
        currentPage = 1;
        invoiceList.clear();
        fullInvoiceList.clear();
        tmpinvoiceList.clear();
      });
      return await FireStore().getInvoiceListing().then((value) {
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            InvoiceModel model = InvoiceModel();
            model.docID = element.id;
            model.partyName = element["party_name"];
            model.address = element["address"];
            model.biilDate = (element["bill_date"] as Timestamp).toDate();
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

            if (element.data().containsKey('price') &&
                element["price"] != null) {
              var calcula = BillingCalCulationModel();
              calcula.discount = element["price"]["discount"];
              calcula.discountValue = element["price"]["discount_value"];
              calcula.discountsys = element["price"]["discount_sys"];
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
              if (calcula.total != null) {
                overallTotal = (overallTotal ?? 0) + calcula.total!.toInt();
              }
              model.price = calcula;
            }
            setState(() {
              fullInvoiceList.add(model);
            });
          }
          tmpinvoiceList.addAll(fullInvoiceList);
        }
        for (var i = 0; i < 10; i++) {
          if (fullInvoiceList.length > i) {
            invoiceList.add(fullInvoiceList[i]);
          }
        }
        return invoiceList;
      });
    } catch (e) {
      snackbar(context, false, e.toString());
      throw e.toString();
    }
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
              MaterialPageRoute(
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
          MaterialPageRoute(
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

  searchInvoice() {
    if (search.text.isNotEmpty) {
      setState(() {
        invoiceList.clear();
      });
      Iterable<InvoiceModel> tmpList = tmpinvoiceList.where((element) {
        if (element.partyName != null &&
            element.partyName!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(search.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.phoneNumber != null &&
            element.phoneNumber!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(search.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.phoneNumber != null &&
            element.phoneNumber!
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(search.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.billNo != null &&
            element.billNo!
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(search.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else {
          return false;
        }
      });
      if (tmpList.isNotEmpty) {
        for (var element in tmpList) {
          setState(() {
            invoiceList.add(element);
          });
        }
      }
    } else {
      setState(() {
        invoiceList.clear();
        invoiceList.addAll(tmpinvoiceList);
      });
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

  showFilterSheet() async {
    var result = await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const InvoiceFilter();
      },
    );
    if (result != null) {
      filtersInvoiceFun(
        result["FromDate"],
        result["ToDate"],
      );
    }
  }

  filtersInvoiceFun(DateTime? fromDate, DateTime? toDate) async {
    try {
      setState(() {
        invoiceList.clear();
        countItems = 10;
        currentPage = 1;
        fullInvoiceList.clear();
        tmpinvoiceList.clear();
      });
      loading(context);
      await FireStore()
          .filterInvoice(fromDate: fromDate!, toDate: toDate!)
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            InvoiceModel model = InvoiceModel();
            model.docID = element.id;
            model.partyName = element["party_name"];
            model.address = element["address"];
            model.biilDate = (element["bill_date"] as Timestamp).toDate();
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

            if (element.data().containsKey('price') &&
                element["price"] != null) {
              var calcula = BillingCalCulationModel();
              calcula.discount = element["price"]["discount"];
              calcula.discountValue = element["price"]["discount_value"];
              calcula.discountsys = element["price"]["discount_sys"];
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
              fullInvoiceList.add(model);
            });
          }
          tmpinvoiceList.addAll(fullInvoiceList);
          for (var i = 0; i < 10; i++) {
            if (fullInvoiceList.length > i) {
              invoiceList.add(fullInvoiceList[i]);
            }
          }
          setState(() {});
        }
        Navigator.pop(context);
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  void _loadMore() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        for (var i = (countItems * currentPage);
            i < ((countItems * currentPage) + countItems);
            i++) {
          if (fullInvoiceList.length > i) {
            invoiceList.add(fullInvoiceList[i]);
          }
        }
        currentPage += 1;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);

        invoiceHandler = getInvoiceList();
        _scrollController.addListener(_loadMore);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);

          invoiceHandler = getInvoiceList();
          _scrollController.addListener(_loadMore);
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Bill of Supply"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  invoiceHandler = getInvoiceList();
                });
              },
              icon: const Icon(Icons.refresh_rounded)),
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
            splashRadius: 20,
            tooltip: "Create New Bill of Supply",
            onPressed: () {
              // downloadExcelData();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoiceCreation(),
                ),
              ).then((value) {
                if (value != null && value) {
                  setState(() {
                    invoiceHandler = getInvoiceList();
                  });
                }
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<ConnectionProvider>(
        builder: (context, connectionProvider, child) {
          return connectionProvider.isConnected ? body() : noInternet(context);
        },
      ),
      floatingActionButton: floatingButtons(context),
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

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: invoiceHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureLoading(context);
        } else if (snapshot.hasError) {
          return errorDisplay(snapshot);
        } else {
          return invoiceList.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      invoiceHandler = getInvoiceList();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
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
                                      "(${invoiceList.length} Bills)",
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
                          height: 10,
                        ),
                        SizedBox(
                          child: TextFormField(
                            controller: search,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: "Search...",
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.search),
                            ),
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus!.unfocus();
                            },
                            onEditingComplete: () {
                              FocusManager.instance.primaryFocus!.unfocus();
                            },
                            onChanged: (v) {
                              searchInvoice();
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: invoiceList.length,
                            itemBuilder: (context, index) {
                              if (invoiceList[index].billNo == null) {
                                return const SizedBox();
                              } else {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InvoiceDetails(
                                          invoice: invoiceList[index],
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value != null && value) {
                                        setState(() {
                                          invoiceHandler = getInvoiceList();
                                        });
                                      }
                                    });
                                  },
                                  onLongPress: () {
                                    showDialog(
                                        context: context,
                                        builder: (builder) {
                                          return BillListOptions(
                                            title:
                                                invoiceList[index].billNo ?? '',
                                          );
                                        }).then((value) {
                                      if (value != null) {
                                        if (value == "1") {
                                          openDialog(invoiceList[index]);
                                        } else if (value == "2") {
                                          openDialog(invoiceList[index]);
                                        } else if (value == "3") {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  InvoiceDetails(
                                                invoice: invoiceList[index],
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
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              invoiceList[index].billNo ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              DateFormat('dd-MM-yyyy').format(
                                                  invoiceList[index].biilDate!),
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    invoiceList[index]
                                                            .partyName ??
                                                        "",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    invoiceList[index]
                                                            .address ??
                                                        "",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                  Text(
                                                    invoiceList[index]
                                                            .phoneNumber ??
                                                        "",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "\u{20B9}${invoiceList[index].totalBillAmount ?? ""}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
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
                        style:
                            Theme.of(context).textTheme.titleLarge!.copyWith(),
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
          MaterialPageRoute(
            builder: (context) => InvoicePdfView(
              title: result,
              invoice: invoiceModel,
            ),
          ),
        );
      }
    });
  }
}
