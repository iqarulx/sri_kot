import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
part 'product_data_model.g.dart';

@JsonSerializable()
class ProductDataModel {
  String? categoryid;
  String? categoryName;
  String? productName;
  String? productCode;
  String? productContent;
  String? qrCode;
  double? price;
  String? videoUrl;
  String? productImg;
  bool? active;
  String? companyId;
  bool? discountLock;
  bool? delete;
  String? name;
  String? productId;
  TextEditingController? qtyForm;
  int? qty;
  String? docid;
  int? postion;
  int? discount;
  DateTime? createdDateTime;
  String? hsnCode;

  ProductDataModel({
    this.categoryid,
    this.categoryName,
    this.productName,
    this.productCode,
    this.productContent,
    this.qrCode,
    this.price,
    this.videoUrl,
    this.productImg,
    this.active,
    this.companyId,
    this.discountLock,
    this.delete,
    this.name,
    this.productId,
    this.qty,
    this.docid,
    this.postion,
    this.discount,
    this.createdDateTime,
    this.hsnCode,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) =>
      _$ProductDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDataModelToJson(this);

  Map<String, dynamic> updateMap() {
    var mapping = <String, dynamic>{};
    mapping["active"] = active;
    mapping["category_id"] = categoryid;
    mapping["discount_lock"] = discountLock;
    mapping["price"] = price;
    mapping["product_code"] = productCode;
    mapping["product_content"] = productContent;
    mapping["product_name"] = productName;
    mapping["qr_code"] = qrCode;
    mapping["video_url"] = videoUrl;
    mapping["name"] = name;
    mapping["hsn_code"] = hsnCode;
    return mapping;
  }

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["active"] = active;
    mapping["category_id"] = categoryid;
    mapping["category_name"] = categoryName;
    mapping["company_id"] = companyId;
    mapping["discount_lock"] = discountLock;
    mapping["price"] = price;
    mapping["product_code"] = productCode;
    mapping["product_content"] = productContent;
    mapping["product_name"] = productName;
    mapping["qr_code"] = qrCode;
    mapping["video_url"] = videoUrl;
    mapping["product_img"] = productImg;
    mapping["delete_at"] = delete;
    mapping["name"] = name;
    mapping["postion"] = postion;
    mapping["hsn_code"] = hsnCode;
    mapping["created_date_time"] =
        createdDateTime?.toIso8601String(); // Convert DateTime to string
    return mapping;
  }
}
