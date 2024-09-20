import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '/model/model.dart';
import '/provider/provider.dart';
import '/utils/utils.dart';
import '/constants/constants.dart';

class PrintViewEstimate extends StatefulWidget {
  final EstimateDataModel estimateData;
  final ProfileModel companyInfo;
  const PrintViewEstimate(
      {super.key, required this.estimateData, required this.companyInfo});

  @override
  State<PrintViewEstimate> createState() => _PrintViewEstimateState();
}

class _PrintViewEstimateState extends State<PrintViewEstimate>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  Uint8List? data;
  Uint8List? dataA5;

  getpriceListPdf() async {
    var pdf = EnqueryPdfCreation(
      estimateData: widget.estimateData,
      type: PdfType.estimate,
      companyInfo: widget.companyInfo,
    );
    var dataResult = await pdf.createPdfA4();
    if (dataResult != null) {
      setState(() {
        data = Uint8List.fromList(dataResult);
      });
    }
  }

  getpriceListA5Pdf() async {
    var pdf = EnqueryPdfCreation(
      estimateData: widget.estimateData,
      type: PdfType.estimate,
      companyInfo: widget.companyInfo,
    );
    var dataResult = await pdf.createPdfA5();
    if (dataResult != null) {
      setState(() {
        dataA5 = Uint8List.fromList(dataResult);
      });
    }
  }

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
    _controller = TabController(length: 2, vsync: this);
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
        title: const Text("Print Enquiry"),
        bottom: TabBar(
          controller: _controller,
          onTap: (value) {
            setState(() {
              if (value == 0) {
                getpriceListPdf();
              } else {
                getpriceListA5Pdf();
              }
            });
          },
          tabs: const [
            Tab(text: "A4"),
            Tab(text: "A5"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        onPressed: () {
          printPriceList();
        },
        label: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.print),
            SizedBox(
              width: 10,
            ),
            Text("Print"),
          ],
        ),
      ),
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
        ],
      ),
    );
  }
}
