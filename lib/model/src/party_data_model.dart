// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PartyDataModel {
  String? docId;
  String? partyName;
  String? address;
  String? city;
  String? mobileNo;
  String? state;
  String? pincode;
  String? transportName;
  String? transportNo;
  String? deliveryAddress;
  String? gstType;
  bool? taxType;
  bool? gstChanged;
  PartyDataModel(
      {this.docId,
      this.partyName,
      this.address,
      this.city,
      this.mobileNo,
      this.state,
      this.pincode,
      this.transportName,
      this.transportNo,
      this.deliveryAddress,
      this.gstType,
      this.taxType,
      this.gstChanged});

  PartyDataModel copyWith({
    String? docId,
    String? partyName,
    String? address,
    String? city,
    String? mobileNo,
    String? state,
    String? pincode,
    String? transportName,
    String? transportNo,
    String? deliveryAddress,
    String? gstType,
    bool? taxType,
  }) {
    return PartyDataModel(
      docId: docId ?? this.docId,
      partyName: partyName ?? this.partyName,
      address: address ?? this.address,
      city: city ?? this.city,
      mobileNo: mobileNo ?? this.mobileNo,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      transportName: transportName ?? this.transportName,
      transportNo: transportNo ?? this.transportNo,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      gstType: gstType ?? this.gstType,
      taxType: taxType ?? this.taxType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'doc_id': docId,
      'party_name': partyName,
      'address': address,
      'city': city,
      'mobile_no': mobileNo,
      'state': state,
      'pincode': pincode,
      'transport_name': transportName,
      'transport_no': transportNo,
      'delivery_address': deliveryAddress,
      'gst_type': gstType,
      'tax_type': taxType,
      'gst_changed': gstChanged,
    };
  }

  factory PartyDataModel.fromMap(Map<String, dynamic> map) {
    return PartyDataModel(
      docId: map['docId'] != null ? map['docId'] as String : null,
      partyName: map['partyName'] != null ? map['partyName'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      mobileNo: map['mobileNo'] != null ? map['mobileNo'] as String : null,
      state: map['state'] != null ? map['state'] as String : null,
      pincode: map['pincode'] != null ? map['pincode'] as String : null,
      transportName:
          map['transportName'] != null ? map['transportName'] as String : null,
      transportNo:
          map['transportNo'] != null ? map['transportNo'] as String : null,
      deliveryAddress: map['deliveryAddress'] != null
          ? map['deliveryAddress'] as String
          : null,
      gstType: map['gstType'] != null ? map['gstType'] as String : null,
      taxType: map['taxType'] != null ? map['taxType'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PartyDataModel.fromJson(String source) =>
      PartyDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PartyDataModel(docId: $docId, partyName: $partyName, address: $address, city: $city, mobileNo: $mobileNo, state: $state, pincode: $pincode, transportName: $transportName, transportNo: $transportNo, deliveryAddress: $deliveryAddress, gstType: $gstType, taxType: $taxType)';
  }

  @override
  bool operator ==(covariant PartyDataModel other) {
    if (identical(this, other)) return true;

    return other.docId == docId &&
        other.partyName == partyName &&
        other.address == address &&
        other.city == city &&
        other.mobileNo == mobileNo &&
        other.state == state &&
        other.pincode == pincode &&
        other.transportName == transportName &&
        other.transportNo == transportNo &&
        other.deliveryAddress == deliveryAddress &&
        other.gstType == gstType &&
        other.taxType == taxType;
  }

  @override
  int get hashCode {
    return docId.hashCode ^
        partyName.hashCode ^
        address.hashCode ^
        city.hashCode ^
        mobileNo.hashCode ^
        state.hashCode ^
        pincode.hashCode ^
        transportName.hashCode ^
        transportNo.hashCode ^
        deliveryAddress.hashCode ^
        gstType.hashCode ^
        taxType.hashCode;
  }
}
