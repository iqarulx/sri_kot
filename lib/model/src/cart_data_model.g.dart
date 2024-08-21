// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartDataModel _$CartDataModelFromJson(Map<String, dynamic> json) =>
    CartDataModel(
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      productName: json['productName'] as String?,
      productId: json['productId'] as String?,
      productImg: json['productImg'] as String?,
      discountLock: json['discountLock'] as bool?,
      productCode: json['productCode'] as String?,
      productContent: json['productContent'] as String?,
      qrCode: json['qrCode'] as String?,
      videoUrl: json['videoUrl'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      mrp: json['mrp'] as String?,
      qty: (json['qty'] as num?)?.toInt(),
      name: json['name'] as String?,
      docID: json['docID'] as String?,
      discount: (json['discount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CartDataModelToJson(CartDataModel instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'productName': instance.productName,
      'productId': instance.productId,
      'productImg': instance.productImg,
      'discountLock': instance.discountLock,
      'productCode': instance.productCode,
      'productContent': instance.productContent,
      'qrCode': instance.qrCode,
      'videoUrl': instance.videoUrl,
      'price': instance.price,
      'mrp': instance.mrp,
      'qty': instance.qty,
      'name': instance.name,
      'docID': instance.docID,
      'discount': instance.discount,
    };
