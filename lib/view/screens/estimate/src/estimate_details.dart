import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import '/constants/constants.dart';
import '/provider/src/file_open.dart' as helper;

class EstimateDetails extends StatefulWidget {
  final String cid;
  const EstimateDetails({super.key, required this.cid});

  @override
  State<EstimateDetails> createState() => _EstimateDetailsState();
}

class _EstimateDetailsState extends State<EstimateDetails> {
  var estimateData = EstimateDataModel();

  Future getEnquiryData() async {
    try {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
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
        await FireStore().getEstimateInfo(cid: widget.cid).then((value) async {
          if (value != null) {
            if (value.exists) {
              var calcula = BillingCalCulationModel();
              calcula.discountValue = value["price"]["discount_value"];
              calcula.extraDiscount = value["price"]["extra_discount"];
              calcula.roundOff = value["price"]["round_off"];
              calcula.extraDiscountValue =
                  value["price"]["extra_discount_value"];
              calcula.extraDiscountsys = value["price"]["extra_discount_sys"];
              calcula.package = value["price"]["package"];
              calcula.packageValue = value["price"]["package_value"];
              calcula.packagesys = value["price"]["package_sys"];
              calcula.subTotal = value["price"]["sub_total"];
              calcula.total = value["price"]["total"];

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
                    var productDataModel = ProductDataModel();
                    productDataModel.categoryid = product["category_id"];
                    productDataModel.categoryName = product["category_name"];
                    productDataModel.price = product["price"];
                    productDataModel.productId = product["product_id"];
                    productDataModel.productName = product["product_name"];
                    productDataModel.qty = product["qty"];
                    productDataModel.productCode =
                        product["product_code"] ?? "";
                    productDataModel.productType =
                        product["discount_lock"] || product["discount"] == null
                            ? ProductType.netRated
                            : ProductType.discounted;
                    productDataModel.discountLock = product["discount_lock"];
                    productDataModel.hsnCode = product["hsn_code"];
                    productDataModel.taxValue = product["tax_value"];
                    if (productDataModel.categoryid != null &&
                        productDataModel.categoryid!.isNotEmpty) {
                      var getCategoryid = categoryList.indexWhere((elements) =>
                          elements.tmpcatid == productDataModel.categoryid);
                      productDataModel.discount =
                          categoryList[getCategoryid].discount;
                    }
                    productDataModel.docid = product.id;
                    productDataModel.name = product["name"];
                    productDataModel.productContent =
                        product["product_content"];
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
                estimateData = EstimateDataModel(
                  docID: value.id,
                  createddate: DateTime.parse(
                    value["created_date"].toDate().toString(),
                  ),
                  enquiryid: null,
                  estimateid: value["estimate_id"],
                  price: calcula,
                  customer: customer,
                  products: tmpProducts,
                );
              });
            }
          }
        });
      } else {
        var localCategories = await DatabaseHelper().getCategory();

        if (localCategories.isNotEmpty) {
          for (var i = 0; i < localCategories.length; i++) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName =
                localCategories[i]["category_name"]?.toString() ?? "";
            model.postion = int.parse(localCategories[i]["postion"]);
            model.tmpcatid = localCategories[i]["category_id"];
            model.discount = localCategories[i]["discount"] != null
                ? int.tryParse(localCategories[i]["discount"]!.toString())
                : null;
            setState(() {
              categoryList.add(model);
            });
          }

          var localEnquiry =
              await DatabaseHelper().getEstimateWithId(widget.cid);
          var calcula = BillingCalCulationModel();
          var price = jsonDecode(localEnquiry['price']) as Map<String, dynamic>;
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
          if (localEnquiry["customer"] != null) {
            var customerData =
                jsonDecode(localEnquiry['customer']) as Map<String, dynamic>;
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

          if (localEnquiry["products"] != null) {
            var productData =
                jsonDecode(localEnquiry['products']) as List<dynamic>;
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
              if (productDataModel.categoryid != null &&
                  productDataModel.categoryid!.isNotEmpty) {
                var getCategoryid = categoryList.indexWhere((elements) =>
                    elements.tmpcatid == productDataModel.categoryid);
                productDataModel.discount =
                    categoryList[getCategoryid].discount;
              }
              setState(() {
                tmpProducts.add(productDataModel);
              });
            }
          }

          estimateData = EstimateDataModel(
            docID: null,
            createddate: DateTime.parse(
              localEnquiry['created_date'],
            ),
            enquiryid: null,
            estimateid: null,
            price: calcula,
            customer: customer,
            products: tmpProducts,
            dataType: DataTypes.local,
            referenceId: localEnquiry["reference_id"],
          );
        }
      }
    } on Exception catch (e) {
      snackbar(context, false, e.toString());
    }
  }

  var companyData = ProfileModel();
  TableRow tableRow(String? title, String? value, bool bold, Function()? func) {
    return TableRow(
      children: [
        GestureDetector(
          onTap: func,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Text(
              title ?? "",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            value ?? "",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? Colors.black : Colors.grey),
          ),
        ),
      ],
    );
  }

  String getItems() {
    String count = "0";
    int tmpcount = 0;
    for (var element in estimateData.products!) {
      tmpcount += element.qty!;
    }
    count = tmpcount.toString();
    return count;
  }

  String itemCount() {
    String result = "0";
    int count = 0;
    for (var element in estimateData.products!) {
      count += element.qty!;
    }
    result = count.toString();
    return result;
  }

  printEstimate() async {
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
          heightFactor: 0.3,
          child: PdfPreviewModal(),
        );
      },
    ).then((value) async {
      if (value == 1) {
        loading(context);
        final connectionProvider =
            Provider.of<ConnectionProvider>(context, listen: false);

        try {
          if (connectionProvider.isConnected) {
            await LocalDB.fetchInfo(type: LocalData.companyid)
                .then((cid) async {
              if (cid != null) {
                await FireStore()
                    .getCompanyDocInfo(cid: cid)
                    .then((companyInfo) {
                  if (companyInfo != null) {
                    setState(() {
                      companyData.companyName = companyInfo["company_name"];
                      companyData.address = companyInfo["address"];
                    });

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PrintViewA4(
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
            var companyName =
                await LocalDB.fetchInfo(type: LocalData.companyName);
            var address =
                await LocalDB.fetchInfo(type: LocalData.companyAddress);
            setState(() {
              companyData.companyName = companyName;
              companyData.address = address;
            });

            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => PrintViewA4(
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
      } else if (value == 2) {
        loading(context);
        final connectionProvider =
            Provider.of<ConnectionProvider>(context, listen: false);

        try {
          if (connectionProvider.isConnected) {
            await LocalDB.fetchInfo(type: LocalData.companyid)
                .then((cid) async {
              if (cid != null) {
                await FireStore()
                    .getCompanyDocInfo(cid: cid)
                    .then((companyInfo) {
                  if (companyInfo != null) {
                    setState(() {
                      companyData.companyName = companyInfo["company_name"];
                      companyData.address = companyInfo["address"];
                    });

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PrintViewA5(
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
            var companyName =
                await LocalDB.fetchInfo(type: LocalData.companyName);
            var address =
                await LocalDB.fetchInfo(type: LocalData.companyAddress);
            setState(() {
              companyData.companyName = companyName;
              companyData.address = address;
            });

            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => PrintViewA5(
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
      } else if (value == 3) {
        loading(context);
        final connectionProvider =
            Provider.of<ConnectionProvider>(context, listen: false);

        try {
          if (connectionProvider.isConnected) {
            await LocalDB.fetchInfo(type: LocalData.companyid)
                .then((cid) async {
              if (cid != null) {
                await FireStore()
                    .getCompanyDocInfo(cid: cid)
                    .then((companyInfo) {
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
                        builder: (context) => PrintView3inch(
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
            var companyName =
                await LocalDB.fetchInfo(type: LocalData.companyName);
            var address =
                await LocalDB.fetchInfo(type: LocalData.companyAddress);
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
                builder: (context) => PrintView3inch(
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
    });
  }

  downloadPrintEnquiry() async {
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
                    type: PdfType.estimate,
                    companyInfo: companyData,
                    pdfAlignment: pdfAlignment);
                Navigator.pop(context);
                var dataResult = await pdf.format1A4();
                var data = Uint8List.fromList(dataResult);
                await helper.saveAndLaunchFile(data,
                    'Estimate ${estimateData.estimateid ?? estimateData.referenceId}.pdf');
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
          pdfAlignment: pdfAlignment,
          estimateData: estimateData,
          type: PdfType.estimate,
          companyInfo: companyData,
        );
        Navigator.pop(context);

        var dataResult = await pdf.format1A4();
        var data = Uint8List.fromList(dataResult);
        await helper.saveAndLaunchFile(data,
            'Estimate ${estimateData.estimateid ?? estimateData.referenceId}.pdf');
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  deleteEnquiry() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await FireStore()
            .deleteEstimate(docID: estimateData.docID!)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Deleted");
        });
      } else {
        await LocalService.deleteEstimate(
                referenceId: estimateData.referenceId ?? '')
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

  duplicateEstimate() async {
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

  List<CategoryDataModel> categoryList = [];
  bool isloading = false;

  checkProductsList() async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    if (connectionProvider.isConnected) {
      if (estimateData.products!.isEmpty) {
        setState(() {
          isloading = true;
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
        await FireStore()
            .getEstimateProducts(docid: estimateData.docID!)
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
              var getCategoryid = categoryList.indexWhere(
                  (elements) => elements.tmpcatid == product["category_id"]);
              productDataModel.discount = categoryList[getCategoryid].discount;
              productDataModel.docid = product.id;
              productDataModel.name = product["name"];
              productDataModel.productContent = product["product_content"];
              productDataModel.productImg = product["product_img"];
              productDataModel.qrCode = product["qr_code"];
              productDataModel.videoUrl = product["video_url"];
              setState(() {
                estimateData.products!.add(productDataModel);
              });
            }
            setState(() {
              isloading = false;
            });
          }
        });
      }
    }
  }

  getinfo() async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    if (connectionProvider.isConnected) {
      FireStore fireStore = FireStore();
      var result = await fireStore.getInvoiceAvailable(
          uid: await LocalDB.fetchInfo(type: LocalData.companyid) ?? '');
      setState(() {
        invoiceEntry = result ?? false;
      });
    }
  }

  bool invoiceEntry = false;

  @override
  void initState() {
    getinfo();
    // checkProductsList();
    enquiryDetailsHandler = getEnquiryData();
    super.initState();
  }

  Future? enquiryDetailsHandler;

  sharePDF() async {
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
                    type: PdfType.estimate,
                    companyInfo: companyData,
                    pdfAlignment: pdfAlignment);
                await pdf.format1A4().then((dataResult) async {
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
          pdfAlignment: pdfAlignment,
          estimateData: estimateData,
          type: PdfType.estimate,
          companyInfo: companyData,
        );
        await pdf.format1A4().then((dataResult) async {
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

  @override
  Widget build(BuildContext context) {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          titleSpacing: 0,
          title:
              Text(estimateData.estimateid ?? estimateData.referenceId ?? ''),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          onPressed: () async {
            await LocalDB.getBillingIndex().then((value) async {
              if (value != null) {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) {
                    if (value == 1) {
                      return BillingOneEdit(
                        isEdit: true,
                        estimateData: estimateData,
                      );
                    } else {
                      return BillingTwo(
                        isEdit: true,
                        estimateData: estimateData,
                      );
                    }
                  }),
                );

                if (result != null) {
                  if (result) {
                    setState(() {
                      enquiryDetailsHandler = getEnquiryData();
                    });
                  }
                }
              }
            });
          },
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Edit"),
            ],
          ),
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx > 0) {
              Navigator.of(context).pop();
            }
          },
          child: FutureBuilder(
              future: enquiryDetailsHandler,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return RefreshIndicator(
                      color: Theme.of(context).primaryColor,
                      onRefresh: () async {
                        setState(() {
                          enquiryDetailsHandler = getEnquiryData();
                        });
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Options",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: sharePDF,
                                      icon: const Icon(Icons.share),
                                    ),
                                    IconButton(
                                      tooltip: "Print Estimate",
                                      splashRadius: 29,
                                      onPressed: () {
                                        printEstimate();
                                      },
                                      icon: const Icon(
                                        Icons.print,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: "Copy Estimate",
                                      splashRadius: 29,
                                      onPressed: () async {
                                        await confirmationDialog(
                                          context,
                                          title: "Alert",
                                          message:
                                              "Do you want Duplicate Estimate?",
                                        ).then((value) {
                                          if (value != null && value == true) {
                                            duplicateEstimate();
                                          }
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.copy,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: "Download PDF",
                                      splashRadius: 29,
                                      onPressed: () async {
                                        await confirmationDialog(
                                          context,
                                          title: "Alert",
                                          message:
                                              "Do you want Download Estimate?",
                                        ).then((value) {
                                          if (value != null && value == true) {
                                            downloadPrintEnquiry();
                                          }
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.file_download_outlined,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: "Delete Estimate",
                                      splashRadius: 29,
                                      onPressed: () async {
                                        await confirmationDialog(
                                          context,
                                          title: "Alert",
                                          message:
                                              "Do you want delete estimate?",
                                        ).then((value) {
                                          if (value != null && value == true) {
                                            deleteEnquiry();
                                          }
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Estimate Details",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Table(
                                  children: [
                                    tableRow(
                                        "Estimate No",
                                        estimateData.estimateid ??
                                            estimateData.referenceId,
                                        true,
                                        () {}),
                                    tableRow(
                                        "Estimate Date",
                                        DateFormat('dd-MM-yyyy HH:mm a')
                                            .format(estimateData.createddate!),
                                        false,
                                        () {}),
                                  ],
                                ),
                                if (connectionProvider.isConnected)
                                  Visibility(
                                    visible: invoiceEntry,
                                    child: Center(
                                      child: TextButton(
                                        onPressed: () async {
                                          await confirmationDialog(
                                            context,
                                            title: "Alert",
                                            message:
                                                "Do you want Convert the Bill of Supply?",
                                          ).then((value) {
                                            if (value != null &&
                                                value == true) {
                                              InvoiceModel model =
                                                  InvoiceModel();
                                              model.state =
                                                  estimateData.customer?.state!;
                                              model.city =
                                                  estimateData.customer?.city!;
                                              model.gstType = null;
                                              model.isEstimateConverted = true;
                                              model.address = estimateData
                                                      .customer?.address ??
                                                  "";
                                              model.deliveryaddress =
                                                  estimateData
                                                          .customer?.address ??
                                                      "";
                                              model.partyName = estimateData
                                                      .customer?.customerName ??
                                                  "";
                                              model.phoneNumber = estimateData
                                                      .customer?.mobileNo ??
                                                  "";
                                              model.totalBillAmount =
                                                  estimateData.price?.total
                                                          ?.toStringAsFixed(
                                                              2) ??
                                                      "";

                                              model.price = estimateData.price;
                                              model.listingProducts = [];
                                              for (var element
                                                  in estimateData.products!) {
                                                InvoiceProductModel
                                                    productElement =
                                                    InvoiceProductModel();
                                                productElement.productID =
                                                    element.productId;
                                                productElement.productName =
                                                    element.productName;
                                                productElement.qty =
                                                    element.qty;
                                                productElement.rate =
                                                    element.price;
                                                productElement.hsnCode =
                                                    element.hsnCode;
                                                productElement.taxValue =
                                                    element.taxValue;
                                                productElement.productType =
                                                    element.productType;
                                                productElement.total =
                                                    element.qty!.toDouble() *
                                                        element.price!;
                                                productElement.unit =
                                                    element.productContent;
                                                productElement.discountLock =
                                                    element.discountLock;
                                                productElement.discount =
                                                    element.discount;

                                                productElement.categoryID =
                                                    element.categoryid;
                                                model.listingProducts!
                                                    .add(productElement);
                                              }
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      InvoiceCreation(
                                                    fromEstimate: true,
                                                    estimateNo:
                                                        estimateData.estimateid,
                                                    invoice: model,
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                        },
                                        child: const Text(
                                            "Convert to Bill of Supply"),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Price",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Table(
                                  children: [
                                    tableRow(
                                        "Sub Total",
                                        "Rs.${estimateData.price!.subTotal}",
                                        false,
                                        () {}),
                                    tableRow(
                                        "Discount",
                                        "Rs.${estimateData.price!.discountValue}",
                                        false, () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DiscountDetailProduct(
                                              productData:
                                                  estimateData.products!);
                                        },
                                      );
                                    }),
                                    tableRow(
                                        "Extra Discount (${estimateData.price!.extraDiscountsys == "%" ? '${estimateData.price!.extraDiscount != null ? (estimateData.price!.extraDiscount)!.round() : ""}%' : 'Rs ${estimateData.price!.extraDiscount != null ? (estimateData.price!.extraDiscount)!.round() : ""}'})",
                                        "Rs.${estimateData.price!.extraDiscountValue}",
                                        false,
                                        () {}),
                                    tableRow(
                                        "Package Charge (${estimateData.price!.packagesys == "%" ? '${estimateData.price!.package != null ? (estimateData.price!.package)!.round() : ""}%' : 'Rs ${estimateData.price!.package != null ? (estimateData.price!.package)!.round() : ""}'})",
                                        "Rs.${estimateData.price!.packageValue}",
                                        false,
                                        () {}),
                                    tableRow(
                                        "Round Off",
                                        "Rs.${estimateData.price!.roundOff}",
                                        false,
                                        () {}),
                                    tableRow(
                                        "Total",
                                        "Rs.${estimateData.price!.total}",
                                        true,
                                        () {}),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          estimateData.customer != null
                              ? Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Customer",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Table(
                                        children: [
                                          tableRow(
                                              "Customer Name",
                                              estimateData
                                                  .customer!.customerName,
                                              true,
                                              () {}),
                                          tableRow(
                                              "City",
                                              estimateData.customer!.city,
                                              false,
                                              () {}),
                                          tableRow(
                                              "Address",
                                              estimateData.customer!.address,
                                              false,
                                              () {}),
                                          tableRow(
                                              "Email",
                                              estimateData.customer!.email,
                                              false,
                                              () {}),
                                          tableRow(
                                              "Mobile No",
                                              estimateData.customer!.mobileNo,
                                              false,
                                              () {}),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          estimateData.customer != null
                              ? const SizedBox(
                                  height: 10,
                                )
                              : const SizedBox(),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Products(${estimateData.products!.length})",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      "Items(${itemCount()})",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(1.5),
                                    1: FlexColumnWidth(7),
                                    2: FlexColumnWidth(1.5),
                                    3: FlexColumnWidth(4),
                                    4: FlexColumnWidth(4),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2, vertical: 5),
                                            child: Text(
                                              "#",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 5),
                                          child: Text(
                                            "Name",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 5),
                                          child: Text(
                                            "Qty",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 5),
                                          child: Text(
                                            "Rate",
                                            textAlign: TextAlign.right,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 5),
                                          child: Text(
                                            "Total",
                                            textAlign: TextAlign.right,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    for (int index = 0;
                                        index < estimateData.products!.length;
                                        index++)
                                      TableRow(
                                        decoration: BoxDecoration(
                                          border: estimateData
                                                      .products!.length !=
                                                  (index + 1)
                                              ? Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Text(
                                                (index + 1).toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Text(estimateData
                                                    .products![index]
                                                    .productName ??
                                                ""),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Text(
                                              estimateData.products![index].qty
                                                  .toString(),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Text(
                                              double.parse(estimateData
                                                      .products![index].price
                                                      .toString())
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: Text(
                                              double.parse((estimateData
                                                              .products![index]
                                                              .qty! *
                                                          estimateData
                                                              .products![index]
                                                              .price!)
                                                      .toString())
                                                  .toStringAsFixed(2),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ));
                }
              }),
        ));
  }
}
