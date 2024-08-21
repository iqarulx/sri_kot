// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffPermissionModel _$StaffPermissionModelFromJson(
        Map<String, dynamic> json) =>
    StaffPermissionModel(
      product: json['product'] as bool?,
      category: json['category'] as bool?,
      customer: json['customer'] as bool?,
      orders: json['orders'] as bool?,
      estimate: json['estimate'] as bool?,
      billofsupply: json['billofsupply'] as bool?,
    );

Map<String, dynamic> _$StaffPermissionModelToJson(
        StaffPermissionModel instance) =>
    <String, dynamic>{
      'product': instance.product,
      'category': instance.category,
      'customer': instance.customer,
      'orders': instance.orders,
      'estimate': instance.estimate,
      'billofsupply': instance.billofsupply,
    };
