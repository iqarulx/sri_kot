import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sri_kot/constants/constants.dart';
import 'package:sri_kot/purchase/products.dart';
import 'package:sri_kot/services/services.dart';
import 'package:sri_kot/utils/src/utilities.dart';
import '../log/log.dart';
import '../services/local/firebase.dart';

class Purchases extends Firebase {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? subscription;

  static void initializePurchaseUpdates(BuildContext context) {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) {
      handlePurchaseUpdates(context, purchaseDetailsList);
    }, onDone: () {
      subscription?.cancel();
    }, onError: (error) {
      snackbar(context, false, "Error in purchase stream: ${error.toString()}");
    });
  }

  static void handlePurchaseUpdates(
      BuildContext context, List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          loading(context);

          // Fetch the product details based on product ID
          final ProductDetails productDetails =
              await Products.getProductDetails(purchaseDetails.productID);

          _storePurchaseInFirebase(purchaseDetails,
                  isConsumable: purchaseDetails.productID == staffId ||
                      purchaseDetails.productID == userId,
                  productDetails: productDetails) // Pass ProductDetails
              .then((value) async {
            if (purchaseDetails.productID == staffId) {
              await LocalService.addStaffCount();
            } else if (purchaseDetails.productID == userId) {
              await LocalService.addUserCount();
            } else {
              await LocalService.updateExpiryDate();
            }
            Navigator.pop(context);
          });
          snackbar(context, true, "Purchase successful!");
          break;

        case PurchaseStatus.error:
          snackbar(context, false,
              "Purchase error: ${purchaseDetails.error?.message}");
          break;

        case PurchaseStatus.pending:
          snackbar(context, true, "Purchase is pending...");
          break;

        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        if (purchaseDetails.productID == staffId ||
            purchaseDetails.productID == userId) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  static void buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);

    if (productDetails.id == staffId) {
      _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam, autoConsume: true);
    } else if (productDetails.id == userId) {
      _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam, autoConsume: true);
    } else {
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  static Future<void> _storePurchaseInFirebase(PurchaseDetails purchaseDetails,
      {required bool isConsumable,
      required ProductDetails productDetails}) async {
    try {
      await Firebase.purchases.add({
        'product_id': purchaseDetails.productID,
        'transaction_date': purchaseDetails.transactionDate,
        'purchase_id': purchaseDetails.purchaseID,
        'status': purchaseDetails.status.name.toString(),
        'is_consumable': isConsumable,
        'error': purchaseDetails.error.toString(),
        'pending': purchaseDetails.pendingCompletePurchase,
        'amount': productDetails.price,
        'currency': productDetails.currencyCode,
        'product_name': productDetails.title,
        'raw_amount': productDetails.rawPrice,
        'company_id': await LocalDB.fetchInfo(type: LocalData.companyid),
        'company_name': await LocalDB.fetchInfo(type: LocalData.companyName),
        'created_at': DateTime.now(),
      });
    } catch (e) {
      Log.addLog("${DateTime.now()} : Error storing purchase in Firebase: $e");
    }
  }

  static void restorePurchases(BuildContext context) {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;

    subscription = purchaseUpdated.listen((purchaseDetailsList) async {
      for (var purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          loading(context);

          // Fetch ProductDetails based on product ID
          try {
            final ProductDetails productDetails =
                await Products.getProductDetails(purchaseDetails.productID);

            // Now call the store function with the required parameter
            await _storePurchaseInFirebase(purchaseDetails,
                isConsumable: false, productDetails: productDetails);

            snackbar(context, true, "Purchase restored successfully!");
          } catch (e) {
            snackbar(context, false,
                "Error fetching product details: ${e.toString()}");
          } finally {
            Navigator.pop(context);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }, onDone: () {
      subscription?.cancel();
    }, onError: (error) {
      snackbar(
          context, false, "Error restoring purchases: ${error.toString()}");
    });
  }

  static Future<bool> isSubscriptionActive(String productId) async {
    try {
      final companyId = await LocalDB.fetchInfo(type: LocalData.companyid);

      final QuerySnapshot querySnapshot = await Firebase.purchases
          .where('company_id', isEqualTo: companyId)
          .where('product_id', isEqualTo: basePlanId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }
    } catch (e) {
      Log.addLog("${DateTime.now()} : Error checking subscription status: $e");
    }
    return false;
  }

  static Future<bool> isBasePlanActive() async {
    try {
      final companyId = await LocalDB.fetchInfo(type: LocalData.companyid);

      final QuerySnapshot querySnapshot = await Firebase.purchases
          .where('company_id', isEqualTo: companyId)
          .where('product_id', isEqualTo: basePlanId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }
    } catch (e) {
      Log.addLog("${DateTime.now()} : Error checking baseplan status: $e");
    }
    return false;
  }

  static void dispose() {
    subscription?.cancel();
  }
}

class Products {
  static Future<ProductDetails> getProductDetails(String productId) async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('Product not found');
    }
    return response.productDetails.first;
  }
}
