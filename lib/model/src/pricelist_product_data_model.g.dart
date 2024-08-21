// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricelist_product_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricelistProdcutDataModel _$PricelistProdcutDataModelFromJson(
        Map<String, dynamic> json) =>
    PricelistProdcutDataModel(
      prodcutName: json['prodcutName'] as String?,
      content: json['content'] as String?,
      price: json['price'] as String?,
    );

Map<String, dynamic> _$PricelistProdcutDataModelToJson(
        PricelistProdcutDataModel instance) =>
    <String, dynamic>{
      'prodcutName': instance.prodcutName,
      'content': instance.content,
      'price': instance.price,
    };
