// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../constants/constants.dart';

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
  int? qty;
  // Exclude non-serializable fields
  TextEditingController? qtyForm;
  String? name;
  String? docID;
  int? discount;
  ProductType? productType;
  double? discountedPrice;
  String? taxValue;
  String? hsnCode;

  CartDataModel(
      {this.categoryId,
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
      this.qty,
      this.qtyForm,
      this.name,
      this.docID,
      this.discount,
      this.productType,
      this.taxValue,
      this.hsnCode});

  CartDataModel copyWith({
    String? categoryId,
    String? categoryName,
    String? productName,
    String? productId,
    String? productImg,
    bool? discountLock,
    String? productCode,
    String? productContent,
    String? qrCode,
    String? videoUrl,
    double? price,
    int? qty,
    TextEditingController? qtyForm,
    String? name,
    String? docID,
    int? discount,
  }) {
    return CartDataModel(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      productName: productName ?? this.productName,
      productId: productId ?? this.productId,
      productImg: productImg ?? this.productImg,
      discountLock: discountLock ?? this.discountLock,
      productCode: productCode ?? this.productCode,
      productContent: productContent ?? this.productContent,
      qrCode: qrCode ?? this.qrCode,
      videoUrl: videoUrl ?? this.videoUrl,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      qtyForm: qtyForm ?? this.qtyForm,
      name: name ?? this.name,
      docID: docID ?? this.docID,
      discount: discount ?? this.discount,
    );
  }

  factory CartDataModel.fromMap(Map<String, dynamic> map) {
    return CartDataModel(
      categoryId:
          map['categoryId'] != null ? map['categoryId'] as String : null,
      categoryName:
          map['categoryName'] != null ? map['categoryName'] as String : null,
      productName:
          map['productName'] != null ? map['productName'] as String : null,
      productId: map['productId'] != null ? map['productId'] as String : null,
      productImg:
          map['productImg'] != null ? map['productImg'] as String : null,
      discountLock:
          map['discountLock'] != null ? map['discountLock'] as bool : null,
      productCode:
          map['productCode'] != null ? map['productCode'] as String : null,
      productContent: map['productContent'] != null
          ? map['productContent'] as String
          : null,
      qrCode: map['qrCode'] != null ? map['qrCode'] as String : null,
      videoUrl: map['videoUrl'] != null ? map['videoUrl'] as String : null,
      price: map['price'] != null ? map['price'] as double : null,
      qty: map['qty'] != null ? map['qty'] as int : null,
      qtyForm: map['qtyForm'] != null
          ? TextEditingController.fromValue(map['qtyForm'])
          : null,
      name: map['name'] != null ? map['name'] as String : null,
      docID: map['docID'] != null ? map['docID'] as String : null,
      discount: map['discount'] != null ? map['discount'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartDataModel.fromJson(String source) =>
      CartDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CartDataModel(categoryId: $categoryId, categoryName: $categoryName, productName: $productName, productId: $productId, productImg: $productImg, discountLock: $discountLock, productCode: $productCode, productContent: $productContent, qrCode: $qrCode, videoUrl: $videoUrl, price: $price, qty: $qty, qtyForm: $qtyForm, name: $name, docID: $docID, discount: $discount)';
  }

  @override
  bool operator ==(covariant CartDataModel other) {
    if (identical(this, other)) return true;

    return other.categoryId == categoryId &&
        other.categoryName == categoryName &&
        other.productName == productName &&
        other.productId == productId &&
        other.productImg == productImg &&
        other.discountLock == discountLock &&
        other.productCode == productCode &&
        other.productContent == productContent &&
        other.qrCode == qrCode &&
        other.videoUrl == videoUrl &&
        other.price == price &&
        other.qty == qty &&
        other.qtyForm == qtyForm &&
        other.name == name &&
        other.docID == docID &&
        other.discount == discount;
  }

  @override
  int get hashCode {
    return categoryId.hashCode ^
        categoryName.hashCode ^
        productName.hashCode ^
        productId.hashCode ^
        productImg.hashCode ^
        discountLock.hashCode ^
        productCode.hashCode ^
        productContent.hashCode ^
        qrCode.hashCode ^
        videoUrl.hashCode ^
        price.hashCode ^
        qty.hashCode ^
        qtyForm.hashCode ^
        name.hashCode ^
        docID.hashCode ^
        discount.hashCode;
  }

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["category_id"] = categoryId;
    mapping["category_name"] = categoryName;
    mapping["product_name"] = productName;
    mapping["product_id"] = productId;
    mapping["product_img"] = productImg;
    mapping["discount"] = discount;
    mapping["price"] = price;
    mapping["qty"] = qty;
    mapping["product_code"] = productCode;
    mapping["discount_lock"] = discountLock;
    mapping["product_content"] = productContent;
    mapping["qr_code"] = qrCode;
    mapping["video_url"] = videoUrl;
    mapping["name"] = name;
    mapping["product_type"] = productType!.name;
    mapping["discounted_price"] = discountedPrice;
    mapping["hsn_code"] = hsnCode;
    mapping["tax_value"] = taxValue;

    return mapping;
  }
}
