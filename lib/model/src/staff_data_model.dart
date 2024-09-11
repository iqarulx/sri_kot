import 'staff_permission_model.dart';
import 'device_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'staff_data_model.g.dart';

@JsonSerializable()
class StaffDataModel {
  String? userName;
  String? phoneNo;
  String? userid;
  String? password;
  String? companyID;
  String? profileImg;
  StaffPermissionModel? permission;
  String? docID;
  bool? deleteAt;
  DeviceModel? deviceModel;
  String? companyName;
  String? companyAddress;

  StaffDataModel(
      {this.userName,
      this.phoneNo,
      this.userid,
      this.password,
      this.companyID,
      this.profileImg,
      this.permission,
      this.docID,
      this.deleteAt,
      this.deviceModel,
      this.companyAddress,
      this.companyName});

  factory StaffDataModel.fromJson(Map<String, dynamic> json) =>
      _$StaffDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffDataModelToJson(this);

  Map<String, dynamic> toCreateMap() {
    var mapping = <String, dynamic>{};
    mapping["staff_name"] = userName;
    mapping["phone_no"] = phoneNo;
    mapping["user_login_id"] = userid;
    mapping["password"] = password;
    mapping["profile_img"] = profileImg;
    mapping["company_id"] = companyID;
    if (permission != null) {
      mapping["permission"] = permission!.toMap();
    }
    if (deviceModel != null) {
      mapping["device"] = deviceModel!.toMap();
    }
    mapping["deleted_at"] = deleteAt;
    return mapping;
  }

  Map<String, dynamic> totoMapUpdateImage() {
    var mapping = <String, dynamic>{};
    mapping["profile_img"] = profileImg;
    return mapping;
  }

  Map<String, dynamic> toMapUpdate() {
    var mapping = <String, dynamic>{};
    mapping["staff_name"] = userName;
    mapping["phone_no"] = phoneNo;
    mapping["user_login_id"] = userid;
    mapping["password"] = password;
    if (permission != null) {
      mapping["permission"] = permission!.toMap();
    }
    return mapping;
  }

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["staff_name"] = userName;
    mapping["phone_no"] = phoneNo;
    mapping["company_id"] = companyID;
    mapping["user_login_id"] = userid;
    return mapping;
  }
}
