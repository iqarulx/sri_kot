// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'device_model.dart';

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
  String? companyName;
  String? companyAddress;
  UserAdminModel({
    this.adminName,
    this.phoneNo,
    this.adminLoginId,
    this.password,
    this.companyId,
    this.uid,
    this.imageUrl,
    this.docid,
    this.createdDateTime,
    this.deviceModel,
    this.companyName,
    this.companyAddress,
  });

  UserAdminModel copyWith({
    String? adminName,
    String? phoneNo,
    String? adminLoginId,
    String? password,
    String? companyId,
    String? uid,
    String? imageUrl,
    String? docid,
    DateTime? createdDateTime,
    DeviceModel? deviceModel,
    String? companyName,
    String? companyAddress,
  }) {
    return UserAdminModel(
      adminName: adminName ?? this.adminName,
      phoneNo: phoneNo ?? this.phoneNo,
      adminLoginId: adminLoginId ?? this.adminLoginId,
      password: password ?? this.password,
      companyId: companyId ?? this.companyId,
      uid: uid ?? this.uid,
      imageUrl: imageUrl ?? this.imageUrl,
      docid: docid ?? this.docid,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      deviceModel: deviceModel ?? this.deviceModel,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
    );
  }

  factory UserAdminModel.fromMap(Map<String, dynamic> map) {
    return UserAdminModel(
      adminName: map['adminName'] != null ? map['adminName'] as String : null,
      phoneNo: map['phoneNo'] != null ? map['phoneNo'] as String : null,
      adminLoginId:
          map['adminLoginId'] != null ? map['adminLoginId'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      companyId: map['companyId'] != null ? map['companyId'] as String : null,
      uid: map['uid'] != null ? map['uid'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      docid: map['docid'] != null ? map['docid'] as String : null,
      createdDateTime: map['createdDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdDateTime'] as int)
          : null,
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

  factory UserAdminModel.fromJson(String source) =>
      UserAdminModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserAdminModel(adminName: $adminName, phoneNo: $phoneNo, adminLoginId: $adminLoginId, password: $password, companyId: $companyId, uid: $uid, imageUrl: $imageUrl, docid: $docid, createdDateTime: $createdDateTime, deviceModel: $deviceModel, companyName: $companyName, companyAddress: $companyAddress)';
  }

  @override
  bool operator ==(covariant UserAdminModel other) {
    if (identical(this, other)) return true;

    return other.adminName == adminName &&
        other.phoneNo == phoneNo &&
        other.adminLoginId == adminLoginId &&
        other.password == password &&
        other.companyId == companyId &&
        other.uid == uid &&
        other.imageUrl == imageUrl &&
        other.docid == docid &&
        other.createdDateTime == createdDateTime &&
        other.deviceModel == deviceModel &&
        other.companyName == companyName &&
        other.companyAddress == companyAddress;
  }

  @override
  int get hashCode {
    return adminName.hashCode ^
        phoneNo.hashCode ^
        adminLoginId.hashCode ^
        password.hashCode ^
        companyId.hashCode ^
        uid.hashCode ^
        imageUrl.hashCode ^
        docid.hashCode ^
        createdDateTime.hashCode ^
        deviceModel.hashCode ^
        companyName.hashCode ^
        companyAddress.hashCode;
  }

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
    mapping["company_name"] = companyName;
    mapping["address"] = companyAddress;

    return mapping;
  }

  updateMap() {
    var mapping = <String, dynamic>{};
    mapping["admin_name"] = adminName;
    mapping["phone_no"] = phoneNo;
    mapping["user_login_id"] = adminLoginId;
    mapping["password"] = password;
    mapping["image_url"] = imageUrl;
    return mapping;
  }
}


/*

 
*/