// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimate_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EstimateDataModel _$EstimateDataModelFromJson(Map<String, dynamic> json) =>
    EstimateDataModel(
      createddate: json['createddate'] == null
          ? null
          : DateTime.parse(json['createddate'] as String),
      enquiryid: json['enquiryid'] as String?,
      estimateid: json['estimateid'] as String?,
      price: json['price'] == null
          ? null
          : BillingCalCulationModel.fromJson(
              json['price'] as Map<String, dynamic>),
      customer: json['customer'] == null
          ? null
          : CustomerDataModel.fromJson(
              json['customer'] as Map<String, dynamic>),
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => ProductDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      docID: json['docID'] as String?,
    );

Map<String, dynamic> _$EstimateDataModelToJson(EstimateDataModel instance) =>
    <String, dynamic>{
      'createddate': instance.createddate?.toIso8601String(),
      'enquiryid': instance.enquiryid,
      'estimateid': instance.estimateid,
      'price': instance.price,
      'customer': instance.customer,
      'products': instance.products,
      'docID': instance.docID,
    };
