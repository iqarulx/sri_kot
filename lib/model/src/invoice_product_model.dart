// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import '../../constants/constants.dart';

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
  String? hsnCode;
  String? taxValue;
  ProductType? productType;
  double? discountedPrice;

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
    this.hsnCode,
    this.taxValue,
    this.productType,
    this.discountedPrice,
  });

  InvoiceProductModel copyWith({
    String? productName,
    String? productID,
    int? qty,
    String? unit,
    double? rate,
    double? total,
    int? discount,
    bool? discountLock,
    String? categoryID,
    String? docID,
    String? hsnCode,
    String? taxValue,
    ProductType? productType,
    double? discountedPrice,
  }) {
    return InvoiceProductModel(
      productName: productName ?? this.productName,
      productID: productID ?? this.productID,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      discountLock: discountLock ?? this.discountLock,
      categoryID: categoryID ?? this.categoryID,
      docID: docID ?? this.docID,
      hsnCode: hsnCode ?? this.hsnCode,
      taxValue: taxValue ?? this.taxValue,
      productType: productType ?? this.productType,
      discountedPrice: discountedPrice ?? this.discountedPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productName': productName,
      'productID': productID,
      'qty': qty,
      'unit': unit,
      'rate': rate,
      'total': total,
      'discount': discount,
      'discountLock': discountLock,
      'categoryID': categoryID,
      'docID': docID,
      'hsnCode': hsnCode,
      'taxValue': taxValue,
      'productType': productType,
      'discountedPrice': discountedPrice,
    };
  }

  factory InvoiceProductModel.fromMap(Map<String, dynamic> map) {
    return InvoiceProductModel(
      productName:
          map['productName'] != null ? map['productName'] as String : null,
      productID: map['productID'] != null ? map['productID'] as String : null,
      qty: map['qty'] != null ? map['qty'] as int : null,
      unit: map['unit'] != null ? map['unit'] as String : null,
      rate: map['rate'] != null ? map['rate'] as double : null,
      total: map['total'] != null ? map['total'] as double : null,
      discount: map['discount'] != null ? map['discount'] as int : null,
      discountLock:
          map['discountLock'] != null ? map['discountLock'] as bool : null,
      categoryID:
          map['categoryID'] != null ? map['categoryID'] as String : null,
      docID: map['docID'] != null ? map['docID'] as String : null,
      hsnCode: map['hsnCode'] != null ? map['hsnCode'] as String : null,
      taxValue: map['taxValue'] != null ? map['taxValue'] as String : null,
      discountedPrice: map['discountedPrice'] != null
          ? map['discountedPrice'] as double
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory InvoiceProductModel.fromJson(String source) =>
      InvoiceProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'InvoiceProductModel(productName: $productName, productID: $productID, qty: $qty, unit: $unit, rate: $rate, total: $total, discount: $discount, discountLock: $discountLock, categoryID: $categoryID, docID: $docID, hsnCode: $hsnCode, taxValue: $taxValue, productType: $productType, discountedPrice: $discountedPrice)';
  }

  @override
  bool operator ==(covariant InvoiceProductModel other) {
    if (identical(this, other)) return true;

    return other.productName == productName &&
        other.productID == productID &&
        other.qty == qty &&
        other.unit == unit &&
        other.rate == rate &&
        other.total == total &&
        other.discount == discount &&
        other.discountLock == discountLock &&
        other.categoryID == categoryID &&
        other.docID == docID &&
        other.hsnCode == hsnCode &&
        other.taxValue == taxValue &&
        other.productType == productType &&
        other.discountedPrice == discountedPrice;
  }

  @override
  int get hashCode {
    return productName.hashCode ^
        productID.hashCode ^
        qty.hashCode ^
        unit.hashCode ^
        rate.hashCode ^
        total.hashCode ^
        discount.hashCode ^
        discountLock.hashCode ^
        categoryID.hashCode ^
        docID.hashCode ^
        hsnCode.hashCode ^
        taxValue.hashCode ^
        productType.hashCode ^
        discountedPrice.hashCode;
  }

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
    mapping["tax_value"] = taxValue;
    mapping["hsn_code"] = hsnCode;
    mapping["product_type"] = productType!.name;
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
    mapping["tax_value"] = taxValue;
    mapping["hsn_code"] = hsnCode;
    mapping["product_type"] = productType!.name;
    mapping["discount_lock"] = discountLock;

    return mapping;
  }
}
