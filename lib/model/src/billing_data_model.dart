// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'category_data_model.dart';
import 'product_data_model.dart';

class BillingDataModel {
  CategoryDataModel? category;
  List<ProductDataModel>? products;
  BillingDataModel({
    this.category,
    this.products,
  });

  BillingDataModel copyWith({
    CategoryDataModel? category,
    List<ProductDataModel>? products,
  }) {
    return BillingDataModel(
      category: category ?? this.category,
      products: products ?? this.products,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'category': category?.toMap(),
      'products': products!.map((x) => x.toMap()).toList(),
    };
  }

  factory BillingDataModel.fromMap(Map<String, dynamic> map) {
    return BillingDataModel(
      category: map['category'] != null
          ? CategoryDataModel.fromMap(map['category'] as Map<String, dynamic>)
          : null,
      products: map['products'] != null
          ? List<ProductDataModel>.from(
              (map['products'] as List<int>).map<ProductDataModel?>(
                (x) => ProductDataModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BillingDataModel.fromJson(String source) =>
      BillingDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'BillingDataModel(category: $category, products: $products)';

  @override
  bool operator ==(covariant BillingDataModel other) {
    if (identical(this, other)) return true;

    return other.category == category && listEquals(other.products, products);
  }

  @override
  int get hashCode => category.hashCode ^ products.hashCode;
}
