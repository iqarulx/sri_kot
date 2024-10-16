// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import '/constants/constants.dart';
import '/view/screens/screens.dart';
import '/model/model.dart';
import 'package:pdf/pdf.dart' as pf;

class InvoicePDFServiceNonGST {
  final String title;
  final InvoiceModel invoice;
  final String total;
  final ProfileModel companyDoc;
  final bool pdfType;
  final int pdfAlignment;
  InvoicePDFServiceNonGST(
      {required this.title,
      required this.invoice,
      required this.total,
      required this.companyDoc,
      required this.pdfType,
      required this.pdfAlignment});

  //************** PDF View **********************/

  Future<Uint8List> format1A4() async {
    var pdf = pw.Document();

    final companyLogo = companyDoc.companyLogo != null
        ? await networkImage(
            companyDoc.companyLogo!,
          )
        : null;

    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    Map<int, TableColumnWidth> productColumnWidth = {
      0: const pw.FlexColumnWidth(1.3),
      1: const pw.FlexColumnWidth(5),
      2: const pw.FlexColumnWidth(3),
      3: const pw.FlexColumnWidth(3),
      4: const pw.FlexColumnWidth(3),
      5: const pw.FlexColumnWidth(3),
    };

    var docGstCode = companyDoc.gstno?.substring(0, 2);
    var gstState = gstCode[docGstCode];

    var boldTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8,
    );
    var normalTextStyle = const pw.TextStyle(
      fontSize: 8,
    );

    var productText = pw.TextStyle(
      fontSize: 8,
      font: roboto,
      fontFallback: [roboto, noto],
    );

