// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'product_data_model.dart';

class DiscountBillModel {
  List<ProductDataModel>? products;
  String? discount;

  DiscountBillModel({
    this.products,
    this.discount,
  });

  DiscountBillModel copyWith({
    List<ProductDataModel>? products,
    String? discount,
  }) {
    return DiscountBillModel(
      products: products ?? this.products,
      discount: discount ?? this.discount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'products': products!.map((x) => x.toMap()).toList(),
      'discount': discount,
    };
  }

  factory DiscountBillModel.fromMap(Map<String, dynamic> map) {
    return DiscountBillModel(
      products: map['products'] != null
          ? List<ProductDataModel>.from(
              (map['products'] as List<int>).map<ProductDataModel?>(
                (x) => ProductDataModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      discount: map['discount'] != null ? map['discount'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DiscountBillModel.fromJson(String source) =>
      DiscountBillModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DiscountBillModel(products: $products, discount: $discount)';

  @override
  bool operator ==(covariant DiscountBillModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.products, products) && other.discount == discount;
  }

  @override
  int get hashCode => products.hashCode ^ discount.hashCode;
}
