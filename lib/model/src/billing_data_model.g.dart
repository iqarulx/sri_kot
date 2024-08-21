// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillingDataModel _$BillingDataModelFromJson(Map<String, dynamic> json) =>
    BillingDataModel(
      category: json['category'] == null
          ? null
          : CategoryDataModel.fromJson(
              json['category'] as Map<String, dynamic>),
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => ProductDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BillingDataModelToJson(BillingDataModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'products': instance.products,
    };
