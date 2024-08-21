import 'package:json_annotation/json_annotation.dart';

part 'invoice_product_model.g.dart';

@JsonSerializable()
class InvoiceProductModel {
  String? productName;
  String? productID;
  int? qty;
  String? unit;
  double? rate;
  double? total;
  int? discount;
  bool? discountLock;
  String? categoryID;
  String? docID;

  InvoiceProductModel({
    this.productName,
    this.productID,
    this.qty,
    this.unit,
    this.rate,
    this.total,
    this.discount,
    this.discountLock,
    this.categoryID,
    this.docID,
  });

  factory InvoiceProductModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceProductModelToJson(this);

  Map<String, dynamic> toCreateMap() {
    var mapping = <String, dynamic>{};
    mapping["product_name"] = productName;
    mapping["product_id"] = productID;
    mapping["qty"] = qty;
    mapping["unit"] = unit;
    mapping["rate"] = rate;
    mapping["total"] = total;
    mapping["discount"] = discount;
    mapping["category_id"] = categoryID;
    mapping["discount_lock"] = discountLock;
    return mapping;
  }

  Map<String, dynamic> toUpdateMap() {
    var mapping = <String, dynamic>{};
    mapping["product_name"] = productName;
    mapping["product_id"] = productID;
    mapping["qty"] = qty;
    mapping["unit"] = unit;
    mapping["rate"] = rate;
    mapping["total"] = total;
    mapping["discount"] = discount;
    mapping["category_id"] = categoryID;
    mapping["discount_lock"] = discountLock;
    return mapping;
  }
}
