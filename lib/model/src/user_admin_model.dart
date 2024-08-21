import 'device_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'user_admin_model.g.dart';

@JsonSerializable()
class UserAdminModel {
  String? adminName;
  String? phoneNo;
  String? adminLoginId;
  String? password;
  String? companyId;
  String? uid;
  String? imageUrl;
  String? docid;
  DateTime? createdDateTime;
  DeviceModel? deviceModel;

  UserAdminModel({
    this.adminName,
    this.phoneNo,
    this.adminLoginId,
    this.password,
    this.companyId,
    this.uid,
    this.imageUrl,
    this.deviceModel,
  });

  factory UserAdminModel.fromJson(Map<String, dynamic> json) =>
      _$UserAdminModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserAdminModelToJson(this);

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["company_id"] = companyId;
    mapping["phone_no"] = phoneNo;
    mapping["uid"] = uid;
    mapping["admin_name"] = adminName;
    mapping["user_login_id"] = adminLoginId;
    mapping["password"] = password;
    mapping["image_url"] = imageUrl;
    mapping["created_date_time"] = createdDateTime;
    mapping["device"] = deviceModel!.toMap();

    return mapping;
  }

  updateMap() {
    var mapping = <String, dynamic>{};
    mapping["admin_name"] = adminName;
    mapping["phone_no"] = phoneNo;
    mapping["user_login_id"] = adminLoginId;
    mapping["password"] = password;
    return mapping;
  }
}
