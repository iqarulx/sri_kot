import 'package:json_annotation/json_annotation.dart';

part 'category_discount_model.g.dart';

@JsonSerializable()
class CategoryDiscountModel {
  String? categoryName;
  int? discountValue;

  CategoryDiscountModel({
    this.categoryName,
    this.discountValue,
  });

  factory CategoryDiscountModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryDiscountModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDiscountModelToJson(this);
}
