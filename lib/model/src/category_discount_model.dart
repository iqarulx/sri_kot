// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CategoryDiscountModel {
  String? categoryName;
  int? discountValue;
  CategoryDiscountModel({
    this.categoryName,
    this.discountValue,
  });

  CategoryDiscountModel copyWith({
    String? categoryName,
    int? discountValue,
  }) {
    return CategoryDiscountModel(
      categoryName: categoryName ?? this.categoryName,
      discountValue: discountValue ?? this.discountValue,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoryName': categoryName,
      'discountValue': discountValue,
    };
  }

  factory CategoryDiscountModel.fromMap(Map<String, dynamic> map) {
    return CategoryDiscountModel(
      categoryName:
          map['categoryName'] != null ? map['categoryName'] as String : null,
      discountValue:
          map['discountValue'] != null ? map['discountValue'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryDiscountModel.fromJson(String source) =>
      CategoryDiscountModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CategoryDiscountModel(categoryName: $categoryName, discountValue: $discountValue)';

  @override
  bool operator ==(covariant CategoryDiscountModel other) {
    if (identical(this, other)) return true;

    return other.categoryName == categoryName &&
        other.discountValue == discountValue;
  }

  @override
  int get hashCode => categoryName.hashCode ^ discountValue.hashCode;
}
