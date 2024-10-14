import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '/constants/constants.dart';
import '/purchase/products.dart';
import '/services/services.dart';
import '/utils/src/utilities.dart';
import '/services/firebase/firebase.dart';

class Products {
  // Fetch product details based on product ID
  static Future<ProductDetails> getProductDetails(String productId) async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception('Product not found');
    }
    return response.productDetails.first;
  }
}

class Purchases {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? subscription;

  // Initialize purchase updates listener
  static void initializePurchaseUpdates(BuildContext context) {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(context, purchaseDetailsList);
    }, onDone: () {
      subscription?.cancel();
    }, onError: (error) {
      snackbar(context, false, "Error in purchase stream: ${error.toString()}");
    });
  }

  // Handles incoming purchases from the purchase stream
  static void _handlePurchaseUpdates(
      BuildContext context, List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (_isSubscription(purchaseDetails.productID)) {
            await _processSubscriptionPurchase(context, purchaseDetails);
          } else {
            await _processProductPurchase(context, purchaseDetails);
          }
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

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  // Check if the product is a subscription
  static bool _isSubscription(String productId) {
    return productId == basePlanId || productId == enterpriseBasePlanId;
  }

  // Process subscription purchases
  static Future<void> _processSubscriptionPurchase(
      BuildContext context, PurchaseDetails purchaseDetails) async {
    // Fetch product details
    final ProductDetails productDetails =
        await Products.getProductDetails(purchaseDetails.productID);

    // Store subscription info in Firebase or backend
    await _storePurchaseInFirebase(purchaseDetails, productDetails,
        isConsumable: false);

    // Example: Updating expiry date for subscription
    if (purchaseDetails.productID == basePlanId ||
        purchaseDetails.productID == enterpriseBasePlanId) {
      await LocalService.updateExpiryDate();
    }

    snackbar(context, true, "Subscription purchase successful!");
  }

  // Process one-time product purchases (non-consumable or consumable)
  static Future<void> _processProductPurchase(
      BuildContext context, PurchaseDetails purchaseDetails) async {
    final ProductDetails productDetails =
        await Products.getProductDetails(purchaseDetails.productID);

    // Determine if the product is consumable
    final isConsumable = (purchaseDetails.productID == staffId ||
        purchaseDetails.productID == userId);

    // Store purchase details in Firebase or backend
    await _storePurchaseInFirebase(purchaseDetails, productDetails,
        isConsumable: isConsumable);

    // Deliver consumable product if applicable
    if (isConsumable) {
      await _deliverConsumableProduct(purchaseDetails);
    }

    snackbar(context, true, "Product purchase successful!");
  }

  // Store purchase information in Firebase or backend
  static Future<void> _storePurchaseInFirebase(
      PurchaseDetails purchaseDetails, ProductDetails productDetails,
      {required bool isConsumable}) async {
    // Save purchase information in Firebase or backend database
    await Firebase.purchases.add({
      'product_id': purchaseDetails.productID,
      'purchase_id': purchaseDetails.purchaseID,
      'transaction_date': purchaseDetails.transactionDate,
      'status': purchaseDetails.status.name.toString(),
      'is_consumable': isConsumable,
      'amount': productDetails.price,
      'currency': productDetails.currencyCode,
      'company_id': await LocalDB.fetchInfo(type: LocalData.companyid),
      'created_at': DateTime.now(),
    });
  }

  // Handle delivery of consumable products (e.g., adding credits)
  static Future<void> _deliverConsumableProduct(
      PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == staffId) {
      await LocalService.addStaffCount();
    } else if (purchaseDetails.productID == userId) {
      await LocalService.addUserCount();
    }
  }

  // Restore purchases functionality (e.g., when re-installing the app)
  static void restorePurchases(BuildContext context) {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) async {
      for (var purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final ProductDetails productDetails =
              await Products.getProductDetails(purchaseDetails.productID);
          await _storePurchaseInFirebase(purchaseDetails, productDetails,
              isConsumable: false);
          snackbar(context, true, "Purchase restored successfully!");
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }, onDone: () {
      subscription?.cancel();
    }, onError: (error) {
      snackbar(
          context, false, "Error restoring purchases: ${error.toString()}");
    });
  }

  static void dispose() {
    subscription?.cancel();
  }
}


// class Purchases extends Firebase {
//   static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   static StreamSubscription<List<PurchaseDetails>>? subscription;

//   static void initializePurchaseUpdates(BuildContext context) {
//     final Stream<List<PurchaseDetails>> purchaseUpdated =
//         _inAppPurchase.purchaseStream;
//     subscription = purchaseUpdated.listen((purchaseDetailsList) {
//       handlePurchaseUpdates(context, purchaseDetailsList);
//     }, onDone: () {
//       subscription?.cancel();
//     }, onError: (error) {
//       snackbar(context, false, "Error in purchase stream: ${error.toString()}");
//     });
//   }

//   static void handlePurchaseUpdates(
//       BuildContext context, List<PurchaseDetails> purchaseDetailsList) async {
//     for (var purchaseDetails in purchaseDetailsList) {
//       switch (purchaseDetails.status) {
//         case PurchaseStatus.purchased:
//         case PurchaseStatus.restored:
//           loading(context);

//           // Fetch the product details based on product ID
//           final ProductDetails productDetails =
//               await Products.getProductDetails(purchaseDetails.productID);

