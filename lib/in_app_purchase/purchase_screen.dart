// import 'package:flutter/material.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import '/in_app_purchase/purchase.dart';

// class PurchaseScreen extends StatefulWidget {
//   const PurchaseScreen({super.key});

//   @override
//   State<PurchaseScreen> createState() => _PurchaseScreenState();
// }

// class _PurchaseScreenState extends State<PurchaseScreen> {
//   List<Package> packages = [];
//   Future? packageHandler;

//   @override
//   void initState() {
//     packageHandler = fetchOffers();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Plans"),
//       ),
//       body: FutureBuilder(
//         future: packageHandler,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Text(snapshot.error.toString());
//           } else {
//             return ListView.builder(
//               itemCount: packages.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () async {},
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Text("Demo"),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }

//   Future fetchOffers() async {
//     final offerings = await Purchase.fetchOffers(all: false);

//     packages = offerings
//         .map((offer) => offer.availablePackages)
//         .expand((pair) => pair)
//         .toList();
//   }
// }
