import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:sri_kot/model/model.dart';
import 'package:sri_kot/view/screens/enquiry/src/print_view/print_enquiry_3inch.dart';
import 'package:sri_kot/view/screens/enquiry/src/print_view/print_enquiry_a5.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

import '../../../constants/constants.dart';
import '../../../provider/provider.dart';
import '../../../services/services.dart';
import '../../../utils/utils.dart';
import '../../screens/invoice/src/billing/edit/billing_one_edit_inv.dart';
import '../../screens/invoice/src/billing/edit/billing_two_edit_inv.dart';
import '../../screens/screens.dart';
import 'commonwidget.dart';
import 'invoice_pdf_type.dart';
import 'pdf_preview_modal.dart';
import '/provider/src/file_open.dart' as helper;

class BillOptions extends StatefulWidget {
  final String title;
  final BillType billType;
  final EstimateDataModel? estimate;
  final EstimateDataModel? enquiry;
  final InvoiceModel? invoice;
  const BillOptions(
      {super.key,
      required this.title,
      required this.billType,
      this.estimate,
      this.enquiry,
      this.invoice});

  @override
  State<BillOptions> createState() => _BillOptionsState();
}

class _BillOptionsState extends State<BillOptions> {
  ProfileModel companyData = ProfileModel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    if (widget.billType == BillType.enquiry) {
                      viewEnquiry();
                    } else if (widget.billType == BillType.estimate) {
                      viewEstimate();
                    } else if (widget.billType == BillType.invoice) {
                      viewInvoice();
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 100,
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_new),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Text(
                            "View",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (widget.billType == BillType.enquiry) {
                      editEnquiry();
                    } else if (widget.billType == BillType.estimate) {
                      editEstimate();
                    } else if (widget.billType == BillType.invoice) {
                      editInvoice();
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 100,
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_rounded),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Text(
                            "Edit",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (widget.billType != BillType.invoice) {
                      if (widget.billType == BillType.enquiry) {
                        await confirmationDialog(
                          context,
                          title: "Alert",
                          message: "Do you want delete enquiry?",
                        ).then((value) {
                          if (value != null && value == true) {
                            deleteEnquiry();
                          }
                        });
                      } else if (widget.billType == BillType.estimate) {
                        await confirmationDialog(
                          context,
                          title: "Alert",
                          message: "Do you want delete estimate?",
                        ).then((value) {
                          if (value != null && value == true) {
                            deleteEstimate();
                          }
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 100,
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.trash),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Text(
                            "Delete",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    if (widget.billType == BillType.enquiry) {
                      sharePDFEnquiry();
                    } else if (widget.billType == BillType.estimate) {
                      sharePDFEstimate();
                    } else if (widget.billType == BillType.invoice) {
                      shareInvoice();
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 100,
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.link),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Text(
                            "Share Pdf",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (widget.billType == BillType.enquiry) {
                      downloadPrintEnquiry();
                    } else if (widget.billType == BillType.estimate) {
                      downloadPrintEstimate();
                    } else if (widget.billType == BillType.invoice) {
                      shareInvoice();
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 100,
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.arrow_down_circle),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Text(
                            "Download",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (widget.billType == BillType.enquiry) {
                      printEnquiry();
                    } else if (widget.billType == BillType.estimate) {
                      printEstimate();
                    } else if (widget.billType == BillType.invoice) {
                      shareInvoice();
                    }
                  },
                  child: Container(
                    height: 80,
                    width: 100,
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.printer),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: Text(
                            "Print Pdf",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            if (widget.billType != BillType.invoice)
              InkWell(
                onTap: () async {
                  if (widget.billType == BillType.enquiry) {
                    whatsappShareEnquiry();
                  } else if (widget.billType == BillType.estimate) {
                    whatsappShareEstimate();
                  } else if (widget.billType == BillType.invoice) {}
                },
                child: Container(
                  width: 325,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/whatsapp.png',
                        height: 30,
                        width: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text("Whatsapp Share")
                    ],
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            // InkWell(
            //   onTap: () async {
            //     if (widget.billType == BillType.enquiry) {
            //       shareToMobileEnquiry();
            //     } else if (widget.billType == BillType.estimate) {
            //       whatsappShareEstimate();
            //     } else if (widget.billType == BillType.invoice) {}
            //   },
            //   child: Container(
            //     width: 325,
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.green.shade100,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Image.asset(
            //           'assets/whatsapp.png',
            //           height: 30,
            //           width: 30,
            //         ),
            //         const SizedBox(
            //           width: 5,
            //         ),
            //         Text(
            //             "Share to ${widget.billType == BillType.enquiry ? widget.enquiry!.customer!.mobileNo! : widget.estimate!.customer!.mobileNo!}")
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  viewInvoice() async {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => InvoiceDetails(
          invoice: widget.invoice!,
        ),
      ),
    );
    Navigator.pop(context);
  }

  editInvoice() async {
    await LocalDB.getBillingIndex().then((value) async {
      if (value != null) {
        final result = await Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) {
            if (value == 1) {
              return BillingOneEditInv(
                invoice: widget.invoice!,
              );
            } else {
              return const BillingTwoEditInv();
            }
          }),
        );
      }
    });
    Navigator.pop(context);
  }

  shareInvoice() async {
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
          heightFactor: 0.4,
          child: InvoicePdfType(),
        );
      },
    ).then((value) async {
      if (value != null) {
        await FireStore().getCompanyTax().then((result) {
          if (result) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => InvoicePdfView(
                  title: value,
                  invoice: widget.invoice ?? InvoiceModel(),
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => InvoicePdfView(
                  title: value,
                  invoice: widget.invoice ?? InvoiceModel(),
                ),
              ),
            );
          }
        });
      }
    });
    Navigator.pop(context);
  }

