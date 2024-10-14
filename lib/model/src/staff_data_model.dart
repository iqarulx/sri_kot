// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'device_model.dart';
import 'staff_permission_model.dart';

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
  StaffDataModel({
    this.userName,
    this.phoneNo,
    this.userid,
    this.password,
    this.companyID,
    this.profileImg,
    this.permission,
    this.docID,
    this.deleteAt,
    this.deviceModel,
    this.companyName,
    this.companyAddress,
  });

  StaffDataModel copyWith({
    String? userName,
    String? phoneNo,
    String? userid,
    String? password,
    String? companyID,
    String? profileImg,
    StaffPermissionModel? permission,
    String? docID,
    bool? deleteAt,
    DeviceModel? deviceModel,
    String? companyName,
    String? companyAddress,
  }) {
    return StaffDataModel(
      userName: userName ?? this.userName,
      phoneNo: phoneNo ?? this.phoneNo,
      userid: userid ?? this.userid,
      password: password ?? this.password,
      companyID: companyID ?? this.companyID,
      profileImg: profileImg ?? this.profileImg,
      permission: permission ?? this.permission,
      docID: docID ?? this.docID,
      deleteAt: deleteAt ?? this.deleteAt,
      deviceModel: deviceModel ?? this.deviceModel,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
    );
  }

  factory StaffDataModel.fromMap(Map<String, dynamic> map) {
    return StaffDataModel(
      userName: map['userName'] != null ? map['userName'] as String : null,
      phoneNo: map['phoneNo'] != null ? map['phoneNo'] as String : null,
      userid: map['userid'] != null ? map['userid'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      companyID: map['companyID'] != null ? map['companyID'] as String : null,
      profileImg:
          map['profileImg'] != null ? map['profileImg'] as String : null,
      permission: map['permission'],
      docID: map['docID'] != null ? map['docID'] as String : null,
      deleteAt: map['deleteAt'] != null ? map['deleteAt'] as bool : null,
      deviceModel: map['deviceModel'] != null
          ? DeviceModel.fromMap(map['deviceModel'] as Map<String, dynamic>)
          : null,
      companyName:
          map['companyName'] != null ? map['companyName'] as String : null,
      companyAddress: map['companyAddress'] != null
          ? map['companyAddress'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StaffDataModel.fromJson(String source) =>
      StaffDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StaffDataModel(userName: $userName, phoneNo: $phoneNo, userid: $userid, password: $password, companyID: $companyID, profileImg: $profileImg, permission: $permission, docID: $docID, deleteAt: $deleteAt, deviceModel: $deviceModel, companyName: $companyName, companyAddress: $companyAddress)';
  }

  @override
  bool operator ==(covariant StaffDataModel other) {
    if (identical(this, other)) return true;

    return other.userName == userName &&
        other.phoneNo == phoneNo &&
        other.userid == userid &&
        other.password == password &&
        other.companyID == companyID &&
        other.profileImg == profileImg &&
        other.permission == permission &&
        other.docID == docID &&
        other.deleteAt == deleteAt &&
        other.deviceModel == deviceModel &&
        other.companyName == companyName &&
        other.companyAddress == companyAddress;
  }

  @override
  int get hashCode {
    return userName.hashCode ^
        phoneNo.hashCode ^
        userid.hashCode ^
        password.hashCode ^
        companyID.hashCode ^
        profileImg.hashCode ^
        permission.hashCode ^
        docID.hashCode ^
        deleteAt.hashCode ^
        deviceModel.hashCode ^
        companyName.hashCode ^
        companyAddress.hashCode;
  }

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
    mapping["company_name"] = companyName;
    mapping["address"] = companyAddress;
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
