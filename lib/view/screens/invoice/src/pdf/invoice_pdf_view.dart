import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/screens/screens.dart';
import '/provider/src/file_open.dart' as helper;
import 'non_gst/invoice_pdf_service.dart';

class InvoicePdfView extends StatefulWidget {
  final String title;
  final InvoiceModel invoice;
  const InvoicePdfView({super.key, required this.title, required this.invoice});

  @override
  State<InvoicePdfView> createState() => _InvoicePdfViewState();
}

class _InvoicePdfViewState extends State<InvoicePdfView>
    with SingleTickerProviderStateMixin {
  Uint8List? format1;
  Uint8List? format2;
  Uint8List? format3;

  initFn() async {
    try {
      await FireStore()
          .getLastInvoiceAmount(
              billDate: widget.invoice.billDate!,
              billNo: widget.invoice.billNo!)
          .then((lastAmount) async {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          await FireStore().getCompanyDocInfo(cid: cid).then((result) async {
            if (result != null && result.exists) {
              ProfileModel model = ProfileModel();
              model.companyName = result["company_name"].toString();
              model.address = result["address"].toString();
              model.city = result["city"].toString();
              model.state = result["state"].toString();
              model.pincode = result["pincode"].toString();
              model.contact = {
                "mobile": result["contact"]["mobile_no"].toString(),
                "phone": result["contact"]["phone_no"].toString(),
              };
              model.gstno = result["gst_no"] ?? "";
              model.companyLogo = result["company_logo"] ?? Strings.productImg;
              model.hsn = result["hsn"];

              var pdfType = await LocalDB.getPdfType() ?? false;
              var pdfAlignment = await LocalDB.getPdfAlignment();

              await FireStore().getCompanyTax().then((result) async {
                if (result) {
                  await InvoicePDFService(
                    title: widget.title,
                    invoice: widget.invoice,
                    total: lastAmount.toStringAsFixed(2),
                    companyDoc: model,
                    pdfType: pdfType,
                    pdfAlignment: pdfAlignment,
                  ).format1A4().then((value) {
                    setState(() {
                      format1 = value;
                    });
                  });
                  await InvoicePDFService(
                    title: widget.title,
                    invoice: widget.invoice,
                    total: lastAmount.toStringAsFixed(2),
                    companyDoc: model,
                    pdfType: pdfType,
                    pdfAlignment: pdfAlignment,
                  ).format2A4().then((value) {
                    setState(() {
                      format2 = value;
                    });
                  });
                  await InvoicePDFService(
                    title: widget.title,
                    invoice: widget.invoice,
                    total: lastAmount.toStringAsFixed(2),
                    companyDoc: model,
                    pdfType: pdfType,
                    pdfAlignment: pdfAlignment,
                  ).format3A4().then((value) {
                    setState(() {
                      format3 = value;
                    });
                  });
                } else {
                  await InvoicePDFServiceNonGST(
                    title: widget.title,
                    invoice: widget.invoice,
                    total: lastAmount.toStringAsFixed(2),
                    companyDoc: model,
                    pdfType: pdfType,
                    pdfAlignment: pdfAlignment,
                  ).format1A4().then((value) {
                    setState(() {
                      format1 = value;
                    });
                  });
                  await InvoicePDFServiceNonGST(
                    title: widget.title,
                    invoice: widget.invoice,
                    total: lastAmount.toStringAsFixed(2),
                    companyDoc: model,
                    pdfType: pdfType,
                    pdfAlignment: pdfAlignment,
                  ).format2A4().then((value) {
                    setState(() {
                      format2 = value;
                    });
                  });
                  await InvoicePDFServiceNonGST(
                    title: widget.title,
                    invoice: widget.invoice,
                    total: lastAmount.toStringAsFixed(2),
                    companyDoc: model,
                    pdfType: pdfType,
                    pdfAlignment: pdfAlignment,
                  ).format3A4().then((value) {
                    setState(() {
                      format3 = value;
                    });
                  });
                }
              });
            }
          });
        });
      });
    } catch (e) {
      snackbar(context, false, e.toString());
    }
  }

  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    initFn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  downloadPdfData() async {
    try {
      if (format1 != null && _controller.index == 0) {
        await helper.saveAndLaunchFile(format1!,
            'Invoie ${widget.invoice.billNo!.replaceAll("/", "-")}.pdf');
      } else if (format2 != null && _controller.index == 1) {
        await helper.saveAndLaunchFile(format2!,
            'Invoie ${widget.invoice.billNo!.replaceAll("/", "-")}.pdf');
      } else if (format3 != null && _controller.index == 2) {
        await helper.saveAndLaunchFile(format3!,
            'Invoie ${widget.invoice.billNo!.replaceAll("/", "-")}.pdf');
      }
    } catch (e) {
      LogConfig.addLog("${DateTime.now()} : ${e.toString()}");
    }
  }

  openMenu() async {
    Uint8List? data;
    if (format1 != null && _controller.index == 0) {
      data = format1!;
    } else if (format2 != null && _controller.index == 1) {
      data = format2!;
    } else if (format3 != null && _controller.index == 2) {
      data = format3!;
    }
    await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (builder) {
        return PrintOptions(pdfData: data!);
      },
    );
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
        titleSpacing: 0,
        title: const Text("PDF Bill of Supply"),
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: "Format 1"),
            Tab(text: "Format 2"),
            Tab(text: "Format 3"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () {
              initFn();
            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        onPressed: () {
          openMenu();
        },
        child: const Icon(Icons.share_rounded),
      ),
      body: TabBarView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          format1 != null
              ? SfPdfViewer.memory(
                  format1!,
                )
              : Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
          format2 != null
              ? SfPdfViewer.memory(
                  format2!,
                )
              : Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
          format3 != null
              ? SfPdfViewer.memory(
                  format3!,
                )
              : Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
