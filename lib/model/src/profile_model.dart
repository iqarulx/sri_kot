// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
  bool? taxType;
  Map<String, dynamic>? device;
  bool? invoiceEntry;
  DateTime? created;
  Map<String, dynamic>? freeTrial;
  int? maxUserCount;
  int? maxStaffCount;
  String? plan;
  DateTime? expiryDate;
  String? userType;
  String? profileImg;

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
    this.taxType,
    this.device,
    this.invoiceEntry,
    this.created,
    this.freeTrial,
    this.maxUserCount,
    this.maxStaffCount,
    this.plan,
    this.expiryDate,
    this.profileImg,
    this.userType,
  });

  ProfileModel copyWith({
    String? docId,
    String? username,
    String? companyLogo,
    String? companyName,
    String? address,
    String? state,
    String? city,
    String? pincode,
    String? gstno,
    int? deviceLimit,
    Map<String, dynamic>? contact,
    String? uid,
    String? userLoginId,
    bool? filled,
    String? password,
    String? companyUniqueID,
    Map<String, dynamic>? hsn,
    bool? taxType,
  }) {
    return ProfileModel(
      docId: docId ?? this.docId,
      username: username ?? this.username,
      companyLogo: companyLogo ?? this.companyLogo,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      gstno: gstno ?? this.gstno,
      deviceLimit: deviceLimit ?? this.deviceLimit,
      contact: contact ?? this.contact,
      uid: uid ?? this.uid,
      userLoginId: userLoginId ?? this.userLoginId,
      filled: filled ?? this.filled,
      password: password ?? this.password,
      companyUniqueID: companyUniqueID ?? this.companyUniqueID,
      hsn: hsn ?? this.hsn,
      taxType: taxType ?? this.taxType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docId': docId,
      'username': username,
      'companyLogo': companyLogo,
      'companyName': companyName,
      'address': address,
      'state': state,
      'city': city,
      'pincode': pincode,
      'gstno': gstno,
      'deviceLimit': deviceLimit,
      'contact': contact,
      'uid': uid,
      'userLoginId': userLoginId,
      'filled': filled,
      'password': password,
      'companyUniqueID': companyUniqueID,
      'hsn': hsn,
      'tax_type': taxType,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      docId: map['docId'] != null ? map['docId'] as String : null,
      username: map['username'] != null ? map['username'] as String : null,
      companyLogo:
          map['companyLogo'] != null ? map['companyLogo'] as String : null,
      companyName:
          map['companyName'] != null ? map['companyName'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      state: map['state'] != null ? map['state'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      pincode: map['pincode'] != null ? map['pincode'] as String : null,
      gstno: map['gstno'] != null ? map['gstno'] as String : null,
      deviceLimit:
          map['deviceLimit'] != null ? map['deviceLimit'] as int : null,
      contact: map['contact'] != null
          ? Map<String, dynamic>.from((map['contact'] as Map<String, dynamic>))
          : null,
      uid: map['uid'] != null ? map['uid'] as String : null,
      userLoginId:
          map['userLoginId'] != null ? map['userLoginId'] as String : null,
      filled: map['filled'] != null ? map['filled'] as bool : null,
      password: map['password'] != null ? map['password'] as String : null,
      companyUniqueID: map['companyUniqueID'] != null
          ? map['companyUniqueID'] as String
          : null,
      hsn: map['hsn'] != null
          ? Map<String, dynamic>.from((map['hsn'] as Map<String, dynamic>))
          : null,
      taxType: map['taxType'] != null ? map['taxType'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) =>
      ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProfileModel(docId: $docId, username: $username, companyLogo: $companyLogo, companyName: $companyName, address: $address, state: $state, city: $city, pincode: $pincode, gstno: $gstno, deviceLimit: $deviceLimit, contact: $contact, uid: $uid, userLoginId: $userLoginId, filled: $filled, password: $password, companyUniqueID: $companyUniqueID, hsn: $hsn, taxType: $taxType)';
  }

  @override
  bool operator ==(covariant ProfileModel other) {
    if (identical(this, other)) return true;

    return other.docId == docId &&
        other.username == username &&
        other.companyLogo == companyLogo &&
        other.companyName == companyName &&
        other.address == address &&
        other.state == state &&
        other.city == city &&
        other.pincode == pincode &&
        other.gstno == gstno &&
        other.deviceLimit == deviceLimit &&
        mapEquals(other.contact, contact) &&
        other.uid == uid &&
        other.userLoginId == userLoginId &&
        other.filled == filled &&
        other.password == password &&
        other.companyUniqueID == companyUniqueID &&
        mapEquals(other.hsn, hsn) &&
        other.taxType == taxType;
  }

  @override
  int get hashCode {
    return docId.hashCode ^
        username.hashCode ^
        companyLogo.hashCode ^
        companyName.hashCode ^
        address.hashCode ^
        state.hashCode ^
        city.hashCode ^
        pincode.hashCode ^
        gstno.hashCode ^
        deviceLimit.hashCode ^
        contact.hashCode ^
        uid.hashCode ^
        userLoginId.hashCode ^
        filled.hashCode ^
        password.hashCode ^
        companyUniqueID.hashCode ^
        hsn.hashCode ^
        taxType.hashCode;
  }

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
    mapping["tax_type"] = taxType;

    return mapping;
  }

  Map<String, dynamic> initRegisterCompany() {
    var mapping = <String, dynamic>{};
    mapping["company_name"] = companyName;
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
    mapping["tax_type"] = taxType;
    mapping["device"] = device;
    mapping["invoice_entry"] = invoiceEntry;
    mapping["created"] = created;
    mapping["free_trial"] = freeTrial;
    mapping["max_user_count"] = maxUserCount;
    mapping["max_staff_count"] = maxStaffCount;
    mapping["plan"] = plan;
    mapping["expiry_date"] = expiryDate;
    mapping["profile_img"] = profileImg;
    mapping["user_type"] = userType;

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
    mapping["tax_type"] = taxType;
    mapping["user_login_id"] = userLoginId;
    mapping["password"] = password;
    return mapping;
  }
}
