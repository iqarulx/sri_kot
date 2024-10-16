import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '/utils/src/utilities.dart';
import '/view/ui/src/table_row.dart';
import '/services/services.dart';
import '../listing/invoice_listing.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import 'add_customer_box_inv.dart';

class OrderSummaryInv extends StatefulWidget {
  final BillingCalCulationModel calc;
  final List<InvoiceProductModel> cart;
  final String cid;
  final BillType billType;
  final SaveType saveType;
  final String? billNo;
  final String? docId;
  const OrderSummaryInv({
    super.key,
    required this.calc,
    required this.cart,
    required this.cid,
    required this.billType,
    required this.saveType,
    this.billNo,
    this.docId,
  });

  @override
  State<OrderSummaryInv> createState() => _OrderSummaryInvState();
}

class _OrderSummaryInvState extends State<OrderSummaryInv> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController customerName = TextEditingController();
  PartyDataModel customerInfo = PartyDataModel();
  String? billNo;
  bool sameState = false;

  @override
  void initState() {
    if (widget.saveType == SaveType.create) {
      getBillNo();
    }
    getParty();
    checkSameState();
    if (widget.billNo != null) {
      billNo = widget.billNo ?? '';
      setState(() {});
    }

    super.initState();
  }

  getParty() async {
    var party = await LocalDB.getInvoiceParty();
    var partyDetails = jsonDecode(party ?? '');
    customerInfo.partyName = partyDetails["party_name"];
    customerInfo.mobileNo = partyDetails["mobile_no"];
    customerInfo.address = partyDetails["address"];
    customerInfo.city = partyDetails["city"];
    customerInfo.state = partyDetails["state"];
    customerInfo.transportName = partyDetails["transport_name"];
    customerInfo.transportNo = partyDetails["transport_no"];
    customerInfo.deliveryAddress = partyDetails["delivery_address"];
    customerInfo.gstType = partyDetails["gst_type"];
    customerInfo.taxType = partyDetails["tax_type"];
    customerInfo.gstChanged = partyDetails["gst_changed"];
    if (customerInfo.gstChanged ?? false || widget.saveType == SaveType.edit) {
      gstChange();
    }
    setState(() {});
  }

  gstChange() {
    if (customerInfo.gstType == "Inclusive") {
      convertToInclusive();
    } else {
      convertToExclusive();
    }
  }

  convertToInclusive() async {
    for (var i = 0; i < widget.cart.length; i++) {
      widget.cart[i].rate = InvoiceCalc.inclusiveRate(
          widget.cart[i].rate!, widget.cart[i].taxValue!);
    }
    setState(() {});
  }

  convertToExclusive() async {
    for (var i = 0; i < widget.cart.length; i++) {
      widget.cart[i].rate = InvoiceCalc.exclusiveRate(
          widget.cart[i].rate!, widget.cart[i].taxValue!);
    }
    setState(() {});
  }

  String itemCount() {
    String result = "0";
    int tmpCount = 0;
    for (var element in widget.cart) {
      tmpCount += element.qty!;
    }
    if (tmpCount.isNaN) {
      tmpCount = 0;
    }
    result = tmpCount.toString();
    return result;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  checkSameState() async {
    var companyState = await FireStore().getCompanyState();

    if (customerInfo.state!.isNotEmpty) {
      if (customerInfo.state! == companyState) {
        sameState = true;
      } else {
        sameState = false;
      }
    } else {
      sameState = false;
    }
    setState(() {});
  }

  getBillNo() async {
    if (widget.billType == BillType.invoice) {
      billNo = await FireStore().getLastInvoiceNumber();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("${toBeginningOfSentenceCase(widget.billType.name)} Summary"),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _scrollToBottom();
              if (billNo != null) {
                if (widget.saveType == SaveType.create) {
                  create();
                } else {
                  edit();
                }
              }
            },
            child: Text(widget.saveType == SaveType.create
                ? "Submit Invoice"
                : "Update Invoice"),
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  toBeginningOfSentenceCase(widget.billType.name),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  billNo ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (!(customerInfo.taxType ?? false))
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SizedBox(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "\u{20B9}${widget.calc.total}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: Colors.green.shade600,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          "\u{20B9} ${widget.calc.subTotal}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return InvoiceDiscountModal(
                                    cartDataModel: widget.cart);
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                "Discount",
                                // "Discount - % 12",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Iconsax.info_circle,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Spacer(),
                        Text(
                          "- \u{20B9}${widget.calc.discountValue}",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.red.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          "Extra Discount - ${widget.calc.extraDiscountsys} ${widget.calc.extraDiscount}",
                          // "Extra Discount - % 5",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 5),
                        const Spacer(),
                        Text(
                          "- \u{20B9}${widget.calc.extraDiscountValue}",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.red.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Packing Charges - ${widget.calc.packagesys} ${widget.calc.package}",
                          // "Packing Charges - % 10",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 5),
                        const Spacer(),
                        Text(
                          "+ \u{20B9}${widget.calc.packageValue}",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.green.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  SizedBox(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "\u{20B9}${(double.parse(InvoiceCalc.calculateCartTotal(
                                productList: widget.cart,
                                gstType: customerInfo.gstType ?? '',
                                extraDiscountType:
                                    widget.calc.extraDiscountsys ?? '',
                                extraDiscountInput:
                                    widget.calc.extraDiscount ?? 0,
                                packingDiscountType:
                                    widget.calc.packagesys ?? '',
                                packingDiscountInput: widget.calc.package ?? 0,
                                taxType: customerInfo.taxType ?? false,
                              )).roundToDouble())}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: Colors.green.shade600,
                                  ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          "\u{20B9} ${double.parse(InvoiceCalc.calculateSubTotal(productList: widget.cart))}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          "Discount",
                          // "Discount - % 12",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 5),
                        const Spacer(),
                        Text(
                          "- \u{20B9}${double.parse(InvoiceCalc.calculateDiscount(productList: widget.cart))}",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.red.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Text(
                          "Extra Discount - ${widget.calc.extraDiscountsys} ${widget.calc.extraDiscount}",
                          // "Extra Discount - % 5",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 5),
                        const Spacer(),
                        Text(
                          "\u{20B9}${InvoiceCalc.calculateExtraDiscount(productList: widget.cart, discountType: widget.calc.extraDiscountsys!, inputValue: widget.calc.extraDiscount!)}",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.red.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Packing Charges - ${widget.calc.packagesys} ${widget.calc.package}",
                          // "Packing Charges - % 10",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 5),
                        const Spacer(),
                        Text(
                          "\u{20B9}${InvoiceCalc.calculatePackingCharges(productList: widget.cart, extraDiscountType: widget.calc.extraDiscountsys!, extraDiscountInput: widget.calc.extraDiscount!, packingDiscountType: widget.calc.packagesys!, packingDiscountInput: widget.calc.package!)}",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.green.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      if (sameState)
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "CGST (${(customerInfo.gstType)!.substring(0, 2)})",
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "${customerInfo.gstType != null && customerInfo.gstType == "Exclusive" ? "+ " : ""}\u{20B9}${((InvoiceCalc.calculateTax(productList: widget.cart, extraDiscountType: widget.calc.extraDiscountsys!, extraDiscountInput: widget.calc.extraDiscount!, packingDiscountType: widget.calc.packagesys!, packingDiscountInput: widget.calc.package!, gstType: customerInfo.gstType ?? '')["total_tax"]) / 2).toStringAsFixed(2)}",
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: customerInfo.gstType != null &&
                                                  customerInfo.gstType ==
                                                      "Exclusive"
                                              ? Colors.green
                                              : Colors.black,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  "SGST (${(customerInfo.gstType)!.substring(0, 2)})",
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "${customerInfo.gstType != null && customerInfo.gstType == "Exclusive" ? "+ " : ""}\u{20B9}${((InvoiceCalc.calculateTax(productList: widget.cart, extraDiscountType: widget.calc.extraDiscountsys!, extraDiscountInput: widget.calc.extraDiscount!, packingDiscountType: widget.calc.packagesys!, packingDiscountInput: widget.calc.package!, gstType: customerInfo.gstType ?? '')["total_tax"]) / 2).toStringAsFixed(2)}",
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: customerInfo.gstType != null &&
                                                  customerInfo.gstType ==
                                                      "Exclusive"
                                              ? Colors.green
                                              : Colors.black,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Text(
                              "IGST (${(customerInfo.gstType)!.substring(0, 2)})",
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${customerInfo.gstType != null && customerInfo.gstType == "Exclusive" ? "+ " : ""}\u{20B9}${InvoiceCalc.calculateTax(productList: widget.cart, extraDiscountType: widget.calc.extraDiscountsys!, extraDiscountInput: widget.calc.extraDiscount!, packingDiscountType: widget.calc.packagesys!, packingDiscountInput: widget.calc.package!, gstType: customerInfo.gstType ?? '')["total_tax"].toStringAsFixed(2)}",
                                textAlign: TextAlign.end,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: customerInfo.gstType != null &&
                                              customerInfo.gstType ==
                                                  "Exclusive"
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Text(
                              "Round Off",
                              // "Discount - % 12",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 5),
                            const Spacer(),
                            Text(
                              "\u{20B9}${InvoiceCalc.calculateRoundOff(
                                productList: widget.cart,
                                extraDiscountType:
                                    widget.calc.extraDiscountsys!,
                                extraDiscountInput: widget.calc.extraDiscount!,
                                packingDiscountType: widget.calc.packagesys!,
                                packingDiscountInput: widget.calc.package!,
                                gstType: customerInfo.gstType ?? '',
                                taxType: customerInfo.taxType ?? false,
                              )["round_off_value"]}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Colors.red.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          Container(
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
                      "Party Details",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          label: const Text(
                            "Edit",
                            style: TextStyle(color: Colors.green),
                          ),
                          onPressed: () {
                            editCustomer();
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_rounded,
                              color: Colors.red),
                          label: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            deleteCustomer();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  border: TableBorder(
                    horizontalInside:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  children: [
                    buildTableRow(
                        context, "Party Name", customerInfo.partyName ?? ''),
                    buildTableRow(
                        context, "Mobile No", customerInfo.mobileNo ?? ''),
                    buildTableRow(
                        context, "Address", customerInfo.address ?? ''),
                    buildTableRow(context, "City", customerInfo.city ?? ''),
                    buildTableRow(context, "State", customerInfo.state ?? ''),
                    buildTableRow(context, "Transport Name",
                        customerInfo.transportName ?? ''),
                    buildTableRow(context, "Transport No",
                        customerInfo.transportNo ?? ''),
                    buildTableRow(context, "Delivery Address",
                        customerInfo.deliveryAddress ?? ''),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Order List",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "(${widget.cart.length})",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.black,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      "Items(${itemCount()})",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.cart[index].productType ==
                                    ProductType.netRated
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Banner(
                                      message: "Net Rate",
                                      location: BannerLocation.topStart,
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        imageUrl: Strings.productImg,
                                        fit: BoxFit.cover,
                                        height: 80.0,
                                        width: 80.0,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Banner(
                                      message:
                                          "${widget.cart[index].discount ?? 0}%",
                                      color: Colors.green,
                                      location: BannerLocation.topStart,
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        imageUrl: Strings.productImg,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        fit: BoxFit.cover,
                                        height: 80.0,
                                        width: 80.0,
                                      ),
                                    ),
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.cart[index].productName ??
                                                  "",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              // height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                  width: 0.5,
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (widget.cart[index]
                                                            .productType ==
                                                        ProductType.netRated)
                                                      Expanded(
                                                        child: Text(
                                                          "${(widget.cart[index].rate)!.toStringAsFixed(2)} X ${widget.cart[index].qty} = ${(widget.cart[index].rate! * widget.cart[index].qty!).toStringAsFixed(2)}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelMedium!
                                                                  .copyWith(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      )
                                                    else
                                                      Expanded(
                                                        child: Text(
                                                          "${(widget.cart[index].rate! - ((widget.cart[index].rate! * widget.cart[index].discount!) / 100)).toStringAsFixed(2)} X ${widget.cart[index].qty} = ${((widget.cart[index].rate! * widget.cart[index].qty!) - (((widget.cart[index].rate! * widget.cart[index].qty!) * widget.cart[index].discount!) / 100)).toStringAsFixed(2)}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .labelMedium!
                                                                  .copyWith(
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  customerInfo.taxType ?? false,
                                              child: Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Tax : ${widget.cart[index].taxValue}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        "HSN : ${widget.cart[index].hsnCode}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      if (widget.cart[index].productType ==
                                          ProductType.netRated)
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "\u{20B9}${(widget.cart[index].rate! * widget.cart[index].qty!).toStringAsFixed(2)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ],
                                        )
                                      else
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "\u{20B9}${(widget.cart[index].rate! * widget.cart[index].qty!).toStringAsFixed(2)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey),
                                            ),
                                            Text(
                                              "\u{20B9}${((widget.cart[index].rate! * widget.cart[index].qty!) - (((widget.cart[index].rate! * widget.cart[index].qty!) * widget.cart[index].discount!) / 100)).toStringAsFixed(2)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ],
                                        )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("View All"),
                    onPressed: () {
                      viewAllProducts();
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  deleteCustomer() {
    confirmationDialog(context,
            title: "Delete", message: "Are you sure want to delete this party?")
        .then((value) async {
      if (value ?? false) {
        await LocalDB.clearInvoiceParty();
        customerInfo = PartyDataModel();
        setState(() {});
        await showModalBottomSheet(
          backgroundColor: Colors.white,
          useSafeArea: true,
          showDragHandle: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          context: context,
          builder: (builder) {
            return const FractionallySizedBox(
              heightFactor: 0.9,
              child: AddCustomerBoxInv(
                edit: false,
              ),
            );
          },
        ).then((value) {});
      }
    });
  }

  editCustomer() async {
    await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (builder) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: AddCustomerBoxInv(
            edit: true,
            party: customerInfo,
          ),
        );
      },
    ).then((value) {
      getParty();
      // gstChange();
      setState(() {});
    });
  }

  Future<bool> dailog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Alert"),
        content: const Text("Do you want update this invoice?"),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Cancel"),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  create() async {
    FocusManager.instance.primaryFocus!.unfocus();

    try {
      loading(context);

      InvoiceModel model = InvoiceModel();
      model.partyName = customerInfo.partyName;
      model.address = customerInfo.address;
      model.phoneNumber = customerInfo.mobileNo;
      model.transportName = customerInfo.transportName;
      model.transportNumber = customerInfo.transportNo;
      model.state = customerInfo.state;
      model.city = customerInfo.city;
      model.gstType = customerInfo.gstType;
      model.taxType = customerInfo.taxType;
      model.deliveryaddress = customerInfo.deliveryAddress;

      model.sameState = sameState;
      model.totalBillAmount = (double.parse(InvoiceCalc.calculateCartTotal(
                productList: widget.cart,
                gstType: customerInfo.gstType ?? '',
                extraDiscountType: widget.calc.extraDiscountsys ?? '',
                extraDiscountInput: widget.calc.extraDiscount ?? 0,
                packingDiscountType: widget.calc.packagesys ?? '',
                packingDiscountInput: widget.calc.package ?? 0,
                taxType: customerInfo.taxType ?? false,
              )) -
              InvoiceCalc.calculateRoundOff(
                productList: widget.cart,
                extraDiscountType: widget.calc.extraDiscountsys!,
                extraDiscountInput: widget.calc.extraDiscount!,
                packingDiscountType: widget.calc.packagesys!,
                packingDiscountInput: widget.calc.package!,
                gstType: customerInfo.gstType ?? '',
                taxType: customerInfo.taxType ?? false,
              )["round_off_value"])
          .toStringAsFixed(2);

      var calc = BillingCalCulationModel();

      calc.discountValue =
          double.parse(InvoiceCalc.calculateDiscount(productList: widget.cart));
      calc.extraDiscount = widget.calc.extraDiscount;
      calc.extraDiscountValue = double.parse(InvoiceCalc.calculateExtraDiscount(
          productList: widget.cart,
          discountType: widget.calc.extraDiscountsys!,
          inputValue: widget.calc.extraDiscount!));
      calc.extraDiscountsys = widget.calc.extraDiscountsys;
      calc.package = widget.calc.package;
      calc.packageValue = double.parse(InvoiceCalc.calculatePackingCharges(
          productList: widget.cart,
          extraDiscountType: widget.calc.extraDiscountsys!,
          extraDiscountInput: widget.calc.extraDiscount!,
          packingDiscountType: widget.calc.packagesys!,
          packingDiscountInput: widget.calc.package!));
      calc.packagesys = widget.calc.packagesys;
      calc.subTotal =
          double.parse(InvoiceCalc.calculateSubTotal(productList: widget.cart));
      calc.roundOff = InvoiceCalc.calculateRoundOff(
        productList: widget.cart,
        extraDiscountType: widget.calc.extraDiscountsys!,
        extraDiscountInput: widget.calc.extraDiscount!,
        packingDiscountType: widget.calc.packagesys!,
        packingDiscountInput: widget.calc.package!,
        gstType: customerInfo.gstType ?? '',
        taxType: customerInfo.taxType ?? false,
      )["round_off_value"]
          .toDouble();

      calc.total = (double.parse(InvoiceCalc.calculateCartTotal(
        productList: widget.cart,
        gstType: customerInfo.gstType ?? '',
        extraDiscountType: widget.calc.extraDiscountsys ?? '',
        extraDiscountInput: widget.calc.extraDiscount ?? 0,
        packingDiscountType: widget.calc.packagesys ?? '',
        packingDiscountInput: widget.calc.package ?? 0,
        taxType: customerInfo.taxType ?? false,
      )).roundToDouble());

      model.price = calc;

      model.listingProducts = [];
      model.listingProducts!.addAll(widget.cart);
      model.companyId = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (model.taxType ?? false) {
        model.taxCalc = InvoiceCalc.calculateTax(
            productList: widget.cart,
            extraDiscountType: widget.calc.extraDiscountsys!,
            extraDiscountInput: widget.calc.extraDiscount!,
            packingDiscountType: widget.calc.packagesys!,
            packingDiscountInput: widget.calc.package!,
            gstType: customerInfo.gstType ?? '');
      }
      model.createdDate = DateTime.now();
      model.billDate = DateTime.now();
      model.billNo = billNo;
      model.isEstimateConverted = false;

      if (!calc.total!.isNegative) {
        await FireStore()
            .createNewInvoice(invoiceData: model)
            .then((value) async {
          Navigator.pop(context);
          Navigator.pop(context);
          if (!(MediaQuery.of(context).size.width > 600)) {
            Navigator.pop(context);
          }
          Navigator.pop(context);
          snackbar(context, true, "Successfully Invoice Created");
          await LocalDB.clearInvoiceParty();
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const InvoiceListing(),
            ),
          );
        });
      } else {
        Navigator.pop(context);
        showToast(
          context,
          isSuccess: false,
          content: "Bill total is negative",
          top: false,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
      throw e.toString();
    }
  }

  edit() async {
    FocusManager.instance.primaryFocus!.unfocus();

    try {
      loading(context);

      InvoiceModel model = InvoiceModel();
      model.partyName = customerInfo.partyName;
      model.address = customerInfo.address;
      model.phoneNumber = customerInfo.mobileNo;
      model.transportName = customerInfo.transportName;
      model.transportNumber = customerInfo.transportNo;
      model.state = customerInfo.state;
      model.city = customerInfo.city;
      model.gstType = customerInfo.gstType;
      model.taxType = customerInfo.taxType;
      model.deliveryaddress = customerInfo.deliveryAddress;

      model.sameState = sameState;
      model.totalBillAmount = (double.parse(InvoiceCalc.calculateCartTotal(
                productList: widget.cart,
                gstType: customerInfo.gstType ?? '',
                extraDiscountType: widget.calc.extraDiscountsys ?? '',
                extraDiscountInput: widget.calc.extraDiscount ?? 0,
                packingDiscountType: widget.calc.packagesys ?? '',
                packingDiscountInput: widget.calc.package ?? 0,
                taxType: customerInfo.taxType ?? false,
              )) -
              InvoiceCalc.calculateRoundOff(
                productList: widget.cart,
                extraDiscountType: widget.calc.extraDiscountsys!,
                extraDiscountInput: widget.calc.extraDiscount!,
                packingDiscountType: widget.calc.packagesys!,
                packingDiscountInput: widget.calc.package!,
                gstType: customerInfo.gstType ?? '',
                taxType: customerInfo.taxType ?? false,
              )["round_off_value"])
          .toStringAsFixed(2);

      var calc = BillingCalCulationModel();

      calc.discountValue =
          double.parse(InvoiceCalc.calculateDiscount(productList: widget.cart));
      calc.extraDiscount = widget.calc.extraDiscount;
      calc.extraDiscountValue = double.parse(InvoiceCalc.calculateExtraDiscount(
          productList: widget.cart,
          discountType: widget.calc.extraDiscountsys!,
          inputValue: widget.calc.extraDiscount!));
      calc.extraDiscountsys = widget.calc.extraDiscountsys;
      calc.package = widget.calc.package;
      calc.packageValue = double.parse(InvoiceCalc.calculatePackingCharges(
          productList: widget.cart,
          extraDiscountType: widget.calc.extraDiscountsys!,
          extraDiscountInput: widget.calc.extraDiscount!,
          packingDiscountType: widget.calc.packagesys!,
          packingDiscountInput: widget.calc.package!));
      calc.packagesys = widget.calc.packagesys;
      calc.subTotal =
          double.parse(InvoiceCalc.calculateSubTotal(productList: widget.cart));
      calc.roundOff = InvoiceCalc.calculateRoundOff(
        productList: widget.cart,
        extraDiscountType: widget.calc.extraDiscountsys!,
        extraDiscountInput: widget.calc.extraDiscount!,
        packingDiscountType: widget.calc.packagesys!,
        packingDiscountInput: widget.calc.package!,
        gstType: customerInfo.gstType ?? '',
        taxType: customerInfo.taxType ?? false,
      )["round_off_value"]
          .toDouble();

      calc.total = (double.parse(InvoiceCalc.calculateCartTotal(
        productList: widget.cart,
        gstType: customerInfo.gstType ?? '',
        extraDiscountType: widget.calc.extraDiscountsys ?? '',
        extraDiscountInput: widget.calc.extraDiscount ?? 0,
        packingDiscountType: widget.calc.packagesys ?? '',
        packingDiscountInput: widget.calc.package ?? 0,
        taxType: customerInfo.taxType ?? false,
      )).roundToDouble());

      model.price = calc;

      model.listingProducts = [];
      model.listingProducts!.addAll(widget.cart);
      model.companyId = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (model.taxType ?? false) {
        model.taxCalc = InvoiceCalc.calculateTax(
            productList: widget.cart,
            extraDiscountType: widget.calc.extraDiscountsys!,
            extraDiscountInput: widget.calc.extraDiscount!,
            packingDiscountType: widget.calc.packagesys!,
            packingDiscountInput: widget.calc.package!,
            gstType: customerInfo.gstType ?? '');
      }

      model.createdDate = DateTime.now();
      model.billDate = DateTime.now();
      model.billNo = billNo;
      model.isEstimateConverted = false;

      if (!calc.total!.isNegative) {
        await FireStore()
            .updateInvoice(
                docID: widget.docId ?? '',
                invoiceData: model,
                cartDataList: widget.cart)
            .then((value) {
          Navigator.pop(context);
          Navigator.pop(context);
          if (!(MediaQuery.of(context).size.width > 600)) {
            Navigator.pop(context);
          }
          Navigator.pop(context, true);
          snackbar(context, true, "Successfully Updated Invoice");
        });
      } else {
        Navigator.pop(context);
        showToast(
          context,
          isSuccess: false,
          content: "Bill total is negative",
          top: false,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
      throw e.toString();
    }
  }

  viewAllProducts() async {
    await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (builder) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: ViewAllProductsInv(
            cart: widget.cart,
            taxType: customerInfo.taxType ?? false,
          ),
        );
      },
    );
  }
}
