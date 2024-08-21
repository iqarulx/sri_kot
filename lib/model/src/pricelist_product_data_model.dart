import 'package:json_annotation/json_annotation.dart';

part 'pricelist_product_data_model.g.dart';

@JsonSerializable()
class PricelistProdcutDataModel {
  String? prodcutName;
  String? content;
  String? price;

  PricelistProdcutDataModel({
    required this.prodcutName,
    required this.content,
    required this.price,
  });

  factory PricelistProdcutDataModel.fromJson(Map<String, dynamic> json) =>
      _$PricelistProdcutDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$PricelistProdcutDataModelToJson(this);
}
