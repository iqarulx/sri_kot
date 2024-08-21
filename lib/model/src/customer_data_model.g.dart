// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerDataModel _$CustomerDataModelFromJson(Map<String, dynamic> json) =>
    CustomerDataModel(
      customerName: json['customerName'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      companyID: json['companyID'] as String?,
      email: json['email'] as String?,
      mobileNo: json['mobileNo'] as String?,
      state: json['state'] as String?,
      docID: json['docID'] as String?,
    );

Map<String, dynamic> _$CustomerDataModelToJson(CustomerDataModel instance) =>
    <String, dynamic>{
      'customerName': instance.customerName,
      'address': instance.address,
      'city': instance.city,
      'companyID': instance.companyID,
      'email': instance.email,
      'mobileNo': instance.mobileNo,
      'state': instance.state,
      'docID': instance.docID,
    };
