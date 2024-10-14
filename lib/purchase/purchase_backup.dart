// import 'dart:io'; // Import for platform checking
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:sri_kot/services/firebase/firestore.dart';
// import '/purchase/products.dart';
// import '/utils/src/utilities.dart';
// import '/view/ui/ui.dart';
// import 'purchases.dart';

// class Purchase extends StatefulWidget {
//   const Purchase({super.key});

//   @override
//   State<Purchase> createState() => _PurchaseState();
// }

// class _PurchaseState extends State<Purchase> {
//   List<ProductDetails> _products = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();

//     if (Platform.isAndroid) {
//       _initializePurchases();
//       Purchases.initializePurchaseUpdates(context);
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _initializePurchases() async {
//     final bool available = await InAppPurchase.instance.isAvailable();
//     if (!available) {
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }

//     var isEnterpriseUser = await FireStore().isEnterpriseUser() ?? false;

//     if (isEnterpriseUser) {
//       const Set<String> kIds = {
//         enterpriseBasePlanId,
//         enterpriseStaffId,
//         enterpriseuserId
//       };
//       final ProductDetailsResponse response =
//           await InAppPurchase.instance.queryProductDetails(kIds);
//       if (response.notFoundIDs.isNotEmpty) {
//         print(response.notFoundIDs);
//       }

//       setState(() {
//         _products = response.productDetails;
//         _isLoading = false;
//       });
//     } else {
//       const Set<String> kIds = {basePlanId, staffId, userId};
//       final ProductDetailsResponse response =
//           await InAppPurchase.instance.queryProductDetails(kIds);
//       if (response.notFoundIDs.isNotEmpty) {
//         print(response.notFoundIDs);
//       }

//       setState(() {
//         _products = response.productDetails;
//         _isLoading = false;
//       });
//     }
//   }

//   void _buyProduct(ProductDetails productDetails) {
//     showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (builder) {
//           return const PurchaseModal();
//         }).then((value) async {
//       if (value != null) {
//         if (value) {
//           if (productDetails.id != basePlanId) {
//             var isBasePlanActive = await Purchases.isBasePlanActive();
//             if (isBasePlanActive) {
//               Purchases.buyProduct(productDetails);
//             } else {
//               snackbar(context, false,
//                   "No base plan found. Please purchase base plan first.");
//             }
//           } else {
//             Purchases.buyProduct(productDetails);
//           }
//         }
//       }
//     });
//   }

//   Future<bool> _isSubscriptionActive(String productId) async {
//     var result = await Purchases.isSubscriptionActive(productId);
//     return result;
//   }

//   @override
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         final value = await confirmationDialog(
//           title: "Exit",
//           context,
//           message: "Are you sure you want to exit?",
//         );
//         return value ?? false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Purchases'),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new_rounded,
//                 color: Colors.white),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         body: GestureDetector(
//           onHorizontalDragEnd: (details) async {
//             if (details.velocity.pixelsPerSecond.dx > 0) {
//               final value = await confirmationDialog(
//                 title: "Exit",
//                 context,
//                 message: "Are you sure you want to exit?",
//               );
//               if (value != null) {
//                 if (value) {
//                   Navigator.pop(context);
//                 }
//               }
//             }
//           },
//           child: _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Platform.isAndroid
//                   ? ListView(
//                       padding: const EdgeInsets.all(10),
//                       children: [
//                         _buildSubscriptionSection(),
//                         _buildProductSection(),
//                       ],
//                     )
//                   : Center(
//                       child: Text(
//                         'Purchases are only available on Android devices.',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//         ),
//       ),
//     );
//   }

//   // Builds the subscription section
//   Widget _buildSubscriptionSection() {
//     final subscriptionProducts = _products
//         .where((product) =>
//             product.id == basePlanId || product.id == enterpriseBasePlanId)
//         .toList();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Subscriptions',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: subscriptionProducts.length,
//           itemBuilder: (context, index) {
//             final product = subscriptionProducts[index];
//             return FutureBuilder<bool>(
//               future: _isSubscriptionActive(product.id),
//               builder: (context, snapshot) {
//                 final isActive = snapshot.data ?? false;
//                 return _buildProductCard(product, isActive, true);
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }

//   // Builds the product (staff, user) section
//   Widget _buildProductSection() {
//     final nonSubscriptionProducts = _products
//         .where((product) => product.id == staffId || product.id == userId)
//         .toList();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Products',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: nonSubscriptionProducts.length,
//           itemBuilder: (context, index) {
//             final product = nonSubscriptionProducts[index];
//             return FutureBuilder<bool>(
//               future:
//                   Purchases.isBasePlanActive(), // Check if base plan is active
//               builder: (context, snapshot) {
//                 final isBasePlanActive = snapshot.data ?? false;
//                 return _buildProductCard(product, isBasePlanActive, false);
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }

//   // Builds a product card for each product/subscription
//   Widget _buildProductCard(
//       ProductDetails product, bool isActive, bool isSubscription) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(15),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           product.title,
//                           style: TextStyle(
//                             color: Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           product.description,
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Column(
//                     children: [
//                       if (!isSubscription)
//                         Text(
//                           "₹${(product.rawPrice * 2).toString()}",
//                           style: const TextStyle(
//                             decoration: TextDecoration.lineThrough,
//                             color: Colors.black,
//                             fontSize: 13,
//                           ),
//                         ),
//                       Text(
//                         product.price,
//                         style: TextStyle(
//                           color: Theme.of(context).primaryColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).primaryColor,
//                 ),
//                 onPressed: isSubscription && isActive
//                     ? null
//                     : () => _buyProduct(product),
//                 child: Text(isSubscription ? 'Subscribe' : 'Buy'),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     Purchases.dispose();
//     super.dispose();
//   }
// }