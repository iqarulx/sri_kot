import 'package:json_annotation/json_annotation.dart';
part 'staff_permission_model.g.dart';

@JsonSerializable()
class StaffPermissionModel {
  bool? product;
  bool? category;
  bool? customer;
  bool? orders;
  bool? estimate;
  bool? billofsupply;

  StaffPermissionModel(
      {this.product,
      this.category,
      this.customer,
      this.orders,
      this.estimate,
      this.billofsupply});

  factory StaffPermissionModel.fromJson(Map<String, dynamic> json) =>
      _$StaffPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffPermissionModelToJson(this);

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["product"] = product;
    mapping["category"] = category;
    mapping["customer"] = customer;
    mapping["orders"] = orders;
    mapping["estimate"] = estimate;
    mapping["billofsupply"] = billofsupply;
    return mapping;
  }
}
