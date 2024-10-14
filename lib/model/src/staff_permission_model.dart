// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class StaffPermissionModel {
  bool? product;
  bool? category;
  bool? customer;
  bool? orders;
  bool? estimate;
  bool? billofsupply;
  StaffPermissionModel({
    this.product,
    this.category,
    this.customer,
    this.orders,
    this.estimate,
    this.billofsupply,
  });

  StaffPermissionModel copyWith({
    bool? product,
    bool? category,
    bool? customer,
    bool? orders,
    bool? estimate,
    bool? billofsupply,
  }) {
    return StaffPermissionModel(
      product: product ?? this.product,
      category: category ?? this.category,
      customer: customer ?? this.customer,
      orders: orders ?? this.orders,
      estimate: estimate ?? this.estimate,
      billofsupply: billofsupply ?? this.billofsupply,
    );
  }

  factory StaffPermissionModel.fromMap(Map<String, dynamic> map) {
    return StaffPermissionModel(
      product: map['product'] != null ? map['product'] as bool : null,
      category: map['category'] != null ? map['category'] as bool : null,
      customer: map['customer'] != null ? map['customer'] as bool : null,
      orders: map['orders'] != null ? map['orders'] as bool : null,
      estimate: map['estimate'] != null ? map['estimate'] as bool : null,
      billofsupply:
          map['billofsupply'] != null ? map['billofsupply'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory StaffPermissionModel.fromJson(String source) =>
      StaffPermissionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StaffPermissionModel(product: $product, category: $category, customer: $customer, orders: $orders, estimate: $estimate, billofsupply: $billofsupply)';
  }

  @override
  bool operator ==(covariant StaffPermissionModel other) {
    if (identical(this, other)) return true;

    return other.product == product &&
        other.category == category &&
        other.customer == customer &&
        other.orders == orders &&
        other.estimate == estimate &&
        other.billofsupply == billofsupply;
  }

  @override
  int get hashCode {
    return product.hashCode ^
        category.hashCode ^
        customer.hashCode ^
        orders.hashCode ^
        estimate.hashCode ^
        billofsupply.hashCode;
  }

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
