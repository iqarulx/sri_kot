import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '/services/services.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/utils/utils.dart';
import '/constants/constants.dart';
import '/view/ui/ui.dart';

class PrintEnquiry3inch extends StatefulWidget {
  final EstimateDataModel estimateData;
  final ProfileModel companyInfo;
  const PrintEnquiry3inch({
    super.key,
    required this.estimateData,
    required this.companyInfo,
  });

  @override
  State<PrintEnquiry3inch> createState() => _PrintEnquiry3inchState();
}

class _PrintEnquiry3inchState extends State<PrintEnquiry3inch> {
  Uint8List? data;

  getPdf() async {
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
        estimateData: widget.estimateData,
        type: PdfType.enquiry,
        companyInfo: widget.companyInfo,
        pdfAlignment: pdfAlignment);
    var dataResult = await pdf.create3InchPDF();
    if (dataResult != null) {
      setState(() {
        data = dataResult;
      });
    }
  }

  printPriceList() async {
    try {
      if (data != null) {
        await Printing.layoutPdf(
          onLayout: (_) => data!,
        );
      } else {
        Navigator.pop(context);
        snackbar(context, false, "Pdf Not Available");
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getPdf();
  }

  openMenu() async {
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
        title: const Text("3inch Enquiry"),
      ),
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: data != null
            ? SfPdfViewer.memory(
                data!,
              )
            : const SizedBox(),
      ),
    );
  }
}
