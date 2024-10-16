import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'package:url_launcher/url_launcher.dart';
import '/constants/constants.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
// import 'consumables.dart';

final bool _kAutoConsume = Platform.isIOS || true;

const String _kUserId = 'user';
const String _kStaffId = 'staff';
const String _kBasePlanId = 'srikot_company';
const String _kPremiumPlanId = "srikot_app";

// const String _kGoldSubscriptionId = 'srikot_app';
const List<String> _kProductIds = <String>[
  _kUserId,
  _kStaffId,
  _kBasePlanId,
  _kPremiumPlanId
];

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => PurchaseState();
}

class PurchaseState extends State<Purchase> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  Future? purchaseHandler;

  @override
  void initState() {
    if (Platform.isAndroid || Platform.isIOS) {
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription =
          purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (Object error) {
        // handle error here.
      });
      purchaseHandler = initStoreInfo();
    }

    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
      });
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
      });
      return;
    }

    setState(() {
      _products = productDetailResponse.productDetails;
    });
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        iosPlatformAddition.setDelegate(null);
      }
      _subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Upgrade Plan"),
        actions: [
          TextButton.icon(
            label: Text(
              "Help",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                  ),
            ),
            icon: const Icon(
              Icons.question_mark_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              _help();
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        onPressed: () async {
          try {
            await _inAppPurchase.restorePurchases();
            snackbar(context, true, "Purchases restored successfully");
          } catch (e) {
            snackbar(context, false, "Failed to restore purchases: $e");
          }
        },
        label: const Text("Restore"),
        icon: const Icon(Icons.refresh_rounded),
      ),
      body: FutureBuilder(
        future: purchaseHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return futureLoading(context);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Color(0xffFFC300),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Buy subscription or add user/staff",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  indent: 10,
                  endIndent: 10,
                ),
                const SizedBox(
                  height: 5,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.grid_view_rounded,
                          color: Color(0xff3f44bb),
                          size: 18,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text("Accessibility to all features",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Color(0xfff5b368),
                          size: 18,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text("Works on offline bill creation",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_graph_rounded,
                          color: Color(0xff1b9a75),
                          size: 18,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text("Better Financial Management",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  indent: 10,
                  endIndent: 10,
                ),
                const SizedBox(
                  height: 5,
                ),
                ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (builder) {
                                  return const PurchaseModal();
                                }).then((value) async {
                              if (value != null && value) {
                                _handlePurchase(index);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              // color: const Color(0xffdcd1fc),
                              color: const Color(0xffffe2c0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Annual",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xfffcb15a),
                                      ),
                                      child: const Text(
                                        "50% OFF",
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //_products[index].id == _kBasePlanId
                                          Text(
                                            _products[index].title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          Text(
                                            _products[index].description,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "\u{20B9}${(_products[index].rawPrice * 2).toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        ),
                                        Text(
                                          _products[index].price,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      color: Color(0xff808080),
                      size: 18,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text("Tap a product to purchase",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff808080))),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  _help() {
    confirmationDialog(context,
            title: "Help contact",
            message: "Contact our sales team for\nfurther assistance")
        .then((value) async {
      if (value != null) {
        if (value) {
          final Uri launchUri = Uri(
            scheme: 'tel',
            path: "+91 8220018086",
          );
          await launchUrl(launchUri);
        }
      }
    });
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == _kStaffId ||
        purchaseDetails.productID == _kUserId) {
      setState(() {
        _purchases.add(purchaseDetails);
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {}

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        snackbar(context, true, "Purchase is pending...");
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            unawaited(deliverProduct(purchaseDetails));
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume &&
              purchaseDetails.productID == _kStaffId &&
              purchaseDetails.productID == _kUserId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
          _storePurchaseInFirebase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _handlePurchase(int index) async {
    final Map<String, PurchaseDetails> purchases =
        Map<String, PurchaseDetails>.fromEntries(
            _purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    final PurchaseDetails? previousPurchase = purchases[_products[index].id];
    if (previousPurchase != null && Platform.isIOS) {
      confirmPriceChange(context);
    } else {
      late PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        final GooglePlayPurchaseDetails? oldSubscription =
            _getOldSubscription(_products[index], purchases);

        purchaseParam = GooglePlayPurchaseParam(
            productDetails: _products[index],
            changeSubscriptionParam: (oldSubscription != null)
                ? ChangeSubscriptionParam(
                    oldPurchaseDetails: oldSubscription,
                    prorationMode: ProrationMode.immediateWithTimeProration,
                  )
                : null);
      } else {
        purchaseParam = PurchaseParam(
          productDetails: _products[index],
        );
      }

      if (_products[index].id == _kUserId) {
        _inAppPurchase.buyConsumable(
            purchaseParam: purchaseParam, autoConsume: _kAutoConsume);
      } else if (_products[index].id == _kStaffId) {
        _inAppPurchase.buyConsumable(
            purchaseParam: purchaseParam, autoConsume: _kAutoConsume);
      } else {
        _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    }
  }

  _storePurchaseInFirebase(PurchaseDetails purchaseDetails) async {
    try {
      loading(context);
      final product = _products.firstWhere(
        (element) => element.id == purchaseDetails.productID,
      );
      await FirebaseQuery.purchases.add({
        'product_id': purchaseDetails.productID,
        'purchase_id': purchaseDetails.purchaseID,
        'transaction_date': purchaseDetails.transactionDate,
        'status': purchaseDetails.status.name.toString(),
        'is_consumable': _kAutoConsume,
        'amount': product.price,
        'currency': product.currencyCode,
        'raw_amount': product.rawPrice,
        'product_name': product.title,
        'currency_symbol': product.currencySymbol,
        'company_id': await LocalDB.fetchInfo(type: LocalData.companyid),
        'created_at': DateTime.now(),
      });
      Navigator.pop(context);
      snackbar(context, true, "Purchase completed successfully");
    } on Exception catch (e) {
      snackbar(context, false, e.toString());
    }
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    /* 
    if (productDetails.id == _kBasePlanId &&
        purchases[_kGoldSubscriptionId] != null) {
      oldSubscription =
          purchases[_kGoldSubscriptionId]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == _kGoldSubscriptionId &&
        purchases[_kBasePlanId] != null) {
      oldSubscription =
          purchases[_kBasePlanId]! as GooglePlayPurchaseDetails;
    }
    */
    if (purchases[_kBasePlanId] != null) {
      oldSubscription = purchases[_kBasePlanId]! as GooglePlayPurchaseDetails;
    } else if (purchases[_kBasePlanId] != null) {
      oldSubscription = purchases[_kBasePlanId]! as GooglePlayPurchaseDetails;
    }

    return oldSubscription;
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
