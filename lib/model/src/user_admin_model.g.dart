// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAdminModel _$UserAdminModelFromJson(Map<String, dynamic> json) =>
    UserAdminModel(
      adminName: json['adminName'] as String?,
      phoneNo: json['phoneNo'] as String?,
      adminLoginId: json['adminLoginId'] as String?,
      password: json['password'] as String?,
      companyId: json['companyId'] as String?,
      uid: json['uid'] as String?,
      imageUrl: json['imageUrl'] as String?,
      deviceModel: json['deviceModel'] == null
          ? null
          : DeviceModel.fromJson(json['deviceModel'] as Map<String, dynamic>),
    )
      ..docid = json['docid'] as String?
      ..createdDateTime = json['createdDateTime'] == null
          ? null
          : DateTime.parse(json['createdDateTime'] as String);

Map<String, dynamic> _$UserAdminModelToJson(UserAdminModel instance) =>
    <String, dynamic>{
      'adminName': instance.adminName,
      'phoneNo': instance.phoneNo,
      'adminLoginId': instance.adminLoginId,
      'password': instance.password,
      'companyId': instance.companyId,
      'uid': instance.uid,
      'imageUrl': instance.imageUrl,
      'docid': instance.docid,
      'createdDateTime': instance.createdDateTime?.toIso8601String(),
      'deviceModel': instance.deviceModel,
    };
