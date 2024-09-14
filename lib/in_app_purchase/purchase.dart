// import 'package:purchases_flutter/purchases_flutter.dart';

// class Purchase {
//   static const _apiKey = "goog_dqpksiSvnYiIdvxdZzIXjgAWvtj";

//   static Future init() async {
//     await Purchases.setDebugLogsEnabled(true);
//     await Purchases.setup(_apiKey);
//   }

//   static Future<List<Offering>> fetchOffersByIds(List<String> ids) async {
//     final offers = await fetchOffers();

//     return offers.where((offer) => ids.contains(offer.identifier)).toList();
//   }

//   static Future<List<Offering>> fetchOffers({bool all = true}) async {
//     try {
//       final offerings = await Purchases.getOfferings();

//       if (!all) {
//         final current = offerings.current;
//         return current == null ? [] : [current];
//       } else {
//         return offerings.all.values.toList();
//       }
//     } on Exception catch (e) {
//       print(e);
//       return [];
//     }
//   }

//   static Future<bool> purchasePackage(Package package) async {
//     try {
//       await Purchases.purchasePackage(package).then((value) {
//         return true;
//       });
//       return false;
//     } on Exception catch (e) {
//       print(e);
//       return false;
//     }
//   }
// }
