import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '/model/model.dart';

class EnquiryExcel {
  final List<EstimateDataModel> enquiryData;
  final bool isEstimate;

  EnquiryExcel({required this.enquiryData, required this.isEstimate});

  Future<List<int>?> createCustomerExcel() async {
    List<int>? resultData;

    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value =
        TextCellValue('S.No');
    if (isEstimate) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = TextCellValue('Estimate ID');
    } else {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = TextCellValue('Enquiry ID');
    }

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value =
        TextCellValue('Customer Name');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value =
        TextCellValue('Customer Address');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value =
        TextCellValue('Enquiry Date');
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

    for (var i = 0; i < enquiryData.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: (i + 1)))
          .value = TextCellValue((i + 1).toString());
      if (isEstimate) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: (i + 1)))
            .value = TextCellValue(enquiryData[i]
                .estimateid ??
            enquiryData[i].referenceId ??
            '');
      } else {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: (i + 1)))
            .value = TextCellValue(enquiryData[i]
                .enquiryid ??
            enquiryData[i].referenceId ??
            '');
      }
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[i].customer != null &&
              enquiryData[i].customer!.customerName != null
          ? enquiryData[i].customer!.customerName!
          : "Counter Sales");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[i].customer != null &&
              enquiryData[i].customer!.address != null
          ? enquiryData[i].customer!.address!
          : "---");
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: (i + 1)))
          .value = TextCellValue(DateFormat(
              'dd-MM-yyyy hh:mm a')
          .format(enquiryData[i].createddate!));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[
              i]
          .price!
          .subTotal!
          .toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[
              i]
          .price!
          .discountValue!
          .toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[
              i]
          .price!
          .extraDiscountValue!
          .toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[
              i]
          .price!
          .packageValue!
          .toStringAsFixed(2));
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: (i + 1)))
          .value = TextCellValue(enquiryData[
              i]
          .price!
          .total!
          .toStringAsFixed(2));
    }

    resultData = excel.save();

    return resultData;
  }
}
