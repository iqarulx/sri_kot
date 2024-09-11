// import 'package:flutter/material.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// enum Entitlement { free, users }

// class YearlyPlan {
//   static const idPlan = 'sri_kot_company';
//   static const allPlan = [idPlan];
// }

// class RevenuecatProvider extends ChangeNotifier {
//   RevenuecatProvider() {
//     init();
//   }

//   Entitlement _entitlement = Entitlement.free;
//   Entitlement get entitlement => _entitlement;

//   Future init() async {
//     Purchases.addCustomerInfoUpdateListener((purchaseInfo) async {
//       updatePurchaseStatus();
//     });
//   }

//   Future updatePurchaseStatus() async {
//     final purchaseInfo = await Purchases.getCustomerInfo();

//     final entitlements = purchaseInfo.entitlements.active.values.toList();

//     _entitlement = entitlements.isEmpty ? Entitlement.free : Entitlement.users;
//   }

//   @override
//   notifyListeners();
// }
