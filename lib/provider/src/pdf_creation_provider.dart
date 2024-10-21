import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pf;
import 'package:pdf/widgets.dart' as pw;
import '/constants/constants.dart';
import '/model/model.dart';

class EnquiryPdf {
  final EstimateDataModel estimateData;
  final PdfType type;
  final ProfileModel companyInfo;
  final int pdfAlignment;
  EnquiryPdf(
      {required this.estimateData,
      required this.type,
      required this.companyInfo,
      required this.pdfAlignment});

  List<List<ProductDataModel>> sortEstimateProduct() {
    List<ProductDataModel> netRatedProducts = [];
    List<List<ProductDataModel>> discountGroups = [];

    if (estimateData.products != null) {
      for (var product in estimateData.products!) {
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

    // Add netRatedProducts only if it contains items
    if (netRatedProducts.isNotEmpty) {
      discountGroups.add(netRatedProducts);
    }

    return sortProductsInGroup(discountGroups);
  }

  List<List<ProductDataModel>> sortProductsInGroup(
      List<List<ProductDataModel>> totalProductList) {
    for (var productList in totalProductList) {
      productList.sort((a, b) =>
          compareProductCodes(a.productCode ?? '', b.productCode ?? ''));
    }
    return totalProductList;
  }

  int compareProductCodes(String codeA, String codeB) {
    final regex = RegExp(r'(\d+|\D+)');
    final matchesA = regex.allMatches(codeA).map((m) => m.group(0)!);
    final matchesB = regex.allMatches(codeB).map((m) => m.group(0)!);

    final iteratorA = matchesA.iterator;
    final iteratorB = matchesB.iterator;

    while (iteratorA.moveNext() && iteratorB.moveNext()) {
      final partA = iteratorA.current;
      final partB = iteratorB.current;

      if (isNumeric(partA) && isNumeric(partB)) {
        final numA = int.parse(partA);
        final numB = int.parse(partB);
        if (numA != numB) {
          return numA.compareTo(numB);
        }
      } else {
        final comparison = partA.compareTo(partB);
        if (comparison != 0) {
          return comparison;
        }
      }
    }

    return matchesA.length.compareTo(matchesB.length);
  }

  bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  String actualPrice(double qty, double price) {
    double totalPrice = qty * price;
    double finalPrice = totalPrice;
    return finalPrice.toStringAsFixed(2);
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

  String totalQty() {
    String total = "0";
    int count = 0;
    for (var element in estimateData.products!) {
      count += element.qty!;
    }
    total = count.toString();
    return total;
  }

  String subTotal() {
    return estimateData.price!.subTotal.toString();
  }

  double groupTotal(List<ProductDataModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      double totalPrice = product.qty! * product.price!;
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

  double beforeDiscountTotal(List<ProductDataModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      double totalPrice = product.qty! * product.price!;
      overallTotal += totalPrice;
    }
    return overallTotal;
  }

  double afterDiscountTotal(List<ProductDataModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      overallTotal += double.parse(afterDiscount(product.qty!.toDouble(),
          product.price!, product.discount, product.discountLock));
    }
    return overallTotal;
  }

  double discountGroupTotal(List<ProductDataModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      double totalPrice = product.qty! * product.price!;
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

  double discountSubtotal(List<ProductDataModel> products) {
    double overallTotal = 0;
    for (var product in products) {
      double totalPrice = product.qty! * product.price!;
      overallTotal += totalPrice;
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
            double totalPrice = product.qty! * product.price!;
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
      double totalPrice = product.qty! * product.price!;
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

  double netTotal() {
    var total = overallDiscountTotal() + overallNetRatedTotal();
    return total;
  }

  Future<Uint8List> format1A4() async {
    var pdf = pw.Document();
    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pf.PdfPageFormat.a4,
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
                        type == PdfType.enquiry ? "Enquiry" : "Estimate",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(child: pw.SizedBox()),
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
                        child: pw.SizedBox(),
                      ),
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.companyName ?? "",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.address ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.city ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          companyInfo.contact != null
                              ? pw.Center(
                                  child: pw.Text(
                                    companyInfo.contact!["mobile_no"] != null
                                        ? "${companyInfo.contact!["mobile_no"]}"
                                        : "",
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : pw.Container(),
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
                                    "Customer",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                estimateData.customer != null
                                    ? pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                            left: 15, bottom: 10),
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              estimateData
                                                      .customer!.customerName ??
                                                  "",
                                              style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.address ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.mobileNo ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : pw.Container(height: 20)
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
                                type == PdfType.enquiry
                                    ? 'Enquiry No : ${estimateData.enquiryid ?? estimateData.referenceId}'
                                    : 'Estimate No : ${estimateData.estimateid ?? estimateData.referenceId}',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Container(),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                "Date : ${DateFormat('dd-MM-yyyy').format(estimateData.createddate ?? DateTime.now())}",
                                textAlign: pw.TextAlign.left,
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(5.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(3),
                  6: const pw.FlexColumnWidth(3),
                },
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
                            "Code",
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
                            "Content",
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
                            "Amount",
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(5.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(3),
                  6: const pw.FlexColumnWidth(3),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: pf.PdfColors.grey300,
                    ),
                    children: [
                      pw.Container(),
                      pw.Container(),
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
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
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
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j].productCode ?? "",
                              textAlign: pw.TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  font: roboto,
                                  fontFallback: [roboto, noto],
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            sortEstimateProduct()[i][j].productName!.length > 30
                                ? sortEstimateProduct()[i][j]
                                    .productName!
                                    .substring(0, 30)
                                : sortEstimateProduct()[i][j].productName!,
                            textAlign: pdfAlignment == 1
                                ? pw.TextAlign.left
                                : pdfAlignment == 2
                                    ? pw.TextAlign.right
                                    : pdfAlignment == 3
                                        ? pw.TextAlign.center
                                        : pw.TextAlign.left,
                            style: TextStyle(
                                fontSize: 10,
                                font: roboto,
                                fontFallback: [roboto, noto],
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j]
                                  .productContent
                                  .toString(),
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
                              double.parse(sortEstimateProduct()[i][j]
                                      .price
                                      .toString())
                                  .toStringAsFixed(2),
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
                            actualPrice(
                                sortEstimateProduct()[i][j].qty!.toDouble(),
                                sortEstimateProduct()[i][j].price!.toDouble()),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (sortEstimateProduct()[i].first.discountLock != null &&
                      !sortEstimateProduct()[i].first.discountLock!)
                    if (sortEstimateProduct()[i].first.discount != null)
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
                                "Sub Total",
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
                              discountSubtotal(sortEstimateProduct()[i])
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
                  if (sortEstimateProduct()[i].first.discountLock != null &&
                      !sortEstimateProduct()[i].first.discountLock!)
                    if (sortEstimateProduct()[i].first.discount != null)
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
                                sortEstimateProduct()[i].first.discountLock !=
                                            null &&
                                        !sortEstimateProduct()[i]
                                            .first
                                            .discountLock!
                                    ? sortEstimateProduct()[i].first.discount !=
                                            null
                                        ? "Discount ${sortEstimateProduct()[i].first.discount}%"
                                        : "NR"
                                    : "NR",
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
                              discountGroupTotal(sortEstimateProduct()[i])
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
                      width: 49,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 177,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 49,
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
                      0: const pw.FlexColumnWidth(8.3),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(5),
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
                                  "Total Products (${estimateData.products!.length})",
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
                              overallDiscountTotal() != 0 &&
                                      overallNetRatedTotal() != 0
                                  ? "Net Total (${overallDiscountTotal().toStringAsFixed(2)} + ${overallNetRatedTotal().toStringAsFixed(2)})"
                                  : "Net Total",
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
                              netTotal().toStringAsFixed(2),
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
                  estimateData.price?.extraDiscountValue != null &&
                          estimateData.price!.extraDiscountValue! > 0.0
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
                                    "Extra Discount(${(estimateData.price!.extraDiscount)!.round()}${estimateData.price!.extraDiscountsys})",
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
                                    estimateData.price?.extraDiscountValue
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
                  estimateData.price?.packageValue != null &&
                          estimateData.price!.packageValue! > 0.0
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
                                    "Packing Charges(${(estimateData.price!.package)!.round()}${estimateData.price!.packagesys})",
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
                                    estimateData.price?.packageValue
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
                              estimateData.price?.roundOff
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
                              estimateData.price?.total?.toStringAsFixed(2) ??
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

  Future<Uint8List> format2A4() async {
    var pdf = pw.Document();
    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pf.PdfPageFormat.a4,
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
                        type == PdfType.enquiry ? "Enquiry" : "Estimate",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(child: pw.SizedBox()),
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
                        child: pw.SizedBox(),
                      ),
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.companyName ?? "",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.address ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.city ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          companyInfo.contact != null
                              ? pw.Center(
                                  child: pw.Text(
                                    companyInfo.contact!["mobile_no"] != null
                                        ? "${companyInfo.contact!["mobile_no"]}"
                                        : "",
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : pw.Container(),
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
                                    "Customer",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                estimateData.customer != null
                                    ? pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                            left: 15, bottom: 10),
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              estimateData
                                                      .customer!.customerName ??
                                                  "",
                                              style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.address ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.mobileNo ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : pw.Container(height: 20)
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
                                type == PdfType.enquiry
                                    ? 'Enquiry No : ${estimateData.enquiryid ?? estimateData.referenceId}'
                                    : 'Estimate No : ${estimateData.estimateid ?? estimateData.referenceId}',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Container(),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                "Date : ${DateFormat('dd-MM-yyyy').format(estimateData.createddate ?? DateTime.now())}",
                                textAlign: pw.TextAlign.left,
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(7),
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
                            "Code",
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
                            "Amount",
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(7),
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
                      pw.Container(),
                      pw.Container(),
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
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
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
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j].productCode ?? "",
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
                            sortEstimateProduct()[i][j].productName!.length > 30
                                ? sortEstimateProduct()[i][j]
                                    .productName!
                                    .substring(0, 30)
                                : sortEstimateProduct()[i][j].productName!,
                            textAlign: pdfAlignment == 1
                                ? pw.TextAlign.left
                                : pdfAlignment == 2
                                    ? pw.TextAlign.right
                                    : pdfAlignment == 3
                                        ? pw.TextAlign.center
                                        : pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: 10,
                              font: roboto,
                              fontFallback: [roboto, noto],
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
                              double.parse(sortEstimateProduct()[i][j]
                                      .price
                                      .toString())
                                  .toStringAsFixed(2),
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
                              sortEstimateProduct()[i][j].price!.toDouble(),
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
                      width: 49,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 226,
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
                                  "Total Products (${estimateData.products!.length})",
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
                              "Net Product Total",
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
                              // subTotal(),
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
                  estimateData.price?.discountValue != null &&
                          estimateData.price!.discountValue! > 0.0
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
                  estimateData.price?.extraDiscountValue != null &&
                          estimateData.price!.extraDiscountValue! > 0.0
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
                                    "Extra Discount(${(estimateData.price!.extraDiscount)!.round()}${estimateData.price!.extraDiscountsys})",
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
                                    "- ${estimateData.price?.extraDiscountValue?.toStringAsFixed(2)}",
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
                  estimateData.price?.packageValue != null &&
                          estimateData.price!.packageValue! > 0.0
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
                                    "Packing Charges(${(estimateData.price!.package)!.round()}${estimateData.price!.packagesys})",
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
                                    estimateData.price?.packageValue
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
                              estimateData.price?.roundOff
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
                              estimateData.price?.total?.toStringAsFixed(2) ??
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

  Future<Uint8List> format3A4() async {
    var pdf = pw.Document();
    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pf.PdfPageFormat.a4,
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
                        type == PdfType.enquiry ? "Enquiry" : "Estimate",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(child: pw.SizedBox()),
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
                        child: pw.SizedBox(),
                      ),
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.companyName ?? "",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.address ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.city ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          companyInfo.contact != null
                              ? pw.Center(
                                  child: pw.Text(
                                    companyInfo.contact!["mobile_no"] != null
                                        ? "${companyInfo.contact!["mobile_no"]}"
                                        : "",
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : pw.Container(),
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
                                    "Customer",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                estimateData.customer != null
                                    ? pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                            left: 15, bottom: 10),
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              estimateData
                                                      .customer!.customerName ??
                                                  "",
                                              style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.address ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.mobileNo ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : pw.Container(height: 20)
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
                                type == PdfType.enquiry
                                    ? 'Enquiry No : ${estimateData.enquiryid ?? estimateData.referenceId}'
                                    : 'Estimate No : ${estimateData.estimateid ?? estimateData.referenceId}',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Container(),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                "Date : ${DateFormat('dd-MM-yyyy').format(estimateData.createddate ?? DateTime.now())}",
                                textAlign: pw.TextAlign.left,
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(5.5),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2.5),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(2),
                  7: const pw.FlexColumnWidth(2),
                },
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
                            "Code",
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
                            "Before\nDiscount",
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
                            "Discounted\nAmount",
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
                            "Amount",
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(5.5),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2.5),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(2),
                  7: const pw.FlexColumnWidth(2),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: pf.PdfColors.grey300,
                    ),
                    children: [
                      pw.Container(),
                      pw.Container(),
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
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
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
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j].productCode ?? "",
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
                            sortEstimateProduct()[i][j].productName!.length > 30
                                ? sortEstimateProduct()[i][j]
                                    .productName!
                                    .substring(0, 30)
                                : sortEstimateProduct()[i][j].productName!,
                            textAlign: pdfAlignment == 1
                                ? pw.TextAlign.left
                                : pdfAlignment == 2
                                    ? pw.TextAlign.right
                                    : pdfAlignment == 3
                                        ? pw.TextAlign.center
                                        : pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: 10,
                              font: roboto,
                              fontFallback: [roboto, noto],
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
                              double.parse(sortEstimateProduct()[i][j]
                                      .price
                                      .toString())
                                  .toStringAsFixed(2),
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
                              (sortEstimateProduct()[i][j].price! *
                                      sortEstimateProduct()[i][j].qty!)
                                  .toStringAsFixed(2),
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
                              afterDiscount(
                                sortEstimateProduct()[i][j].qty!.toDouble(),
                                sortEstimateProduct()[i][j].price!.toDouble(),
                                sortEstimateProduct()[i][j].discount,
                                sortEstimateProduct()[i][j].discountLock,
                              ),
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
                              sortEstimateProduct()[i][j].price!.toDouble(),
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
                          beforeDiscountTotal(sortEstimateProduct()[i])
                              .toStringAsFixed(2),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          afterDiscountTotal(sortEstimateProduct()[i])
                              .toStringAsFixed(2),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
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
                      width: 46,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 168,
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
                    pw.Container(
                      width: 77,
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
            pw.Container(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
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
                                  "Total Products (${estimateData.products!.length})",
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
                              // subTotal(),
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
                  estimateData.price?.discountValue != null &&
                          estimateData.price!.discountValue! > 0.0
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
                  estimateData.price?.extraDiscountValue != null &&
                          estimateData.price!.extraDiscountValue! > 0.0
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
                                    "Extra Discount(${(estimateData.price!.extraDiscount)!.round()}${estimateData.price!.extraDiscountsys})",
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
                                    estimateData.price?.extraDiscountValue
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
                  estimateData.price?.packageValue != null &&
                          estimateData.price!.packageValue! > 0.0
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
                                    "Packing Charges(${(estimateData.price!.package)!.round()}${estimateData.price!.packagesys})",
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
                                    estimateData.price?.packageValue
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
                              estimateData.price?.roundOff
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
                              estimateData.price?.total?.toStringAsFixed(2) ??
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

  Future<Uint8List> format1A5() async {
    var pdf = pw.Document();
    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pf.PdfPageFormat.a5,
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
                        type == PdfType.enquiry ? "Enquiry" : "Estimate",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(child: pw.SizedBox()),
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
                        child: pw.SizedBox(),
                      ),
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.companyName ?? "",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.address ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.city ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          companyInfo.contact != null
                              ? pw.Center(
                                  child: pw.Text(
                                    companyInfo.contact!["mobile_no"] != null
                                        ? "${companyInfo.contact!["mobile_no"]}"
                                        : "",
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : pw.Container(),
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
                                    "Customer",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                estimateData.customer != null
                                    ? pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                            left: 15, bottom: 10),
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              estimateData
                                                      .customer!.customerName ??
                                                  "",
                                              style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.address ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.mobileNo ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : pw.Container(height: 10)
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
                                type == PdfType.enquiry
                                    ? 'Enquiry No : ${estimateData.enquiryid ?? estimateData.referenceId}'
                                    : 'Estimate No : ${estimateData.estimateid ?? estimateData.referenceId}',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Container(),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                "Date : ${DateFormat('dd-MM-yyyy').format(estimateData.createddate ?? DateTime.now())}",
                                textAlign: pw.TextAlign.left,
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
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(6.5),
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
                            "S.No",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Code",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
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
                              fontSize: 8,
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
                              fontSize: 8,
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
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Amount",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
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
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(6.5),
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
                      pw.Container(),
                      pw.Container(),
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
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j].productCode ?? "",
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            sortEstimateProduct()[i][j].productName!.length > 30
                                ? sortEstimateProduct()[i][j]
                                    .productName!
                                    .substring(0, 30)
                                : sortEstimateProduct()[i][j].productName!,
                            textAlign: pdfAlignment == 1
                                ? pw.TextAlign.left
                                : pdfAlignment == 2
                                    ? pw.TextAlign.right
                                    : pdfAlignment == 3
                                        ? pw.TextAlign.center
                                        : pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: 8,
                              font: roboto,
                              fontFallback: [roboto, noto],
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              double.parse(sortEstimateProduct()[i][j]
                                      .price
                                      .toString())
                                  .toStringAsFixed(2),
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            discount(
                              sortEstimateProduct()[i][j].qty!.toDouble(),
                              sortEstimateProduct()[i][j].price!.toDouble(),
                              sortEstimateProduct()[i][j].discount,
                              sortEstimateProduct()[i][j].discountLock,
                            ),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(
                              fontSize: 8,
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
                              fontSize: 8,
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
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      width: 29,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 45,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 146,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 45,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 67,
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
                                  "Total Products (${estimateData.products!.length})",
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.Text(
                                  "Total QTY",
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8,
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
                                  fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              // subTotal(),
                              overallNetRatedTotal().toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  estimateData.price?.discountValue != null &&
                          estimateData.price!.discountValue! > 0.0
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
                                      fontSize: 8,
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
                                      fontSize: 8,
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
                                fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  estimateData.price?.extraDiscountValue != null &&
                          estimateData.price!.extraDiscountValue! > 0.0
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
                                    "Extra Discount(${(estimateData.price!.extraDiscount)!.round()}${estimateData.price!.extraDiscountsys})",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "- ${estimateData.price?.extraDiscountValue?.toStringAsFixed(2)}",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : pw.SizedBox(),
                  estimateData.price?.packageValue != null &&
                          estimateData.price!.packageValue! > 0.0
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
                                    "Packing Charges(${(estimateData.price!.package)!.round()}${estimateData.price!.packagesys})",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    estimateData.price?.packageValue
                                            ?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              estimateData.price?.roundOff
                                      ?.toStringAsFixed(2) ??
                                  "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              estimateData.price?.total?.toStringAsFixed(2) ??
                                  "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
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

  Future<Uint8List> format2A5() async {
    var pdf = pw.Document();
    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pf.PdfPageFormat.a5,
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
                        type == PdfType.enquiry ? "Enquiry" : "Estimate",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(child: pw.SizedBox()),
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
                        child: pw.SizedBox(),
                      ),
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.companyName ?? "",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.address ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.city ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          companyInfo.contact != null
                              ? pw.Center(
                                  child: pw.Text(
                                    companyInfo.contact!["mobile_no"] != null
                                        ? "${companyInfo.contact!["mobile_no"]}"
                                        : "",
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : pw.Container(),
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
                                    "Customer",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                estimateData.customer != null
                                    ? pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                            left: 15, bottom: 10),
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              estimateData
                                                      .customer!.customerName ??
                                                  "",
                                              style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.address ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.mobileNo ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : pw.Container(height: 10)
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
                                type == PdfType.enquiry
                                    ? 'Enquiry No : ${estimateData.enquiryid ?? estimateData.referenceId}'
                                    : 'Estimate No : ${estimateData.estimateid ?? estimateData.referenceId}',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Container(),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                "Date : ${DateFormat('dd-MM-yyyy').format(estimateData.createddate ?? DateTime.now())}",
                                textAlign: pw.TextAlign.left,
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(5.3),
                  3: const pw.FlexColumnWidth(1.7),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(3),
                  6: const pw.FlexColumnWidth(3),
                },
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
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Code",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
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
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Content",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
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
                              fontSize: 8,
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
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Amount",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(5.3),
                  3: const pw.FlexColumnWidth(1.7),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(3),
                  6: const pw.FlexColumnWidth(3),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: pf.PdfColors.grey300,
                    ),
                    children: [
                      pw.Container(),
                      pw.Container(),
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
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j].productCode ?? "",
                              textAlign: pw.TextAlign.center,
                              style: TextStyle(
                                  fontSize: 8,
                                  font: roboto,
                                  fontFallback: [roboto, noto],
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            sortEstimateProduct()[i][j].productName!.length > 30
                                ? sortEstimateProduct()[i][j]
                                    .productName!
                                    .substring(0, 30)
                                : sortEstimateProduct()[i][j].productName!,
                            textAlign: pdfAlignment == 1
                                ? pw.TextAlign.left
                                : pdfAlignment == 2
                                    ? pw.TextAlign.right
                                    : pdfAlignment == 3
                                        ? pw.TextAlign.center
                                        : pw.TextAlign.left,
                            style: TextStyle(
                                fontSize: 8,
                                font: roboto,
                                fontFallback: [roboto, noto],
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j]
                                  .productContent
                                  .toString(),
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              double.parse(sortEstimateProduct()[i][j]
                                      .price
                                      .toString())
                                  .toStringAsFixed(2),
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            actualPrice(
                                sortEstimateProduct()[i][j].qty!.toDouble(),
                                sortEstimateProduct()[i][j].price!.toDouble()),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (sortEstimateProduct()[i].first.discountLock != null &&
                      !sortEstimateProduct()[i].first.discountLock!)
                    if (sortEstimateProduct()[i].first.discount != null)
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
                                "Sub Total",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              discountSubtotal(sortEstimateProduct()[i])
                                  .toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                  if (sortEstimateProduct()[i].first.discountLock != null &&
                      !sortEstimateProduct()[i].first.discountLock!)
                    if (sortEstimateProduct()[i].first.discount != null)
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
                                sortEstimateProduct()[i].first.discountLock !=
                                            null &&
                                        !sortEstimateProduct()[i]
                                            .first
                                            .discountLock!
                                    ? sortEstimateProduct()[i].first.discount !=
                                            null
                                        ? "Discount ${sortEstimateProduct()[i].first.discount}%"
                                        : "NR"
                                    : "NR",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              discountGroupTotal(sortEstimateProduct()[i])
                                  .toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
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
                            "Total",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
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
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      width: 29,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 34,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 119,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 38,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 45,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 67,
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
                                  "Total Products (${estimateData.products!.length})",
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.Text(
                                  "Total QTY",
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8,
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
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              "Net Total",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              netTotal().toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  estimateData.price?.extraDiscountValue != null &&
                          estimateData.price!.extraDiscountValue! > 0.0
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
                                    "Extra Discount(${(estimateData.price!.extraDiscount)!.round()}${estimateData.price!.extraDiscountsys})",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "- ${estimateData.price?.extraDiscountValue?.toStringAsFixed(2)}",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : pw.SizedBox(),
                  estimateData.price?.packageValue != null &&
                          estimateData.price!.packageValue! > 0.0
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
                                    "Packing Charges(${(estimateData.price!.package)!.round()}${estimateData.price!.packagesys})",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    estimateData.price?.packageValue
                                            ?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              estimateData.price?.roundOff
                                      ?.toStringAsFixed(2) ??
                                  "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              estimateData.price?.total?.toStringAsFixed(2) ??
                                  "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
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

  Future<Uint8List> format3A5() async {
    var pdf = pw.Document();
    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pf.PdfPageFormat.a5,
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
                        type == PdfType.enquiry ? "Enquiry" : "Estimate",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(child: pw.SizedBox()),
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
                        child: pw.SizedBox(),
                      ),
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.companyName ?? "",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.address ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Center(
                            child: pw.Text(
                              companyInfo.city ?? "",
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          companyInfo.contact != null
                              ? pw.Center(
                                  child: pw.Text(
                                    companyInfo.contact!["mobile_no"] != null
                                        ? "${companyInfo.contact!["mobile_no"]}"
                                        : "",
                                    style: const pw.TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              : pw.Container(),
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
                                    "Customer",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                estimateData.customer != null
                                    ? pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                            left: 15, bottom: 10),
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              estimateData
                                                      .customer!.customerName ??
                                                  "",
                                              style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.address ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.Text(
                                              estimateData.customer!.mobileNo ??
                                                  "",
                                              style: const pw.TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : pw.Container(height: 10)
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
                                type == PdfType.enquiry
                                    ? 'Enquiry No : ${estimateData.enquiryid ?? estimateData.referenceId}'
                                    : 'Estimate No : ${estimateData.estimateid ?? estimateData.referenceId}',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Container(),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                "Date : ${DateFormat('dd-MM-yyyy').format(estimateData.createddate ?? DateTime.now())}",
                                textAlign: pw.TextAlign.left,
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(5.5),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(2.5),
                  7: const pw.FlexColumnWidth(2),
                },
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
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Code",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
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
                              fontSize: 8,
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
                              fontSize: 8,
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
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Before\nDiscount",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Discounted\nAmount",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Center(
                          child: pw.Text(
                            "Amount",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
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
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(5.5),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(2.5),
                  7: const pw.FlexColumnWidth(2),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: pf.PdfColors.grey300,
                    ),
                    children: [
                      pw.Container(),
                      pw.Container(),
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
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Container(),
                      pw.Container(),
                      pw.Container(),
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              sortEstimateProduct()[i][j].productCode ?? "",
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            sortEstimateProduct()[i][j].productName!.length > 30
                                ? sortEstimateProduct()[i][j]
                                    .productName!
                                    .substring(0, 30)
                                : sortEstimateProduct()[i][j].productName!,
                            textAlign: pdfAlignment == 1
                                ? pw.TextAlign.left
                                : pdfAlignment == 2
                                    ? pw.TextAlign.right
                                    : pdfAlignment == 3
                                        ? pw.TextAlign.center
                                        : pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontSize: 8,
                              font: roboto,
                              fontFallback: [roboto, noto],
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              double.parse(sortEstimateProduct()[i][j]
                                      .price
                                      .toString())
                                  .toStringAsFixed(2),
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              (sortEstimateProduct()[i][j].price! *
                                      sortEstimateProduct()[i][j].qty!)
                                  .toStringAsFixed(2),
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Center(
                            child: pw.Text(
                              afterDiscount(
                                sortEstimateProduct()[i][j].qty!.toDouble(),
                                sortEstimateProduct()[i][j].price!.toDouble(),
                                sortEstimateProduct()[i][j].discount,
                                sortEstimateProduct()[i][j].discountLock,
                              ),
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            discount(
                              sortEstimateProduct()[i][j].qty!.toDouble(),
                              sortEstimateProduct()[i][j].price!.toDouble(),
                              sortEstimateProduct()[i][j].discount,
                              sortEstimateProduct()[i][j].discountLock,
                            ),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(
                              fontSize: 8,
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
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          beforeDiscountTotal(sortEstimateProduct()[i])
                              .toStringAsFixed(2),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          afterDiscountTotal(sortEstimateProduct()[i])
                              .toStringAsFixed(2),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
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
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      width: 28,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 31,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 117,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 43,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 42,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 43,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          right: pw.BorderSide(),
                        ),
                      ),
                    ),
                    pw.Container(
                      width: 53,
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
                                  "Total Products (${estimateData.products!.length})",
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.Text(
                                  "Total QTY",
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8,
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
                                  fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              // subTotal(),
                              overallNetRatedTotal().toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  estimateData.price?.discountValue != null &&
                          estimateData.price!.discountValue! > 0.0
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
                                      fontSize: 8,
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
                                      fontSize: 8,
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
                                fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  estimateData.price?.extraDiscountValue != null &&
                          estimateData.price!.extraDiscountValue! > 0.0
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
                                    "Extra Discount(${(estimateData.price!.extraDiscount)!.round()}${estimateData.price!.extraDiscountsys})",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    "- ${estimateData.price?.extraDiscountValue?.toStringAsFixed(2)}",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : pw.SizedBox(),
                  estimateData.price?.packageValue != null &&
                          estimateData.price!.packageValue! > 0.0
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
                                    "Packing Charges(${(estimateData.price!.package)!.round()}${estimateData.price!.packagesys})",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(
                                    estimateData.price?.packageValue
                                            ?.toStringAsFixed(2) ??
                                        "",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              estimateData.price?.roundOff
                                      ?.toStringAsFixed(2) ??
                                  "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
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
                                fontSize: 8,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text(
                              estimateData.price?.total?.toStringAsFixed(2) ??
                                  "",
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
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

  Font? regularFont;
  Font? boldFont;
  pw.TextStyle? heading1;
  pw.TextStyle? heading2;
  pw.TextStyle? subtitle1;
  pw.TextStyle? subtitle2;

  Future<Uint8List?> create3InchPDF() async {
    final pdf = pw.Document();

    heading1 = pw.TextStyle(
      font: boldFont,
      color: pf.PdfColors.black,
      fontWeight: pw.FontWeight.bold,
      fontSize: 11,
    );
    heading2 = pw.TextStyle(
      font: boldFont,
      color: pf.PdfColors.black,
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
    );
    subtitle1 = pw.TextStyle(
      font: regularFont,
      fontSize: 10,
      fontWeight: pw.FontWeight.normal,
    );
    subtitle2 = pw.TextStyle(
      font: regularFont,
      fontSize: 10,
      fontWeight: pw.FontWeight.normal,
    );

    const pageWidth = 3.15 * PdfPageFormat.inch;
    const pageHeight = 4 * PdfPageFormat.inch;
    final Font roboto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final Font noto =
        pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(pageWidth, pageHeight, marginAll: 0),
        margin: const EdgeInsets.all(10),
        theme: ThemeData.withFont(
          base: regularFont,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  companyInfo.companyName ?? "",
                  style: heading1,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  companyInfo.address ?? "",
                  textAlign: pw.TextAlign.center,
                  style: subtitle1,
                ),
              ),
              companyInfo.contact != null
                  ? pw.Center(
                      child: pw.Text(
                        companyInfo.contact!["mobile_no"].toString(),
                        textAlign: pw.TextAlign.center,
                        style: subtitle1,
                      ),
                    )
                  : pw.Container(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "No: ${type == PdfType.enquiry ? estimateData.enquiryid ?? estimateData.referenceId : estimateData.estimateid ?? estimateData.referenceId}",
                    textAlign: pw.TextAlign.center,
                    style: subtitle1,
                  ),
                  pw.Text(
                    "Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(estimateData.createddate!)}",
                    textAlign: pw.TextAlign.center,
                    style: subtitle1,
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              Text(
                "Bill To",
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.normal,
                ),
              ),
              estimateData.customer != null
                  ? pw.RichText(
                      text: pw.TextSpan(
                        text: estimateData.customer!.customerName != null
                            ? '${estimateData.customer!.customerName}\n${estimateData.customer!.mobileNo ?? ""}\n'
                            : "",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.normal,
                        ),
                        children: [
                          estimateData.customer!.address != null
                              ? pw.TextSpan(
                                  text: '${estimateData.customer!.address}\n')
                              : const pw.TextSpan(),
                          estimateData.customer!.city != null
                              ? pw.TextSpan(
                                  text: '${estimateData.customer!.city}\n')
                              : const pw.TextSpan(),
                          estimateData.customer!.state != null
                              ? pw.TextSpan(
                                  text: '${estimateData.customer!.state}\n')
                              : const pw.TextSpan(),
                        ],
                      ),
                    )
                  : pw.Container(),
              pw.SizedBox(height: 8),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                // border: pw.TableBorder.all(),
                border: const pw.TableBorder(
                  // left: pw.BorderSide(color: pf.PdfColors.black),
                  top: pw.BorderSide(color: pf.PdfColors.black),
                  // right: pw.BorderSide(color: pf.PdfColors.black),
                  bottom: pw.BorderSide(color: pf.PdfColors.black),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "Product Name",
                          textAlign: pw.TextAlign.left,
                          style: heading2,
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "Qty",
                            style: heading2,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "Rate",
                          textAlign: pw.TextAlign.right,
                          style: heading2,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          "Amount",
                          textAlign: pw.TextAlign.right,
                          style: heading2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              for (int i = 0; i < sortEstimateProduct().length; i++)
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2.5),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: pf.PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(
                            sortEstimateProduct()[i].first.discountLock !=
                                        null &&
                                    !sortEstimateProduct()[i]
                                        .first
                                        .discountLock!
                                ? sortEstimateProduct()[i].first.discount !=
                                        null
                                    ? "Discount: ${sortEstimateProduct()[i].first.discount}%"
                                    : "Net Rated Products"
                                : "Net Rated Products",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var j = 0; j < sortEstimateProduct()[i].length; j++)
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: pf.PdfColors.grey400,
                            ),
                          ),
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: Text(
                              textAlign: pdfAlignment == 1
                                  ? pw.TextAlign.left
                                  : pdfAlignment == 2
                                      ? pw.TextAlign.right
                                      : pdfAlignment == 3
                                          ? pw.TextAlign.center
                                          : pw.TextAlign.left,
                              sortEstimateProduct()[i][j].productName!.length >
                                      30
                                  ? sortEstimateProduct()[i][j]
                                      .productName!
                                      .substring(0, 30)
                                  : sortEstimateProduct()[i][j].productName!,
                              style: pw.TextStyle(
                                fontSize: 8,
                                font: roboto,
                                fontFallback: [roboto, noto],
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Text(
                                sortEstimateProduct()[i][j].qty != null
                                    ? sortEstimateProduct()[i][j].qty.toString()
                                    : "",
                                style: subtitle1,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              sortEstimateProduct()[i][j].price != null
                                  ? sortEstimateProduct()[i][j]
                                      .price!
                                      .toStringAsFixed(2)
                                  : "",
                              textAlign: pw.TextAlign.right,
                              style: subtitle1,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                              sortEstimateProduct()[i][j].qty != null &&
                                      sortEstimateProduct()[i][j].price != null
                                  ? (estimateData.products![i].qty! *
                                          estimateData.products![i].price!)
                                      .toStringAsFixed(2)
                                  : "",
                              textAlign: pw.TextAlign.right,
                              style: subtitle1,
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
                          child: pw.Center(
                            child: pw.Text(
                              "Total",
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 8,
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
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(5),
                  1: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  calculationTableView3Inch("Net Products Total",
                      overallNetRatedTotal().toStringAsFixed(2)),
                  calculationTableView3Inch("Discounted Products Total",
                      overallDiscountTotal().toStringAsFixed(2)),
                  calculationTableView3Inch("Subtotal",
                      estimateData.price!.subTotal!.toStringAsFixed(2)),
                  estimateData.price!.extraDiscount != 0
                      ? calculationTableView3Inch(
                          "Extra Discount(${(estimateData.price!.extraDiscount)!.round()}${estimateData.price!.extraDiscountsys})",
                          estimateData.price?.extraDiscountValue
                                  ?.toStringAsFixed(2) ??
                              "")
                      : const pw.TableRow(children: []),
                  estimateData.price!.package != 0
                      ? calculationTableView3Inch(
                          "Packing Charges(${(estimateData.price!.package)!.round()}${estimateData.price!.packagesys})",
                          estimateData.price?.packageValue
                                  ?.toStringAsFixed(2) ??
                              "")
                      : const pw.TableRow(children: []),
                  calculationTableView3Inch("Round Off",
                      estimateData.price!.roundOff!.toStringAsFixed(2)),
                  calculationTableView3Inch(
                      "Total", estimateData.price!.total!.toStringAsFixed(2)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "No.Product : ${estimateData.products!.length}",
                    textAlign: pw.TextAlign.center,
                    style: heading2,
                  ),
                  pw.Text(
                    "No.QTY : ${getItems()}",
                    textAlign: pw.TextAlign.center,
                    style: heading2,
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
            ],
          );
        },
      ),
    );
    return await pdf.save();
  }

  pw.TableRow calculationTableView3Inch(String title, String value) {
    return pw.TableRow(
      decoration: title.toLowerCase() == "total"
          ? const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: pf.PdfColors.black,
                ),
                top: pw.BorderSide(
                  color: pf.PdfColors.black,
                ),
              ),
            )
          : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            title,
            textAlign: pw.TextAlign.right,
            style: subtitle2,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: subtitle2,
          ),
        ),
      ],
    );
  }

  String getItems() {
    String count = "0";
    int tmpcount = 0;
    for (var element in estimateData.products!) {
      tmpcount += element.qty!;
    }
    count = tmpcount.toString();
    return count;
  }
}

class PdfCreationProvider {
  String companyName;
  String companyAddress;
  List<PricelistCategoryDataModel> priceList;
  PdfCreationProvider({
    required this.companyName,
    required this.companyAddress,
    required this.priceList,
  });

  // Future<List<int>?> createProceList() async {
  //   // Return Pdf Data
  //   List<int>? bytes;
  //   // Ini New Doucument
  //   final PdfDocument document = PdfDocument();
  //   // Page Orientation
  //   document.pageSettings.orientation = PdfPageOrientation.portrait;
  //   // Page Margins
  //   document.pageSettings.margins.all = 20;
  //   // Page Size
  //   document.pageSettings.size = PdfPageSize.a4;
  //   PdfSection section = document.sections!.add();
  //   PdfPageTemplateElement topHeader = PdfPageTemplateElement(
  //     Rect.fromLTWH(0, 0, document.pageSettings.size.width + 2, 71),
  //   );
  //   // topHeader.
  //   PdfGrid headergrid = PdfGrid();
  //   headergrid.columns.add(count: 6);
  //   headergrid.headers.add(1);
  //   //Add the rows to the grid
  //   PdfGridRow headergridrow = headergrid.headers[0];
  //   PdfStringFormat headerformat = PdfStringFormat();
  //   headerformat.alignment = PdfTextAlignment.center;
  //   headerformat.lineAlignment = PdfVerticalAlignment.middle;
  //   headergridrow.cells[0].value = '$companyName,\n$companyAddress';
  //   headergridrow.cells[0].columnSpan = 6;
  //   headergridrow.cells[0].stringFormat = headerformat;
  //   // //Add rows to grid
  //   PdfGridRow headerrow = headergrid.rows.add();
  //   headerrow.cells[0].value = 'Price List';
  //   headerrow.cells[0].columnSpan = 6;
  //   headerrow.cells[0].stringFormat = headerformat;
  //   headerrow = headergrid.rows.add();
  //   headerrow.cells[0].value = 'Product Code';
  //   headerrow.cells[1].value = 'Product Name';
  //   headerrow.cells[2].value = 'Content';
  //   headerrow.cells[3].value = 'Qnt';
  //   headerrow.cells[4].value = 'Price';
  //   headerrow.cells[5].value = 'Amount';
  //   headerrow.cells[0].stringFormat = headerformat;
  //   headerrow.cells[1].stringFormat = headerformat;
  //   headerrow.cells[2].stringFormat = headerformat;
  //   headerrow.cells[3].stringFormat = headerformat;
  //   headerrow.cells[4].stringFormat = headerformat;
  //   headerrow.cells[5].stringFormat = headerformat;
  //   headergrid.draw(
  //     graphics: topHeader.graphics,
  //   );
  //   document.template.top = topHeader;
  //   // Table Creation
  //   PdfGrid grid = PdfGrid();
  //   grid.columns.add(count: 6);
  //   PdfStringFormat format = PdfStringFormat();
  //   format.alignment = PdfTextAlignment.center;
  //   format.lineAlignment = PdfVerticalAlignment.middle;
  //   PdfGridCellStyle style = PdfGridCellStyle(
  //     cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
  //     backgroundBrush: PdfBrushes.lightGray,
  //     textBrush: PdfBrushes.black,
  //   );
  //   // //Add rows to grid
  //   int count = 1;
  //   for (int i = 0; i < priceList.length; i++) {
  //     PdfGridRow row = grid.rows.add();
  //     row.cells[0].value = priceList[i].categoryName.toString();
  //     row.cells[0].columnSpan = 6;
  //     row.cells[0].stringFormat = format;
  //     row.cells[0].style = style;
  //     for (var j = 0; j < priceList[i].productModel!.length; j++) {
  //       var prodData = priceList[i].productModel![j];
  //       row = grid.rows.add();
  //       row.cells[0].value = '$count';
  //       row.cells[1].value = prodData.prodcutName;
  //       row.cells[2].value = prodData.content;
  //       row.cells[3].value = '';
  //       row.cells[4].value = prodData.price;
  //       row.cells[5].value = '';
  //       count++;
  //     }
  //   }
  //   // row = grid.rows.add();
  //   // row.cells[0].value = 'E02';
  //   // row.cells[1].value = 'Simon';
  //   // row.cells[2].value = '\$12,000';
  //   //Set the grid style
  //   grid.style = PdfGridStyle(
  //     cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 2),
  //     textBrush: PdfBrushes.black,
  //   );
  //   //Draw the grid
  //   grid.draw(
  //     page: section.pages.add(),
  //   );
  //   //Save and dispose the PDF document
  //   // Directory dir = Directory('/storage/emulated/0/Download');
  //   bytes = await document.save();
  //   // File('${dir.path}/SampleOutput.pdf').writeAsBytes(await document.save());
  //   document.dispose();
  //   return bytes;
  // }

  int code = 0;
  productTableList(PricelistProdcutDataModel prod, Font? font) {
    code += 1;
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(6),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
      },
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  "$code",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  prod.prodcutName ?? "",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  prod.content ?? "",
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  "",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  prod.price ?? "",
                  style: const pw.TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Text(
                  "",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<Uint8List> createPriceList() async {
    final font = await PdfGoogleFonts.notoSansTamilRegular();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: pf.PdfPageFormat.a4,
        header: (context) {
          return pw.Column(
            children: [
              pw.Table(
                border: const pw.TableBorder(
                  left: pw.BorderSide(color: pf.PdfColors.black),
                  top: pw.BorderSide(color: pf.PdfColors.black),
                  right: pw.BorderSide(color: pf.PdfColors.black),
                  bottom: pw.BorderSide(color: pf.PdfColors.black),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                companyName,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                companyAddress,
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Table(
                border: const pw.TableBorder(
                  left: pw.BorderSide(color: pf.PdfColors.black),
                  top: pw.BorderSide(color: pf.PdfColors.black),
                  right: pw.BorderSide(color: pf.PdfColors.black),
                  bottom: pw.BorderSide(color: pf.PdfColors.black),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Center(
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                "Price List",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(6),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(2),
                },
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "CODE",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "PRODUCT NAME",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "CONTENT",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "QTY",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "RATE",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            "AMOUNT",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
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
        build: (context) {
          return [
            for (int i = 0; i < priceList.length; i++)
              pw.Column(
                children: [
                  pw.Table(
                    border: const pw.TableBorder(
                      left: pw.BorderSide(color: pf.PdfColors.black),
                      top: pw.BorderSide(color: pf.PdfColors.black),
                      right: pw.BorderSide(color: pf.PdfColors.black),
                      bottom: pw.BorderSide(color: pf.PdfColors.black),
                    ),
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: pf.PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Center(
                              child: pw.Column(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text(
                                    priceList[i].categoryName ?? "",
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  for (int j = 0; j < priceList[i].productModel!.length; j++)
                    productTableList(priceList[i].productModel![j], font),
                ],
              ),
          ];
        },
      ),
    );

    return await pdf.save();
  }
}

// class EnqueryPdfCreation {
//   final EstimateDataModel estimateData;
//   final PdfType type;
//   final ProfileModel companyInfo;
//   EnqueryPdfCreation({
//     required this.estimateData,
//     required this.type,
//     required this.companyInfo,
//   });

//   Future<List<int>?> createPdfA4() async {
//     List<int>? resultData;

//     PdfDocument document = PdfDocument();

//     document.pageSettings.size = PdfPageSize.a4;
//     document.pageSettings.margins.all = 10;

//     // Pdf Page Header Section Start

//     // Create Header size
//     PdfPageTemplateElement header = PdfPageTemplateElement(
//       Rect.fromLTWH(0, 0, document.pageSettings.size.width - 2, 162),
//     );

//     // Grid Varable
//     PdfGrid headerGrid = PdfGrid();

//     // Assign Column 3
//     headerGrid.columns.add(count: 7);
//     headerGrid.headers.add(1);

//     headerGrid.columns[0].width = 31;
//     headerGrid.columns[1].width = 41;
//     headerGrid.columns[3].width = 41;
//     headerGrid.columns[4].width = 41.5;
//     headerGrid.columns[5].width = 41.5;
//     headerGrid.columns[6].width = 82.5;

//     PdfGridRow titleHeader = headerGrid.headers[0];
//     titleHeader.cells[0].value =
//         'Estimate ID: ${type == PdfType.enquiry ? estimateData.enquiryid ?? estimateData.referenceId : estimateData.estimateid ?? estimateData.referenceId}';
//     titleHeader.cells[2].value = 'Estimate';
//     titleHeader.cells[5].value =
//         'Date: ${DateFormat('dd-MM-yyyy HH:mm a').format(estimateData.createddate!)}';

//     // Header Style Start
//     titleHeader.cells[0].columnSpan = 2;
//     titleHeader.cells[2].columnSpan = 3;
//     titleHeader.cells[5].columnSpan = 2;
//     titleHeader.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(right: PdfPens.transparent),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.left,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     titleHeader.cells[2].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         right: PdfPens.transparent,
//         left: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//       textBrush: PdfBrushes.black,
//       font: PdfStandardFont(
//         PdfFontFamily.timesRoman,
//         9,
//         style: PdfFontStyle.bold,
//       ),
//     );
//     titleHeader.cells[5].style = PdfGridCellStyle(
//       borders: PdfBorders(left: PdfPens.transparent),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.right,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     // Header Style End

//     // Header Table Rows Mobile No Mail Addresss
//     PdfGridRow headerRow = headerGrid.rows.add();
//     /*
//       headerRow.cells[0].value = "Mobile No: ${companyInfo.contact}";
//       headerRow.cells[3].value = "Email: msankar032@gmil.com";
//     */
//     // Header Table Rows Mobile No Mail Addresss Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 3;
//     headerRow.cells[3].columnSpan = 4;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         right: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.left,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     headerRow.cells[3].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         left: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.right,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     //  Style End

//     // Header Table Rows 2 Company Name
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value = companyInfo.companyName;
//     // Header Table Rows 2 Company Name Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 7;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         top: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//       font: PdfStandardFont(
//         PdfFontFamily.timesRoman,
//         9,
//         style: PdfFontStyle.bold,
//       ),
//     );
//     //  Style End

//     // Header Tabel Rows 3 Company Address
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value = companyInfo.address;
//     // Header Table Rows 3 Company Address Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 7;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         top: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     //  Style End

//     // Header Table Rows 4 Customer Details title
//     // if (pageNumber) {
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value = "Customer Details";
//     // }
//     // Header Table Rows 4 Customer Details title Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 7;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         // top: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       font: PdfStandardFont(
//         PdfFontFamily.timesRoman,
//         9,
//         style: PdfFontStyle.bold,
//       ),
//     );
//     //  Style End

//     // Header Table Rows 4 Customer Information
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value =
//         "${estimateData.customer?.customerName}\n${estimateData.customer?.address},${estimateData.customer?.state},${estimateData.customer?.city},${estimateData.customer?.mobileNo}";
//     // Header Table Rows 4 Customer Details title Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 7;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         top: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//     );
//     //

//     // Header Table Rows 5 Product Conetent Title Seaction
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value = 'S.No';
//     headerRow.cells[1].value = 'Code';
//     headerRow.cells[2].value = 'Product Name';
//     headerRow.cells[3].value = 'Discount';
//     headerRow.cells[4].value = 'QTY';
//     headerRow.cells[5].value = 'Rate';
//     headerRow.cells[6].value = 'Amount';

//     var style = PdfGridCellStyle(
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//       borders: PdfBorders(
//         bottom: PdfPens.transparent,
//       ),
//       font: PdfStandardFont(
//         PdfFontFamily.timesRoman,
//         9,
//         style: PdfFontStyle.bold,
//       ),
//     );

//     headerRow.cells[0].style = style;
//     headerRow.cells[1].style = style;
//     headerRow.cells[2].style = style;
//     headerRow.cells[3].style = style;
//     headerRow.cells[4].style = style;
//     headerRow.cells[5].style = style;
//     headerRow.cells[6].style = style;

//     headerGrid.style.cellPadding = PdfPaddings(
//       left: 2,
//       right: 2,
//       bottom: 6.5,
//       top: 2,
//     );

//     headerGrid.draw(
//       graphics: header.graphics,
//     );
//     document.template.top = header;

//     // Pdf Page Header Section End

//     //Add section to the document
//     PdfSection section = document.sections!.add();

//     // Product Listing Table Section Start
//     PdfGrid prodcutGrid = PdfGrid();

//     prodcutGrid.columns.add(count: 7);

//     prodcutGrid.columns[0].width = 30;
//     prodcutGrid.columns[1].width = 40;
//     prodcutGrid.columns[3].width = 40;
//     prodcutGrid.columns[4].width = 40;
//     prodcutGrid.columns[5].width = 40;
//     prodcutGrid.columns[6].width = 80;
//     // Product List Start
//     int count = 1;
//     PdfGridCellStyle centerstyle = PdfGridCellStyle(
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     PdfGridCellStyle rightstyle = PdfGridCellStyle(
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.right,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     for (int i = 0; i < estimateData.products!.length; i++) {
//       PdfGridRow productRow = prodcutGrid.rows.add();
//       productRow.cells[0].value = '$count';
//       productRow.cells[1].value = '${estimateData.products![i].productCode}';
//       productRow.cells[2].value = '${estimateData.products![i].productName}';
//       productRow.cells[3].value =
//           estimateData.products![i].discountLock == true ? "Yes" : "No";
//       productRow.cells[4].value = '${estimateData.products![i].qty}';
//       productRow.cells[5].value = '${estimateData.products![i].price}';
//       productRow.cells[6].value =
//           '${estimateData.products![i].qty! * estimateData.products![i].price!}';
//       productRow.cells[0].style = centerstyle;
//       productRow.cells[1].style = centerstyle;
//       productRow.cells[3].style = centerstyle;
//       productRow.cells[4].style = centerstyle;
//       productRow.cells[5].style = rightstyle;
//       productRow.cells[6].style = rightstyle;
//       count++;
//     }
//     // Product List End
//     PdfGridRow productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'SubTotal';
//     productRow.cells[6].value = '${estimateData.price!.subTotal}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'Discount';
//     productRow.cells[6].value = '${estimateData.price!.discountValue}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'Extra Discount';
//     productRow.cells[6].value = '${estimateData.price!.extraDiscountValue}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'Package Charges';
//     productRow.cells[6].value = '${estimateData.price!.packageValue}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'Total';
//     productRow.cells[6].value = '${estimateData.price!.total}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value =
//         'Total Items (${estimateData.products!.length})';
//     productRow.cells[3].value = 'Overall Total';
//     productRow.cells[6].value = '${estimateData.price!.total}';
//     productRow.cells[0].columnSpan = 2;
//     productRow.cells[3].columnSpan = 3;

//     productRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         right: PdfPens.transparent,
//       ),
//     );
//     productRow.cells[2].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         left: PdfPens.transparent,
//         right: PdfPens.transparent,
//       ),
//     );
//     productRow.cells[3].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         left: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.right,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     productRow.cells[6].style = rightstyle;

//     prodcutGrid.style.cellPadding = PdfPaddings(
//       left: 2,
//       right: 2,
//       bottom: 2,
//       top: 2,
//     );

//     prodcutGrid.draw(page: section.pages.add());
//     // Product Listing Table Section End

//     resultData = await document.save();

//     return resultData;
//   }

//   Future<List<int>?> createPdfA5() async {
//     List<int>? resultData;

//     PdfDocument document = PdfDocument();

//     document.pageSettings.size = PdfPageSize.a5;
//     document.pageSettings.margins.all = 10;

//     // Pdf Page Header Section Start

//     // Create Header size
//     PdfPageTemplateElement header = PdfPageTemplateElement(
//       Rect.fromLTWH(0, 0, document.pageSettings.size.width - 20, 162),
//     );

//     // Grid Varable
//     PdfGrid headerGrid = PdfGrid();

//     // Assign Column 3
//     headerGrid.columns.add(count: 7);
//     headerGrid.headers.add(1);

//     headerGrid.columns[0].width = 30;
//     headerGrid.columns[1].width = 40;
//     headerGrid.columns[3].width = 40;
//     headerGrid.columns[4].width = 40;
//     headerGrid.columns[5].width = 40;
//     headerGrid.columns[6].width = 80;

//     PdfGridRow titleHeader = headerGrid.headers[0];
//     titleHeader.cells[0].value =
//         'Estimate ID: ${type == PdfType.enquiry ? estimateData.enquiryid ?? estimateData.referenceId : estimateData.estimateid ?? estimateData.referenceId}';
//     titleHeader.cells[2].value =
//         type == PdfType.enquiry ? 'Enquiry' : 'Estimate';
//     titleHeader.cells[5].value =
//         'Date: ${DateFormat('dd-MM-yyyy HH:mm a').format(estimateData.createddate!)}';

//     // Header Style Start
//     titleHeader.cells[0].columnSpan = 2;
//     titleHeader.cells[2].columnSpan = 3;
//     titleHeader.cells[5].columnSpan = 2;
//     titleHeader.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(right: PdfPens.transparent),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.left,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     titleHeader.cells[2].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         right: PdfPens.transparent,
//         left: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//       textBrush: PdfBrushes.black,
//       font: PdfStandardFont(
//         PdfFontFamily.timesRoman,
//         9,
//         style: PdfFontStyle.bold,
//       ),
//     );
//     titleHeader.cells[5].style = PdfGridCellStyle(
//       borders: PdfBorders(left: PdfPens.transparent),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.right,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     // Header Style End

//     // Header Table Rows Mobile No Mail Addresss
//     PdfGridRow headerRow = headerGrid.rows.add();
//     /*
//     headerRow.cells[0].value = "Mobile No: +91 9942782219";
//     headerRow.cells[3].value = "Email: msankar032@gmil.com";
//     */

//     // Header Table Rows Mobile No Mail Addresss Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 3;
//     headerRow.cells[3].columnSpan = 4;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         right: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.left,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     headerRow.cells[3].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         left: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.right,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     //  Style End

//     // Header Table Rows 2 Company Name
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value = companyInfo.companyName;
//     // Header Table Rows 2 Company Name Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 7;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         top: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//       font: PdfStandardFont(
//         PdfFontFamily.timesRoman,
//         9,
//         style: PdfFontStyle.bold,
//       ),
//     );
//     //  Style End

//     // Header Tabel Rows 3 Company Address
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value = companyInfo.address;
//     // Header Table Rows 3 Company Address Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 7;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         top: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     //  Style End

//     // Header Table Rows 4 Customer Details title
//     // if (pageNumber) {
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value = "Customer Details";
//     // }
//     // Header Table Rows 4 Customer Details title Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 7;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         // top: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//       font: PdfStandardFont(
//         PdfFontFamily.timesRoman,
//         9,
//         style: PdfFontStyle.bold,
//       ),
//     );
//     //  Style End

//     // Header Table Rows 4 Customer Information
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value =
//         "${estimateData.customer?.customerName}\n${estimateData.customer?.address},${estimateData.customer?.state},${estimateData.customer?.city},${estimateData.customer?.mobileNo}";
//     // Header Table Rows 4 Customer Details title Style
//     //  Style Start
//     headerRow.cells[0].columnSpan = 7;
//     headerRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         top: PdfPens.transparent,
//         bottom: PdfPens.transparent,
//       ),
//     );
//     //

//     // Header Table Rows 5 Product Conetent Title Seaction
//     headerRow = headerGrid.rows.add();
//     headerRow.cells[0].value = 'S.No';
//     headerRow.cells[1].value = 'Code';
//     headerRow.cells[2].value = 'Product Name';
//     headerRow.cells[3].value = 'Discount';
//     headerRow.cells[4].value = 'QTY';
//     headerRow.cells[5].value = 'Rate';
//     headerRow.cells[6].value = 'Amount';

//     var style = PdfGridCellStyle(
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//       borders: PdfBorders(
//         bottom: PdfPens.transparent,
//       ),
//       font: PdfStandardFont(
//         PdfFontFamily.timesRoman,
//         9,
//         style: PdfFontStyle.bold,
//       ),
//     );

//     headerRow.cells[0].style = style;
//     headerRow.cells[1].style = style;
//     headerRow.cells[2].style = style;
//     headerRow.cells[3].style = style;
//     headerRow.cells[4].style = style;
//     headerRow.cells[5].style = style;
//     headerRow.cells[6].style = style;

//     headerGrid.style.cellPadding = PdfPaddings(
//       left: 2,
//       right: 2,
//       bottom: 2,
//       top: 2,
//     );

//     headerGrid.draw(
//       graphics: header.graphics,
//     );
//     document.template.top = header;

//     // Pdf Page Header Section End

//     //Add section to the document
//     PdfSection section = document.sections!.add();

//     // Product Listing Table Section Start
//     PdfGrid prodcutGrid = PdfGrid();

//     prodcutGrid.columns.add(count: 7);

//     prodcutGrid.columns[0].width = 30;
//     prodcutGrid.columns[1].width = 40;
//     prodcutGrid.columns[3].width = 40;
//     prodcutGrid.columns[4].width = 40;
//     prodcutGrid.columns[5].width = 40;
//     prodcutGrid.columns[6].width = 80;
//     // Product List Start
//     int count = 1;
//     PdfGridCellStyle centerstyle = PdfGridCellStyle(
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.center,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     PdfGridCellStyle rightstyle = PdfGridCellStyle(
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.right,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     for (int i = 0; i < estimateData.products!.length; i++) {
//       PdfGridRow productRow = prodcutGrid.rows.add();
//       productRow.cells[0].value = '$count';
//       productRow.cells[1].value = '${estimateData.products![i].productCode}';
//       productRow.cells[2].value = '${estimateData.products![i].productName}';
//       productRow.cells[3].value =
//           estimateData.products![i].discountLock == true ? "Yes" : "No";
//       productRow.cells[4].value = '${estimateData.products![i].qty}';
//       productRow.cells[5].value = '${estimateData.products![i].price}';
//       productRow.cells[6].value =
//           '${estimateData.products![i].qty! * estimateData.products![i].price!}';
//       productRow.cells[0].style = centerstyle;
//       productRow.cells[1].style = centerstyle;
//       productRow.cells[3].style = centerstyle;
//       productRow.cells[4].style = centerstyle;
//       productRow.cells[5].style = rightstyle;
//       productRow.cells[6].style = rightstyle;
//       count++;
//     }
//     // Product List End
//     PdfGridRow productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'SubTotal';
//     productRow.cells[6].value = '${estimateData.price!.subTotal}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'Discount';
//     productRow.cells[6].value = '${estimateData.price!.discountValue}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'Extra Discount';
//     productRow.cells[6].value = '${estimateData.price!.extraDiscountValue}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'Package Charges';
//     productRow.cells[6].value = '${estimateData.price!.packageValue}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value = 'Total';
//     productRow.cells[6].value = '${estimateData.price!.total}';
//     productRow.cells[0].columnSpan = 6;
//     productRow.cells[0].style = rightstyle;
//     productRow.cells[6].style = rightstyle;

//     productRow = prodcutGrid.rows.add();
//     productRow.cells[0].value =
//         'Total Items (${estimateData.products!.length})';
//     productRow.cells[3].value = 'Overall Total';
//     productRow.cells[6].value = '${estimateData.price!.total}';
//     productRow.cells[0].columnSpan = 2;
//     productRow.cells[3].columnSpan = 3;

//     productRow.cells[0].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         right: PdfPens.transparent,
//       ),
//     );
//     productRow.cells[2].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         left: PdfPens.transparent,
//         right: PdfPens.transparent,
//       ),
//     );
//     productRow.cells[3].style = PdfGridCellStyle(
//       borders: PdfBorders(
//         left: PdfPens.transparent,
//       ),
//       format: PdfStringFormat(
//         alignment: PdfTextAlignment.right,
//         lineAlignment: PdfVerticalAlignment.middle,
//         characterSpacing: 0.2,
//       ),
//     );
//     productRow.cells[6].style = rightstyle;

//     prodcutGrid.style.cellPadding = PdfPaddings(
//       left: 2,
//       right: 2,
//       bottom: 2,
//       top: 2,
//     );

//     prodcutGrid.draw(page: section.pages.add());
//     // Product Listing Table Section End

//     resultData = await document.save();

//     return resultData;
//   }

//   List<DiscountBillModel> discountList = [];

//   Future<Uint8List?> createPDFDemoA4(
//       {required pf.PdfPageFormat pageSize}) async {
//     final pdf = pw.Document();

//     for (var element in estimateData.products!) {
//       int index = discountList.indexWhere((discountElement) =>
//           discountElement.discount == element.discount.toString());
//       if (index != -1) {
//         discountList[index].products!.add(element);
//       } else {
//         DiscountBillModel bill = DiscountBillModel();
//         bill.discount = element.discount.toString();
//         bill.products = [];
//         bill.products!.add(element);
//         discountList.add(bill);
//       }
//     }

//     pdf.addPage(
//       pw.MultiPage(
//         margin: const pw.EdgeInsets.all(10),
//         pageFormat: pageSize,
//         footer: (context) {
//           return pw.Container(
//             margin: const pw.EdgeInsets.only(top: 5, bottom: 3),
//             child: pw.Center(
//               child: pw.Text(
//                 "Page ${context.pageNumber}/${context.pagesCount}",
//                 style: const pw.TextStyle(fontSize: 8),
//               ),
//             ),
//           );
//         },
//         header: (context) {
//           return pw.Column(
//             children: [
//               pw.Table(
//                 border: const pw.TableBorder(
//                   left: pw.BorderSide(color: pf.PdfColors.black),
//                   top: pw.BorderSide(color: pf.PdfColors.black),
//                   right: pw.BorderSide(color: pf.PdfColors.black),
//                   bottom: pw.BorderSide(color: pf.PdfColors.black),
//                 ),
//                 children: [
//                   pw.TableRow(
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Text(
//                           "${type == PdfType.enquiry ? 'Enquiry ID' : 'Estimate ID'} : ${estimateData.enquiryid ?? estimateData.referenceId}",
//                           style: const pw.TextStyle(
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Center(
//                           child: pw.Text(
//                             type == PdfType.enquiry ? "Enquiry" : "Estimate",
//                             style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold,
//                               fontSize: 10,
//                             ),
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Text(
//                           "Date: ${DateFormat('dd-MM-yyyy HH:mm a').format(estimateData.createddate!)}",
//                           textAlign: pw.TextAlign.right,
//                           style: const pw.TextStyle(
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.TableRow(
//                     decoration: const pw.BoxDecoration(
//                       border: pw.Border(
//                         top: pw.BorderSide(),
//                       ),
//                     ),
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Text(
//                           "${pageSize == pf.PdfPageFormat.a4 ? "Phone Number" : "Ph No"} : ${companyInfo.contact!["phone_no"] ?? ""}",
//                           style: const pw.TextStyle(
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Center(
//                           child: pw.Column(
//                             mainAxisSize: pw.MainAxisSize.min,
//                             children: [
//                               pw.Text(
//                                 "${companyInfo.companyName}",
//                                 style: pw.TextStyle(
//                                   fontWeight: pw.FontWeight.bold,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                               pw.Text(
//                                 "${companyInfo.address}",
//                                 textAlign: pw.TextAlign.center,
//                                 style: const pw.TextStyle(
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       // pw.Padding(
//                       //   padding: const pw.EdgeInsets.all(2),
//                       //   child: pw.Text(
//                       //     "Email: ${estimateData.customer!.email ?? ""}",
//                       //     textAlign: pw.TextAlign.right,
//                       //     style: const pw.TextStyle(
//                       //       fontSize: 10,
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ],
//               ),
//               pw.Table(
//                 border: const pw.TableBorder(
//                   left: pw.BorderSide(color: pf.PdfColors.black),
//                   top: pw.BorderSide(color: pf.PdfColors.black),
//                   right: pw.BorderSide(color: pf.PdfColors.black),
//                   bottom: pw.BorderSide(color: pf.PdfColors.black),
//                 ),
//                 children: [
//                   pw.TableRow(
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           mainAxisSize: pw.MainAxisSize.min,
//                           children: [
//                             pw.Text(
//                               "Customer Details",
//                               style: pw.TextStyle(
//                                 fontWeight: pw.FontWeight.bold,
//                                 fontSize: 10,
//                               ),
//                             ),
//                             pw.SizedBox(height: 6),
//                             pw.Text(
//                               "${estimateData.customer!.customerName ?? ""}\n${estimateData.customer!.address ?? ""}${estimateData.customer!.address != null ? ',' : ''}${estimateData.customer!.city ?? ""}${estimateData.customer!.city != null ? ',' : ''}${estimateData.customer!.state ?? ""}${estimateData.customer!.state != null ? ',' : ''}${estimateData.customer!.mobileNo ?? ""}",
//                               style: const pw.TextStyle(
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               pw.Table(
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(1),
//                   1: const pw.FlexColumnWidth(1.5),
//                   2: const pw.FlexColumnWidth(6),
//                   3: const pw.FlexColumnWidth(2),
//                   4: const pw.FlexColumnWidth(2),
//                   5: const pw.FlexColumnWidth(2),
//                   6: const pw.FlexColumnWidth(3),
//                 },
//                 border: pw.TableBorder.all(),
//                 // border: const pw.TableBorder(
//                 //   left: pw.BorderSide(color: pf.PdfColors.black),
//                 //   top: pw.BorderSide(color: pf.PdfColors.black),
//                 //   right: pw.BorderSide(color: pf.PdfColors.black),
//                 //   bottom: pw.BorderSide(color: pf.PdfColors.black),
//                 // ),
//                 children: [
//                   pw.TableRow(
//                     children: [
//                       pw.Center(
//                         child: pw.Padding(
//                           padding: const pw.EdgeInsets.all(2),
//                           child: pw.Text(
//                             "S.No",
//                             style: pw.TextStyle(
//                               fontSize:
//                                   pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       pw.Center(
//                         child: pw.Padding(
//                           padding: const pw.EdgeInsets.all(2),
//                           child: pw.Text(
//                             "Code",
//                             style: pw.TextStyle(
//                               fontSize:
//                                   pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       pw.Center(
//                         child: pw.Padding(
//                           padding: const pw.EdgeInsets.all(2),
//                           child: pw.Text(
//                             "Product Name",
//                             style: pw.TextStyle(
//                               fontSize:
//                                   pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       pw.Center(
//                         child: pw.Padding(
//                           padding: const pw.EdgeInsets.all(2),
//                           child: pw.Text(
//                             "Discount",
//                             style: pw.TextStyle(
//                               fontSize:
//                                   pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       pw.Center(
//                         child: pw.Padding(
//                           padding: const pw.EdgeInsets.all(2),
//                           child: pw.Text(
//                             "Qty",
//                             style: pw.TextStyle(
//                               fontSize:
//                                   pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       pw.Center(
//                         child: pw.Padding(
//                           padding: const pw.EdgeInsets.all(2),
//                           child: pw.Text(
//                             "Rate",
//                             style: pw.TextStyle(
//                               fontSize:
//                                   pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       pw.Center(
//                         child: pw.Padding(
//                           padding: const pw.EdgeInsets.all(2),
//                           child: pw.Text(
//                             "Amount",
//                             style: pw.TextStyle(
//                               fontSize:
//                                   pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//         build: (pw.Context context) {
//           return [
//             for (int j = 0; j < discountList.length; j++)
//               pw.Column(
//                 mainAxisSize: pw.MainAxisSize.min,
//                 children: [
//                   pw.Table(
//                     columnWidths: {
//                       0: const pw.FlexColumnWidth(1),
//                       1: const pw.FlexColumnWidth(1.5),
//                       2: const pw.FlexColumnWidth(6),
//                       3: const pw.FlexColumnWidth(2),
//                       4: const pw.FlexColumnWidth(2),
//                       5: const pw.FlexColumnWidth(2),
//                       6: const pw.FlexColumnWidth(3),
//                     },
//                     border: const TableBorder(
//                       verticalInside: pw.BorderSide(),
//                       left: pw.BorderSide(),
//                       right: pw.BorderSide(),
//                     ),
//                     // border: const pw.TableBorder(
//                     //   left: pw.BorderSide(color: pf.PdfColors.black),
//                     //   top: pw.BorderSide(color: pf.PdfColors.black),
//                     //   right: pw.BorderSide(color: pf.PdfColors.black),
//                     //   bottom: pw.BorderSide(color: pf.PdfColors.black),
//                     // ),
//                     children: [
//                       for (int i = 0; i < discountList[j].products!.length; i++)
//                         productTableListView(j, i, pageSize),
//                     ],
//                   ),
//                 ],
//               ),
//             pw.Expanded(
//               child: pw.Container(
//                 decoration: pw.BoxDecoration(
//                   border: pw.TableBorder.all(),
//                 ),
//                 child: pw.Row(
//                   children: [
//                     pw.Container(
//                       width: pageSize == pf.PdfPageFormat.a4 ? 33 : 23,
//                       decoration: const pw.BoxDecoration(
//                         border: pw.Border(
//                           right: pw.BorderSide(),
//                         ),
//                       ),
//                     ),
//                     pw.Container(
//                       width: pageSize == pf.PdfPageFormat.a4 ? 49 : 34,
//                       decoration: const pw.BoxDecoration(
//                         border: pw.Border(
//                           right: pw.BorderSide(),
//                         ),
//                       ),
//                     ),
//                     pw.Container(
//                       width: pageSize == pf.PdfPageFormat.a4 ? 197 : 137,
//                       decoration: const pw.BoxDecoration(
//                         border: pw.Border(
//                           right: pw.BorderSide(),
//                         ),
//                       ),
//                     ),
//                     pw.Container(
//                       width: pageSize == pf.PdfPageFormat.a4 ? 66 : 46,
//                       decoration: const pw.BoxDecoration(
//                         border: pw.Border(
//                           right: pw.BorderSide(),
//                         ),
//                       ),
//                     ),
//                     pw.Container(
//                       width: pageSize == pf.PdfPageFormat.a4 ? 66 : 46,
//                       decoration: const pw.BoxDecoration(
//                         border: pw.Border(
//                           right: pw.BorderSide(),
//                         ),
//                       ),
//                     ),
//                     pw.Container(
//                       width: pageSize == pf.PdfPageFormat.a4 ? 66 : 46,
//                       decoration: const pw.BoxDecoration(
//                         border: pw.Border(
//                           right: pw.BorderSide(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             pw.Container(
//               child: pw.Column(
//                 mainAxisSize: pw.MainAxisSize.min,
//                 children: [
//                   pw.Table(
//                     columnWidths: {
//                       0: const pw.FlexColumnWidth(14.5),
//                       1: const pw.FlexColumnWidth(3),
//                     },
//                     border: pw.TableBorder.all(),
//                     // border: const pw.TableBorder(
//                     //   left: pw.BorderSide(color: pf.PdfColors.black),
//                     //   top: pw.BorderSide(color: pf.PdfColors.black),
//                     //   right: pw.BorderSide(color: pf.PdfColors.black),
//                     //   bottom: pw.BorderSide(color: pf.PdfColors.black),
//                     // ),
//                     children: [
//                       calculationTableView(
//                           "Subtotal", estimateData.price!.subTotal.toString()),
//                       calculationTableView(
//                           "Discount (${estimateData.price!.discountsys == "%" ? '${estimateData.price!.discount}%' : 'Rs'})",
//                           estimateData.price!.discountValue.toString()),
//                       calculationTableView(
//                           "Extra Discount (${estimateData.price!.extraDiscountsys == "%" ? '${estimateData.price!.extraDiscount}%' : 'Rs'})",
//                           estimateData.price!.extraDiscountValue.toString()),
//                       calculationTableView(
//                           "Package Charges (${estimateData.price!.packagesys == "%" ? '${estimateData.price!.package}%' : 'Rs'})",
//                           estimateData.price!.packageValue.toString()),
//                       calculationTableView(
//                           "Round Off", estimateData.price!.roundOff.toString()),
//                       calculationTableView(
//                           "Total", estimateData.price!.total.toString()),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ];
//         },
//       ),
//     );
//     return await pdf.save();
//   }

//   Font? regularFont;
//   Font? boldFont;
//   pw.TextStyle? heading1;
//   pw.TextStyle? heading2;
//   pw.TextStyle? subtitle1;
//   pw.TextStyle? subtitle2;

//   Future<Uint8List?> create3InchPDF() async {
//     final pdf = pw.Document();
//     // regularFont = Font.ttf(await rootBundle.load('assets/fonts/times new roman.ttf'));
//     // boldFont = await fontFromAssetBundle('assets/fonts/times new roman bold.ttf');

//     heading1 = pw.TextStyle(
//       font: boldFont,
//       color: pf.PdfColors.black,
//       fontWeight: pw.FontWeight.bold,
//       fontSize: 11,
//     );
//     heading2 = pw.TextStyle(
//       font: boldFont,
//       color: pf.PdfColors.black,
//       fontWeight: pw.FontWeight.bold,
//       fontSize: 8,
//     );
//     subtitle1 = pw.TextStyle(
//       font: regularFont,
//       fontSize: 8,
//       fontWeight: pw.FontWeight.normal,
//     );
//     subtitle2 = pw.TextStyle(
//       font: regularFont,
//       fontSize: 8,
//       fontWeight: pw.FontWeight.normal,
//     );

//     pdf.addPage(
//       pw.Page(
//         pageFormat: pf.PdfPageFormat.roll80,
//         margin: const pw.EdgeInsets.all(10),
//         // theme: ThemeData.withFont(
//         //   base: regularFont,
//         // ),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Center(
//                 child: pw.Text(
//                   companyInfo.companyName ?? "",
//                   style: heading1,
//                 ),
//               ),
//               pw.SizedBox(height: 10),
//               pw.Center(
//                 child: pw.Text(
//                   companyInfo.address ?? "",
//                   textAlign: pw.TextAlign.center,
//                   style: subtitle1,
//                 ),
//               ),
//               // pw.SizedBox(height: 10),
//               pw.Center(
//                 child: pw.Text(
//                   companyInfo.contact!["mobile_no"].toString(),
//                   textAlign: pw.TextAlign.center,
//                   style: subtitle1,
//                 ),
//               ),
//               pw.SizedBox(height: 10),
//               // pw.Center(
//               //   child: pw.Text(
//               //     "Date: ${DateFormat('dd-MM-yyyy HH:mm a').format(estimateData.createddate!)}",
//               //     textAlign: pw.TextAlign.center,
//               //     style: subtitle1,
//               //   ),
//               // ),
//               // pw.Center(
//               //   child: pw.Text(
//               //     "No: ${estimateData.enquiryid}",
//               //     textAlign: pw.TextAlign.center,
//               //     style: subtitle1,
//               //   ),
//               // ),

//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Text(
//                     "No: ${estimateData.enquiryid ?? estimateData.referenceId}",
//                     textAlign: pw.TextAlign.center,
//                     style: subtitle1,
//                   ),
//                   pw.Text(
//                     "Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(estimateData.createddate!)}",
//                     textAlign: pw.TextAlign.center,
//                     style: subtitle1,
//                   ),
//                 ],
//               ),
//               pw.SizedBox(height: 15),
//               pw.Text(
//                 "Bill TO:\n\n${estimateData.customer!.customerName ?? ""}\n${estimateData.customer!.address ?? ""}${estimateData.customer!.address != null ? ',' : ''}${estimateData.customer!.city ?? ""}${estimateData.customer!.city != null ? ',' : ''}${estimateData.customer!.state ?? ""}${estimateData.customer!.state != null ? ',' : ''}${estimateData.customer!.mobileNo ?? ""}",
//                 textAlign: pw.TextAlign.left,
//                 style: subtitle1,
//               ),
//               pw.SizedBox(height: 15),
//               pw.Table(
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(2.5),
//                   1: const pw.FlexColumnWidth(1),
//                   2: const pw.FlexColumnWidth(1.5),
//                   3: const pw.FlexColumnWidth(1.5),
//                 },
//                 // border: pw.TableBorder.all(),
//                 border: const pw.TableBorder(
//                   // left: pw.BorderSide(color: pf.PdfColors.black),
//                   top: pw.BorderSide(color: pf.PdfColors.black),
//                   // right: pw.BorderSide(color: pf.PdfColors.black),
//                   bottom: pw.BorderSide(color: pf.PdfColors.black),
//                 ),
//                 children: [
//                   pw.TableRow(
//                     children: [
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Text(
//                           "PRODUCT NAME",
//                           textAlign: pw.TextAlign.left,
//                           style: heading2,
//                         ),
//                       ),
//                       pw.Center(
//                         child: pw.Padding(
//                           padding: const pw.EdgeInsets.all(2),
//                           child: pw.Text(
//                             "QTY",
//                             style: heading2,
//                           ),
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Text(
//                           "RATE",
//                           textAlign: pw.TextAlign.right,
//                           style: heading2,
//                         ),
//                       ),
//                       pw.Padding(
//                         padding: const pw.EdgeInsets.all(2),
//                         child: pw.Text(
//                           "AMOUNT",
//                           textAlign: pw.TextAlign.right,
//                           style: heading2,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               pw.Table(
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(2.5),
//                   1: const pw.FlexColumnWidth(1),
//                   2: const pw.FlexColumnWidth(1.5),
//                   3: const pw.FlexColumnWidth(1.5),
//                 },
//                 // // border: pw.TableBorder.all(),
//                 // border: const pw.TableBorder(
//                 //   // left: pw.BorderSide(color: pf.PdfColors.black),
//                 //   // top: pw.BorderSide(color: pf.PdfColors.black),
//                 //   // right: pw.BorderSide(color: pf.PdfColors.black),
//                 //   bottom: pw.BorderSide(color: pf.PdfColors.black),
//                 // ),
//                 children: [
//                   for (int i = 0; i < estimateData.products!.length; i++)
//                     productTableListView3Inch(i),
//                 ],
//               ),
//               pw.Table(
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(5),
//                   1: const pw.FlexColumnWidth(1.5),
//                 },
//                 // border: pw.TableBorder.all(),
//                 // border: const pw.TableBorder(
//                 //   left: pw.BorderSide(color: pf.PdfColors.black),
//                 //   top: pw.BorderSide(color: pf.PdfColors.black),
//                 //   right: pw.BorderSide(color: pf.PdfColors.black),
//                 //   bottom: pw.BorderSide(color: pf.PdfColors.black),
//                 // ),
//                 children: [
//                   calculationTableView3Inch("Subtotal",
//                       estimateData.price!.subTotal!.toStringAsFixed(2)),
//                   estimateData.price!.discount != 0
//                       ? calculationTableView3Inch(
//                           "Discount (${estimateData.price!.discount}${estimateData.price!.discountsys})",
//                           estimateData.price!.discountValue!.toStringAsFixed(2))
//                       : const pw.TableRow(children: []),
//                   estimateData.price!.extraDiscount != 0
//                       ? calculationTableView3Inch(
//                           "Extra Discount (${estimateData.price!.extraDiscount}${estimateData.price!.extraDiscountsys})",
//                           estimateData.price!.extraDiscountValue!
//                               .toStringAsFixed(2))
//                       : const pw.TableRow(children: []),
//                   estimateData.price!.package != 0
//                       ? calculationTableView3Inch(
//                           "Package Charges (${estimateData.price!.package}${estimateData.price!.packagesys})",
//                           estimateData.price!.packageValue!.toStringAsFixed(2))
//                       : const pw.TableRow(children: []),
//                   calculationTableView3Inch(
//                       "Total", estimateData.price!.total!.toStringAsFixed(2)),
//                 ],
//               ),
//               pw.SizedBox(height: 10),
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Text(
//                     "No Product : ${estimateData.products!.length}",
//                     textAlign: pw.TextAlign.center,
//                     style: heading2,
//                   ),
//                   pw.Text(
//                     "No QTY : ${getItems()}",
//                     textAlign: pw.TextAlign.center,
//                     style: heading2,
//                   ),
//                 ],
//               ),
//               // pw.Center(
//               //   child: pw.Text(
//               //     "Total Items: ",
//               //     style: pw.TextStyle(
//               //       color: pf.PdfColors.black,
//               //       fontWeight: pw.FontWeight.bold,
//               //     ),
//               //   ),
//               // ),
//               pw.SizedBox(height: 40),
//             ],
//           );
//         },
//       ),
//     );
//     return await pdf.save();
//   }

//   pw.TableRow calculationTableView(String title, String value) {
//     return pw.TableRow(
//       children: [
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             title,
//             textAlign: pw.TextAlign.right,
//             style: const pw.TextStyle(
//               fontSize: 10,
//             ),
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             value,
//             textAlign: pw.TextAlign.right,
//             style: const pw.TextStyle(
//               fontSize: 10,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   pw.TableRow productTableListView(int j, int i, pf.PdfPageFormat pageSize) {
//     var element = discountList[j].products![i];
//     return pw.TableRow(
//       children: [
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Center(
//             child: pw.Text(
//               (i + 1).toString(),
//               style: pw.TextStyle(
//                 fontSize: pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//               ),
//             ),
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Center(
//             child: pw.Text(
//               element.productCode ?? "",
//               style: pw.TextStyle(
//                 fontSize: pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//               ),
//             ),
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             element.productName ?? "",
//             style: pw.TextStyle(
//               fontSize: pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//             ),
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Center(
//             child: pw.Text(
//               element.discountLock != null
//                   ? element.discountLock == true
//                       ? "YES"
//                       : "NO"
//                   : "",
//               style: pw.TextStyle(
//                 fontSize: pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//               ),
//             ),
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Center(
//             child: pw.Text(
//               element.qty != null ? element.qty.toString() : "",
//               style: pw.TextStyle(
//                 fontSize: pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//               ),
//             ),
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             element.price != null ? element.price!.toStringAsFixed(2) : "",
//             textAlign: pw.TextAlign.right,
//             style: pw.TextStyle(
//               fontSize: pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//             ),
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             element.qty != null && element.price != null
//                 ? (double.parse(element.qty.toString()) * element.price!)
//                     .toStringAsFixed(2)
//                 : "",
//             textAlign: pw.TextAlign.right,
//             style: pw.TextStyle(
//               fontSize: pageSize == pf.PdfPageFormat.a4 ? 10 : 8,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   pw.TableRow productTableListView3Inch(int i) {
//     var element = estimateData.products![i];
//     return pw.TableRow(
//       decoration: const pw.BoxDecoration(
//         border: pw.Border(
//           bottom: pw.BorderSide(
//             color: pf.PdfColors.grey400,
//           ),
//         ),
//       ),
//       children: [
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             element.productName ?? "",
//             style: subtitle1,
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Center(
//             child: pw.Text(
//               element.qty != null ? element.qty.toString() : "",
//               style: subtitle1,
//             ),
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             element.price != null ? element.price!.toStringAsFixed(2) : "",
//             textAlign: pw.TextAlign.right,
//             style: subtitle1,
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             element.qty != null && element.price != null
//                 ? (double.parse(element.qty.toString()) * element.price!)
//                     .toStringAsFixed(2)
//                 : "",
//             textAlign: pw.TextAlign.right,
//             style: subtitle1,
//           ),
//         ),
//       ],
//     );
//   }

//   pw.TableRow calculationTableView3Inch(String title, String value) {
//     return pw.TableRow(
//       decoration: title.toLowerCase() == "total"
//           ? const pw.BoxDecoration(
//               border: pw.Border(
//                 bottom: pw.BorderSide(
//                   color: pf.PdfColors.black,
//                 ),
//                 top: pw.BorderSide(
//                   color: pf.PdfColors.black,
//                 ),
//               ),
//             )
//           : null,
//       children: [
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             title,
//             textAlign: pw.TextAlign.right,
//             style: subtitle2,
//           ),
//         ),
//         pw.Padding(
//           padding: const pw.EdgeInsets.all(2),
//           child: pw.Text(
//             value,
//             textAlign: pw.TextAlign.right,
//             style: subtitle2,
//           ),
//         ),
//       ],
//     );
//   }

//   String getItems() {
//     String count = "0";
//     int tmpcount = 0;
//     for (var element in estimateData.products!) {
//       tmpcount += element.qty!;
//     }
//     count = tmpcount.toString();
//     return count;
//   }
// }