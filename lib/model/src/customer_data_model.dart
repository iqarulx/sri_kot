import 'package:json_annotation/json_annotation.dart';
part 'customer_data_model.g.dart';

@JsonSerializable()
class CustomerDataModel {
  String? customerName;
  String? address;
  String? city;
  String? companyID;
  String? email;
  String? mobileNo;
  String? state;
  String? docID;

  CustomerDataModel(
      {this.customerName,
      this.address,
      this.city,
      this.companyID,
      this.email,
      this.mobileNo,
      this.state,
      this.docID});

  factory CustomerDataModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerDataModelToJson(this);

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_id"] = companyID;
    mapping["email"] = email;
    mapping["mobile_no"] = mobileNo;
    mapping["customer_name"] = customerName;
    mapping["state"] = state;
    return mapping;
  }

  Map<String, dynamic> toOrderMap() {
    var mapping = <String, dynamic>{};
    mapping["address"] = address;
    mapping["city"] = city;
    mapping["company_id"] = companyID;
    mapping["email"] = email;
    mapping["mobile_no"] = mobileNo;
    mapping["customer_name"] = customerName;
    mapping["state"] = state;
    mapping["customer_id"] = docID;
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
    return mapping;
  }
}
