import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '/view/screens/screens.dart';
import '/model/model.dart';
import 'package:pdf/pdf.dart' as pf;

class InvoicePDFService {
  final String title;
  final InvoiceModel invoice;
  final String total;
  final ProfileModel companyDoc;
  final bool pdfType;
  final int pdfAlignment;
  InvoicePDFService(
      {required this.title,
      required this.invoice,
      required this.total,
      required this.companyDoc,
      required this.pdfType,
      required this.pdfAlignment});

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

  Future<Uint8List> showA4PDf() async {
    var pdf = pw.Document();

    final companyLogo = companyDoc.companyLogo != null
        ? await networkImage(
            companyDoc.companyLogo!,
          )
        : null;

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 5, bottom: 3),
            child: pw.Center(
              child: pw.Text(
                "Page ${context.pageNumber}/${context.pagesCount}",
                style: const pw.TextStyle(fontSize: 8),
              ),
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
                          fontSize: 10,
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
                        fontSize: 10,
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
                        padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                        child: pw.SizedBox(
                          height: 50,
                          width: 50,
                          child: companyLogo != null
                              ? pw.Image(companyLogo)
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
                                fontSize: 11,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyDoc.address ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              companyDoc.city ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              "${companyDoc.state ?? ""} - ${companyDoc.pincode ?? ""}",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              "${companyDoc.contact!["mobile"]} ${companyDoc.contact!["phone"]}",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                          companyDoc.gstno != null &&
                                  companyDoc.gstno!.isNotEmpty
                              ? pw.Center(
                                  child: pw.Text(
                                    "GST NO: ${companyDoc.gstno ?? ""}",
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : pw.SizedBox(),
                          pw.SizedBox(height: 5),
                        ],
                      ),
                      pw.SizedBox(),
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
                                  child: pw.Text(
                                    "Buyer",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      left: 15, bottom: 10),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        invoice.partyName ?? "",
                                        style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                      pw.Text(
                                        invoice.address ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      pw.Text(
                                        invoice.phoneNumber ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
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
                                  child: pw.Text(
                                    "Delivery Address",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      left: 15, bottom: 10),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        invoice.deliveryaddress ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
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
                                  child: pw.Text(
                                    "Transport Details",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      left: 15, bottom: 10),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        invoice.transportName ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      pw.Text(
                                        invoice.transportNumber ?? "",
                                        style: const pw.TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
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
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                companyDoc.hsn != null &&
                                        companyDoc.hsn!.isNotEmpty &&
                                        companyDoc.hsn!["common_hsn"]
                                    ? "HSN : ${companyDoc.hsn!["common_hsn_value"]} / Date: ${DateFormat("dd-MM-yyyy").format(invoice.biilDate!)}"
                                    : "Date: ${DateFormat("dd-MM-yyyy").format(invoice.biilDate!)}",
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
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
                          child: pw.Text(
                            "S.NO",
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
                            "PRODUCTS",
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
                            "UNIT",
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
                            "QTY",
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
                            "RATE/QTY",
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
                            "AMOUNT",
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
          int totalSerialNumber = 1;

          return [
            for (int i = 0; i < sortEstimateProduct().length; i++)
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
                          sortEstimateProduct()[i].first.discountLock != null &&
                                  !sortEstimateProduct()[i].first.discountLock!
                              ? sortEstimateProduct()[i].first.discount != null
                                  ? "Discount: ${sortEstimateProduct()[i].first.discount}%"
                                  : "Net Rated Products"
                              : "Net Rated Products",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Container(color: pf.PdfColors.grey500),
                      pw.Container(color: pf.PdfColors.grey500),
                      pw.Container(color: pf.PdfColors.grey500),
                      pw.Container(color: pf.PdfColors.grey500),
                    ],
                  ),
                  for (var j = 0; j < sortEstimateProduct()[i].length; j++)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              (totalSerialNumber++).toString(),
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
                            "${sortEstimateProduct()[i][j].productName}",
                            textAlign: pdfAlignment == 1
                                ? pw.TextAlign.left
                                : pdfAlignment == 2
                                    ? pw.TextAlign.right
                                    : pdfAlignment == 3
                                        ? pw.TextAlign.center
                                        : pw.TextAlign.left,
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j].unit ?? '',
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j].qty.toString(),
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              double.parse(
                                sortEstimateProduct()[i][j].rate.toString(),
                              ).toStringAsFixed(2),
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
                            discount(
                              sortEstimateProduct()[i][j].qty!.toDouble(),
                              sortEstimateProduct()[i][j].rate!.toDouble(),
                              sortEstimateProduct()[i][j].discount,
                              sortEstimateProduct()[i][j].discountLock,
                            ),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Container(),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Container(),
                        ),
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
                            "Total",
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
                        child: pw.Text(
                          groupTotal(sortEstimateProduct()[i])
                              .toStringAsFixed(2),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            // pw.Table(
            //   defaultVerticalAlignment: pw.TableCellVerticalAlignment.full,
            //   columnWidths: {
            //     0: const pw.FlexColumnWidth(1.3),
            //     1: const pw.FlexColumnWidth(6),
            //     2: const pw.FlexColumnWidth(2.5),
            //     3: const pw.FlexColumnWidth(2),
            //     4: const pw.FlexColumnWidth(3),
            //     5: const pw.FlexColumnWidth(3),
            //   },
            //   border: pw.TableBorder.all(),
            //   children: [
            //     pw.TableRow(
            //       children: [
            //         pw.Container(
            //           child: pw.Column(mainAxisSize: pw.MainAxisSize.max),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //         pw.Container(
            //           child: pw.Expanded(
            //             child: pw.SizedBox(),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // pw.Table(
            //   border: pw.TableBorder.all(),
            //   children: [
            //     pw.TableRow(
            //       children: [
            //         pw.Container(
            //           height: 50,
            //         ),
            //         pw.Container(
            //           height: 50,
            //         ),
            //         pw.Container(
            //           height: 50,
            //         ),
            //         // ...add other children here
            //       ],
            //     ),
            //   ],
            // ),

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
                      width: 80.7,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 64.7,
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
                                invoice.price?.total?.toStringAsFixed(2) ?? "",
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
                                (double.parse(total) + invoice.price!.total!)
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
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                pw.Text(
                                  "Total QTY",
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Center(
                              child: pw.Text(
                                totalQty(),
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
                            child: pw.Text(
                              "Net Rated Total",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              overallNetRatedTotal().toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  invoice.price?.discountValue != null &&
                          invoice.price!.discountValue! > 0.0
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
                                    "Discounted Products Total",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    overallDiscountTotal().toStringAsFixed(2),
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
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
                            child: pw.Text(
                              "Sub Total",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              (overallNetRatedTotal() + overallDiscountTotal())
                                  .toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
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
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    invoice.price?.extraDiscountValue
                                            ?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
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
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    invoice.price?.packageValue
                                            ?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
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
                            child: pw.Text(
                              "Round Off",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              invoice.price?.roundOff?.toStringAsFixed(2) ?? "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
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
                            child: pw.Text(
                              "Total",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              invoice.price?.total?.toStringAsFixed(2) ?? "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.1),
                      1: const pw.FlexColumnWidth(5),
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "Amount(in Words)",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              // NumberToWordsEnglish.convert(int.parse(double.parse(subTotal()).toStringAsFixed(0)))
                              //     .toString(),
                              // NumberToWordsEnglish.convert(114000),
                              AmountToWords().convertAmountToWords(double.parse(
                                  invoice.price!.total!.toStringAsFixed(0))),
                              // NumberToWordConverter.convert(number: 100000),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Table(
                    defaultVerticalAlignment:
                        pw.TableCellVerticalAlignment.bottom,
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
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
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

    return await pdf.save();
  }
}
