import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_kot/services/services.dart';
import 'package:sri_kot/utils/src/utilities.dart';
import 'package:sri_kot/view/screens/purchase_history/src/purchase_details_view.dart';
import 'package:sri_kot/view/ui/ui.dart';
import '../../../../model/model.dart';

class PurchaseHistory extends StatefulWidget {
  const PurchaseHistory({super.key});

  @override
  State<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  Future? purchaseHandler;
  List<PurchaseHistoryModel> purchaseHistory = [];

  @override
  void initState() {
    purchaseHandler = getPayments();
    super.initState();
  }

  getPayments() async {
    try {
      setState(() {
        purchaseHistory.clear();
      });
      await LocalService.getPurchaseHistory().then((value) {
        if (value.docs.isNotEmpty) {
          for (var data in value.docs) {
            PurchaseHistoryModel purchaseHistoryModel = PurchaseHistoryModel();

            purchaseHistoryModel.docId = data.id;
            purchaseHistoryModel.amount = data["amount"];
            purchaseHistoryModel.companId = data["company_id"];
            purchaseHistoryModel.companyName = data["company_name"];
            purchaseHistoryModel.createdAt = data["created_at"].toDate();
            purchaseHistoryModel.currency = data["currency"];
            purchaseHistoryModel.error = data["error"];
            purchaseHistoryModel.isConsumable = data["is_consumable"];
            purchaseHistoryModel.productId = data["product_id"];
            purchaseHistoryModel.productName = data["product_name"];
            purchaseHistoryModel.purchaseId = data["purchase_id"];
            purchaseHistoryModel.rawAmount = data["raw_amount"].toInt();
            purchaseHistoryModel.status = data["status"];
            purchaseHistoryModel.transactionDate = data["transaction_date"];

            setState(() {
              purchaseHistory.add(purchaseHistoryModel);
            });
          }
        }
      });
    } on Exception catch (e) {
      snackbar(context, false, e.toString());
    }
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
        title: const Text("Payment History"),
      ),
      body: FutureBuilder(
        future: purchaseHandler,
        builder: (builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return futureLoading(context);
          } else if (snapshot.hasError) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        "Failed",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      snapshot.error.toString() == "null"
                          ? "Something went Wrong"
                          : snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            purchaseHandler = getPayments();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          "Refresh",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: purchaseHistory.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (builder) {
                      return PurchaseDetailsView(model: purchaseHistory[index]);
                    }));
                  },
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    purchaseHistory[index].productName ?? '',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    DateFormat('dd-MM-yyyy h:m s').format(
                                        purchaseHistory[index].createdAt ??
                                            DateTime.now()),
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
                                  purchaseHistory[index].amount ?? '',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (purchaseHistory[index].status !=
                                    "purchased")
                                  const Text(
                                    "Failed",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
