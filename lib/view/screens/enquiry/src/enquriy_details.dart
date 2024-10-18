import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../billing/src/utils/add_customer_box.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import '/constants/constants.dart';
import '/provider/src/file_open.dart' as helper;

class EnquiryDetails extends StatefulWidget {
  final String cid;
  const EnquiryDetails({super.key, required this.cid});

  @override
  State<EnquiryDetails> createState() => _EnquiryDetailsState();
}

class _EnquiryDetailsState extends State<EnquiryDetails> {
  var enquiryData = EstimateDataModel();
  List<CategoryDataModel> categoryList = [];

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
        }).then((value) async {
          await FireStore().getEnquiryInfo(cid: widget.cid).then((value) async {
            if (value != null) {
              if (value.exists) {
                var calc = BillingCalCulationModel();
                calc.discountValue = value["price"]["discount_value"];
                calc.extraDiscount = value["price"]["extra_discount"];
                calc.roundOff = value["price"]["round_off"];
                calc.extraDiscountValue =
                    value["price"]["extra_discount_value"];
                calc.extraDiscountsys = value["price"]["extra_discount_sys"];
                calc.package = value["price"]["package"];
                calc.packageValue = value["price"]["package_value"];
                calc.packagesys = value["price"]["package_sys"];
                calc.subTotal = value["price"]["sub_total"];
                calc.total = value["price"]["total"];
                calc.netratedTotal = value["price"]["netrated_total"];
                calc.discountedTotal = value["price"]["discounted_total"];
                calc.netPlusDisTotal = value["price"]["net_plus_dis_total"];
                calc.discounts = value["price"]["discounts"];

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
                    .getEnquiryProducts(docid: value.id)
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
                      productDataModel.productCode =
                          product["product_code"] ?? "";
                      productDataModel.discountLock = product["discount_lock"];
                      productDataModel.docid = product.id;
                      productDataModel.name = product["name"];

                      productDataModel.productType = product["discount_lock"] ||
                              (p.containsKey('discount')
                                  ? product["discount"] != null
                                  : false)
                          ? ProductType.netRated
                          : ProductType.discounted;
                      productDataModel.hsnCode = (p.containsKey('hsn_code')
                          ? product["hsn_code"]
                          : null);
                      productDataModel.taxValue = (p.containsKey('tax_value')
                          ? product["hsn_code"]
                          : null);
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
                  enquiryData = EstimateDataModel(
                    docID: value.id,
                    createddate: DateTime.parse(
                      value["created_date"].toDate().toString(),
                    ),
                    enquiryid: value['enquiry_id'],
                    estimateid: value["estimate_id"],
                    price: calc,
                    customer: customer,
                    products: tmpProducts,
                  );
                });
              }
            }
          });
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
              await DatabaseHelper().getEnquiryWithId(widget.cid);
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
              if (productDataModel.categoryid != null) {
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

          enquiryData = EstimateDataModel(
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
    for (var element in enquiryData.products!) {
      tmpcount += element.qty!;
    }
    count = tmpcount.toString();
    return count;
  }

  printEnquiry() async {
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
                      companyData.contact = companyInfo["contact"];
                    });

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PrintEnquiryA4(
                          estimateData: enquiryData,
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
                builder: (context) => PrintEnquiryA4(
                  estimateData: enquiryData,
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
                      companyData.contact = companyInfo["contact"];
                    });

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PrintEnquiryA5(
                          estimateData: enquiryData,
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
                builder: (context) => PrintEnquiryA5(
                  estimateData: enquiryData,
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
                        builder: (context) => PrintEnquiry3inch(
                          estimateData: enquiryData,
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
                builder: (context) => PrintEnquiry3inch(
                  estimateData: enquiryData,
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
                    estimateData: enquiryData,
                    type: PdfType.enquiry,
                    companyInfo: companyData,
                    pdfAlignment: pdfAlignment);
                var dataResult = await pdf.format1A4();
                // var dataResult = await pdf.create3InchPDF();
                var data = Uint8List.fromList(dataResult);
                Navigator.pop(context);
                await helper.saveAndLaunchFile(
                    data, 'Enquiry ${enquiryData.enquiryid}.pdf');
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
            estimateData: enquiryData,
            type: PdfType.enquiry,
            companyInfo: companyData,
            pdfAlignment: pdfAlignment);
        var dataResult = await pdf.format1A4();
        // var dataResult = await pdf.create3InchPDF();
        var data = Uint8List.fromList(dataResult);
        Navigator.pop(context);
        await helper.saveAndLaunchFile(
            data, 'Enquiry ${enquiryData.enquiryid}.pdf');
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
            .deleteEnquiry(docID: enquiryData.docID!)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Deleted");
        });
      } else {
        await LocalService.deleteEnquiry(
                referenceId: enquiryData.referenceId ?? '')
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

  convertEstimate() async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (enquiryData.customer != null &&
          enquiryData.customer!.mobileNo != null &&
          enquiryData.customer!.mobileNo!.isNotEmpty) {
        loading(context);

        if (connectionProvider.isConnected) {
          await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
            if (cid != null) {
              await FireStore()
                  .orderToConvertEstimate(
                cid: cid,
                docID: enquiryData.docID!,
              )
                  .then((value) async {
                // await FireStore()
                //     .deleteEnquiry(docID: enquiryData.docID!)
                //     .then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                snackbar(
                  context,
                  true,
                  "Successfully Enquiry Converted to Estimate",
                );
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const EstimateListing(),
                  ),
                );
                // });
              });
            }
          });
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
          LocalService.enquiryToEstimate(
              referenceId: enquiryData.referenceId ?? '',
              cid: await LocalDB.fetchInfo(type: LocalData.companyid));
          snackbar(
            context,
            true,
            "Successfully Enquiry Converted to Estimate",
          );
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const EstimateListing(),
            ),
          );
        }
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (builder) {
              return const CustomerChoose();
            }).then((value) async {
          if (value != null) {
            if (value == "1") {
              await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return const AddCustomerBox(
                    isInvoice: false,
                    isEdit: false,
                  );
                },
              ).then((value) async {
                if (value != null) {
                  if (connectionProvider.isConnected) {
                    await FireStore()
                        .updateEnquiryCustomer(
                            docId: widget.cid,
                            address: value.address ?? '',
                            city: value.city ?? '',
                            companyId: value.companyID ?? '',
                            customerId: value.docID ?? '',
                            customerName: value.customerName ?? '',
                            email: value.email ?? '',
                            mobileNo: value.mobileNo ?? '',
                            state: value.state ?? '')
                        .then((onValue) {
                      setState(() {
                        enquiryData.customer = CustomerDataModel(
                          customerName: value.customerName ?? '',
                          address: value.address ?? '',
                          city: value.city ?? '',
                          state: value.state ?? '',
                          email: value.email ?? '',
                          mobileNo: value.mobileNo ?? '',
                        );
                      });
                      convertEstimate();
                    });
                  } else {
                    await LocalService.updateCustomerInfo(
                            customerInfo: value,
                            referenceId: enquiryData.referenceId ?? '')
                        .then((result) {
                      setState(() {
                        enquiryData.customer = CustomerDataModel(
                          customerName: value.customerName ?? '',
                          address: value.address ?? '',
                          city: value.city ?? '',
                          state: value.state ?? '',
                          email: value.email ?? '',
                          mobileNo: value.mobileNo ?? '',
                        );
                      });
                      convertEstimate();
                    });
                  }
                }
              });
            } else if (value == "2") {
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
                    child: CustomerSearchView(),
                  );
                },
              ).then((value) async {
                if (connectionProvider.isConnected) {
                  await FireStore()
                      .updateEnquiryCustomer(
                          docId: widget.cid,
                          address: value.address,
                          city: value.city,
                          companyId: value.companyID,
                          customerId: value.docID,
                          customerName: value.customerName,
                          email: value.email,
                          mobileNo: value.mobileNo,
                          state: value.state)
                      .then((onValue) {
                    setState(() {
                      enquiryData.customer = CustomerDataModel(
                        customerName: value.customerName ?? '',
                        address: value.address ?? '',
                        city: value.city ?? '',
                        state: value.state ?? '',
                        email: value.email ?? '',
                        mobileNo: value.mobileNo ?? '',
                      );
                    });
                    convertEstimate();
                  });
                } else {
                  await LocalService.updateCustomerInfo(
                          customerInfo: value,
                          referenceId: enquiryData.referenceId ?? '')
                      .then((result) {
                    setState(() {
                      enquiryData.customer = CustomerDataModel(
                        customerName: value.customerName ?? '',
                        address: value.address ?? '',
                        city: value.city ?? '',
                        state: value.state ?? '',
                        email: value.email ?? '',
                        mobileNo: value.mobileNo ?? '',
                      );
                    });
                    convertEstimate();
                  });
                }
              });
            }
          }
        });
      }
    } catch (e) {
      // Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  duplicateEnquiry() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStore()
                .duplicateEnquiry(docID: enquiryData.docID!, cid: cid)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context, true);
              snackbar(context, true, "Successfully Enqiry Duplicated");
            });
          }
        });
      } else {
        await LocalService.duplicateEnquiry(
                referenceId: enquiryData.referenceId!)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Enqiry Duplicated");
        });
      }
    } catch (e) {
      Navigator.pop(context);
      throw e.toString();
    }
  }

  bool isloading = false;

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
                    estimateData: enquiryData,
                    type: PdfType.enquiry,
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
            estimateData: enquiryData,
            type: PdfType.enquiry,
            companyInfo: companyData,
            pdfAlignment: pdfAlignment);
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

  String itemCount() {
    String result = "0";
    int count = 0;
    for (var element in enquiryData.products!) {
      count += element.qty!;
    }
    result = count.toString();
    return result;
  }

  @override
  void initState() {
    super.initState();
    enquiryDetailsHandler = getEnquiryData();
  }

  Future? enquiryDetailsHandler;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      floatingActionButton: floatingButton(context),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: sharePDF,
                                icon: const Icon(Icons.share),
                              ),
                              IconButton(
                                tooltip: "Print Enquiry",
                                splashRadius: 29,
                                onPressed: () {
                                  printEnquiry();
                                },
                                icon: const Icon(
                                  Icons.print,
                                ),
                              ),
                              IconButton(
                                tooltip: "Copy Enquiry",
                                splashRadius: 29,
                                onPressed: () async {
                                  await confirmationDialog(
                                    context,
                                    title: "Alert",
                                    message: "Do you want Duplicate enquiry?",
                                  ).then((value) {
                                    if (value != null && value == true) {
                                      duplicateEnquiry();
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
                                    message: "Do you want Download enquiry?",
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
                                tooltip: "Delete Enquiry",
                                splashRadius: 29,
                                onPressed: () async {
                                  await confirmationDialog(
                                    context,
                                    title: "Alert",
                                    message: "Do you want delete enquiry?",
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
                    Container(
                      margin: const EdgeInsets.only(top: 10),
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
                            "Order Details",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Table(
                            children: [
                              tableRow(
                                  "Order No",
                                  enquiryData.enquiryid ??
                                      enquiryData.referenceId,
                                  true,
                                  () {}),
                              tableRow(
                                  "Order Date",
                                  DateFormat('dd-MM-yyyy hh:mm a')
                                      .format(enquiryData.createddate!),
                                  false,
                                  () {}),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          enquiryData.estimateid == null
                              ? Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      await confirmationDialog(
                                        context,
                                        title: "Alert",
                                        message:
                                            "Do you want Convert the Estimate?",
                                      ).then((value) {
                                        if (value != null && value == true) {
                                          convertEstimate();
                                        }
                                      });
                                    },
                                    child: const Text("Convert to Estimate"),
                                  ),
                                )
                              : Center(
                                  child: Column(
                                  children: [
                                    const Text(
                                      "Already converted to estimate",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await confirmationDialog(
                                          context,
                                          title: "Alert",
                                          message:
                                              "Do you want Convert the Estimate?",
                                        ).then((value) {
                                          if (value != null && value == true) {
                                            convertEstimate();
                                          }
                                        });
                                      },
                                      child: const Text(
                                          "Convert to Another Estimate"),
                                    ),
                                  ],
                                )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    enquiryData.customer != null
                        ? Container(
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
                                  "Customer",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Table(
                                  children: [
                                    tableRow(
                                        "Customer Name",
                                        enquiryData.customer!.customerName,
                                        true,
                                        () {}),
                                    tableRow(
                                        "Address",
                                        enquiryData.customer!.address,
                                        false,
                                        () {}),
                                    tableRow("City", enquiryData.customer!.city,
                                        false, () {}),
                                    tableRow(
                                        "State",
                                        enquiryData.customer!.state,
                                        false,
                                        () {}),
                                    tableRow(
                                        "Email",
                                        enquiryData.customer!.email,
                                        false,
                                        () {}),
                                    tableRow(
                                        "Mobile No",
                                        enquiryData.customer!.mobileNo,
                                        false,
                                        () {}),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
                    enquiryData.customer != null
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Products(${enquiryData.products!.length})",
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
                                  index < enquiryData.products!.length;
                                  index++)
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: enquiryData.products!.length !=
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
                                      child: Text(enquiryData
                                              .products![index].productName ??
                                          ""),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        enquiryData.products![index].qty
                                            .toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        double.parse(enquiryData
                                                .products![index].price
                                                .toString())
                                            .toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        double.parse((enquiryData
                                                        .products![index].qty! *
                                                    enquiryData.products![index]
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
                                  "Rs.${enquiryData.price!.subTotal}",
                                  false,
                                  () {}),
                              tableRow(
                                  "Discount",
                                  "Rs.${enquiryData.price!.discountValue}",
                                  false, () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return DiscountDetailProduct(
                                        productData: enquiryData.products!);
                                  },
                                );
                              }),
                              tableRow(
                                  "Extra Discount (${enquiryData.price!.extraDiscountsys == "%" ? '${enquiryData.price!.extraDiscount != null ? (enquiryData.price!.extraDiscount)!.round() : ""}%' : 'Rs ${enquiryData.price!.extraDiscount != null ? (enquiryData.price!.extraDiscount)!.round() : ""}'})",
                                  "Rs.${enquiryData.price!.extraDiscountValue}",
                                  false,
                                  () {}),
                              tableRow(
                                  "Package Charge (${enquiryData.price!.packagesys == "%" ? '${enquiryData.price!.package != null ? (enquiryData.price!.package)!.round() : ""}%' : 'Rs ${enquiryData.price!.package != null ? (enquiryData.price!.package)!.round() : ""}'})",
                                  "Rs.${enquiryData.price!.packageValue}",
                                  false,
                                  () {}),
                              tableRow(
                                  "Round Off",
                                  "Rs.${enquiryData.price!.roundOff}",
                                  false,
                                  () {}),
                              tableRow(
                                  "Total",
                                  "Rs.${enquiryData.price!.total}",
                                  true,
                                  () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  FloatingActionButton floatingButton(BuildContext context) {
    return FloatingActionButton.extended(
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
                    enquiryData: enquiryData,
                  );
                } else {
                  return BillingTwoEdit(
                    isEdit: true,
                    enquiryData: enquiryData,
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
    );
  }

  AppBar appbar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      titleSpacing: 0,
      title: Text(
        enquiryData.enquiryid ?? enquiryData.referenceId ?? '',
      ),
    );
  }
}
