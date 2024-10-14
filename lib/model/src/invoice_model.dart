// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'billing_calculation_model.dart';
import 'invoice_product_model.dart';

class InvoiceModel {
  String? companyId;
  String? partyName;
  String? address;
  String? deliveryaddress;
  String? phoneNumber;
  String? transportName;
  String? transportNumber;
  String? totalBillAmount;
  String? billNo;
  DateTime? billDate;
  DateTime? createdDate;
  BillingCalCulationModel? price;
  String? docID;
  List<InvoiceProductModel>? listingProducts;
  bool? isEstimateConverted;
  bool? taxType;
  String? gstType;
  String? state;
  String? city;
  Map<String, dynamic>? taxCalc;
  bool? sameState;

  InvoiceModel({
    this.companyId,
    this.partyName,
    this.address,
    this.deliveryaddress,
    this.phoneNumber,
    this.transportName,
    this.transportNumber,
    this.totalBillAmount,
    this.billNo,
    this.billDate,
    this.createdDate,
    this.price,
    this.docID,
    this.listingProducts,
    this.isEstimateConverted,
    this.taxType,
    this.gstType,
    this.state,
    this.city,
    this.taxCalc,
    this.sameState,
  });

  InvoiceModel copyWith({
    String? companyId,
    String? partyName,
    String? address,
    String? deliveryaddress,
    String? phoneNumber,
    String? transportName,
    String? transportNumber,
    String? totalBillAmount,
    String? billNo,
    DateTime? billDate,
    DateTime? createdDate,
    BillingCalCulationModel? price,
    String? docID,
    List<InvoiceProductModel>? listingProducts,
    bool? isEstimateConverted,
    bool? taxType,
    String? gstType,
    String? state,
    String? city,
    Map<String, dynamic>? taxCalc,
  }) {
    return InvoiceModel(
      companyId: companyId ?? this.companyId,
      partyName: partyName ?? this.partyName,
      address: address ?? this.address,
      deliveryaddress: deliveryaddress ?? this.deliveryaddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      transportName: transportName ?? this.transportName,
      transportNumber: transportNumber ?? this.transportNumber,
      totalBillAmount: totalBillAmount ?? this.totalBillAmount,
      billNo: billNo ?? this.billNo,
      billDate: billDate ?? this.billDate,
      createdDate: createdDate ?? this.createdDate,
      price: price ?? this.price,
      docID: docID ?? this.docID,
      listingProducts: listingProducts ?? this.listingProducts,
      isEstimateConverted: isEstimateConverted ?? this.isEstimateConverted,
      taxType: taxType ?? this.taxType,
      gstType: gstType ?? this.gstType,
      state: state ?? this.state,
      city: city ?? this.city,
      taxCalc: taxCalc ?? this.taxCalc,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'companyId': companyId,
      'partyName': partyName,
      'address': address,
      'deliveryaddress': deliveryaddress,
      'phoneNumber': phoneNumber,
      'transportName': transportName,
      'transportNumber': transportNumber,
      'totalBillAmount': totalBillAmount,
      'billNo': billNo,
      'billDate': billDate?.millisecondsSinceEpoch,
      'createdDate': createdDate?.millisecondsSinceEpoch,
      'price': price?.toMap(),
      'docID': docID,
      'isEstimateConverted': isEstimateConverted,
      'taxType': taxType,
      'gstType': gstType,
      'state': state,
      'city': city,
      'tax_calc': taxCalc,
      'is_same_state': sameState,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
        companyId: map['companyId'] != null ? map['companyId'] as String : null,
        partyName: map['partyName'] != null ? map['partyName'] as String : null,
        address: map['address'] != null ? map['address'] as String : null,
        deliveryaddress: map['deliveryaddress'] != null
            ? map['deliveryaddress'] as String
            : null,
        phoneNumber:
            map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
        transportName: map['transportName'] != null
            ? map['transportName'] as String
            : null,
        transportNumber: map['transportNumber'] != null
            ? map['transportNumber'] as String
            : null,
        totalBillAmount: map['totalBillAmount'] != null
            ? map['totalBillAmount'] as String
            : null,
        billNo: map['billNo'] != null ? map['billNo'] as String : null,
        billDate: map['billDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['billDate'] as int)
            : null,
        createdDate: map['createdDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['createdDate'] as int)
            : null,
        price: map['price'] != null
            ? BillingCalCulationModel.fromMap(
                map['price'] as Map<String, dynamic>)
            : null,
        docID: map['docID'] != null ? map['docID'] as String : null,
        listingProducts: map['listingProducts'] != null
            ? List<InvoiceProductModel>.from(
                (map['listingProducts'] as List<int>).map<InvoiceProductModel?>(
                  (x) => InvoiceProductModel.fromMap(x as Map<String, dynamic>),
                ),
              )
            : null,
        isEstimateConverted: map['isEstimateConverted'] != null
            ? map['isEstimateConverted'] as bool
            : null,
        taxType: map['taxType'] != null ? map['taxType'] as bool : null,
        gstType: map['gstType'] != null ? map['gstType'] as String : null,
        state: map['state'] != null ? map['state'] as String : null,
        city: map['city'] != null ? map['city'] as String : null,
        taxCalc: Map<String, dynamic>.from(
          (map['taxCalc'] as Map<String, dynamic>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory InvoiceModel.fromJson(String source) =>
      InvoiceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'InvoiceModel(companyId: $companyId, partyName: $partyName, address: $address, deliveryaddress: $deliveryaddress, phoneNumber: $phoneNumber, transportName: $transportName, transportNumber: $transportNumber, totalBillAmount: $totalBillAmount, billNo: $billNo, billDate: $billDate, createdDate: $createdDate, price: $price, docID: $docID, listingProducts: $listingProducts, isEstimateConverted: $isEstimateConverted, taxType: $taxType, gstType: $gstType, state: $state, city: $city, taxCalc: $taxCalc)';
  }

  @override
  bool operator ==(covariant InvoiceModel other) {
    if (identical(this, other)) return true;

    return other.companyId == companyId &&
        other.partyName == partyName &&
        other.address == address &&
        other.deliveryaddress == deliveryaddress &&
        other.phoneNumber == phoneNumber &&
        other.transportName == transportName &&
        other.transportNumber == transportNumber &&
        other.totalBillAmount == totalBillAmount &&
        other.billNo == billNo &&
        other.billDate == billDate &&
        other.createdDate == createdDate &&
        other.price == price &&
        other.docID == docID &&
        listEquals(other.listingProducts, listingProducts) &&
        other.isEstimateConverted == isEstimateConverted &&
        other.taxType == taxType &&
        other.gstType == gstType &&
        other.state == state &&
        other.city == city &&
        mapEquals(other.taxCalc, taxCalc);
  }

  @override
  int get hashCode {
    return companyId.hashCode ^
        partyName.hashCode ^
        address.hashCode ^
        deliveryaddress.hashCode ^
        phoneNumber.hashCode ^
        transportName.hashCode ^
        transportNumber.hashCode ^
        totalBillAmount.hashCode ^
        billNo.hashCode ^
        billDate.hashCode ^
        createdDate.hashCode ^
        price.hashCode ^
        docID.hashCode ^
        listingProducts.hashCode ^
        isEstimateConverted.hashCode ^
        taxType.hashCode ^
        gstType.hashCode ^
        state.hashCode ^
        city.hashCode ^
        taxCalc.hashCode;
  }

  Map<String, dynamic> toCreationMap() {
    var mapping = <String, dynamic>{};
    mapping["company_id"] = companyId;
    mapping["bill_no"] = billNo;
    mapping["party_name"] = partyName;
    mapping["address"] = address;
    mapping["delivery_address"] = deliveryaddress;
    mapping["phone_number"] = phoneNumber;
    mapping["transport_name"] = transportName;
    mapping["transport_number"] = transportNumber;
    mapping["created_date"] = createdDate;
    mapping["bill_date"] = billDate;
    mapping["delete_at"] = false;
    mapping["total_amount"] = totalBillAmount;
    mapping["price"] = price?.toMap();
    mapping["products"] = listingProducts != null
        ? [
            for (var data in listingProducts!) data.toCreateMap(),
          ]
        : null;
    mapping["is_istimate_converted"] = isEstimateConverted;
    mapping["tax_type"] = taxType;
    mapping["gst_type"] = gstType;
    mapping["state"] = state;
    mapping["city"] = city;
    mapping["tax_calc"] = taxCalc;
    mapping['is_same_state'] = sameState;
    return mapping;
  }

  Map<String, dynamic> toUpdateMap() {
    var mapping = <String, dynamic>{};
    mapping["party_name"] = partyName;
    mapping["address"] = address;
    mapping["delivery_address"] = deliveryaddress;
    mapping["phone_number"] = phoneNumber;
    mapping["transport_name"] = transportName;
    mapping["transport_number"] = transportNumber;
    mapping["total_amount"] = totalBillAmount;
    mapping["price"] = price?.toMap();
    mapping["products"] = listingProducts != null
        ? [
            for (var data in listingProducts!) data.toCreateMap(),
          ]
        : null;
    mapping["is_istimate_converted"] = isEstimateConverted;
    mapping["tax_type"] = taxType;
    mapping["gst_type"] = gstType;
    mapping["state"] = state;
    mapping["city"] = city;
    mapping["tax_calc"] = taxCalc;
    mapping['is_same_state'] = sameState;

    return mapping;
  }
}
