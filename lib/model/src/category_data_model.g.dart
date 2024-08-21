// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryDataModel _$CategoryDataModelFromJson(Map<String, dynamic> json) =>
    CategoryDataModel(
      categoryName: json['categoryName'] as String?,
      name: json['name'] as String?,
      postion: (json['postion'] as num?)?.toInt(),
      cid: json['cid'] as String?,
      deleteAt: json['deleteAt'] as bool?,
      discount: (json['discount'] as num?)?.toInt(),
      tmpcatid: json['tmpcatid'] as String?,
      discountEnable: json['discountEnable'] as bool?,
    );

Map<String, dynamic> _$CategoryDataModelToJson(CategoryDataModel instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'name': instance.name,
      'postion': instance.postion,
      'cid': instance.cid,
      'deleteAt': instance.deleteAt,
      'discount': instance.discount,
      'tmpcatid': instance.tmpcatid,
      'discountEnable': instance.discountEnable,
    };