  sharePDFEstimate() async {
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
                  pdfAlignment: pdfAlignment,
                  estimateData: widget.estimate!,
                  type: PdfType.enquiry,
                  companyInfo: companyData,
                );
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
          estimateData: widget.estimate!,
          type: PdfType.enquiry,
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
    Navigator.pop(context);
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
          heightFactor: 0.25,
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
                          estimateData: widget.estimate!,
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
                  estimateData: widget.estimate!,
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
                          estimateData: widget.estimate!,
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
                builder: (context) => PrintEnquiryA5(
                  estimateData: widget.estimate!,
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
                          estimateData: widget.estimate!,
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
                  estimateData: widget.estimate!,
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
    Navigator.pop(context);
  }

  viewEstimate() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EstimateDetails(
          cid: widget.estimate!.docID ?? widget.estimate!.referenceId ?? '',
        ),
      ),
    );
    Navigator.pop(context);
  }

  deleteEstimate() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await FireStore()
            .deleteEstimate(docID: widget.estimate!.docID!)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Deleted");
        });
      } else {
        await LocalService.deleteEstimate(
                referenceId: widget.estimate!.referenceId ?? '')
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
    Navigator.pop(context);
  }

  downloadPrintEstimate() async {
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
                    estimateData: widget.estimate!,
                    type: PdfType.estimate,
                    companyInfo: companyData,
                    pdfAlignment: pdfAlignment);
                Navigator.pop(context);
                var dataResult = await pdf.format1A4();
                var data = Uint8List.fromList(dataResult);
                await helper.saveAndLaunchFile(data,
                    'Estimate ${widget.estimate!.estimateid ?? widget.estimate!.referenceId}.pdf');
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
          estimateData: widget.estimate!,
          type: PdfType.estimate,
          companyInfo: companyData,
        );
        Navigator.pop(context);

        var dataResult = await pdf.format1A4();
        var data = Uint8List.fromList(dataResult);
        await helper.saveAndLaunchFile(data,
            'Estimate ${widget.estimate!.estimateid ?? widget.estimate!.referenceId}.pdf');
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  sharePDFEnquiry() async {
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
                  estimateData: widget.enquiry!,
                  type: PdfType.enquiry,
                  companyInfo: companyData,
                  pdfAlignment: pdfAlignment,
                );
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
          estimateData: widget.enquiry!,
          type: PdfType.enquiry,
          companyInfo: companyData,
          pdfAlignment: pdfAlignment,
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
    Navigator.pop(context);
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
          heightFactor: 0.25,
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
                          estimateData: widget.enquiry!,
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
                  estimateData: widget.enquiry!,
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
                          estimateData: widget.enquiry!,
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
                  estimateData: widget.enquiry!,
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
                          estimateData: widget.enquiry!,
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
                  estimateData: widget.enquiry!,
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
    Navigator.pop(context);
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
                    estimateData: widget.enquiry!,
                    type: PdfType.enquiry,
                    companyInfo: companyData,
                    pdfAlignment: pdfAlignment);
                var dataResult = await pdf.format1A4();
                // var dataResult = await pdf.create3InchPDF();
                var data = Uint8List.fromList(dataResult);
                Navigator.pop(context);
                await helper.saveAndLaunchFile(
                    data, 'Enquiry ${widget.enquiry!.enquiryid}.pdf');
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
            estimateData: widget.enquiry!,
            type: PdfType.enquiry,
            companyInfo: companyData,
            pdfAlignment: pdfAlignment);
        var dataResult = await pdf.format1A4();
        // var dataResult = await pdf.create3InchPDF();
        var data = Uint8List.fromList(dataResult);
        Navigator.pop(context);
        await helper.saveAndLaunchFile(
            data, 'Enquiry ${widget.enquiry!.enquiryid}.pdf');
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
    Navigator.pop(context);
  }

  viewEnquiry() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EnquiryDetails(
          cid: widget.enquiry!.docID ?? '',
        ),
      ),
    );
    Navigator.pop(context);
  }

  deleteEnquiry() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);

    try {
      if (connectionProvider.isConnected) {
        await FireStore()
            .deleteEnquiry(docID: widget.enquiry!.docID ?? '')
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Deleted");
        });
      } else {
        await LocalService.deleteEnquiry(
                referenceId: widget.enquiry!.referenceId ?? '')
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
    Navigator.pop(context);
  }

  editEnquiry() async {
    await LocalDB.getBillingIndex().then((value) async {
      if (value != null) {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) {
            if (value == 1) {
              return BillingOneEdit(
                isEdit: true,
                enquiryData: widget.enquiry!,
              );
            } else {
              return BillingTwo(
                isEdit: true,
                enquiryData: widget.enquiry!,
              );
            }
          }),
        );
      }
    });
    Navigator.pop(context);
  }

  editEstimate() async {
    await LocalDB.getBillingIndex().then((value) async {
      if (value != null) {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) {
            if (value == 1) {
              return BillingOneEdit(
                isEdit: true,
                enquiryData: widget.estimate!,
              );
            } else {
              return BillingTwo(
                isEdit: true,
                enquiryData: widget.estimate!,
              );
            }
          }),
        );
      }
    });
    Navigator.pop(context);
  }

  whatsappShareEnquiry() async {
    const SocialPlatform platform = SocialPlatform.whatsapp;
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/document.pdf';
    final file = File(filePath);
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.enquiry!,
      type: PdfType.estimate,
      companyInfo: companyData,
    );
    var dataResult = await pdf.format1A4();
    var data = Uint8List.fromList(dataResult);
    await file.writeAsBytes(data);
    await SocialSharingPlus.shareToSocialMedia(
      platform,
      "Sharing enquiry pdf",
      media: filePath,
      isOpenBrowser: true,
    );
    Navigator.pop(context);
  }

  shareToMobileEnquiry() async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/document.pdf';
    final file = File(filePath);
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.enquiry!,
      type: PdfType.estimate,
      companyInfo: companyData,
    );
    var dataResult = await pdf.format1A4();
    var data = Uint8List.fromList(dataResult);
    await file.writeAsBytes(data);
    await WhatsappShare.shareFile(
      phone: '91${widget.enquiry!.customer!.mobileNo!}',
      filePath: [file.path],
    );
    Navigator.pop(context);
  }

  whatsappShareEstimate() async {
    const SocialPlatform platform = SocialPlatform.whatsapp;
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/document.pdf';
    final file = File(filePath);
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.estimate!,
      type: PdfType.estimate,
      companyInfo: companyData,
    );
    var dataResult = await pdf.format1A4();
    var data = Uint8List.fromList(dataResult);
    await file.writeAsBytes(data);
    await SocialSharingPlus.shareToSocialMedia(
      platform,
      "Sharing enquiry pdf",
      media: filePath,
      isOpenBrowser: true,
    );
    Navigator.pop(context);
  }

  shareToMobileEstimate() async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/document.pdf';
    final file = File(filePath);
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.estimate!,
      type: PdfType.estimate,
      companyInfo: companyData,
    );
    var dataResult = await pdf.format1A4();
    var data = Uint8List.fromList(dataResult);
    await file.writeAsBytes(data);
    await WhatsappShare.shareFile(
      phone: '91${widget.estimate!.customer!.mobileNo!}',
      filePath: [file.path],
    );
    Navigator.pop(context);
  }
}
