// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceProductModel _$InvoiceProductModelFromJson(Map<String, dynamic> json) =>
    InvoiceProductModel(
      productName: json['productName'] as String?,
      productID: json['productID'] as String?,
      qty: (json['qty'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      rate: (json['rate'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toInt(),
      discountLock: json['discountLock'] as bool?,
      categoryID: json['categoryID'] as String?,
      docID: json['docID'] as String?,
    );

Map<String, dynamic> _$InvoiceProductModelToJson(
        InvoiceProductModel instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'productID': instance.productID,
      'qty': instance.qty,
      'unit': instance.unit,
      'rate': instance.rate,
      'total': instance.total,
      'discount': instance.discount,
      'discountLock': instance.discountLock,
      'categoryID': instance.categoryID,
      'docID': instance.docID,
    };
