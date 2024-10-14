import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '/services/services.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/utils/utils.dart';
import '/constants/constants.dart';
import '/view/ui/ui.dart';

class PrintViewA5 extends StatefulWidget {
  final EstimateDataModel estimateData;
  final ProfileModel companyInfo;
  const PrintViewA5(
      {super.key, required this.estimateData, required this.companyInfo});

  @override
  State<PrintViewA5> createState() => _PrintViewA5State();
}

class _PrintViewA5State extends State<PrintViewA5>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  Uint8List? format1;
  Uint8List? format2;
  Uint8List? format3;

  format1Pdf() async {
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.estimateData,
      type: PdfType.estimate,
      companyInfo: widget.companyInfo,
    );

    var dataResult = await pdf.format1A5();
    setState(() {
      format1 = dataResult;
    });
  }

  format2Pdf() async {
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.estimateData,
      type: PdfType.estimate,
      companyInfo: widget.companyInfo,
    );

    var dataResult = await pdf.format2A5();
    setState(() {
      format2 = dataResult;
    });
  }

  format3Pdf() async {
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.estimateData,
      type: PdfType.estimate,
      companyInfo: widget.companyInfo,
    );

    var dataResult = await pdf.format3A5();
    setState(() {
      format3 = dataResult;
    });
  }

  print() async {
    try {
      if (format1 != null && _controller.index == 0) {
        await Printing.layoutPdf(
          onLayout: (_) => format1!,
        );
      } else if (format2 != null && _controller.index == 1) {
        await Printing.layoutPdf(
          onLayout: (_) => format2!,
        );
      } else if (format3 != null && _controller.index == 2) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => format3!,
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
    _controller = TabController(length: 3, vsync: this);
    format1Pdf();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        title: const Text("A5 Estimate"),
        bottom: TabBar(
          controller: _controller,
          onTap: (value) {
            setState(() {
              if (value == 0) {
                format1Pdf();
              } else if (value == 1) {
                format2Pdf();
              } else {
                format3Pdf();
              }
            });
          },
          tabs: const [
            Tab(text: "Format 1"),
            Tab(text: "Format 2"),
            Tab(text: "Format 3"),
          ],
        ),
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
      body: TabBarView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          format1 != null
              ? SfPdfViewer.memory(
                  format1!,
                )
              : const SizedBox(),
          format2 != null
              ? SfPdfViewer.memory(
                  format2!,
                )
              : const SizedBox(),
          format3 != null
              ? SfPdfViewer.memory(
                  format3!,
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
