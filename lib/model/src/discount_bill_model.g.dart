// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_bill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscountBillModel _$DiscountBillModelFromJson(Map<String, dynamic> json) =>
    DiscountBillModel(
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => ProductDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      discount: json['discount'] as String?,
    );

Map<String, dynamic> _$DiscountBillModelToJson(DiscountBillModel instance) =>
    <String, dynamic>{
      'products': instance.products,
      'discount': instance.discount,
    };
