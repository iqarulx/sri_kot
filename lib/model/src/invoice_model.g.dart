// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceModel _$InvoiceModelFromJson(Map<String, dynamic> json) => InvoiceModel(
      partyName: json['partyName'] as String?,
      address: json['address'] as String?,
      deliveryaddress: json['deliveryaddress'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      transportName: json['transportName'] as String?,
      transportNumber: json['transportNumber'] as String?,
      totalBillAmount: json['totalBillAmount'] as String?,
      billNo: json['billNo'] as String?,
      biilDate: json['biilDate'] == null
          ? null
          : DateTime.parse(json['biilDate'] as String),
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      price: json['price'] == null
          ? null
          : BillingCalCulationModel.fromJson(
              json['price'] as Map<String, dynamic>),
      docID: json['docID'] as String?,
      listingProducts: (json['listingProducts'] as List<dynamic>?)
          ?.map((e) => InvoiceProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isEstimateConverted: json['isEstimateConverted'] as bool?,
    );

Map<String, dynamic> _$InvoiceModelToJson(InvoiceModel instance) =>
    <String, dynamic>{
      'partyName': instance.partyName,
      'address': instance.address,
      'deliveryaddress': instance.deliveryaddress,
      'phoneNumber': instance.phoneNumber,
      'transportName': instance.transportName,
      'transportNumber': instance.transportNumber,
      'totalBillAmount': instance.totalBillAmount,
      'billNo': instance.billNo,
      'biilDate': instance.biilDate?.toIso8601String(),
      'createdDate': instance.createdDate?.toIso8601String(),
      'price': instance.price,
      'docID': instance.docID,
      'listingProducts': instance.listingProducts,
      'isEstimateConverted': instance.isEstimateConverted,
    };
