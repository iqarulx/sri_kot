// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PurchaseHistoryModel {
  String? docId;
  String? amount;
  String? companId;
  String? companyName;
  DateTime? createdAt;
  String? currency;
  String? error;
  bool? isConsumable;
  String? productId;
  String? productName;
  String? purchaseId;
  int? rawAmount;
  String? status;
  String? transactionDate;

  PurchaseHistoryModel({
    this.docId,
    this.amount,
    this.companId,
    this.companyName,
    this.createdAt,
    this.currency,
    this.error,
    this.isConsumable,
    this.productId,
    this.productName,
    this.purchaseId,
    this.rawAmount,
    this.status,
    this.transactionDate,
  });

  PurchaseHistoryModel copyWith({
    String? docId,
    String? amount,
    String? companId,
    String? companyName,
    DateTime? createdAt,
    String? currency,
    String? error,
    bool? isConsumable,
    String? productId,
    String? productName,
    String? purchaseId,
    int? rawAmount,
    String? status,
    String? transactionDate,
  }) {
    return PurchaseHistoryModel(
      docId: docId ?? this.docId,
      amount: amount ?? this.amount,
      companId: companId ?? this.companId,
      companyName: companyName ?? this.companyName,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
      error: error ?? this.error,
      isConsumable: isConsumable ?? this.isConsumable,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      purchaseId: purchaseId ?? this.purchaseId,
      rawAmount: rawAmount ?? this.rawAmount,
      status: status ?? this.status,
      transactionDate: transactionDate ?? this.transactionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'docId': docId,
      'amount': amount,
      'companId': companId,
      'companyName': companyName,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'currency': currency,
      'error': error,
      'isConsumable': isConsumable,
      'productId': productId,
      'productName': productName,
      'purchaseId': purchaseId,
      'rawAmount': rawAmount,
      'status': status,
      'transactionDate': transactionDate,
    };
  }

  factory PurchaseHistoryModel.fromMap(Map<String, dynamic> map) {
    return PurchaseHistoryModel(
      docId: map['docId'] != null ? map['docId'] as String : null,
      amount: map['amount'] != null ? map['amount'] as String : null,
      companId: map['companId'] != null ? map['companId'] as String : null,
      companyName:
          map['companyName'] != null ? map['companyName'] as String : null,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      currency: map['currency'] != null ? map['currency'] as String : null,
      error: map['error'] != null ? map['error'] as String : null,
      isConsumable:
          map['isConsumable'] != null ? map['isConsumable'] as bool : null,
      productId: map['productId'] != null ? map['productId'] as String : null,
      productName:
          map['productName'] != null ? map['productName'] as String : null,
      purchaseId:
          map['purchaseId'] != null ? map['purchaseId'] as String : null,
      rawAmount: map['rawAmount'] != null ? map['rawAmount'] as int : null,
      status: map['status'] != null ? map['status'] as String : null,
      transactionDate: map['transactionDate'] != null
          ? map['transactionDate'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory PurchaseHistoryModel.fromJson(String source) =>
      PurchaseHistoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PurchaseHistoryModel(docId: $docId, amount: $amount, companId: $companId, companyName: $companyName, createdAt: $createdAt, currency: $currency, error: $error, isConsumable: $isConsumable, productId: $productId, productName: $productName, purchaseId: $purchaseId, rawAmount: $rawAmount, status: $status, transactionDate: $transactionDate)';
  }

  @override
  bool operator ==(covariant PurchaseHistoryModel other) {
    if (identical(this, other)) return true;

    return other.docId == docId &&
        other.amount == amount &&
        other.companId == companId &&
        other.companyName == companyName &&
        other.createdAt == createdAt &&
        other.currency == currency &&
        other.error == error &&
        other.isConsumable == isConsumable &&
        other.productId == productId &&
        other.productName == productName &&
        other.purchaseId == purchaseId &&
        other.rawAmount == rawAmount &&
        other.status == status &&
        other.transactionDate == transactionDate;
  }

  @override
  int get hashCode {
    return docId.hashCode ^
        amount.hashCode ^
        companId.hashCode ^
        companyName.hashCode ^
        createdAt.hashCode ^
        currency.hashCode ^
        error.hashCode ^
        isConsumable.hashCode ^
        productId.hashCode ^
        productName.hashCode ^
        purchaseId.hashCode ^
        rawAmount.hashCode ^
        status.hashCode ^
        transactionDate.hashCode;
  }
}
