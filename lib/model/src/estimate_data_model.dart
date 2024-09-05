import 'package:json_annotation/json_annotation.dart';
import 'billing_calculation_model.dart';
import 'customer_data_model.dart';
import 'product_data_model.dart';
import '/constants/constants.dart';

part 'estimate_data_model.g.dart';

@JsonSerializable()
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

  EstimateDataModel(
      {this.createddate,
      this.enquiryid,
      this.estimateid,
      this.price,
      this.customer,
      this.products,
      this.docID,
      this.dataType,
      this.referenceId});

  factory EstimateDataModel.fromJson(Map<String, dynamic> json) =>
      _$EstimateDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$EstimateDataModelToJson(this);
}
