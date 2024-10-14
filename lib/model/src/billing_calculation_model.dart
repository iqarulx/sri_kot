// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BillingCalCulationModel {
  double? subTotal;
  double? roundOff;

  double? discountValue;
  double? extraDiscount;
  String? extraDiscountsys;
  double? extraDiscountValue;
  double? package;
  String? packagesys;
  double? packageValue;
  double? total;
  double? netratedTotal;
  double? discountedTotal;
  double? netPlusDisTotal;
  Map<String, dynamic>? discounts;

  BillingCalCulationModel({
    this.subTotal,
    this.roundOff,
    this.discountValue,
    this.extraDiscount,
    this.extraDiscountsys,
    this.extraDiscountValue,
    this.package,
    this.packagesys,
    this.packageValue,
    this.total,
  });

  BillingCalCulationModel copyWith(
      {double? subTotal,
      double? roundOff,
      double? discount,
      String? discountsys,
      double? discountValue,
      double? extraDiscount,
      String? extraDiscountsys,
      double? extraDiscountValue,
      double? package,
      String? packagesys,
      double? packageValue,
      double? total}) {
    return BillingCalCulationModel(
      subTotal: subTotal ?? this.subTotal,
      roundOff: roundOff ?? this.roundOff,
      discountValue: discountValue ?? this.discountValue,
      extraDiscount: extraDiscount ?? this.extraDiscount,
      extraDiscountsys: extraDiscountsys ?? this.extraDiscountsys,
      extraDiscountValue: extraDiscountValue ?? this.extraDiscountValue,
      package: package ?? this.package,
      packagesys: packagesys ?? this.packagesys,
      packageValue: packageValue ?? this.packageValue,
      total: total ?? this.total,
    );
  }

  factory BillingCalCulationModel.fromMap(Map<String, dynamic> map) {
    return BillingCalCulationModel(
      subTotal: map['subTotal'] != null ? map['subTotal'] as double : null,
      roundOff: map['roundOff'] != null ? map['roundOff'] as double : null,
      discountValue:
          map['discountValue'] != null ? map['discountValue'] as double : null,
      extraDiscount:
          map['extraDiscount'] != null ? map['extraDiscount'] as double : null,
      extraDiscountsys: map['extraDiscountsys'] != null
          ? map['extraDiscountsys'] as String
          : null,
      extraDiscountValue: map['extraDiscountValue'] != null
          ? map['extraDiscountValue'] as double
          : null,
      package: map['package'] != null ? map['package'] as double : null,
      packagesys:
          map['packagesys'] != null ? map['packagesys'] as String : null,
      packageValue:
          map['packageValue'] != null ? map['packageValue'] as double : null,
      total: map['total'] != null ? map['total'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BillingCalCulationModel.fromJson(String source) =>
      BillingCalCulationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BillingCalCulationModel(subTotal: $subTotal, roundOff: $roundOff,  discountValue: $discountValue, extraDiscount: $extraDiscount, extraDiscountsys: $extraDiscountsys, extraDiscountValue: $extraDiscountValue, package: $package, packagesys: $packagesys, packageValue: $packageValue, total: $total)';
  }

  @override
  bool operator ==(covariant BillingCalCulationModel other) {
    if (identical(this, other)) return true;

    return other.subTotal == subTotal &&
        other.roundOff == roundOff &&
        other.discountValue == discountValue &&
        other.extraDiscount == extraDiscount &&
        other.extraDiscountsys == extraDiscountsys &&
        other.extraDiscountValue == extraDiscountValue &&
        other.package == package &&
        other.packagesys == packagesys &&
        other.packageValue == packageValue &&
        other.total == total;
  }

  @override
  int get hashCode {
    return subTotal.hashCode ^
        roundOff.hashCode ^
        discountValue.hashCode ^
        extraDiscount.hashCode ^
        extraDiscountsys.hashCode ^
        extraDiscountValue.hashCode ^
        package.hashCode ^
        packagesys.hashCode ^
        packageValue.hashCode ^
        total.hashCode;
  }

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["sub_total"] = subTotal;
    mapping["round_off"] = roundOff;
    mapping["discount_value"] = discountValue;
    mapping["extra_discount"] = extraDiscount;
    mapping["extra_discount_sys"] = extraDiscountsys;
    mapping["extra_discount_value"] = extraDiscountValue;
    mapping["package"] = package;
    mapping["package_sys"] = packagesys;
    mapping["package_value"] = packageValue;
    mapping["total"] = total;
    mapping["netrated_total"] = netratedTotal;
    mapping["discounted_total"] = discountedTotal;
    mapping["net_plus_dis_total"] = netPlusDisTotal;
    mapping["discounts"] = discounts;
    return mapping;
  }
}
