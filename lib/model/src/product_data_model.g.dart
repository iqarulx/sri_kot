// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDataModel _$ProductDataModelFromJson(Map<String, dynamic> json) =>
    ProductDataModel(
      categoryid: json['categoryid'] as String?,
      categoryName: json['categoryName'] as String?,
      productName: json['productName'] as String?,
      productCode: json['productCode'] as String?,
      productContent: json['productContent'] as String?,
      qrCode: json['qrCode'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      videoUrl: json['videoUrl'] as String?,
      productImg: json['productImg'] as String?,
      active: json['active'] as bool?,
      companyId: json['companyId'] as String?,
      discountLock: json['discountLock'] as bool?,
      delete: json['delete'] as bool?,
      name: json['name'] as String?,
      productId: json['productId'] as String?,
      qty: (json['qty'] as num?)?.toInt(),
      docid: json['docid'] as String?,
      postion: (json['postion'] as num?)?.toInt(),
      discount: (json['discount'] as num?)?.toInt(),
      createdDateTime: json['createdDateTime'] == null
          ? null
          : DateTime.parse(json['createdDateTime'] as String),
    );

Map<String, dynamic> _$ProductDataModelToJson(ProductDataModel instance) =>
    <String, dynamic>{
      'categoryid': instance.categoryid,
      'categoryName': instance.categoryName,
      'productName': instance.productName,
      'productCode': instance.productCode,
      'productContent': instance.productContent,
      'qrCode': instance.qrCode,
      'price': instance.price,
      'videoUrl': instance.videoUrl,
      'productImg': instance.productImg,
      'active': instance.active,
      'companyId': instance.companyId,
      'discountLock': instance.discountLock,
      'delete': instance.delete,
      'name': instance.name,
      'productId': instance.productId,
      'qty': instance.qty,
      'docid': instance.docid,
      'postion': instance.postion,
      'discount': instance.discount,
      'createdDateTime': instance.createdDateTime?.toIso8601String(),
    };
