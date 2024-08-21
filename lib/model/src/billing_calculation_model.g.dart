// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_calculation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillingCalCulationModel _$BillingCalCulationModelFromJson(
        Map<String, dynamic> json) =>
    BillingCalCulationModel(
      subTotal: (json['subTotal'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      discountsys: json['discountsys'] as String?,
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      extraDiscount: (json['extraDiscount'] as num?)?.toDouble(),
      extraDiscountsys: json['extraDiscountsys'] as String?,
      extraDiscountValue: (json['extraDiscountValue'] as num?)?.toDouble(),
      package: (json['package'] as num?)?.toDouble(),
      packagesys: json['packagesys'] as String?,
      packageValue: (json['packageValue'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BillingCalCulationModelToJson(
        BillingCalCulationModel instance) =>
    <String, dynamic>{
      'subTotal': instance.subTotal,
      'discount': instance.discount,
      'discountsys': instance.discountsys,
      'discountValue': instance.discountValue,
      'extraDiscount': instance.extraDiscount,
      'extraDiscountsys': instance.extraDiscountsys,
      'extraDiscountValue': instance.extraDiscountValue,
      'package': instance.package,
      'packagesys': instance.packagesys,
      'packageValue': instance.packageValue,
      'total': instance.total,
    };
