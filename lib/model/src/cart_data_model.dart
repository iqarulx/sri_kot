import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_data_model.g.dart';

@JsonSerializable()
class CartDataModel {
  String? categoryId;
  String? categoryName;
  String? productName;
  String? productId;
  String? productImg;
  bool? discountLock;
  String? productCode;
  String? productContent;
  String? qrCode;
  String? videoUrl;
  double? price;
  String? mrp;
  int? qty;
  // Exclude non-serializable fields
  TextEditingController? qtyForm;
  String? name;
  String? docID;
  int? discount;

  CartDataModel({
    this.categoryId,
    this.categoryName,
    this.productName,
    this.productId,
    this.productImg,
    this.discountLock,
    this.productCode,
    this.productContent,
    this.qrCode,
    this.videoUrl,
    this.price,
    this.mrp,
    this.qty,
    this.name,
    this.docID,
    this.discount,
  });

  factory CartDataModel.fromJson(Map<String, dynamic> json) =>
      _$CartDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartDataModelToJson(this);

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["category_id"] = categoryId;
    mapping["category_name"] = categoryName;
    mapping["product_name"] = productName;
    mapping["product_id"] = productId;
    mapping["product_img"] = productImg;
    mapping["price"] = price;
    mapping["mrp"] = mrp;
    mapping["qty"] = qty;
    mapping["product_code"] = productCode;
    mapping["discount_lock"] = discountLock;
    mapping["product_content"] = productContent;
    mapping["qr_code"] = qrCode;
    mapping["video_url"] = videoUrl;
    mapping["name"] = name;
    return mapping;
  }
}
