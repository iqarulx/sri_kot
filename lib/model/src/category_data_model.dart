// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CategoryDataModel {
  String? categoryName;
  String? name;
  int? postion;
  String? cid;
  bool? deleteAt;
  int? discount;
  String? tmpcatid;
  bool? discountEnable;
  String? hsnCode;
  String? taxValue;

  CategoryDataModel({
    this.categoryName,
    this.name,
    this.postion,
    this.cid,
    this.deleteAt,
    this.discount,
    this.tmpcatid,
    this.discountEnable,
    this.hsnCode,
    this.taxValue,
  });

  CategoryDataModel copyWith({
    String? categoryName,
    String? name,
    int? postion,
    String? cid,
    bool? deleteAt,
    int? discount,
    String? tmpcatid,
    bool? discountEnable,
  }) {
    return CategoryDataModel(
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      postion: postion ?? this.postion,
      cid: cid ?? this.cid,
      deleteAt: deleteAt ?? this.deleteAt,
      discount: discount ?? this.discount,
      tmpcatid: tmpcatid ?? this.tmpcatid,
      discountEnable: discountEnable ?? this.discountEnable,
    );
  }

  factory CategoryDataModel.fromMap(Map<String, dynamic> map) {
    return CategoryDataModel(
      categoryName:
          map['categoryName'] != null ? map['categoryName'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      postion: map['postion'] != null ? map['postion'] as int : null,
      cid: map['cid'] != null ? map['cid'] as String : null,
      deleteAt: map['deleteAt'] != null ? map['deleteAt'] as bool : null,
      discount: map['discount'] != null ? map['discount'] as int : null,
      tmpcatid: map['tmpcatid'] != null ? map['tmpcatid'] as String : null,
      discountEnable:
          map['discountEnable'] != null ? map['discountEnable'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryDataModel.fromJson(String source) =>
      CategoryDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CategoryDataModel(categoryName: $categoryName, name: $name, postion: $postion, cid: $cid, deleteAt: $deleteAt, discount: $discount, tmpcatid: $tmpcatid, discountEnable: $discountEnable)';
  }

  @override
  bool operator ==(covariant CategoryDataModel other) {
    if (identical(this, other)) return true;

    return other.categoryName == categoryName &&
        other.name == name &&
        other.postion == postion &&
        other.cid == cid &&
        other.deleteAt == deleteAt &&
        other.discount == discount &&
        other.tmpcatid == tmpcatid &&
        other.discountEnable == discountEnable;
  }

  @override
  int get hashCode {
    return categoryName.hashCode ^
        name.hashCode ^
        postion.hashCode ^
        cid.hashCode ^
        deleteAt.hashCode ^
        discount.hashCode ^
        tmpcatid.hashCode ^
        discountEnable.hashCode;
  }

  Map<String, dynamic> toMap() {
    var mapping = <String, dynamic>{};
    mapping["name"] = name;
    mapping["category_name"] = categoryName;
    mapping["postion"] = postion;
    mapping["company_id"] = cid;
    mapping["delete_at"] = deleteAt;
    mapping["discount"] = discount;
    mapping["hsn_code"] = hsnCode;
    mapping["tax_value"] = taxValue;
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
    mapping["hsn_code"] = hsnCode;
    mapping["tax_value"] = taxValue;
    return mapping;
  }
}


/*


*/