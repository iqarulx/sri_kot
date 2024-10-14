// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CustomerDataModel {
  String? customerName;
  String? companyName;
  String? address;
  String? city;
  String? companyID;
  String? email;
  String? mobileNo;
  String? state;
  String? pincode;
  String? docID;
  bool? isCompany;
  String? identificationType;
  String? identificationNo;

  CustomerDataModel({
    this.customerName,
    this.companyName,
    this.address,
    this.city,
    this.companyID,
    this.email,
    this.mobileNo,
    this.state,
    this.pincode,
    this.docID,
    this.isCompany,
    this.identificationType,
    this.identificationNo,
  });

  CustomerDataModel copyWith({
    String? customerName,
    String? companyName,
    String? address,
    String? city,
    String? companyID,
    String? email,
    String? mobileNo,
    String? state,
    String? pincode,
    String? docID,
    bool? isCompany,
    String? identificationType,
    String? identificationNo,
  }) {
    return CustomerDataModel(
      customerName: customerName ?? this.customerName,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      city: city ?? this.city,
      companyID: companyID ?? this.companyID,
      email: email ?? this.email,
      mobileNo: mobileNo ?? this.mobileNo,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      docID: docID ?? this.docID,
      isCompany: isCompany ?? this.isCompany,
      identificationType: identificationType ?? this.identificationType,
      identificationNo: identificationNo ?? this.identificationNo,
    );
  }

  factory CustomerDataModel.fromMap(Map<String, dynamic> map) {
    return CustomerDataModel(
      customerName:
          map['customerName'] != null ? map['customerName'] as String : null,
      companyName:
          map['companyName'] != null ? map['companyName'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      companyID: map['companyID'] != null ? map['companyID'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      mobileNo: map['mobileNo'] != null ? map['mobileNo'] as String : null,
      state: map['state'] != null ? map['state'] as String : null,
      pincode: map['pincode'] != null ? map['pincode'] as String : null,
      docID: map['docID'] != null ? map['docID'] as String : null,
      isCompany: map['isCompany'] != null ? map['isCompany'] as bool : null,
      identificationType: map['identificationType'] != null
          ? map['identificationType'] as String
          : null,
      identificationNo: map['identificationNo'] != null
          ? map['identificationNo'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerDataModel.fromJson(String source) =>
      CustomerDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CustomerDataModel(customerName: $customerName, companyName: $companyName, address: $address, city: $city, companyID: $companyID, email: $email, mobileNo: $mobileNo, state: $state, pincode: $pincode, docID: $docID, isCompany: $isCompany, identificationType: $identificationType, identificationNo: $identificationNo)';
  }

  @override
  bool operator ==(covariant CustomerDataModel other) {
    if (identical(this, other)) return true;

    return other.customerName == customerName &&
        other.companyName == companyName &&
        other.address == address &&
        other.city == city &&
        other.companyID == companyID &&
        other.email == email &&
        other.mobileNo == mobileNo &&
        other.state == state &&
        other.pincode == pincode &&
        other.docID == docID &&
        other.isCompany == isCompany &&
        other.identificationType == identificationType &&
        other.identificationNo == identificationNo;
  }

  @override
  int get hashCode {
    return customerName.hashCode ^
        companyName.hashCode ^
        address.hashCode ^
        city.hashCode ^
        companyID.hashCode ^
        email.hashCode ^
        mobileNo.hashCode ^
        state.hashCode ^
        pincode.hashCode ^
        docID.hashCode ^
        isCompany.hashCode ^
        identificationType.hashCode ^
        identificationNo.hashCode;
  }

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_id"] = companyID;
    mapping["email"] = email;
    mapping["mobile_no"] = mobileNo;
    mapping["customer_name"] = customerName;
    mapping["state"] = state;
    mapping["pincode"] = pincode;
    mapping["identification_no"] = identificationNo;
    mapping["identification_type"] = identificationType;
    mapping["is_company"] = isCompany;
    return mapping;
  }

  Map<String, dynamic> toOrderMap() {
    var mapping = <String, dynamic>{};
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_id"] = companyID;
    mapping["email"] = email;
    mapping["doc_id"] = docID;
    mapping["mobile_no"] = mobileNo;
    mapping["customer_name"] = customerName;
    mapping["state"] = state;
    mapping["customer_id"] = docID;
    mapping["pincode"] = pincode;
    mapping["identification_no"] = identificationNo;
    return mapping;
  }

  Map<String, dynamic> toUpdateMap() {
    var mapping = <String, dynamic>{};
    mapping["customer_name"] = customerName;
    mapping["mobile_no"] = mobileNo;
    mapping["address"] = address;
    mapping["state"] = state;
    mapping["city"] = city;
    mapping["email"] = email;
    mapping["pincode"] = pincode;
    mapping["identification_no"] = identificationNo;
    mapping["identification_type"] = identificationType;
    mapping["is_company"] = isCompany;
    return mapping;
  }
}
