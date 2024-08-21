import 'package:json_annotation/json_annotation.dart';

part 'category_data_model.g.dart';

@JsonSerializable()
class CategoryDataModel {
  String? categoryName;
  String? name;
  int? postion;
  String? cid;
  bool? deleteAt;
  int? discount;
  String? tmpcatid;
  bool? discountEnable;

  CategoryDataModel({
    this.categoryName,
    this.name,
    this.postion,
    this.cid,
    this.deleteAt,
    this.discount,
    this.tmpcatid,
    this.discountEnable,
  });

  factory CategoryDataModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDataModelToJson(this);

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["name"] = name;
    mapping["category_name"] = categoryName;
    mapping["postion"] = postion;
    mapping["company_id"] = cid;
    mapping["delete_at"] = deleteAt;
    mapping["discount"] = discount;
    return mapping;
  }

  Map<String, dynamic> toDiscountUpdate() {
    var mapping = <String, dynamic>{};
    mapping["discount"] = discount;
    return mapping;
  }

  Map<String, dynamic> toUpdateMap() {
    var mapping = <String, dynamic>{};
    mapping["name"] = name;
    mapping["category_name"] = categoryName;
    return mapping;
  }
}
