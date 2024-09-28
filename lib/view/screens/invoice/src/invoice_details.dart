import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sri_kot/services/services.dart';
import '../../../../constants/constants.dart';
import '/model/model.dart';
import '/view/screens/screens.dart';

class InvoiceDetails extends StatefulWidget {
  final InvoiceModel invoice;
  const InvoiceDetails({super.key, required this.invoice});

  @override
  State<InvoiceDetails> createState() => _InvoiceDetailsState();
}

class _InvoiceDetailsState extends State<InvoiceDetails> {
  InvoiceModel? invoice;
  List<CategoryDataModel> categoryList = [];

  openDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Print Options"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Cancel"),
          ),
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context, "Original");
              },
              title: const Text("Original"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context, "Duplicate");
              },
              title: const Text("Duplicate"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context, "Triplicate");
              },
              title: const Text("Triplicate"),
            ),
          ],
        ),
      ),
    ).then((result) {
      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoicePdfView(
              title: result,
              invoice: invoice ?? InvoiceModel(),
            ),
          ),
        );
      }
    });
  }

  TableRow tableRow(String? title, String? value, bool bold) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            title ?? "",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3),
          child: Text(
            value ?? "",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: bold ? Colors.black : Colors.grey),
          ),
        ),
      ],
    );
  }

  String itemCount() {
    String result = "0";
    int count = 0;
    for (var element in invoice!.listingProducts!) {
      count += element.qty!;
    }
    result = count.toString();
    return result;
  }

  Future getInvoice() async {
    try {
      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        await FireStore().categoryListing(cid: cid).then((value) {
          if (value != null && value.docs.isNotEmpty) {
            for (var categorylist in value.docs) {
              CategoryDataModel model = CategoryDataModel();
              model.categoryName = categorylist["category_name"].toString();
              model.postion = categorylist["postion"];
              model.tmpcatid = categorylist.id;
              model.discount = categorylist["discount"];
              setState(() {
                categoryList.add(model);
              });
            }
          }
        });
      }).then((value) async {
        await FireStore()
            .getInvoiceInfo(cid: widget.invoice.docID ?? '')
            .then((value) {
          if (value != null) {
            if (value.exists) {
              InvoiceModel model = InvoiceModel();
              model.docID = value.id;
              model.partyName = value["party_name"];
              model.address = value["address"];
              model.biilDate = (value["bill_date"] as Timestamp).toDate();
              model.billNo = value["bill_no"];
              model.phoneNumber = value["phone_number"];
              model.totalBillAmount = value["total_amount"];
              model.transportName = value["transport_name"];
              model.transportNumber = value["transport_number"];
              model.listingProducts = [];
              if (value["products"] != null) {
                for (var productElement in value["products"]) {
                  InvoiceProductModel models = InvoiceProductModel();
                  models.productID = productElement["product_id"];
                  models.productName = productElement["product_name"];
                  models.qty = productElement["qty"];
                  models.rate = productElement["rate"].toDouble();
                  models.total = productElement["total"].toDouble();
                  models.unit = productElement["unit"];
                  models.categoryID = productElement["category_id"];
                  models.discountLock = productElement["discount_lock"];
                  if (models.categoryID != null &&
                      models.categoryID!.isNotEmpty) {
                    var getCategoryid = categoryList.indexWhere(
                        (elements) => elements.tmpcatid == models.categoryID);
                    models.discount = categoryList[getCategoryid].discount;
                  }

                  setState(() {
                    model.listingProducts!.add(models);
                  });
                }
              }
              model.deliveryaddress = value["delivery_address"] ?? "";

              if (value["price"] != null) {
                var calcula = BillingCalCulationModel();
                calcula.discount = value["price"]["discount"];
                calcula.discountValue = value["price"]["discount_value"];
                calcula.discountsys = value["price"]["discount_sys"];
                calcula.extraDiscount = value["price"]["extra_discount"];
                calcula.extraDiscountValue =
                    value["price"]["extra_discount_value"];
                calcula.extraDiscountsys = value["price"]["extra_discount_sys"];
                calcula.package = value["price"]["package"];
                calcula.packageValue = value["price"]["package_value"];
                calcula.packagesys = value["price"]["package_sys"];
                calcula.subTotal = value["price"]["sub_total"];
                calcula.roundOff = value["price"]["round_off"];
                calcula.total = value["price"]["total"];

                model.price = calcula;
              }
              setState(() {
                invoice = model;
              });
            }
          }
        });
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    invoiceHanlder = getInvoice();
    super.initState();
  }

  Future? invoiceHanlder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      body: FutureBuilder(
        future: invoiceHanlder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  invoiceHanlder = getInvoice();
                });
              },
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Table(
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    "Invoice",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    invoice!.billNo ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    "Date",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    invoice!.biilDate != null
                                        ? DateFormat("dd-MM-yyyy")
                                            .format(invoice!.biilDate!)
                                        : "",
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    "Total Amount",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    "₹${invoice!.totalBillAmount ?? ""}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Table(
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    "Party Name",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    invoice!.partyName ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    "Address",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(invoice!.address ?? ""),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    "Delivery Address",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(invoice!.deliveryaddress ?? ""),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    "Transport Name",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    invoice!.transportName ?? "",
                                  ),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    "Transport Number",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    invoice!.transportNumber ?? "",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Price",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Table(
                          children: [
                            tableRow(
                                "Sub Total",
                                "Rs.${invoice != null ? invoice!.price!.subTotal : ""}",
                                false),
                            tableRow("Discount",
                                "Rs.${invoice!.price!.discountValue}", false),
                            tableRow(
                                "Extra Discount (${invoice != null ? invoice!.price!.extraDiscountsys == "%" ? '${invoice!.price!.extraDiscount != null ? (invoice!.price!.extraDiscount)!.round() : ""}%' : 'Rs ${invoice!.price!.extraDiscount != null ? (invoice!.price!.extraDiscount)!.round() : ""}' : ""})",
                                "Rs.${invoice!.price!.extraDiscountValue}",
                                false),
                            tableRow(
                                "Package Charge (${invoice != null ? invoice!.price!.packagesys == "%" ? '${invoice!.price!.package != null ? (invoice!.price!.package)!.round() : ""}%' : 'Rs ${invoice!.price!.package != null ? (invoice!.price!.package)!.round() : ""}' : ""})",
                                "Rs.${invoice!.price!.packageValue}",
                                false),
                            tableRow(
                                "Round Off",
                                "Rs.${invoice != null ? invoice!.price!.roundOff : ""}",
                                false),
                            tableRow(
                                "Total",
                                "Rs.${invoice != null ? invoice!.price!.total : ""}",
                                true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Products(${invoice!.listingProducts!.length})",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              "Items(${itemCount()})",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.5),
                            1: FlexColumnWidth(7),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(4),
                            4: FlexColumnWidth(4),
                          },
                          children: [
                            TableRow(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2, vertical: 5),
                                    child: Text(
                                      "#",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 5),
                                  child: Text(
                                    "Name",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 5),
                                  child: Text(
                                    "Qty",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 5),
                                  child: Text(
                                    "Rate",
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 5),
                                  child: Text(
                                    "Total",
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            for (int index = 0;
                                index < invoice!.listingProducts!.length;
                                index++)
                              TableRow(
                                decoration: BoxDecoration(
                                  border: invoice!.listingProducts!.length !=
                                          (index + 1)
                                      ? Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        )
                                      : null,
                                ),
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        (index + 1).toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(invoice!.listingProducts?[index]
                                            .productName ??
                                        ""),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      invoice!.listingProducts![index].qty
                                          .toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      double.parse(invoice!
                                              .listingProducts![index].rate
                                              .toString())
                                          .toStringAsFixed(2),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      double.parse(invoice!
                                              .listingProducts![index].total
                                              .toString())
                                          .toStringAsFixed(2),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text("Bill of Supply"),
      actions: [
        IconButton(
          splashRadius: 20,
          onPressed: () {
            openDialog();
          },
          icon: const Icon(
            Icons.print,
          ),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InvoiceCreation(invoice: invoice),
              ),
            );

            if (result != null) {
              if (result) {
                setState(() {
                  invoiceHanlder = getInvoice();
                });
              }
            }
          },
          icon: const Icon(
            Icons.edit,
          ),
        ),
      ],
    );
  }
}
