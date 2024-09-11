import 'dart:io';
import 'package:excel/excel.dart';
import '/model/class.dart';

class ExcelReaderProvider {
  Future<List<ExcelCategoryClass>?> readExcelData({required File file}) async {
    List<ExcelCategoryClass>? excelData = [];
    try {
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      print(excel.tables.keys.length);
      print(excel.tables.keys.first.codeUnits);

      if (excel.tables.keys.isNotEmpty) {
        for (var table in excel.tables.keys) {
          print("hiiii");
          print(excel.tables[table]!.rows.length);

          for (var row in excel.tables[table]!.rows) {
            print("Hiii");
            print(row.first?.value?.toString() ?? 'No value');

            if ((row[0]?.value?.toString().isEmpty ?? true) &&
                (row[1]?.value?.toString().isEmpty ?? true) &&
                (row[2]?.value?.toString().isEmpty ?? true) &&
                (row[3]?.value?.toString().isEmpty ?? true)) {
              print("Row is empty skipped, moving to next row");
              continue;
            } else if ((row[0]?.value?.toString().isEmpty ?? true) &&
                (row[2]?.value?.toString().isEmpty ?? true) &&
                (row[3]?.value?.toString().isEmpty ?? true)) {
              print(
                  "Category added: ${row[1]?.value?.toString() ?? 'Category not found'}");
              excelData.add(
                ExcelCategoryClass(
                  categoryname: row[1]?.value?.toString() ?? '',
                  product: [],
                ),
              );
            } else {
              excelData[excelData.length - 1].product.add(
                    ExcelProductClass(
                      productno: row[0]?.value?.toString() ?? '',
                      productname: row[1]?.value?.toString() ?? '',
                      content: row[2]?.value?.toString() ?? '',
                      price: row[3]?.value?.toString() ?? '',
                      discountlock: "0", // Assuming default for now
                      qrcode: "1", // Assuming default for now
                    ),
                  );
              print(
                  "Product added: ${row[1]?.value?.toString() ?? 'Product name not found'}");
            }
          }
          // break; // If you want to process only the first table, otherwise remove
        }
      } else {
        throw "Excel is empty";
      }
    } catch (e) {
      throw e.toString();
    }
    return excelData;
  }
}
