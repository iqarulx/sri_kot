import 'dart:typed_data';
import 'package:esc_pos_printer_new/esc_pos_printer_new.dart';
import 'package:esc_pos_utils_new/esc_pos_utils_new.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../services/services.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/utils/utils.dart';
import '/constants/constants.dart';

class PrintView extends StatefulWidget {
  final EstimateDataModel estimateData;
  final ProfileModel companyInfo;
  const PrintView({
    super.key,
    required this.estimateData,
    required this.companyInfo,
  });

  @override
  State<PrintView> createState() => _PrintViewState();
}

class _PrintViewState extends State<PrintView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  Uint8List? data;
  Uint8List? dataA5;
  Uint8List? data3Inch;

  getpriceListPdf() async {
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.estimateData,
      type: PdfType.enquiry,
      companyInfo: widget.companyInfo,
    );

    var dataResult = await pdf.showA4PDf();
    setState(() {
      data = dataResult;
    });
  }

  getpriceListA5Pdf() async {
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
      pdfAlignment: pdfAlignment,
      estimateData: widget.estimateData,
      type: PdfType.enquiry,
      companyInfo: widget.companyInfo,
    );
    // var dataResult = await pdf.createPdfA5();
    var dataResult = await pdf.showA5PDf();
    setState(() {
      dataA5 = Uint8List.fromList(dataResult);
    });
  }

  getpriceList3InchPdf() async {
    var pdfAlignment = await LocalDB.getPdfAlignment();

    var pdf = EnquiryPdf(
        estimateData: widget.estimateData,
        type: PdfType.enquiry,
        companyInfo: widget.companyInfo,
        pdfAlignment: pdfAlignment);
    var dataResult = await pdf.create3InchPDF();
    if (dataResult != null) {
      setState(() {
        data3Inch = dataResult;
      });
    }
  }

  // Future<void> _print() async {
  //   try {
  //     // var printer = const Printer(url: "192.168.000.145:9100", name: "srisoftwarez", location: '192.168.000.145:9100');
  //     // await Printing.directPrintPdf(printer: printer, onLayout: (_) => data3Inch!);
  //     Uint8List? imageData;
  //     await for (final page in Printing.raster(data3Inch!)) {
  //       imageData = await page.toPng();
  //     }
  //     if (imageData != override) {
  //       log(imageData.toString());
  //       await Printing.layoutPdf(
  //         format: pw.PdfPageFormat.roll80,
  //         onLayout: (_) async => imageData!,
  //       );
  //     }

  //     // Printer? pri = await Printing.pickPrinter(context: context);
  //     // await Printing.directPrintPdf(printer: pri!, onLayout: (_) async => data3Inch!);

  //     // await Printing.sharePdf(bytes: data3Inch!);
  //   } on Exception catch (e) {
  //     log(e.toString());
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  printPriceList() async {
    try {
      if (data != null && _controller.index == 0) {
        await Printing.layoutPdf(
          onLayout: (_) => data!,
        );
      } else if (dataA5 != null && _controller.index == 1) {
        await Printing.layoutPdf(
          onLayout: (_) => dataA5!,
        );
      } else if (data3Inch != null && _controller.index == 2) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => data3Inch!,
        );
        // await Printing.layoutPdf(
        //   onLayout: (_) => data3Inch!,
        // );
        // await Printing.layoutPdf(
        //   onLayout: (_) => data3Inch!,
        // );
        // Future<Uint8List>? image;
        // await for (var page in Printing.raster(data3Inch!, dpi: 180)) {
        //   image = page.toPng(); // ...or page.toPng()
        // }

        // _print();
        // await Printing.layoutPdf(
        //   onLayout: (_) => data3Inch!,
        // );
      } else {
        Navigator.pop(context);
        snackbar(context, false, "Pdf Not Available");
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  demoPrint(NetworkPrinter printer) {
    printer.cut();
  }

  print() async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res =
        await printer.connect('192.168.000.145', port: 9100);

    if (res == PosPrintResult.success) {
      Termal3InchPDF(
              estimateData: widget.estimateData,
              companyInfo: widget.companyInfo)
          .printDemoReceipt(printer);
      // demoPrint(printer);
      printer.disconnect();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    getpriceListPdf();
  }

  @override
  void dispose() {
    _controller.dispose();
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
        title: const Text("Print Enquiry / Estimate"),
        bottom: TabBar(
          controller: _controller,
          onTap: (value) {
            setState(() {
              if (value == 0) {
                getpriceListPdf();
              } else if (value == 1) {
                getpriceListA5Pdf();
              } else {
                getpriceList3InchPdf();
              }
            });
          },
          tabs: const [
            Tab(text: "A4"),
            Tab(text: "A5"),
            Tab(text: "3-Inch"),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              printPriceList();
            },
            icon: const Icon(
              Icons.print,
              size: 20,
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   shape: RoundedRectangleBorder(
      //     side: BorderSide.none,
      //     borderRadius: BorderRadius.circular(10),
      //   ),
      //   onPressed: () {},
      //   label: const Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Icon(Icons.print),
      //       SizedBox(
      //         width: 10,
      //       ),
      //       Text("Print"),
      //     ],
      //   ),
      // ),
      body: TabBarView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          data != null
              ? SfPdfViewer.memory(
                  data!,
                )
              : const SizedBox(),
          dataA5 != null
              ? SfPdfViewer.memory(
                  dataA5!,
                )
              : const SizedBox(),
          data3Inch != null
              ? SfPdfViewer.memory(
                  data3Inch!,
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
