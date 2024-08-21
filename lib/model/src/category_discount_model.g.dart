// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_discount_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryDiscountModel _$CategoryDiscountModelFromJson(
        Map<String, dynamic> json) =>
    CategoryDiscountModel(
      categoryName: json['categoryName'] as String?,
      discountValue: (json['discountValue'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CategoryDiscountModelToJson(
        CategoryDiscountModel instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'discountValue': instance.discountValue,
    };
