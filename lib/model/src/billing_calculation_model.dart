import 'package:json_annotation/json_annotation.dart';

part 'billing_calculation_model.g.dart';

@JsonSerializable()
class BillingCalCulationModel {
  double? subTotal;
  double? discount;
  String? discountsys;
  double? discountValue;
  double? extraDiscount;
  String? extraDiscountsys;
  double? extraDiscountValue;
  double? package;
  String? packagesys;
  double? packageValue;
  double? total;

  BillingCalCulationModel({
    this.subTotal,
    this.discount,
    this.discountsys,
    this.discountValue,
    this.extraDiscount,
    this.extraDiscountsys,
    this.extraDiscountValue,
    this.package,
    this.packagesys,
    this.packageValue,
    this.total,
  });

  factory BillingCalCulationModel.fromJson(Map<String, dynamic> json) =>
      _$BillingCalCulationModelFromJson(json);

  Map<String, dynamic> toJson() => _$BillingCalCulationModelToJson(this);

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["sub_total"] = subTotal;
    mapping["discount"] = discount;
    mapping["discount_sys"] = discountsys;
    mapping["discount_value"] = discountValue;
    mapping["extra_discount"] = extraDiscount;
    mapping["extra_discount_sys"] = extraDiscountsys;
    mapping["extra_discount_value"] = extraDiscountValue;
    mapping["package"] = package;
    mapping["package_sys"] = packagesys;
    mapping["package_value"] = packageValue;
    mapping["total"] = total;
    return mapping;
  }
}
