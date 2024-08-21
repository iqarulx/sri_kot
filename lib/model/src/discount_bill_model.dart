import 'package:json_annotation/json_annotation.dart';
import 'product_data_model.dart';

part 'discount_bill_model.g.dart';

@JsonSerializable()
class DiscountBillModel {
  List<ProductDataModel>? products;
  String? discount;

  DiscountBillModel({
    this.products,
    this.discount,
  });

  factory DiscountBillModel.fromJson(Map<String, dynamic> json) =>
      _$DiscountBillModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountBillModelToJson(this);
}
