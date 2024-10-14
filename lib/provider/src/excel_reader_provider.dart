import 'dart:io';
import 'package:excel/excel.dart';
import '/model/class.dart';

class ExcelReaderProvider {
  Future<List<ExcelCategoryClass>?> readExcelData({required File file}) async {
    List<ExcelCategoryClass> excelData = [];
    try {
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      Map<String, ExcelCategoryClass> categoryMap = {};

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];

        for (var row in sheet!.rows) {
          if (row[0]?.value == null) continue;
          var productNo = row[0]?.value.toString();
          var categoryName = row[1]?.value.toString();
          var productName = row[2]?.value.toString();
          var content = row[3]?.value.toString();
          var price = row[4]?.value.toString();

          if (!categoryMap.containsKey(categoryName)) {
            categoryMap[categoryName!] = ExcelCategoryClass(
              categoryname: categoryName,
              product: [],
            );
            excelData.add(categoryMap[categoryName]!);
          }

          categoryMap[categoryName]!.product.add(ExcelProductClass(
                productno: productNo.toString(),
                productname: productName.toString(),
                content: content.toString(),
                price: price ?? '',
                discountlock: "0",
                qrcode: "1",
                discount: null,
                taxValue: null,
                hsnCode: null,
              ));
        }
      }
    } catch (e) {
      throw 'Error: ${e.toString()}';
    }
    return excelData.isNotEmpty ? excelData : null;
  }
}
