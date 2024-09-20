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
}
