class ExcelCategoryClass {
  final String categoryname;
  final List<ExcelProductClass> product;
  ExcelCategoryClass({
    required this.categoryname,
    required this.product,
  });
}

class ExcelProductClass {
  final String productno;
  final String productname;
  final String content;
  final String price;
  final String discountlock;
  final String qrcode;
  String? discount;
  String? taxValue;
  String? hsnCode;
  ExcelProductClass({
    required this.productno,
    required this.productname,
    required this.content,
    required this.price,
    required this.discountlock,
    required this.qrcode,
    required this.discount,
    required this.taxValue,
    required this.hsnCode,
  });
}