//           await _storePurchaseInFirebase(purchaseDetails,
//                   isConsumable: purchaseDetails.productID == staffId ||
//                       purchaseDetails.productID == userId,
//                   productDetails: productDetails)
//               .then((value) async {
//             if (purchaseDetails.productID == enterpriseBasePlanId) {
//               await LocalService.updateExpiryDate();
//               await LocalService.addBulkStaffCount();
//             } else {
//               if (purchaseDetails.productID == staffId) {
//                 await LocalService.addStaffCount();
//               } else if (purchaseDetails.productID == userId) {
//                 await LocalService.addUserCount();
//               } else {
//                 await LocalService.updateExpiryDate();
//               }
//             }

//             // After delivering the content, call completePurchase
//             if (purchaseDetails.pendingCompletePurchase) {
//               await _completePurchase(purchaseDetails);
//             }

//             Navigator.pop(context);
//           });

//           snackbar(context, true, "Purchase successful!");
//           break;

//         case PurchaseStatus.error:
//           snackbar(context, false,
//               "Purchase error: ${purchaseDetails.error?.message}");
//           break;

//         case PurchaseStatus.pending:
//           snackbar(context, true, "Purchase is pending...");
//           break;

//         default:
//           break;
//       }
//     }
//   }

//   static Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
//     try {
//       await _inAppPurchase.completePurchase(purchaseDetails);
//       Log.addLog(
//           "${DateTime.now()} : Purchase completed for ${purchaseDetails.productID}");
//     } catch (e) {
//       Log.addLog("${DateTime.now()} : Error completing purchase: $e");
//     }
//   }

//   static void buyProduct(ProductDetails productDetails) {
//     final PurchaseParam purchaseParam =
//         PurchaseParam(productDetails: productDetails);

//     if (productDetails.id == staffId) {
//       _inAppPurchase.buyConsumable(
//           purchaseParam: purchaseParam, autoConsume: true);
//     } else if (productDetails.id == userId) {
//       _inAppPurchase.buyConsumable(
//           purchaseParam: purchaseParam, autoConsume: true);
//     } else {
//       _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//     }
//   }

//   static Future _storePurchaseInFirebase(PurchaseDetails purchaseDetails,
//       {required bool isConsumable,
//       required ProductDetails productDetails}) async {
//     try {
//       DocumentReference ref = await Firebase.purchases.add({
//         'product_id': purchaseDetails.productID,
//         'transaction_date': purchaseDetails.transactionDate,
//         'purchase_id': purchaseDetails.purchaseID,
//         'status': purchaseDetails.status.name.toString(),
//         'is_consumable': isConsumable,
//         'error': purchaseDetails.error.toString(),
//         'pending': purchaseDetails.pendingCompletePurchase,
//         'amount': productDetails.price,
//         'currency': productDetails.currencyCode,
//         'product_name': productDetails.title,
//         'raw_amount': productDetails.rawPrice,
//         'company_id': await LocalDB.fetchInfo(type: LocalData.companyid),
//         'company_name': await LocalDB.fetchInfo(type: LocalData.companyName),
//         'created_at': DateTime.now(),
//       });

//       await Messaging.sendPaymentToAdmin(
//           amount: productDetails.price,
//           product: productDetails.title,
//           docId: ref.id);
//     } catch (e) {
//       Log.addLog("${DateTime.now()} : Error storing purchase in Firebase: $e");
//     }
//   }

//   static void restorePurchases(BuildContext context) {
//     final Stream<List<PurchaseDetails>> purchaseUpdated =
//         _inAppPurchase.purchaseStream;

//     subscription = purchaseUpdated.listen((purchaseDetailsList) async {
//       for (var purchaseDetails in purchaseDetailsList) {
//         if (purchaseDetails.status == PurchaseStatus.purchased ||
//             purchaseDetails.status == PurchaseStatus.restored) {
//           loading(context);

//           // Fetch ProductDetails based on product ID
//           try {
//             final ProductDetails productDetails =
//                 await Products.getProductDetails(purchaseDetails.productID);

//             // Now call the store function with the required parameter
//             await _storePurchaseInFirebase(purchaseDetails,
//                 isConsumable: false, productDetails: productDetails);

//             snackbar(context, true, "Purchase restored successfully!");
//           } catch (e) {
//             snackbar(context, false,
//                 "Error fetching product details: ${e.toString()}");
//           } finally {
//             Navigator.pop(context);
//           }
//         }

//         if (purchaseDetails.pendingCompletePurchase) {
//           _inAppPurchase.completePurchase(purchaseDetails);
//         }
//       }
//     }, onDone: () {
//       subscription?.cancel();
//     }, onError: (error) {
//       snackbar(
//           context, false, "Error restoring purchases: ${error.toString()}");
//     });
//   }

//   static Future<bool> isSubscriptionActive(String productId) async {
//     try {
//       final companyId = await LocalDB.fetchInfo(type: LocalData.companyid);

//       final QuerySnapshot querySnapshot = await Firebase.purchases
//           .where('company_id', isEqualTo: companyId)
//           .where('product_id', isEqualTo: basePlanId)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         return true;
//       }
//     } catch (e) {
//       Log.addLog("${DateTime.now()} : Error checking subscription status: $e");
//     }
//     return false;
//   }

//   static Future<bool> isBasePlanActive() async {
//     try {
//       final companyId = await LocalDB.fetchInfo(type: LocalData.companyid);

//       final QuerySnapshot querySnapshot = await Firebase.purchases
//           .where('company_id', isEqualTo: companyId)
//           .where('product_id', isEqualTo: basePlanId)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         return true;
//       }
//     } catch (e) {
//       Log.addLog("${DateTime.now()} : Error checking baseplan status: $e");
//     }
//     return false;
//   }

//   static void dispose() {
//     subscription?.cancel();
//   }
// }

