// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../constants/constants.dart';

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
  String? taxValue;
  ProductType? productType;
  double? discountedPrice;

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
    this.qtyForm,
    this.qty,
    this.docid,
    this.postion,
    this.discount,
    this.createdDateTime,
    this.hsnCode,
    this.taxValue,
  });

  ProductDataModel copyWith({
    String? categoryid,
    String? categoryName,
    String? productName,
    String? productCode,
    String? productContent,
    String? qrCode,
    double? price,
    String? videoUrl,
    String? productImg,
    bool? active,
    String? companyId,
    bool? discountLock,
    bool? delete,
    String? name,
    String? productId,
    TextEditingController? qtyForm,
    int? qty,
    String? docid,
    int? postion,
    int? discount,
    DateTime? createdDateTime,
    String? hsnCode,
  }) {
    return ProductDataModel(
      categoryid: categoryid ?? this.categoryid,
      categoryName: categoryName ?? this.categoryName,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      productContent: productContent ?? this.productContent,
      qrCode: qrCode ?? this.qrCode,
      price: price ?? this.price,
      videoUrl: videoUrl ?? this.videoUrl,
      productImg: productImg ?? this.productImg,
      active: active ?? this.active,
      companyId: companyId ?? this.companyId,
      discountLock: discountLock ?? this.discountLock,
      delete: delete ?? this.delete,
      name: name ?? this.name,
      productId: productId ?? this.productId,
      qtyForm: qtyForm ?? this.qtyForm,
      qty: qty ?? this.qty,
      docid: docid ?? this.docid,
      postion: postion ?? this.postion,
      discount: discount ?? this.discount,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      hsnCode: hsnCode ?? this.hsnCode,
    );
  }

  factory ProductDataModel.fromMap(Map<String, dynamic> map) {
    return ProductDataModel(
      categoryid:
          map['categoryid'] != null ? map['categoryid'] as String : null,
      categoryName:
          map['categoryName'] != null ? map['categoryName'] as String : null,
      productName:
          map['productName'] != null ? map['productName'] as String : null,
      productCode:
          map['productCode'] != null ? map['productCode'] as String : null,
      productContent: map['productContent'] != null
          ? map['productContent'] as String
          : null,
      qrCode: map['qrCode'] != null ? map['qrCode'] as String : null,
      price: map['price'] != null ? map['price'] as double : null,
      videoUrl: map['videoUrl'] != null ? map['videoUrl'] as String : null,
      productImg:
          map['productImg'] != null ? map['productImg'] as String : null,
      active: map['active'] != null ? map['active'] as bool : null,
      companyId: map['companyId'] != null ? map['companyId'] as String : null,
      discountLock:
          map['discountLock'] != null ? map['discountLock'] as bool : null,
      delete: map['delete'] != null ? map['delete'] as bool : null,
      name: map['name'] != null ? map['name'] as String : null,
      productId: map['productId'] != null ? map['productId'] as String : null,
      qtyForm: map['qtyForm'] != null
          ? TextEditingController.fromValue(map['qtyForm'])
          : null,
      qty: map['qty'] != null ? map['qty'] as int : null,
      docid: map['docid'] != null ? map['docid'] as String : null,
      postion: map['postion'] != null ? map['postion'] as int : null,
      discount: map['discount'] != null ? map['discount'] as int : null,
      createdDateTime: map['createdDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdDateTime'] as int)
          : null,
      hsnCode: map['hsnCode'] != null ? map['hsnCode'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductDataModel.fromJson(String source) =>
      ProductDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductDataModel(categoryid: $categoryid, categoryName: $categoryName, productName: $productName, productCode: $productCode, productContent: $productContent, qrCode: $qrCode, price: $price, videoUrl: $videoUrl, productImg: $productImg, active: $active, companyId: $companyId, discountLock: $discountLock, delete: $delete, name: $name, productId: $productId, qtyForm: $qtyForm, qty: $qty, docid: $docid, postion: $postion, discount: $discount, createdDateTime: $createdDateTime, hsnCode: $hsnCode)';
  }

  @override
  bool operator ==(covariant ProductDataModel other) {
    if (identical(this, other)) return true;

    return other.categoryid == categoryid &&
        other.categoryName == categoryName &&
        other.productName == productName &&
        other.productCode == productCode &&
        other.productContent == productContent &&
        other.qrCode == qrCode &&
        other.price == price &&
        other.videoUrl == videoUrl &&
        other.productImg == productImg &&
        other.active == active &&
        other.companyId == companyId &&
        other.discountLock == discountLock &&
        other.delete == delete &&
        other.name == name &&
        other.productId == productId &&
        other.qtyForm == qtyForm &&
        other.qty == qty &&
        other.docid == docid &&
        other.postion == postion &&
        other.discount == discount &&
        other.createdDateTime == createdDateTime &&
        other.hsnCode == hsnCode;
  }

  @override
  int get hashCode {
    return categoryid.hashCode ^
        categoryName.hashCode ^
        productName.hashCode ^
        productCode.hashCode ^
        productContent.hashCode ^
        qrCode.hashCode ^
        price.hashCode ^
        videoUrl.hashCode ^
        productImg.hashCode ^
        active.hashCode ^
        companyId.hashCode ^
        discountLock.hashCode ^
        delete.hashCode ^
        name.hashCode ^
        productId.hashCode ^
        qtyForm.hashCode ^
        qty.hashCode ^
        docid.hashCode ^
        postion.hashCode ^
        discount.hashCode ^
        createdDateTime.hashCode ^
        hsnCode.hashCode;
  }

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
    mapping["tax_value"] = taxValue;
    mapping["hsn_code"] = hsnCode;
    mapping["product_type"] = productType!.name;
    mapping["discount"] = discount;
    mapping["created_date_time"] = createdDateTime?.toIso8601String();
    return mapping;
  }
}
