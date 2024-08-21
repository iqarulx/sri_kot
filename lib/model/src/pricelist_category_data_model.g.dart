// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricelist_category_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricelistCategoryDataModel _$PricelistCategoryDataModelFromJson(
        Map<String, dynamic> json) =>
    PricelistCategoryDataModel(
      categoryName: json['categoryName'] as String?,
      productModel: (json['productModel'] as List<dynamic>?)
          ?.map((e) =>
              PricelistProdcutDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PricelistCategoryDataModelToJson(
        PricelistCategoryDataModel instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'productModel': instance.productModel,
    };
