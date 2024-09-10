import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
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

class EnquiryDetails extends StatefulWidget {
  final EstimateDataModel estimateData;
  const EnquiryDetails({super.key, required this.estimateData});

  @override
  State<EnquiryDetails> createState() => _EnquiryDetailsState();
}

class _EnquiryDetailsState extends State<EnquiryDetails> {
  var companyData = ProfileModel();
  TableRow tableRow(String? title, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            title ?? "",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            value ?? "",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String getItems() {
    String count = "0";
    int tmpcount = 0;
    for (var element in widget.estimateData.products!) {
      tmpcount += element.qty!;
    }
    count = tmpcount.toString();
    return count;
  }

  printEnquiry() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStoreProvider()
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
                    builder: (context) => PrintView(
                      estimateData: widget.estimateData,
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
              estimateData: widget.estimateData,
              companyInfo: companyData,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  downloadPrintEnquiry() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStoreProvider()
                .getCompanyDocInfo(cid: cid)
                .then((companyInfo) async {
              if (companyInfo != null) {
                setState(() {
                  companyData.companyName = companyInfo["company_name"];
                  companyData.address = companyInfo["address"];
                });

                var pdf = EnqueryPdfCreation(
                  estimateData: widget.estimateData,
                  type: PdfType.enquiry,
                  companyInfo: companyData,
                );
                var dataResult =
                    await pdf.createPDFDemoA4(pageSize: PdfPageFormat.a4);
                // var dataResult = await pdf.create3InchPDF();
                if (dataResult != null) {
                  var data = Uint8List.fromList(dataResult);
                  Navigator.pop(context);
                  await helper.saveAndLaunchFile(
                      data, 'Enquiry ${widget.estimateData.enquiryid}.pdf');
                } else {
                  Navigator.pop(context);
                }
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

        var pdf = EnqueryPdfCreation(
          estimateData: widget.estimateData,
          type: PdfType.enquiry,
          companyInfo: companyData,
        );
        var dataResult = await pdf.createPDFDemoA4(pageSize: PdfPageFormat.a4);
        // var dataResult = await pdf.create3InchPDF();
        if (dataResult != null) {
          var data = Uint8List.fromList(dataResult);
          Navigator.pop(context);
          await helper.saveAndLaunchFile(
              data, 'Enquiry ${widget.estimateData.enquiryid}.pdf');
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  deleteEnquiry() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await FireStoreProvider()
            .deleteEnquiry(docID: widget.estimateData.docID!)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackBarCustom(context, true, "Successfully Deleted");
        });
      } else {
        await LocalService.deleteEnquiry(
                referenceId: widget.estimateData.referenceId ?? '')
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackBarCustom(context, true, "Successfully Deleted");
        });
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  convertEstimate() async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (widget.estimateData.customer != null &&
          widget.estimateData.customer!.customerName != null &&
          widget.estimateData.customer!.customerName!.isNotEmpty) {
        loading(context);

        if (connectionProvider.isConnected) {
          await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
            if (cid != null) {
              await FireStoreProvider()
                  .orderToConvertEstimate(
                cid: cid,
                docID: widget.estimateData.docID!,
              )
                  .then((value) async {
                await FireStoreProvider()
                    .deleteEnquiry(docID: widget.estimateData.docID!)
                    .then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                  snackBarCustom(
                    context,
                    true,
                    "Successfully Enquiry Converted to Estimate",
                  );
                });
              });
            }
          });
        } else {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackBarCustom(
            context,
            true,
            "Successfully Enquiry Converted to Estimate",
          );
          LocalService.enquiryToEstimate(
              referenceId: widget.estimateData.referenceId ?? '',
              cid: await LocalDB.fetchInfo(type: LocalData.companyid));
        }
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return CustomerSearch(
              isConnected: connectionProvider.isConnected,
            );
          },
        ).then((value) async {
          if (value != null) {
            if (connectionProvider.isConnected) {
              await FireStoreProvider()
                  .updateEnquiryCustomer(
                      docId: widget.estimateData.docID!,
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
                  widget.estimateData.customer!.customerName =
                      value.customerName ?? '';
                  widget.estimateData.customer!.address = value.address ?? '';
                  widget.estimateData.customer!.city = value.city ?? '';
                  widget.estimateData.customer!.state = value.state ?? '';
                  widget.estimateData.customer!.email = value.email ?? '';
                  widget.estimateData.customer!.mobileNo = value.mobileNo ?? '';
                });
                convertEstimate();
              });
            } else {
              await LocalService.updateCustomerInfo(
                      customerInfo: value,
                      referenceId: widget.estimateData.referenceId ?? '')
                  .then((result) {
                setState(() {
                  widget.estimateData.customer!.customerName =
                      value?.customerName ?? '';
                  widget.estimateData.customer!.address = value?.address ?? '';
                  widget.estimateData.customer!.city = value?.city ?? '';
                  widget.estimateData.customer!.state = value?.state ?? '';
                  widget.estimateData.customer!.email = value?.email ?? '';
                  widget.estimateData.customer!.mobileNo =
                      value?.mobileNo ?? '';
                });
                convertEstimate();
              });
            }
          }
        });
      }
    } catch (e) {
      // Navigator.pop(context);
      print(e);
      snackBarCustom(context, false, e.toString());
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
            await FireStoreProvider()
                .duplicateEnquiry(docID: widget.estimateData.docID!, cid: cid)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context, true);
              snackBarCustom(context, true, "Successfully Enqiry Duplicated");
            });
          }
        });
      } else {
        await LocalService.duplicateEnquiry(
                referenceId: widget.estimateData.referenceId!)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackBarCustom(context, true, "Successfully Enqiry Duplicated");
        });
      }
    } catch (e) {
      Navigator.pop(context);
      throw e.toString();
    }
  }

  bool isloading = false;

  checkProductsList() async {
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    if (connectionProvider.isConnected) {
      if (widget.estimateData.products!.isEmpty) {
        setState(() {
          isloading = true;
        });
        await FireStoreProvider()
            .getEnquiryProducts(docid: widget.estimateData.docID!)
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
                widget.estimateData.products!.add(productDataModel);
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

  sharePDF() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStoreProvider()
                .getCompanyDocInfo(cid: cid)
                .then((companyInfo) async {
              if (companyInfo != null) {
                setState(() {
                  companyData.companyName = companyInfo["company_name"];
                  companyData.address = companyInfo["address"];
                });

                var pdf = EnqueryPdfCreation(
                  estimateData: widget.estimateData,
                  type: PdfType.enquiry,
                  companyInfo: companyData,
                );
                await pdf
                    .createPDFDemoA4(pageSize: PdfPageFormat.a4)
                    .then((dataResult) async {
                  if (dataResult != null) {
                    await Printing.sharePdf(
                      bytes: dataResult,
                    ).then((value) {
                      Navigator.pop(context);
                    });
                  } else {
                    Navigator.pop(context);
                  }
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
        var pdf = EnqueryPdfCreation(
          estimateData: widget.estimateData,
          type: PdfType.enquiry,
          companyInfo: companyData,
        );
        await pdf
            .createPDFDemoA4(pageSize: PdfPageFormat.a4)
            .then((dataResult) async {
          if (dataResult != null) {
            await Printing.sharePdf(
              bytes: dataResult,
            ).then((value) {
              Navigator.pop(context);
            });
          } else {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      Navigator.pop(context);
      snackBarCustom(context, false, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    checkProductsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      floatingActionButton: floatingButton(context),
      backgroundColor: const Color(0xffEEEEEE),
      body: ListView(
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
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                        widget.estimateData.enquiryid ??
                            widget.estimateData.referenceId),
                    tableRow(
                      "Order Date",
                      DateFormat('dd-MM-yyyy hh:mm a')
                          .format(widget.estimateData.createddate!),
                    ),
                  ],
                ),
                widget.estimateData.estimateid == null
                    ? Center(
                        child: TextButton(
                          onPressed: () async {
                            await confirmationDialog(
                              context,
                              title: "Alert",
                              message: "Do you want Convert the Estimate?",
                            ).then((value) {
                              if (value != null && value == true) {
                                convertEstimate();
                              }
                            });
                          },
                          child: const Text("Convert to Estimate"),
                        ),
                      )
                    : const SizedBox(),
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
                      "Total",
                      "Rs.${widget.estimateData.price!.total}",
                    ),
                    tableRow(
                      "Discount",
                      "Rs.${widget.estimateData.price!.discountValue}",
                    ),
                    tableRow(
                      "Extra Discount",
                      "Rs.${widget.estimateData.price!.extraDiscountValue}",
                    ),
                    tableRow(
                      "Package Charge",
                      "Rs.${widget.estimateData.price!.packageValue}",
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          widget.estimateData.customer != null
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
                            widget.estimateData.customer!.customerName,
                          ),
                          tableRow(
                            "Address",
                            widget.estimateData.customer!.address,
                          ),
                          tableRow(
                            "City",
                            widget.estimateData.customer!.city,
                          ),
                          tableRow(
                            "State",
                            widget.estimateData.customer!.state,
                          ),
                          tableRow(
                            "Email",
                            widget.estimateData.customer!.email,
                          ),
                          tableRow(
                            "Mobile No",
                            widget.estimateData.customer!.mobileNo,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          widget.estimateData.customer != null
              ? const SizedBox(
                  height: 10,
                )
              : const SizedBox(),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Products(${widget.estimateData.products!.length})",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "Items - ${getItems()}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                isloading == false
                    ? ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: widget.estimateData.products!.length,
                        itemBuilder: (context, index) {
                          var product = widget.estimateData.products![index];
                          return Container(
                            margin: EdgeInsets.only(
                              bottom:
                                  widget.estimateData.products!.length - 1 !=
                                          index
                                      ? 10
                                      : 0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // FastCachedImage(
                                //   width: 80,
                                //   height: 80,
                                //   url: product.productImg ?? Strings.productImg,
                                //   fit: BoxFit.cover,
                                //   repeat: ImageRepeat.noRepeat,
                                //   showErrorLog: true,
                                //   filterQuality: FilterQuality.low,
                                //   fadeInDuration: const Duration(seconds: 1),
                                //   errorBuilder:
                                //       (context, exception, stacktrace) {
                                //     return Text(stacktrace.toString());
                                //   },
                                // ),

                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   product.categoryName ?? "",
                                      //   style: Theme.of(context).textTheme.bodySmall,
                                      // ),
                                      Text(
                                        product.productName ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Rs.${product.price} / ${product.productContent}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Text(
                                        "Quantity : ${product.qty}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Rs.${product.price! * product.qty!}",
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                if (value == 1) {
                  return BillingOne(
                    isEdit: true,
                    enquiryData: widget.estimateData,
                  );
                } else {
                  return BillingTwo(
                    isEdit: true,
                    enquiryData: widget.estimateData,
                  );
                }
              }),
            );
          }
        });
      },
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit),
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
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Text(
        widget.estimateData.enquiryid ?? widget.estimateData.referenceId ?? '',
      ),
      // actions: [
      // IconButton(
      //   tooltip: "Print Enquiry",
      //   splashRadius: 29,
      //   onPressed: () {
      //     printEnquiry();
      //   },
      //   icon: const Icon(
      //     Icons.print,
      //   ),
      // ),
      // IconButton(
      //   tooltip: "Delete Enquiry",
      //   splashRadius: 29,
      //   onPressed: () async {
      //     await confirmationDialog(
      //       context,
      //       title: "Alert",
      //       message: "Do you want delete enquiry?",
      //     ).then((value) {
      //       if (value != null && value == true) {
      //         deleteEnquiry();
      //       }
      //     });
      //   },
      //   icon: const Icon(
      //     Icons.delete,
      //   ),
      // ),
      // IconButton(
      //   tooltip: "Copy Enquiry",
      //   splashRadius: 29,
      //   onPressed: () async {
      //     await confirmationDialog(
      //       context,
      //       title: "Alert",
      //       message: "Do you want Duplicate enquiry?",
      //     ).then((value) {
      //       if (value != null && value == true) {
      //         duplicateEnquiry();
      //       }
      //     });
      //   },
      //   icon: const Icon(
      //     Icons.copy,
      //   ),
      // ),
      // IconButton(
      //   tooltip: "Download PDF",
      //   splashRadius: 29,
      //   onPressed: () async {
      //     await confirmationDialog(
      //       context,
      //       title: "Alert",
      //       message: "Do you want Download enquiry?",
      //     ).then((value) {
      //       if (value != null && value == true) {
      //         downloadPrintEnquiry();
      //       }
      //     });
      //   },
      //   icon: const Icon(
      //     Icons.file_download_outlined,
      //   ),
      // ),
      // ],
    );
  }
}
