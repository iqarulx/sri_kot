import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sri_kot/utils/utils.dart';
import '../../../../constants/enum.dart';
import '../../../../in_app_purchase/purchase.dart';
import '/services/services.dart';

class Plans extends StatefulWidget {
  const Plans({super.key});

  @override
  State<Plans> createState() => _PlansState();
}

class _PlansState extends State<Plans> {
  List<Package> packages = [];
  Future? packageHanlder;

  Future fetchOffersIds() async {
    final offerings = await Purchase.fetchOffers();

    packages = offerings
        .map((offer) => offer.availablePackages)
        .expand((pair) => pair)
        .toList();
  }

  @override
  void initState() {
    packageHanlder = fetchOffersIds();
    super.initState();
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
        title: const Text("Plans Details"),
        actions: [
          IconButton(
            onPressed: () async {
              LocalService.callService(context);
            },
            icon: const Icon(
              CupertinoIcons.phone_arrow_up_right,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: packageHanlder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return ListView.builder(
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              packages[index].storeProduct.title,
                              style: const TextStyle(
                                color: Color(0xff003049),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xff4895ef),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      packages[index].storeProduct.description,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                "${packages[index].storeProduct.currencyCode} ${packages[index].storeProduct.price + 0}",
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                " ${packages[index].storeProduct.currencyCode} ${packages[index].storeProduct.priceString}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        var result =
                                            await Purchase.purchasePackage(
                                                packages[index]);
                                        if (result) {
                                          snackBarCustom(context, true,
                                              "Purchase successfull");

                                          await LocalService.updateCount(
                                                  uid: await LocalDbProvider()
                                                          .fetchInfo(
                                                              type: LocalData
                                                                  .companyid) ??
                                                      '',
                                                  type: ProfileType.admin)
                                              .then((value) async {
                                            print("Firebase : $value");

                                            if (value) {
                                              await LocalService.addPayment(
                                                      uid: await LocalDbProvider()
                                                              .fetchInfo(
                                                                  type: LocalData
                                                                      .companyid) ??
                                                          '',
                                                      type: PaymentType.staff)
                                                  .then((result) {
                                                if (result) {
                                                  print("Payment Success");
                                                }
                                              });
                                            }
                                          });
                                        } else {
                                          snackBarCustom(context, false,
                                              "Purchase was unsuccessfull");
                                        }
                                      },
                                      child: Container(
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFF7777),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Buy Now",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Icon(
                                                CupertinoIcons.forward,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}
