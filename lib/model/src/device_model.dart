// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DeviceModel {
  String? deviceType;
  String? deviceId;
  String? deviceName;
  String? modelName;
  DateTime? lastlogin;
  DeviceModel({
    this.deviceType,
    this.deviceId,
    this.deviceName,
    this.modelName,
    this.lastlogin,
  });

  DeviceModel copyWith({
    String? deviceType,
    String? deviceId,
    String? deviceName,
    String? modelName,
    DateTime? lastlogin,
  }) {
    return DeviceModel(
      deviceType: deviceType ?? this.deviceType,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      modelName: modelName ?? this.modelName,
      lastlogin: lastlogin ?? this.lastlogin,
    );
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      deviceType:
          map['deviceType'] != null ? map['deviceType'] as String : null,
      deviceId: map['deviceId'] != null ? map['deviceId'] as String : null,
      deviceName:
          map['deviceName'] != null ? map['deviceName'] as String : null,
      modelName: map['modelName'] != null ? map['modelName'] as String : null,
      lastlogin: map['lastlogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastlogin'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceModel.fromJson(String source) =>
      DeviceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeviceModel(deviceType: $deviceType, deviceId: $deviceId, deviceName: $deviceName, modelName: $modelName, lastlogin: $lastlogin)';
  }

  @override
  bool operator ==(covariant DeviceModel other) {
    if (identical(this, other)) return true;

    return other.deviceType == deviceType &&
        other.deviceId == deviceId &&
        other.deviceName == deviceName &&
        other.modelName == modelName &&
        other.lastlogin == lastlogin;
  }

  @override
  int get hashCode {
    return deviceType.hashCode ^
        deviceId.hashCode ^
        deviceName.hashCode ^
        modelName.hashCode ^
        lastlogin.hashCode;
  }

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping['device_type'] = deviceType;
    mapping['device_id'] = deviceId;
    mapping['device_name'] = deviceName;
    mapping['model_name'] = modelName;
    mapping['last_login'] = lastlogin;
    return mapping;
  }
}
