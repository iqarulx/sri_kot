// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      username: json['username'] as String?,
      companyLogo: json['companyLogo'] as String?,
      companyName: json['companyName'] as String?,
      address: json['address'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      gstno: json['gstno'] as String?,
      deviceLimit: (json['deviceLimit'] as num?)?.toInt(),
      contact: json['contact'] as Map<String, dynamic>?,
      uid: json['uid'] as String?,
      userLoginId: json['userLoginId'] as String?,
      filled: json['filled'] as bool?,
      password: json['password'] as String?,
      companyUniqueID: json['companyUniqueID'] as String?,
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'companyLogo': instance.companyLogo,
      'companyName': instance.companyName,
      'address': instance.address,
      'state': instance.state,
      'city': instance.city,
      'pincode': instance.pincode,
      'gstno': instance.gstno,
      'deviceLimit': instance.deviceLimit,
      'contact': instance.contact,
      'uid': instance.uid,
      'userLoginId': instance.userLoginId,
      'filled': instance.filled,
      'password': instance.password,
      'companyUniqueID': instance.companyUniqueID,
    };