    var data = serializeDataFormat1();
    for (var i = 0; i < data["total_pages"]; i++) {
      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(10),
          pageFormat: PdfPageFormat.a4,
          footer: (context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 5, bottom: 3),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  if (i == data["total_pages"])
                    pw.Text(
                      "*** This is a Computer Generated bill. Hence Digital Signature is not required ***",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  pw.Text(
                    "Page ${i + 1}/${data["total_pages"]}",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            );
          },
          header: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.SizedBox(),
                    ),
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Text(
                          "Bill of Supply",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        title,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                  },
                  border:
                      pw.TableBorder.symmetric(outside: const pw.BorderSide()),
                  children: [
                    pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        pw.Padding(
                          padding:
                              const pw.EdgeInsets.symmetric(horizontal: 15),
                          child: pw.SizedBox(
                            height: 50,
                            width: 50,
                            child: companyLogo != null
                                ? pw.Image(companyLogo, width: 50, height: 50)
                                : pw.SizedBox(),
                          ),
                        ),
                        pw.Column(
                          children: [
                            pw.SizedBox(height: 5),
                            pw.Center(
                              child: pw.Text(
                                companyDoc.companyName ?? "",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Center(
                              child: pw.Text(companyDoc.address ?? "",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(companyDoc.city ?? "",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(
                                  "${companyDoc.state ?? ""} - ${companyDoc.pincode ?? ""}",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(
                                  "Phone No : ${companyDoc.contact!["mobile"]}, ${companyDoc.contact!["phone"]}",
                                  style: normalTextStyle),
                            ),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                        companyDoc.gstno != null && companyDoc.gstno!.isNotEmpty
                            ? pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(right: 5),
                                    child: pw.Text(
                                      "GST NO: ${companyDoc.gstno ?? ""}",
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(right: 5),
                                    child: pw.Text(
                                      "$docGstCode : $gstState",
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  pw.SizedBox(height: 15),
                                  pw.SizedBox(height: 15),
                                ],
                              )
                            : pw.SizedBox(),
                      ],
                    ),
                  ],
                ),
                context.pageNumber == 1
                    ? pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                          2: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child:
                                        pw.Text("Buyer", style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.partyName ?? "",
                                            style: boldTextStyle),
                                        pw.Text(invoice.address ?? "",
                                            style: normalTextStyle),
                                        pw.Text(
                                            "${invoice.city ?? ""}, ${invoice.state ?? ""}",
                                            style: normalTextStyle),
                                        pw.Text(invoice.phoneNumber ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text("Delivery Address",
                                        style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.deliveryaddress ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text("Transport Details",
                                        style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.transportName ?? "",
                                            style: normalTextStyle),
                                        pw.Text(invoice.transportNumber ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : pw.SizedBox(),
                context.pageNumber == 1
                    ? pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.symmetric(
                          outside: const pw.BorderSide(),
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                    "Invoice No: ${invoice.billNo ?? ""}",
                                    textAlign: pw.TextAlign.left,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                    companyDoc.hsn != null &&
                                            companyDoc.hsn!.isNotEmpty &&
                                            companyDoc.hsn!["common_hsn"]
                                        ? "HSN : ${companyDoc.hsn!["common_hsn_value"]} / Date: ${DateFormat("dd-MM-yyyy").format(invoice.billDate!)}"
                                        : "Date: ${DateFormat("dd-MM-yyyy").format(invoice.billDate!)}",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      )
                    : pw.SizedBox(),
                pw.Table(
                  columnWidths: productColumnWidth,
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              "S.No",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              "Products",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              "Unit",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              "Qty",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              "Rate/Qty",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              "Amount (Rs)",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
          build: (pw.Context context) {
            List<pw.TableRow> pageContent = [];
            int totalSerialNumber = 1;
            var productList = sortEstimateProduct();

            for (int j = 0; j < productList.length; j++) {
              pageContent.add(
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: pf.PdfColors.grey300,
                  ),
                  children: [
                    pw.Container(),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                          productList[j].first.discountLock != null &&
                                  !productList[j].first.discountLock!
                              ? productList[j].first.discount != null
                                  ? "Discount: ${productList[j].first.discount}%"
                                  : "Net Rated Products"
                              : "Net Rated Products",
                          style: boldTextStyle),
                    ),
                    pw.Container(),
                    pw.Container(),
                    pw.Container(),
                    pw.Container(),
                  ],
                ),
              );
              for (var k = 0; k < productList[j].length; k++) {
                pageContent.add(
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text((totalSerialNumber++).toString(),
                              textAlign: pw.TextAlign.center,
                              style: normalTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          productList[j][k].productName!,
                          textAlign: pdfAlignment == 1
                              ? pw.TextAlign.left
                              : pdfAlignment == 2
                                  ? pw.TextAlign.right
                                  : pdfAlignment == 3
                                      ? pw.TextAlign.center
                                      : pw.TextAlign.left,
                          style: productText,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(productList[j][k].unit.toString(),
                              textAlign: pw.TextAlign.center,
                              style: normalTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(productList[j][k].qty.toString(),
                              textAlign: pw.TextAlign.center,
                              style: normalTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                              double.parse(productList[j][k].rate.toString())
                                  .toStringAsFixed(2),
                              textAlign: pw.TextAlign.center,
                              style: normalTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                            actualPrice(productList[j][k].qty!.toDouble(),
                                productList[j][k].rate!.toDouble()),
                            textAlign: pw.TextAlign.right,
                            style: normalTextStyle),
                      ),
                    ],
                  ),
                );
              }
              if (productList[j].first.discountLock != null &&
                  !productList[j].first.discountLock!) {
                if (productList[j].first.discount != null) {
                  pageContent.add(pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text("Sub Total",
                              textAlign: pw.TextAlign.center,
                              style: boldTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                            discountSubtotal(productList[j]).toStringAsFixed(2),
                            textAlign: pw.TextAlign.right,
                            style: boldTextStyle),
                      ),
                    ],
                  ));
                }
              }
              if (productList[j].first.discountLock != null &&
                  !productList[j].first.discountLock!) {
                if (productList[j].first.discount != null) {
                  pageContent.add(pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                              productList[j].first.discountLock != null &&
                                      !productList[j].first.discountLock!
                                  ? productList[j].first.discount != null
                                      ? "Discount ${productList[j].first.discount}%"
                                      : "NR"
                                  : "NR",
                              textAlign: pw.TextAlign.center,
                              style: boldTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                            discountGroupTotal(productList[j])
                                .toStringAsFixed(2),
                            textAlign: pw.TextAlign.right,
                            style: boldTextStyle),
                      ),
                    ],
                  ));
                }
              }
              pageContent.add(pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Container(),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Container(),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Container(),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Container(),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Center(
                      child: pw.Text("Total",
                          textAlign: pw.TextAlign.center, style: boldTextStyle),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                        groupTotal(productList[j]).toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: boldTextStyle),
                  ),
                ],
              ));
            }
            return [
              pw.Table(
                columnWidths: productColumnWidth,
                border: pw.TableBorder.all(),
                children: [
                  for (var m = data["pages_products_length"][i][0];
                      m <= data["pages_products_length"][i][1];
                      m++)
                    pageContent[m],
                ],
              ),
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.TableBorder.all(),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 41,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 157,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 94.5,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 94.5,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 94.5,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i + 1 == data["last_page"])
                pw.Container(
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      if (pdfType)
                        pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(1.3),
                            1: const pw.FlexColumnWidth(6),
                            2: const pw.FlexColumnWidth(2.5),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(3),
                            5: const pw.FlexColumnWidth(3),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text("",
                                        textAlign: pw.TextAlign.center,
                                        style: normalTextStyle),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                      "Goods Value Upto Previous Bill Rs.",
                                      textAlign: pw.TextAlign.right,
                                      style: normalTextStyle),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(total,
                                      textAlign: pw.TextAlign.right,
                                      style: normalTextStyle),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text("",
                                        textAlign: pw.TextAlign.center,
                                        style: normalTextStyle),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text("Goods Value for bill Rs.",
                                      textAlign: pw.TextAlign.right,
                                      style: normalTextStyle),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                      invoice.price?.total
                                              ?.toStringAsFixed(2) ??
                                          "",
                                      textAlign: pw.TextAlign.right,
                                      style: normalTextStyle),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text("",
                                        textAlign: pw.TextAlign.center,
                                        style: normalTextStyle),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text("Total Rs.",
                                      textAlign: pw.TextAlign.right,
                                      style: normalTextStyle),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                      (double.parse(total) +
                                              invoice.price!.total!)
                                          .toStringAsFixed(2),
                                      textAlign: pw.TextAlign.right,
                                      style: normalTextStyle),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                          ],
                        ),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(9.3),
                          1: const pw.FlexColumnWidth(3),
                          2: const pw.FlexColumnWidth(3),
                          3: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                        "Total Products (${invoice.listingProducts!.length})",
                                        textAlign: pw.TextAlign.left,
                                        style: boldTextStyle),
                                    pw.Text("Total QTY",
                                        textAlign: pw.TextAlign.right,
                                        style: boldTextStyle),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Center(
                                  child: pw.Text(totalQty(),
                                      textAlign: pw.TextAlign.center,
                                      style: boldTextStyle),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Net Total",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(netTotal().toStringAsFixed(2),
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      invoice.price?.extraDiscountValue != null &&
                              invoice.price!.extraDiscountValue! > 0.0
                          ? pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(15.3),
                                1: const pw.FlexColumnWidth(3),
                              },
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "Extra Discount(${(invoice.price!.extraDiscount)!.round()}${invoice.price!.extraDiscountsys})",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "- ${invoice.price?.extraDiscountValue?.toStringAsFixed(2)}",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : pw.SizedBox(),
                      invoice.price?.packageValue != null &&
                              invoice.price!.packageValue! > 0.0
                          ? pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(15.3),
                                1: const pw.FlexColumnWidth(3),
                              },
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "Packing Charges(${(invoice.price!.package)!.round()}${invoice.price!.packagesys})",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          invoice.price?.packageValue
                                                  ?.toStringAsFixed(2) ??
                                              "",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : pw.SizedBox(),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(15.3),
                          1: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Round Off",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                    invoice.price?.roundOff
                                            ?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(15.3),
                          1: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Total",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                    invoice.price?.total?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          1: const pw.FlexColumnWidth(18.3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.RichText(
                                  text: TextSpan(
                                    text: 'Amount in Words : ',
                                    style: boldTextStyle,
                                    children: [
                                      TextSpan(
                                        text:
                                            '${AmountToWords().convertAmountToWords(double.parse(invoice.price!.total!.toStringAsFixed(0)))} Only',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: pw.FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        // defaultVerticalAlignment:
                        //     pw.TableCellVerticalAlignment.bottom,
                        columnWidths: {
                          0: const pw.FlexColumnWidth(3),
                          1: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.symmetric(
                          outside: const pw.BorderSide(),
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      "Declaration",
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 9,
                                        decoration: pw.TextDecoration.underline,
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                      "We declare that this bill shows the actual price of the goods\ndescribed and that all particulars are true and correct\nComposition dealer is not eligible to collect the taxes on supply",
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Container(
                                  alignment: pw.Alignment.bottomCenter,
                                  child: pw.Text(
                                    "Authorised Signatory",
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ];
          },
        ),
      );
    }

    return await pdf.save();
  }

  Future<Uint8List> format2A4() async {
    var pdf = pw.Document();

    final companyLogo = companyDoc.companyLogo != null
        ? await networkImage(
            companyDoc.companyLogo!,
          )
        : null;

    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    final Map<int, TableColumnWidth> columnWidth = {
      0: const pw.FlexColumnWidth(1.3),
      1: const pw.FlexColumnWidth(6),
      2: const pw.FlexColumnWidth(2.5),
      3: const pw.FlexColumnWidth(2),
      4: const pw.FlexColumnWidth(3),
      5: const pw.FlexColumnWidth(3),
    };
    final bool commonHsn = companyDoc.hsn != null &&
        companyDoc.hsn!.isNotEmpty &&
        companyDoc.hsn!["common_hsn"];
    final String commonHsnValue = companyDoc.hsn!["common_hsn_value"];

    var docGstCode = companyDoc.gstno?.substring(0, 2);
    var gstState = gstCode[docGstCode];

    var boldTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8,
    );
    var normalTextStyle = const pw.TextStyle(
      fontSize: 8,
    );

    var productText = pw.TextStyle(
      fontSize: 8,
      font: roboto,
      fontFallback: [roboto, noto],
    );

    var data = serializeData();

    for (var i = 0; i < data["total_pages"]; i++) {
      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(10),
          pageFormat: PdfPageFormat.a4,
          footer: (context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 5, bottom: 3),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  if (i == data["total_pages"])
                    pw.Text(
                      "*** This is a Computer Generated bill. Hence Digital Signature is not required ***",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  pw.Text(
                    "Page ${i + 1}/${data["total_pages"]}",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            );
          },
          header: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.SizedBox(),
                    ),
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Text(
                          "Bill of Supply",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        title,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                  },
                  border:
                      pw.TableBorder.symmetric(outside: const pw.BorderSide()),
                  children: [
                    pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        pw.Padding(
                          padding:
                              const pw.EdgeInsets.symmetric(horizontal: 15),
                          child: pw.SizedBox(
                            height: 50,
                            width: 50,
                            child: companyLogo != null
                                ? pw.Image(companyLogo, width: 50, height: 50)
                                : pw.SizedBox(),
                          ),
                        ),
                        pw.Column(
                          children: [
                            pw.SizedBox(height: 5),
                            pw.Center(
                              child: pw.Text(
                                companyDoc.companyName ?? "",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Center(
                              child: pw.Text(companyDoc.address ?? "",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(companyDoc.city ?? "",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(
                                  "${companyDoc.state ?? ""} - ${companyDoc.pincode ?? ""}",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(
                                  "Phone No : ${companyDoc.contact!["mobile"]}, ${companyDoc.contact!["phone"]}",
                                  style: normalTextStyle),
                            ),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                        companyDoc.gstno != null && companyDoc.gstno!.isNotEmpty
                            ? pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(right: 5),
                                    child: pw.Text(
                                      "GST NO: ${companyDoc.gstno ?? ""}",
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(right: 5),
                                    child: pw.Text(
                                      "$docGstCode : $gstState",
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  pw.SizedBox(height: 15),
                                  pw.SizedBox(height: 15),
                                ],
                              )
                            : pw.SizedBox(),
                      ],
                    ),
                  ],
                ),
                context.pageNumber == 1
                    ? pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                          2: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child:
                                        pw.Text("Buyer", style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.partyName ?? "",
                                            style: boldTextStyle),
                                        pw.Text(invoice.address ?? "",
                                            style: normalTextStyle),
                                        pw.Text(
                                            "${invoice.city ?? ""}, ${invoice.state ?? ""}",
                                            style: normalTextStyle),
                                        pw.Text(invoice.phoneNumber ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text("Delivery Address",
                                        style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.deliveryaddress ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text("Transport Details",
                                        style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.transportName ?? "",
                                            style: normalTextStyle),
                                        pw.Text(invoice.transportNumber ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : pw.SizedBox(),
                context.pageNumber == 1
                    ? pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.symmetric(
                          outside: const pw.BorderSide(),
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                    "Invoice No: ${invoice.billNo ?? ""}",
                                    textAlign: pw.TextAlign.left,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                    companyDoc.hsn != null &&
                                            companyDoc.hsn!.isNotEmpty &&
                                            companyDoc.hsn!["common_hsn"]
                                        ? "HSN : ${companyDoc.hsn!["common_hsn_value"]} / Date: ${DateFormat("dd-MM-yyyy").format(invoice.billDate!)}"
                                        : "Date: ${DateFormat("dd-MM-yyyy").format(invoice.billDate!)}",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      )
                    : pw.SizedBox(),
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1.3),
                    1: const pw.FlexColumnWidth(6),
                    2: const pw.FlexColumnWidth(2.5),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(3),
                    5: const pw.FlexColumnWidth(3),
                  },
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("S.No",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Products",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Unit",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Qty",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Rate/Qty",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Amount",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
          build: (context) {
            List<pw.TableRow> pageContent = [];
            int totalSerialNumber = 1;
            var productList = sortEstimateProduct();
            for (int j = 0; j < productList.length; j++) {
              pageContent.add(pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: pf.PdfColors.grey300,
                ),
                children: [
                  pw.Container(
                    color: pf.PdfColors.grey500,
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                        productList[j].first.discountLock != null &&
                                !productList[j].first.discountLock!
                            ? productList[j].first.discount != null
                                ? "Discount: ${productList[j].first.discount}%"
                                : "Net Rated Products"
                            : "Net Rated Products",
                        style: boldTextStyle),
                  ),
                  pw.Container(color: pf.PdfColors.grey500),
                  pw.Container(color: pf.PdfColors.grey500),
                  pw.Container(color: pf.PdfColors.grey500),
                  pw.Container(color: pf.PdfColors.grey500),
                ],
              ));

              for (var k = 0; k < productList[j].length; k++) {
                pageContent.add(
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1.5),
                        child: pw.Center(
                          child: pw.Text(
                            (totalSerialNumber++).toString(),
                            textAlign: pw.TextAlign.center,
                            style: normalTextStyle,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1.5),
                        child: pw.Text("${productList[j][k].productName}",
                            textAlign: pdfAlignment == 1
                                ? pw.TextAlign.left
                                : pdfAlignment == 2
                                    ? pw.TextAlign.right
                                    : pdfAlignment == 3
                                        ? pw.TextAlign.center
                                        : pw.TextAlign.left,
                            style: productText),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1.5),
                        child: pw.Center(
                          child: pw.Text(productList[j][k].unit ?? '',
                              textAlign: pw.TextAlign.center,
                              style: normalTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1.5),
                        child: pw.Center(
                          child: pw.Text(productList[j][k].qty.toString(),
                              textAlign: pw.TextAlign.center,
                              style: normalTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1.5),
                        child: pw.Center(
                          child: pw.Text(
                              double.parse(
                                productList[j][k].rate.toString(),
                              ).toStringAsFixed(2),
                              textAlign: pw.TextAlign.center,
                              style: normalTextStyle),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(1.5),
                        child: pw.Text(
                            discount(
                              productList[j][k].qty!.toDouble(),
                              productList[j][k].rate!.toDouble(),
                              productList[j][k].discount,
                              productList[j][k].discountLock,
                            ),
                            textAlign: pw.TextAlign.right,
                            style: normalTextStyle),
                      ),
                    ],
                  ),
                );
              }
              pageContent.add(pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Center(
                      child: pw.Container(),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Center(
                      child: pw.Container(),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Container(),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Container(),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Center(
                      child: pw.Text("Total",
                          textAlign: pw.TextAlign.center, style: boldTextStyle),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Text(
                        groupTotal(productList[j]).toStringAsFixed(2),
                        textAlign: pw.TextAlign.right,
                        style: boldTextStyle),
                  ),
                ],
              ));
            }

            return [
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.3),
                  1: const pw.FlexColumnWidth(6),
                  2: const pw.FlexColumnWidth(2.5),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(3),
                  5: const pw.FlexColumnWidth(3),
                },
                border: pw.TableBorder.all(),
                children: [
                  for (var m = data["pages_products_length"][i][0];
                      m <= data["pages_products_length"][i][1];
                      m++)
                    pageContent[m],
                ],
              ),
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.TableBorder.all(),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 42,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 194,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 81,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 64.5,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 97,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i + 1 == data["last_page"])
                pw.Container(
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1.3),
                          1: const pw.FlexColumnWidth(6),
                          2: const pw.FlexColumnWidth(2.5),
                          3: const pw.FlexColumnWidth(2),
                          4: const pw.FlexColumnWidth(3),
                          5: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          if (pdfType)
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(
                                      "",
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Goods Value Upto Previous Bill Rs.",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    total,
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                          if (pdfType)
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(
                                      "",
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Goods Value for bill Rs.",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    invoice.price?.total?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                          if (pdfType)
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(
                                      "",
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Total Rs.",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    (double.parse(total) +
                                            invoice.price!.total!)
                                        .toStringAsFixed(2),
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(9.8),
                          1: const pw.FlexColumnWidth(2),
                          2: const pw.FlexColumnWidth(3),
                          3: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                        "Total Products (${invoice.listingProducts!.length})",
                                        textAlign: pw.TextAlign.left,
                                        style: boldTextStyle),
                                    pw.Text("Total QTY",
                                        textAlign: pw.TextAlign.right,
                                        style: boldTextStyle),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Center(
                                  child: pw.Text(totalQty(),
                                      textAlign: pw.TextAlign.center,
                                      style: boldTextStyle),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Net Total",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(netTotal().toStringAsFixed(2),
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(14.8),
                          1: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Discounted Products Total",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                    overallDiscountTotal().toStringAsFixed(2),
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      invoice.price?.extraDiscountValue != null &&
                              invoice.price!.extraDiscountValue! > 0.0
                          ? pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(14.8),
                                1: const pw.FlexColumnWidth(3),
                              },
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "Extra Discount(${(invoice.price!.extraDiscount)!.round()}${invoice.price!.extraDiscountsys})",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "- ${invoice.price?.extraDiscountValue?.toStringAsFixed(2)}",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : pw.SizedBox(),
                      invoice.price?.packageValue != null &&
                              invoice.price!.packageValue! > 0.0
                          ? pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(14.8),
                                1: const pw.FlexColumnWidth(3),
                              },
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "Packing Charges(${(invoice.price!.package)!.round()}${invoice.price!.packagesys})",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          invoice.price?.packageValue
                                                  ?.toStringAsFixed(2) ??
                                              "",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : pw.SizedBox(),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(14.8),
                          1: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Round Off",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                    invoice.price?.roundOff
                                            ?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(14.8),
                          1: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Total",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                    invoice.price?.total?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          1: const pw.FlexColumnWidth(14.5),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.RichText(
                                  text: TextSpan(
                                    text: 'Amount in Words : ',
                                    style: boldTextStyle,
                                    children: [
                                      TextSpan(
                                        text:
                                            '${AmountToWords().convertAmountToWords(double.parse(invoice.price!.total!.toStringAsFixed(0)))} Only',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: pw.FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        // defaultVerticalAlignment:
                        //     pw.TableCellVerticalAlignment.bottom,
                        columnWidths: {
                          0: const pw.FlexColumnWidth(3),
                          1: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.symmetric(
                          outside: const pw.BorderSide(),
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      "Declaration",
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 9,
                                        decoration: pw.TextDecoration.underline,
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                      "We declare that this bill shows the actual price of the goods\ndescribed and that all particulars are true and correct\nComposition dealer is not eligible to collect the taxes on supply",
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Container(
                                  alignment: pw.Alignment.bottomCenter,
                                  child: pw.Text(
                                    "Authorised Signatory",
                                    textAlign: pw.TextAlign.center,
                                    style: const pw.TextStyle(
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ];
          },
        ),
      );
    }

    return await pdf.save();
  }

  Future<Uint8List> format3A4() async {
    var pdf = pw.Document();

    final companyLogo = companyDoc.companyLogo != null
        ? await networkImage(
            companyDoc.companyLogo!,
          )
        : null;

    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    final bool commonHsn = companyDoc.hsn != null &&
        companyDoc.hsn!.isNotEmpty &&
        companyDoc.hsn!["common_hsn"];
    final String commonHsnValue = companyDoc.hsn!["common_hsn_value"];

    Map<int, TableColumnWidth> productColumnWidth = {
      0: const pw.FlexColumnWidth(1.3),
      1: const pw.FlexColumnWidth(6),
      2: const pw.FlexColumnWidth(2.25),
      3: const pw.FlexColumnWidth(2.25),
      4: const pw.FlexColumnWidth(2),
      5: const pw.FlexColumnWidth(2),
      6: const pw.FlexColumnWidth(3),
    };

    var docGstCode = companyDoc.gstno?.substring(0, 2);
    var gstState = gstCode[docGstCode];

    var boldTextStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 8,
    );
    var normalTextStyle = const pw.TextStyle(
      fontSize: 8,
    );
    var productText = pw.TextStyle(
      fontSize: 8,
      font: roboto,
      fontFallback: [roboto, noto],
    );

    var data = serializeData();
    for (var i = 0; i < data["total_pages"]; i++) {
      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(10),
          pageFormat: PdfPageFormat.a4,
          footer: (context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 5, bottom: 3),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  if (i == data["total_pages"])
                    pw.Text(
                      "*** This is a Computer Generated bill. Hence Digital Signature is not required ***",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  pw.Text(
                    "Page ${i + 1}/${data["total_pages"]}",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            );
          },
          header: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.SizedBox(),
                    ),
                    pw.Expanded(
                      child: pw.Center(
                        child: pw.Text(
                          "Bill of Supply",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        title,
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                  },
                  border:
                      pw.TableBorder.symmetric(outside: const pw.BorderSide()),
                  children: [
                    pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      children: [
                        pw.Padding(
                          padding:
                              const pw.EdgeInsets.symmetric(horizontal: 15),
                          child: pw.SizedBox(
                            height: 50,
                            width: 50,
                            child: companyLogo != null
                                ? pw.Image(companyLogo, width: 50, height: 50)
                                : pw.SizedBox(),
                          ),
                        ),
                        pw.Column(
                          children: [
                            pw.SizedBox(height: 5),
                            pw.Center(
                              child: pw.Text(
                                companyDoc.companyName ?? "",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Center(
                              child: pw.Text(companyDoc.address ?? "",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(companyDoc.city ?? "",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(
                                  "${companyDoc.state ?? ""} - ${companyDoc.pincode ?? ""}",
                                  style: normalTextStyle),
                            ),
                            pw.Center(
                              child: pw.Text(
                                  "Phone No : ${companyDoc.contact!["mobile"]}, ${companyDoc.contact!["phone"]}",
                                  style: normalTextStyle),
                            ),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                        companyDoc.gstno != null && companyDoc.gstno!.isNotEmpty
                            ? pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(right: 5),
                                    child: pw.Text(
                                      "GST NO: ${companyDoc.gstno ?? ""}",
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(right: 5),
                                    child: pw.Text(
                                      "$docGstCode : $gstState",
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                  pw.SizedBox(height: 15),
                                  pw.SizedBox(height: 15),
                                ],
                              )
                            : pw.SizedBox(),
                      ],
                    ),
                  ],
                ),
                context.pageNumber == 1
                    ? pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                          2: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child:
                                        pw.Text("Buyer", style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.partyName ?? "",
                                            style: boldTextStyle),
                                        pw.Text(invoice.address ?? "",
                                            style: normalTextStyle),
                                        pw.Text(
                                            "${invoice.city ?? ""}, ${invoice.state ?? ""}",
                                            style: normalTextStyle),
                                        pw.Text(invoice.phoneNumber ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text("Delivery Address",
                                        style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.deliveryaddress ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text("Transport Details",
                                        style: boldTextStyle),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                        left: 15, bottom: 10),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(invoice.transportName ?? "",
                                            style: normalTextStyle),
                                        pw.Text(invoice.transportNumber ?? "",
                                            style: normalTextStyle),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : pw.SizedBox(),
                context.pageNumber == 1
                    ? pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1),
                          1: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.symmetric(
                          outside: const pw.BorderSide(),
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                    "Invoice No: ${invoice.billNo ?? ""}",
                                    textAlign: pw.TextAlign.left,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                    companyDoc.hsn != null &&
                                            companyDoc.hsn!.isNotEmpty &&
                                            companyDoc.hsn!["common_hsn"]
                                        ? "HSN : ${companyDoc.hsn!["common_hsn_value"]} / Date: ${DateFormat("dd-MM-yyyy").format(invoice.billDate!)}"
                                        : "Date: ${DateFormat("dd-MM-yyyy").format(invoice.billDate!)}",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      )
                    : pw.SizedBox(),
                pw.Table(
                  columnWidths: productColumnWidth,
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("S.No",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Products",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Qty",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Rate/\nQty",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Before\nDiscount",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Discounted\nAmount",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text("Amount",
                                textAlign: pw.TextAlign.center,
                                style: boldTextStyle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
          build: (pw.Context context) {
            List<pw.TableRow> pageContent = [];
            int totalSerialNumber = 1;
            var productList = sortEstimateProduct();

            for (int j = 0; j < productList.length; j++) {
              pageContent.add(
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: pf.PdfColors.grey300,
                  ),
                  children: [
                    pw.Container(),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                          productList[j].first.discountLock != null &&
                                  !productList[j].first.discountLock!
                              ? productList[j].first.discount != null
                                  ? "Discount: ${productList[j].first.discount}%"
                                  : "Net Rated Products"
                              : "Net Rated Products",
                          style: boldTextStyle),
                    ),
                    pw.Container(),
                    pw.Container(),
                    pw.Container(),
                    pw.Container(),
                  ],
                ),
              );
              for (var k = 0; k < productList[j].length; k++) {
                pageContent.add(pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Center(
                        child: pw.Text((totalSerialNumber++).toString(),
                            textAlign: pw.TextAlign.center,
                            style: normalTextStyle),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text("${productList[j][k].productName}",
                          textAlign: pdfAlignment == 1
                              ? pw.TextAlign.left
                              : pdfAlignment == 2
                                  ? pw.TextAlign.right
                                  : pdfAlignment == 3
                                      ? pw.TextAlign.center
                                      : pw.TextAlign.left,
                          style: productText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Center(
                        child: pw.Text(productList[j][k].qty.toString(),
                            textAlign: pw.TextAlign.center,
                            style: normalTextStyle),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Center(
                        child: pw.Text(
                            double.parse(productList[j][k].rate.toString())
                                .toStringAsFixed(2),
                            textAlign: pw.TextAlign.center,
                            style: normalTextStyle),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Center(
                        child: pw.Text(
                            (productList[j][k].rate! * productList[j][k].qty!)
                                .toStringAsFixed(2),
                            textAlign: pw.TextAlign.center,
                            style: normalTextStyle),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Center(
                        child: pw.Text(
                            afterDiscount(
                              productList[j][k].qty!.toDouble(),
                              productList[j][k].rate!.toDouble(),
                              productList[j][k].discount,
                              productList[j][k].discountLock,
                            ),
                            textAlign: pw.TextAlign.center,
                            style: normalTextStyle),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                          discount(
                            productList[j][k].qty!.toDouble(),
                            productList[j][k].rate!.toDouble(),
                            productList[j][k].discount,
                            productList[j][k].discountLock,
                          ),
                          textAlign: pw.TextAlign.right,
                          style: normalTextStyle),
                    ),
                  ],
                ));
              }

              pageContent.add(
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Container(),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Container(),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Container(),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Center(
                        child: pw.Text("Total",
                            textAlign: pw.TextAlign.center,
                            style: boldTextStyle),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                          beforeDiscountTotal(productList[j])
                              .toStringAsFixed(2),
                          textAlign: pw.TextAlign.center,
                          style: boldTextStyle),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                          afterDiscountTotal(productList[j]).toStringAsFixed(2),
                          textAlign: pw.TextAlign.center,
                          style: boldTextStyle),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                          groupTotal(productList[j]).toStringAsFixed(2),
                          textAlign: pw.TextAlign.right,
                          style: boldTextStyle),
                    ),
                  ],
                ),
              );
            }

            return [
              pw.Table(
                columnWidths: productColumnWidth,
                border: pw.TableBorder.all(),
                children: [
                  for (var m = data["pages_products_length"][i][0];
                      m <= data["pages_products_length"][i][1];
                      m++)
                    pageContent[m],
                ],
              ),
              pw.Expanded(
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.TableBorder.all(),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 40,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 183,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 69.5,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 68,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 62,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 61,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i + 1 == data["last_page"])
                pw.Container(
                  child: pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      if (pdfType)
                        pw.Table(
                          columnWidths: {
                            0: const pw.FlexColumnWidth(1.3),
                            1: const pw.FlexColumnWidth(6),
                            2: const pw.FlexColumnWidth(2.5),
                            3: const pw.FlexColumnWidth(2),
                            4: const pw.FlexColumnWidth(3),
                            5: const pw.FlexColumnWidth(3),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(
                                      "",
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Goods Value Upto Previous Bill Rs.",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    total,
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(
                                      "",
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Goods Value for bill Rs.",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    invoice.price?.total?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(
                                      "",
                                      textAlign: pw.TextAlign.center,
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "Total Rs.",
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    (double.parse(total) +
                                            invoice.price!.total!)
                                        .toStringAsFixed(2),
                                    textAlign: pw.TextAlign.right,
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Center(
                                    child: pw.Text(""),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(""),
                                ),
                              ],
                            ),
                          ],
                        ),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(7.3),
                          1: const pw.FlexColumnWidth(2.25),
                          2: const pw.FlexColumnWidth(6.25),
                          3: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                        "Total Products (${invoice.listingProducts!.length})",
                                        textAlign: pw.TextAlign.left,
                                        style: boldTextStyle),
                                    pw.Text("Total QTY",
                                        textAlign: pw.TextAlign.right,
                                        style: boldTextStyle),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Center(
                                  child: pw.Text(totalQty(),
                                      textAlign: pw.TextAlign.center,
                                      style: boldTextStyle),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Net Total",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(netTotal().toStringAsFixed(2),
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      invoice.price?.extraDiscountValue != null &&
                              invoice.price!.extraDiscountValue! > 0.0
                          ? pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(15.8),
                                1: const pw.FlexColumnWidth(3),
                              },
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "Extra Discount(${(invoice.price!.extraDiscount)!.round()}${invoice.price!.extraDiscountsys})",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "- ${invoice.price?.extraDiscountValue?.toStringAsFixed(2)}",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : pw.SizedBox(),
                      invoice.price?.packageValue != null &&
                              invoice.price!.packageValue! > 0.0
                          ? pw.Table(
                              columnWidths: {
                                0: const pw.FlexColumnWidth(15.8),
                                1: const pw.FlexColumnWidth(3),
                              },
                              border: pw.TableBorder.all(),
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          "Packing Charges(${(invoice.price!.package)!.round()}${invoice.price!.packagesys})",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(3),
                                      child: pw.Text(
                                          invoice.price?.packageValue
                                                  ?.toStringAsFixed(2) ??
                                              "",
                                          textAlign: pw.TextAlign.right,
                                          style: boldTextStyle),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : pw.SizedBox(),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(15.8),
                          1: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Round Off",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                    invoice.price?.roundOff
                                            ?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          0: const pw.FlexColumnWidth(15.8),
                          1: const pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text("Total",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text(
                                    invoice.price?.total?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: boldTextStyle),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        columnWidths: {
                          1: const pw.FlexColumnWidth(14.5),
                        },
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.RichText(
                                  text: TextSpan(
                                    text: 'Amount in Words : ',
                                    style: boldTextStyle,
                                    children: [
                                      TextSpan(
                                        text:
                                            '${AmountToWords().convertAmountToWords(double.parse(invoice.price!.total!.toStringAsFixed(0)))} Only',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: pw.FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Table(
                        // defaultVerticalAlignment:
                        //     pw.TableCellVerticalAlignment.bottom,
                        columnWidths: {
                          0: const pw.FlexColumnWidth(3),
                          1: const pw.FlexColumnWidth(1),
                        },
                        border: pw.TableBorder.symmetric(
                          outside: const pw.BorderSide(),
                        ),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      "Declaration",
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8,
                                        decoration: pw.TextDecoration.underline,
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                        "We declare that this bill shows the actual price of the goods\ndescribed and that all particulars are true and correct\nComposition dealer is not eligible to collect the taxes on supply",
                                        style: normalTextStyle),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Container(
                                  alignment: pw.Alignment.bottomCenter,
                                  child: pw.Text("Authorised Signatory",
                                      textAlign: pw.TextAlign.center,
                                      style: normalTextStyle),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ];
          },
        ),
      );
    }

    return await pdf.save();
  }

//************** PDF Functions **********************/

  int getFooterCount() {
    int footerCount = 0;
    if (invoice.price!.extraDiscount != null) {
      if (invoice.price!.extraDiscountValue != null) {
        footerCount += 1;
      }
    }
    if (invoice.price!.package != null) {
      if (invoice.price!.packageValue != null) {
        footerCount += 1;
      }
    }

    footerCount += 3;
    return footerCount;
  }

  Map<String, dynamic> serializeData() {
    int totalLength = 0;
    int totalProducts = 0;
    int footerLength = 0;

    totalLength = sortEstimateProduct().length * 2;
    totalProducts = sortEstimateProduct().length * 2;
    totalLength += getFooterCount();
    footerLength = getFooterCount();

    for (int i = 0; i < sortEstimateProduct().length; i++) {
      totalProducts += sortEstimateProduct()[i].length;
      totalLength += sortEstimateProduct()[i].length;
    }

    int totalLengthPerPage = 43;

    int totalPages = (totalLength / totalLengthPerPage).ceil();
    List<int> pagesProducts = [];
    int remainingProducts = totalProducts;

    int productsPerPage = 49;
    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      if (remainingProducts > productsPerPage) {
        pagesProducts.add(productsPerPage);
        remainingProducts -= productsPerPage;
      } else {
        pagesProducts.add(remainingProducts);
        remainingProducts = 0;
      }
    }

    List<List<int>> pagesProductsLength = [];
    int startIndex = 0;

    for (int count in pagesProducts) {
      int endIndex = startIndex + count - 1;
      pagesProductsLength.add([startIndex, endIndex]);
      startIndex = endIndex + 1;
    }

    int lastPageCount = footerLength + pagesProducts.last;
    bool footerView = false;
    if (lastPageCount > 36) {
      footerView = false;
    } else if (pagesProducts.last > 20) {
      footerView = false;
    } else {
      footerView = true;
    }

    return {
      "total_pages": totalPages,
      "total_length": totalLength,
      "total_products": totalProducts,
      "pages_products": pagesProducts,
      "pages_products_length": pagesProductsLength,
      "footer_view": footerView,
      "last_page": pagesProducts.length,
    };
  }

  Map<String, dynamic> serializeDataFormat1() {
    int totalLength = 0;
    int totalProducts = 0;
    int footerLength = 0;

    var productList = sortEstimateProduct();

    if (productList.last.first.productType == ProductType.netRated) {
      totalLength = ((productList.length - 1) * 4) + 2;
      totalProducts = ((productList.length - 1) * 4) + 2;
    } else {
      totalLength = productList.length * 4;
      totalProducts = productList.length * 4;
    }

    totalLength += getFooterCount();
    footerLength = getFooterCount();

    for (int i = 0; i < productList.length; i++) {
      totalProducts += productList[i].length;
      totalLength += productList[i].length;
    }

    int totalLengthPerPage = 36;

    int totalPages = (totalLength / totalLengthPerPage).ceil();

    List<int> pagesProducts = [];
    int remainingProducts = totalProducts;

    int productsPerPage = 36;
    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      if (remainingProducts > productsPerPage) {
        pagesProducts.add(productsPerPage);
        remainingProducts -= productsPerPage;
      } else {
        pagesProducts.add(remainingProducts);
        remainingProducts = 0;
      }
    }

    List<List<int>> pagesProductsLength = [];
    int startIndex = 0;

    for (int count in pagesProducts) {
      int endIndex = startIndex + count - 1;
      pagesProductsLength.add([startIndex, endIndex]);
      startIndex = endIndex + 1;
    }

    int lastPageCount = footerLength + pagesProducts.last;
    bool footerView = false;
    if (lastPageCount > 36) {
      footerView = false;
    } else if (pagesProducts.last > 20) {
      footerView = false;
    } else {
      footerView = true;
    }

    return {
      "total_pages": totalPages,
      "total_length": totalLength,
      "total_products": totalProducts,
      "pages_products": pagesProducts,
      "pages_products_length": pagesProductsLength,
      "footer_view": footerView,
      "last_page": pagesProducts.length,
    };
  }

  //************** Product Sorting **********************/
  List<List<InvoiceProductModel>> sortEstimateProduct() {
    List<InvoiceProductModel> netRatedProducts = [];
    List<List<InvoiceProductModel>> discountGroups = [];

    if (invoice.listingProducts != null) {
      for (var product in invoice.listingProducts!) {
        if (product.discountLock != null && !product.discountLock!) {
          if (product.discount != null) {
            bool groupExists = false;
            for (var group in discountGroups) {
              if (group.isNotEmpty && group[0].discount == product.discount) {
                group.add(product);
                groupExists = true;
                break;
              }
            }

            if (!groupExists) {
              discountGroups.add([product]);
            }
          } else {
            netRatedProducts.add(product);
          }
        } else {
          netRatedProducts.add(product);
        }
      }
    }

    discountGroups.add(netRatedProducts);

    return discountGroups;
  }

  //************** Calculations **********************/

  String totalQty() {
    String total = "0";
    int count = 0;
    for (var element in invoice.listingProducts!) {
      count += element.qty!;
    }
    total = count.toString();
    return total;
  }

  String subTotal() {
    String total = "0.00";
    double count = 0.00;
    for (var element in invoice.listingProducts!) {
      count += element.total!;
    }
    total = count.toStringAsFixed(2);
    return total;
  }

  String discount(double qty, double price, int? discount, bool? discountLock) {
    if (discountLock != null && !discountLock) {
      if (discount != null) {
        double totalPrice = qty * price;
        double discountAmount = totalPrice * (discount / 100);
        double finalPrice = totalPrice - discountAmount;
        return finalPrice.toStringAsFixed(2);
      } else {
        double totalPrice = qty * price;
        double finalPrice = totalPrice;
        return finalPrice.toStringAsFixed(2);
      }
    } else {
      double totalPrice = qty * price;
      double finalPrice = totalPrice;
      return finalPrice.toStringAsFixed(2);
    }
  }

  double groupTotal(List<InvoiceProductModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      double totalPrice = product.qty! * product.rate!;
      if (product.discountLock != null && !product.discountLock!) {
        if (product.discount != null) {
          double discountAmount = totalPrice * (product.discount! / 100);
          double finalPrice = totalPrice - discountAmount;
          overallTotal += finalPrice;
        } else {
          overallTotal += totalPrice;
        }
      } else {
        overallTotal += totalPrice;
      }
    }
    return overallTotal;
  }

  double overallDiscountTotal() {
    double overallTotal = 0;
    for (var productList in sortEstimateProduct()) {
      if (productList.first.discountLock != null &&
          !productList.first.discountLock!) {
        if (productList.first.discount != null) {
          for (var product in productList) {
            double totalPrice = product.qty! * product.rate!;
            double discountAmount = totalPrice * (product.discount! / 100);
            double finalPrice = totalPrice - discountAmount;
            overallTotal += finalPrice;
          }
        }
      }
    }
    return overallTotal;
  }

  double overallNetRatedTotal() {
    double overallTotal = 0;
    for (var product in sortEstimateProduct().last) {
      double totalPrice = product.qty! * product.rate!;
      if (product.discountLock != null && product.discountLock!) {
        overallTotal += totalPrice;
      } else {
        if (product.discount == null) {
          overallTotal += totalPrice;
        }
      }
    }
    return overallTotal;
  }

  double discountGroupTotal(List<InvoiceProductModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      double totalPrice = product.qty! * product.rate!;
      if (product.discountLock != null && !product.discountLock!) {
        if (product.discount != null) {
          double discountAmount = totalPrice * (product.discount! / 100);
          overallTotal += discountAmount;
        } else {
          overallTotal += totalPrice;
        }
      } else {
        overallTotal += totalPrice;
      }
    }
    return overallTotal;
  }

  String actualPrice(double qty, double price) {
    double totalPrice = qty * price;
    double finalPrice = totalPrice;
    return finalPrice.toStringAsFixed(2);
  }

  double discountSubtotal(List<InvoiceProductModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      double totalPrice = product.qty! * product.rate!;
      overallTotal += totalPrice;
    }
    return overallTotal;
  }

  double beforeDiscountTotal(List<InvoiceProductModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      double totalPrice = product.qty! * product.rate!;
      overallTotal += totalPrice;
    }
    return overallTotal;
  }

  double netTotal() {
    var total = overallDiscountTotal() + overallNetRatedTotal();
    return total;
  }

  double afterDiscountTotal(List<InvoiceProductModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      overallTotal += double.parse(afterDiscount(product.qty!.toDouble(),
          product.rate!, product.discount, product.discountLock));
    }
    return overallTotal;
  }

  String afterDiscount(
      double qty, double price, int? discount, bool? discountLock) {
    if (discountLock != null && !discountLock) {
      if (discount != null) {
        double totalPrice = qty * price;
        double discountAmount = totalPrice * (discount / 100);
        double finalPrice = discountAmount;
        return finalPrice.toStringAsFixed(2);
      } else {
        double totalPrice = qty * price;
        double finalPrice = totalPrice;
        return finalPrice.toStringAsFixed(2);
      }
    } else {
      double totalPrice = qty * price;
      double finalPrice = totalPrice;
      return finalPrice.toStringAsFixed(2);
    }
  }
}
