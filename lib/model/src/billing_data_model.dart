import 'package:json_annotation/json_annotation.dart';
import 'category_data_model.dart';
import 'product_data_model.dart';

part 'billing_data_model.g.dart';

@JsonSerializable()
class BillingDataModel {
  CategoryDataModel? category;
  List<ProductDataModel>? products;
  BillingDataModel({this.category, this.products});

  factory BillingDataModel.fromJson(Map<String, dynamic> json) =>
      _$BillingDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$BillingDataModelToJson(this);
}
