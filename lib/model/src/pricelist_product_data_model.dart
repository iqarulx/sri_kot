// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PricelistProdcutDataModel {
  String? prodcutName;
  String? content;
  String? price;
  PricelistProdcutDataModel({
    this.prodcutName,
    this.content,
    this.price,
  });

  PricelistProdcutDataModel copyWith({
    String? prodcutName,
    String? content,
    String? price,
  }) {
    return PricelistProdcutDataModel(
      prodcutName: prodcutName ?? this.prodcutName,
      content: content ?? this.content,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'prodcutName': prodcutName,
      'content': content,
      'price': price,
    };
  }

  factory PricelistProdcutDataModel.fromMap(Map<String, dynamic> map) {
    return PricelistProdcutDataModel(
      prodcutName:
          map['prodcutName'] != null ? map['prodcutName'] as String : null,
      content: map['content'] != null ? map['content'] as String : null,
      price: map['price'] != null ? map['price'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PricelistProdcutDataModel.fromJson(String source) =>
      PricelistProdcutDataModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'PricelistProdcutDataModel(prodcutName: $prodcutName, content: $content, price: $price)';

  @override
  bool operator ==(covariant PricelistProdcutDataModel other) {
    if (identical(this, other)) return true;

    return other.prodcutName == prodcutName &&
        other.content == content &&
        other.price == price;
  }

  @override
  int get hashCode => prodcutName.hashCode ^ content.hashCode ^ price.hashCode;
}
