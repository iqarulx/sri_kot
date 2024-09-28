import 'dart:io'; // Import for platform checking
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sri_kot/services/firebase/firestore.dart';
import '/purchase/products.dart';
import '/utils/src/utilities.dart';
import '/view/ui/ui.dart';
import 'purchases.dart';

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  List<ProductDetails> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      _initializePurchases();
      Purchases.initializePurchaseUpdates(context);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializePurchases() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var isEnterpriseUser = await FireStore().isEnterpriseUser() ?? false;

    if (isEnterpriseUser) {
      const Set<String> kIds = {
        enterpriseBasePlanId,
        enterpriseStaffId,
        enterpriseuserId
      };
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(kIds);
      if (response.notFoundIDs.isNotEmpty) {
        print(response.notFoundIDs);
      }

      setState(() {
        _products = response.productDetails;
        _isLoading = false;
      });
    } else {
      const Set<String> kIds = {basePlanId, staffId, userId};
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(kIds);
      if (response.notFoundIDs.isNotEmpty) {
        print(response.notFoundIDs);
      }

      setState(() {
        _products = response.productDetails;
        _isLoading = false;
      });
    }
  }

  void _buyProduct(ProductDetails productDetails) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) {
          return const PurchaseModal();
        }).then((value) async {
      if (value != null) {
        if (value) {
          if (productDetails.id != basePlanId) {
            var isBasePlanActive = await Purchases.isBasePlanActive();
            if (isBasePlanActive) {
              Purchases.buyProduct(productDetails);
            } else {
              snackbar(context, false,
                  "No base plan found. Please purchase base plan first.");
            }
          } else {
            Purchases.buyProduct(productDetails);
          }
        }
      }
    });
  }

  Future<bool> _isSubscriptionActive(String productId) async {
    var result = await Purchases.isSubscriptionActive(productId);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Platform.isAndroid
              ? ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];

                    return FutureBuilder<bool>(
                      future: _isSubscriptionActive(product.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }

                        final isActive = snapshot.data ?? false;

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.id == basePlanId)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Base Plan",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (isActive)
                                              const Text(
                                                " (Active)",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.title,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              product.description,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        children: [
                                          Text(
                                            "₹${(product.rawPrice * 2).toString()}",
                                            style: const TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.black,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            product.price,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    onPressed:
                                        product.id == basePlanId && isActive
                                            ? null
                                            : () => _buyProduct(product),
                                    child: const Text('Buy'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    );
                  },
                )
              : Center(
                  child: Text(
                    'Purchases are only available on Android devices.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
    );
  }

  @override
  void dispose() {
    Purchases.dispose();
    super.dispose();
  }
}
