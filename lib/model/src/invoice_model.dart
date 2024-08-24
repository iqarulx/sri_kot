import 'billing_calculation_model.dart';

import 'package:json_annotation/json_annotation.dart';

import 'invoice_product_model.dart';

part 'invoice_model.g.dart';

@JsonSerializable()
class InvoiceModel {
  String? partyName;
  String? address;
  String? deliveryaddress;
  String? phoneNumber;
  String? transportName;
  String? transportNumber;
  String? totalBillAmount;
  String? billNo;
  DateTime? biilDate;
  DateTime? createdDate;
  BillingCalCulationModel? price;
  String? docID;
  List<InvoiceProductModel>? listingProducts;
  bool? isEstimateConverted;

  InvoiceModel({
    this.partyName,
    this.address,
    this.deliveryaddress,
    this.phoneNumber,
    this.transportName,
    this.transportNumber,
    this.totalBillAmount,
    this.billNo,
    this.biilDate,
    this.createdDate,
    this.price,
    this.docID,
    this.listingProducts,
    this.isEstimateConverted,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceModelToJson(this);

  Map<String, dynamic> toCreationMap() {
    var mapping = <String, dynamic>{};
    mapping["bill_no"] = billNo;
    mapping["party_name"] = partyName;
    mapping["address"] = address;
    mapping["delivery_address"] = deliveryaddress;
    mapping["phone_number"] = phoneNumber;
    mapping["transport_name"] = transportName;
    mapping["transport_number"] = transportNumber;
    mapping["created_date"] = createdDate;
    mapping["bill_date"] = biilDate;
    mapping["delete_at"] = false;
    mapping["total_amount"] = totalBillAmount;
    mapping["price"] = price?.toMap();
    mapping["products"] = listingProducts != null
        ? [
            for (var data in listingProducts!) data.toCreateMap(),
          ]
        : null;
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
    mapping["products"] = listingProducts != null
        ? [
            for (var data in listingProducts!) data.toCreateMap(),
          ]
        : null;
    return mapping;
  }
}
