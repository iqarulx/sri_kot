import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '/model/model.dart';

class InvoiceExcel {
  final List<InvoiceModel> inviceData;

  InvoiceExcel({required this.inviceData});

  Future<List<int>?> createInvoiceExcel() async {
    List<int>? resultData;

    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('S.No');

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value =
        TextCellValue('Invoice Number');

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        TextCellValue('Customer Name');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        TextCellValue('Customer Address');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        TextCellValue('Invoice Date');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value =
        TextCellValue('Subtotal');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value =
        TextCellValue('Discount');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value =
        TextCellValue('Extra Discount');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0)).value =
        TextCellValue('Packing Charges');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0)).value =
        TextCellValue('Total Amount');

    for (var i = 0; i < inviceData.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: (i + 1)))
          .value = TextCellValue((i + 1).toString());
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[i].billNo!);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[i].partyName ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[i].address ?? "");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: (i + 1)))
          .value = TextCellValue(DateFormat(
              'dd-MM-yyyy hh:mm a')
          .format(inviceData[i].billDate!));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[
              i]
          .price!
          .subTotal!
          .toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[
              i]
          .price!
          .discountValue!
          .toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[
              i]
          .price!
          .extraDiscountValue!
          .toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[
              i]
          .price!
          .packageValue!
          .toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: (i + 1)))
          .value = TextCellValue(inviceData[i].totalBillAmount ?? "");
    }

    resultData = excel.save();

    return resultData;
  }
}
