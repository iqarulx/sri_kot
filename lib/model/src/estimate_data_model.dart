// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/constants/constants.dart';
import 'billing_calculation_model.dart';
import 'customer_data_model.dart';
import 'product_data_model.dart';

class EstimateDataModel {
  DateTime? createddate;
  String? enquiryid;
  String? estimateid;
  BillingCalCulationModel? price;
  CustomerDataModel? customer;
  List<ProductDataModel>? products;
  String? docID;
  String? referenceId;
  DataTypes? dataType;
  String? billNo;
  EstimateDataModel({
    this.createddate,
    this.enquiryid,
    this.estimateid,
    this.price,
    this.customer,
    this.products,
    this.docID,
    this.referenceId,
    this.dataType,
    this.billNo,
  });

  EstimateDataModel copyWith({
    DateTime? createddate,
    String? enquiryid,
    String? estimateid,
    BillingCalCulationModel? price,
    CustomerDataModel? customer,
    List<ProductDataModel>? products,
    String? docID,
    String? referenceId,
    DataTypes? dataType,
  }) {
    return EstimateDataModel(
      createddate: createddate ?? this.createddate,
      enquiryid: enquiryid ?? this.enquiryid,
      estimateid: estimateid ?? this.estimateid,
      price: price ?? this.price,
      customer: customer ?? this.customer,
      products: products ?? this.products,
      docID: docID ?? this.docID,
      referenceId: referenceId ?? this.referenceId,
      dataType: dataType ?? this.dataType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createddate': createddate?.millisecondsSinceEpoch,
      'enquiryid': enquiryid,
      'estimateid': estimateid,
      'price': price?.toMap(),
      'customer': customer?.toMap(),
      'products': products!.map((x) => x.toMap()).toList(),
      'docID': docID,
      'referenceId': referenceId,
      'dataType': dataType,
    };
  }

  factory EstimateDataModel.fromMap(Map<String, dynamic> map) {
    return EstimateDataModel(
      createddate: map['createddate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createddate'] as int)
          : null,
      enquiryid: map['enquiryid'] != null ? map['enquiryid'] as String : null,
      estimateid:
          map['estimateid'] != null ? map['estimateid'] as String : null,
      price: map['price'],
      customer: map['customer'],
      products: map['products'] != null
          ? List<ProductDataModel>.from(
              (map['products'] as List<int>).map<ProductDataModel?>(
                (x) => ProductDataModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      docID: map['docID'] != null ? map['docID'] as String : null,
      referenceId:
          map['referenceId'] != null ? map['referenceId'] as String : null,
      dataType: map['dataType'] != null ? DataTypes.cloud : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EstimateDataModel.fromJson(String source) =>
      EstimateDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EstimateDataModel(createddate: $createddate, enquiryid: $enquiryid, estimateid: $estimateid, price: $price, customer: $customer, products: $products, docID: $docID, referenceId: $referenceId, dataType: $dataType)';
  }

  @override
  bool operator ==(covariant EstimateDataModel other) {
    if (identical(this, other)) return true;

    return other.createddate == createddate &&
        other.enquiryid == enquiryid &&
        other.estimateid == estimateid &&
        other.price == price &&
        other.customer == customer &&
        listEquals(other.products, products) &&
        other.docID == docID &&
        other.referenceId == referenceId &&
        other.dataType == dataType;
  }

  @override
  int get hashCode {
    return createddate.hashCode ^
        enquiryid.hashCode ^
        estimateid.hashCode ^
        price.hashCode ^
        customer.hashCode ^
        products.hashCode ^
        docID.hashCode ^
        referenceId.hashCode ^
        dataType.hashCode;
  }
}
