import 'package:json_annotation/json_annotation.dart';

import 'pricelist_product_data_model.dart';

part 'pricelist_category_data_model.g.dart';

@JsonSerializable()
class PricelistCategoryDataModel {
  String? categoryName;
  List<PricelistProdcutDataModel>? productModel;

  PricelistCategoryDataModel({
    required this.categoryName,
    required this.productModel,
  });

  factory PricelistCategoryDataModel.fromJson(Map<String, dynamic> json) =>
      _$PricelistCategoryDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$PricelistCategoryDataModelToJson(this);
}
