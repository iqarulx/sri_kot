import 'package:json_annotation/json_annotation.dart';
part 'device_model.g.dart';

@JsonSerializable()
class DeviceModel {
  String? deviceType;
  String? deviceId;
  String? deviceName;
  String? modelName;
  DateTime? lastlogin;

  DeviceModel(
      {this.deviceId,
      this.deviceType,
      this.deviceName,
      this.lastlogin,
      this.modelName});

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceModelToJson(this);

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
