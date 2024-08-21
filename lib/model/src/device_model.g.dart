// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceModel _$DeviceModelFromJson(Map<String, dynamic> json) => DeviceModel(
      deviceId: json['deviceId'] as String?,
      deviceType: json['deviceType'] as String?,
      deviceName: json['deviceName'] as String?,
      lastlogin: json['lastlogin'] == null
          ? null
          : DateTime.parse(json['lastlogin'] as String),
      modelName: json['modelName'] as String?,
    );

Map<String, dynamic> _$DeviceModelToJson(DeviceModel instance) =>
    <String, dynamic>{
      'deviceType': instance.deviceType,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'modelName': instance.modelName,
      'lastlogin': instance.lastlogin?.toIso8601String(),
    };
