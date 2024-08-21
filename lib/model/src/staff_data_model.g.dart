// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffDataModel _$StaffDataModelFromJson(Map<String, dynamic> json) =>
    StaffDataModel(
      userName: json['userName'] as String?,
      phoneNo: json['phoneNo'] as String?,
      userid: json['userid'] as String?,
      password: json['password'] as String?,
      companyID: json['companyID'] as String?,
      profileImg: json['profileImg'] as String?,
      permission: json['permission'] == null
          ? null
          : StaffPermissionModel.fromJson(
              json['permission'] as Map<String, dynamic>),
      docID: json['docID'] as String?,
      deleteAt: json['deleteAt'] as bool?,
      deviceModel: json['deviceModel'] == null
          ? null
          : DeviceModel.fromJson(json['deviceModel'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StaffDataModelToJson(StaffDataModel instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'phoneNo': instance.phoneNo,
      'userid': instance.userid,
      'password': instance.password,
      'companyID': instance.companyID,
      'profileImg': instance.profileImg,
      'permission': instance.permission,
      'docID': instance.docID,
      'deleteAt': instance.deleteAt,
      'deviceModel': instance.deviceModel,
    };
