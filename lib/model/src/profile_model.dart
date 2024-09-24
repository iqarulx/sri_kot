import 'package:json_annotation/json_annotation.dart';
part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  String? docId;
  String? username;
  String? companyLogo;
  String? companyName;
  String? address;
  String? state;
  String? city;
  String? pincode;
  String? gstno;
  int? deviceLimit;
  Map<String, dynamic>? contact;
  String? uid;
  String? userLoginId;
  bool? filled;
  String? password;
  String? companyUniqueID;
  Map<String, dynamic>? hsn;

  ProfileModel({
    this.docId,
    this.username,
    this.companyLogo,
    this.companyName,
    this.address,
    this.state,
    this.city,
    this.pincode,
    this.gstno,
    this.deviceLimit,
    this.contact,
    this.uid,
    this.userLoginId,
    this.filled,
    this.password,
    this.companyUniqueID,
    this.hsn,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  // Existing methods
  Map<String, dynamic> dataMap() {
    var mapping = <String, dynamic>{};
    mapping["user_name"] = username;
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_logo"] = companyLogo;
    mapping["company_name"] = companyName;
    mapping["contact"] = contact;
    mapping["device_limit"] = deviceLimit;
    mapping["gst_no"] = gstno;
    mapping["pincode"] = pincode;
    mapping["state"] = state;
    mapping["uid"] = uid;
    mapping["user_login_id"] = userLoginId;
    return mapping;
  }

  Map<String, dynamic> initRegisterCompany() {
    var mapping = <String, dynamic>{};
    mapping["company_name"] = companyName;
    mapping["uid"] = uid;
    mapping["user_login_id"] = userLoginId;
    mapping["user_name"] = username;
    mapping["info_filled"] = filled;
    mapping["password"] = password;
    return mapping;
  }

  Map<String, dynamic> newRegisterCompany() {
    var mapping = <String, dynamic>{};
    mapping["user_name"] = username;
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_logo"] = companyLogo;
    mapping["company_name"] = companyName;
    mapping["contact"] = contact;
    mapping["gst_no"] = gstno;
    mapping["pincode"] = pincode;
    mapping["state"] = state;
    mapping["device_limit"] = deviceLimit;
    mapping["info_filled"] = filled;
    mapping["company_unique_id"] = companyUniqueID;
    mapping["password"] = password;
    return mapping;
  }

  Map<String, dynamic> updateCompany() {
    var mapping = <String, dynamic>{};
    mapping["user_name"] = username;
    mapping["company_name"] = companyName;
    mapping["address"] = address;
    mapping["pincode"] = pincode;
    mapping["contact"] = contact;
    mapping["gst_no"] = gstno;
    mapping["user_login_id"] = userLoginId;
    mapping["password"] = password;
    return mapping;
  }
}
