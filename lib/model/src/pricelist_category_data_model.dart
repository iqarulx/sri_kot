// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../model.dart';

class PricelistCategoryDataModel {
  String? categoryName;
  List<PricelistProdcutDataModel>? productModel;
  PricelistCategoryDataModel({
    this.categoryName,
    this.productModel,
  });

  PricelistCategoryDataModel copyWith({
    String? categoryName,
    List<PricelistProdcutDataModel>? productModel,
  }) {
    return PricelistCategoryDataModel(
      categoryName: categoryName ?? this.categoryName,
      productModel: productModel ?? this.productModel,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoryName': categoryName,
      'productModel': productModel!.map((x) => x.toMap()).toList(),
    };
  }

  factory PricelistCategoryDataModel.fromMap(Map<String, dynamic> map) {
    return PricelistCategoryDataModel(
      categoryName:
          map['categoryName'] != null ? map['categoryName'] as String : null,
      productModel: map['productModel'] != null
          ? List<PricelistProdcutDataModel>.from(
              (map['productModel'] as List<int>)
                  .map<PricelistProdcutDataModel?>(
                (x) => PricelistProdcutDataModel.fromMap(
                    x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PricelistCategoryDataModel.fromJson(String source) =>
      PricelistCategoryDataModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PricelistCategoryDataModel(categoryName: $categoryName, productModel: $productModel)';

  @override
  bool operator ==(covariant PricelistCategoryDataModel other) {
    if (identical(this, other)) return true;

    return other.categoryName == categoryName &&
        listEquals(other.productModel, productModel);
  }

  @override
  int get hashCode => categoryName.hashCode ^ productModel.hashCode;
}
