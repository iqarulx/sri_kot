import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sri_kot/view/ui/src/customer_search_view.dart';
import '../../billing/src/utils/add_customer_box.dart';
import '/func/invoice_calc.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import 'tax_detail_modal.dart';

class InvoiceCreation extends StatefulWidget {
  final InvoiceModel? invoice;
  final bool fromEstimate;
  final String? estimateNo;
  const InvoiceCreation(
      {super.key, this.invoice, required this.fromEstimate, this.estimateNo});

  @override
  State<InvoiceCreation> createState() => _InvoiceCreationState();
}

class _InvoiceCreationState extends State<InvoiceCreation> {
  /// ******************** Screen UI ***********************

  bool isTab() {
    return MediaQuery.of(context).size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final value = await confirmationDialog(
          title: "Exit",
          context,
          message: "Are you sure you want to exit?",
        );
        return value ?? false;
      },
      child: Scaffold(
        appBar: appbar(context),
        body: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(10),
          children: [
            if (!isTab()) mobileView(context) else tabView(context),
          ],
        ),
      ),
    );
  }

  Column tabView(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tabViewCustomerForm(context),
            const SizedBox(
              width: 10,
            ),
            tabViewProductsForm(context),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        tabViewCalculation(context)
      ],
    );
  }

  Visibility tabViewCalculation(BuildContext context) {
    return Visibility(
      visible: cartProductList.isNotEmpty,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Subtotal",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "\u{20B9} ${double.parse(InvoiceCalc.calculateSubTotal(productList: cartProductList))}",
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return InvoiceDiscountModal(cartDataModel: cartProductList);
                  },
                );
              },
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Discount",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Iconsax.info_circle,
                        size: 16,
                      )
                    ],
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      "- \u{20B9}${double.parse(InvoiceCalc.calculateDiscount(productList: cartProductList))}",
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return DiscountModal(
                        title: "Extra Discount",
                        symbol: extraDiscountSys,
                        value: extraDiscountInput.toString(),
                        isPackingCharge: false,
                        amount: InvoiceCalc.calculateCartTotal(
                          productList: cartProductList,
                          gstType: gstType ?? '',
                          extraDiscountType: extraDiscountSys,
                          extraDiscountInput: extraDiscountInput,
                          packingDiscountType: packingChargeSys,
                          packingDiscountInput: packingChargeInput,
                          taxType: taxType,
                        ),
                      );
                    }).then((value) {
                  if (value != null) {
                    setState(() {
                      extraDiscountSys = value["sys"];
                      extraDiscountInput = double.parse(value["value"]);
                    });
                  }
                });
              },
              child: Row(
                children: [
                  Text(
                    "Extra Discount - ${extraDiscountSys.toUpperCase()} $extraDiscountInput",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.edit,
                    size: 15,
                    color: Colors.green,
                  ),
                  Expanded(
                    child: Text(
                      "- \u{20B9}${InvoiceCalc.calculateExtraDiscount(productList: cartProductList, discountType: extraDiscountSys, inputValue: extraDiscountInput)}",
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return DiscountModal(
                        title: "Packing Charges",
                        symbol: packingChargeSys,
                        value: packingChargeInput.toString(),
                        amount: InvoiceCalc.calculateCartTotal(
                          productList: cartProductList,
                          gstType: gstType ?? '',
                          extraDiscountType: extraDiscountSys,
                          extraDiscountInput: extraDiscountInput,
                          packingDiscountType: packingChargeSys,
                          packingDiscountInput: packingChargeInput,
                          taxType: taxType,
                        ),
                        isPackingCharge: true,
                      );
                    }).then((value) {
                  if (value != null) {
                    setState(() {
                      packingChargeSys = value["sys"];
                      packingChargeInput = double.parse(value["value"]);
                    });
                  }
                });
              },
              child: Row(
                children: [
                  Text(
                    "Packing Charges - ${packingChargeSys.toUpperCase()} $packingChargeInput",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.edit,
                    color: Colors.green,
                    size: 15,
                  ),
                  Expanded(
                    child: Text(
                      "+ \u{20B9}${InvoiceCalc.calculatePackingCharges(productList: cartProductList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput)}",
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            if (taxType)
              FutureBuilder(
                future: checkSameState(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return GestureDetector(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return TaxDetailModal(
                              data: InvoiceCalc.calculateTax(
                                  productList: cartProductList,
                                  extraDiscountType: extraDiscountSys,
                                  extraDiscountInput: extraDiscountInput,
                                  packingDiscountType: packingChargeSys,
                                  packingDiscountInput: packingChargeInput,
                                  gstType: gstType ?? ''),
                            );
                          },
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          if (snapshot.data ?? false)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "CGST",
                                      textAlign: TextAlign.start,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        "${gstType != null && gstType == "Exclusive" ? "+ " : ""}\u{20B9}${((InvoiceCalc.calculateTax(productList: cartProductList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput, gstType: gstType ?? '')["total_tax"]) / 2).toStringAsFixed(2)}",
                                        textAlign: TextAlign.end,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: gstType != null &&
                                                      gstType == "Exclusive"
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
                                      "SGST",
                                      textAlign: TextAlign.start,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        "${gstType != null && gstType == "Exclusive" ? "+ " : ""}\u{20B9}${((InvoiceCalc.calculateTax(productList: cartProductList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput, gstType: gstType ?? '')["total_tax"]) / 2).toStringAsFixed(2)}",
                                        textAlign: TextAlign.end,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: gstType != null &&
                                                      gstType == "Exclusive"
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
                                  "IGST",
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "${gstType != null && gstType == "Exclusive" ? "+ " : ""}\u{20B9}${InvoiceCalc.calculateTax(productList: cartProductList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput, gstType: gstType ?? '')["total_tax"].toStringAsFixed(2)}",
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: gstType != null &&
                                                  gstType == "Exclusive"
                                              ? Colors.green
                                              : Colors.black,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "CGST",
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "",
                                textAlign: TextAlign.end,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "SGST",
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "",
                                textAlign: TextAlign.end,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "Round Off",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "\u{20B9}${InvoiceCalc.calculateRoundOff(
                      productList: cartProductList,
                      extraDiscountType: extraDiscountSys,
                      extraDiscountInput: extraDiscountInput,
                      packingDiscountType: packingChargeSys,
                      packingDiscountInput: packingChargeInput,
                      taxType: taxType,
                      gstType: gstType ?? '',
                    )["round_off_value"]}",
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Divider(
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Total",
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "\u{20B9}${(double.parse(InvoiceCalc.calculateCartTotal(
                      taxType: taxType,
                      gstType: gstType ?? '',
                      productList: cartProductList,
                      extraDiscountType: extraDiscountSys,
                      extraDiscountInput: extraDiscountInput,
                      packingDiscountType: packingChargeSys,
                      packingDiscountInput: packingChargeInput,
                    )).roundToDouble())}",
                    textAlign: TextAlign.end,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                createInvoice();
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  // color: const Color(0xffFF8989),
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "${widget.invoice != null ? "Update" : "Create New"} Invoice",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded tabViewProductsForm(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: productFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Products",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        style: const ButtonStyle(),
                        onPressed: () {
                          showCustomProducts();
                        },
                        label: const Text('Custom Product'),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Product Name",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: null,
                              icon: Icon(Icons.arrow_drop_down_outlined),
                            ),
                            hintText: "Product Name",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          controller: productName,
                          onTap: () {
                            showProductAlert();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Product Name is must";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "QTY",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEEEEEE),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "QTY",
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                controller: qty,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "QTY is must";
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Unit",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEEEEEE),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Unit",
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                controller: unit,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Unit is must";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rate",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Rate",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          controller: rate,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Rate is must";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                      child: Text(
                    "Total = ${currentProductTotal()}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  )),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (invoiceFormKey.currentState!.validate()) {
                        addInvoiceProductFn();
                      }
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        // color: const Color(0xffFF8989),
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Add Product",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: cartProductList.isNotEmpty,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Products List",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 428),
                    child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: cartProductList.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 0.5,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartProductList[index].productName ?? "",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "QTY - ${cartProductList[index].qty ?? ""}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    Text(
                                      "Rate - ${cartProductList[index].rate ?? ""}/${cartProductList[index].unit ?? ""}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    if (taxType)
                                      Text(
                                        "Tax - ${cartProductList[index].taxValue}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Total - ${cartProductList[index].total ?? ""}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            InvoiceEditAlertView(
                                          productDataList: productDataList,
                                          editProduct: cartProductList[index],
                                        ),
                                      ).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await confirmationDialog(context,
                                              title: "Alert",
                                              message:
                                                  "Do you confim delete this product")
                                          .then((value) {
                                        if (value != null && value) {
                                          setState(() {
                                            cartProductList.removeAt(index);
                                          });
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded tabViewCustomerForm(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Form(
          key: invoiceFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Invoice No",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        invoiceNumber,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Divider(),
              const SizedBox(
                height: 5,
              ),
              if (taxType)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GST Type",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    DropdownButtonFormField<String>(
                      menuMaxHeight: 300,
                      value: gstType,
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            "Select gst type",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Inclusive",
                          child: Text("Inclusive"),
                        ),
                        DropdownMenuItem(
                          value: "Exclusive",
                          child: Text("Exclusive"),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            gstType = v;
                          });
                          if (v == "Inclusive") {
                            for (var i in cartProductList) {
                              setState(() {
                                i.rate = InvoiceCalc.inclusiveRate(
                                    i.rate!, i.taxValue!);
                              });
                            }
                          }
                        }
                      },
                      isExpanded: true,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xffEEEEEE),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Gst Type",
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "GST Type is must";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Party Details",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    style: const ButtonStyle(),
                    onPressed: () {
                      customerAddAlert();
                    },
                    label: const Text('Custom Party'),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Party Name (*)",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xffEEEEEE),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Party Name",
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: IconButton(
                          onPressed: () {
                            customerAlert();
                          },
                          icon: const Icon(Icons.search),
                        ),
                      ),
                      controller: partyName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Party Name is must";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Address (*)",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xffEEEEEE),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Address",
                        // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      controller: address,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Address is must";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone Number (*)",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xffEEEEEE),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Phone Number",
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        prefixIcon: Icon(Icons.call),
                      ),
                      controller: phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone Number is must";
                        } else if (phone.text.length != 10) {
                          return "Phone Number is Not Valid";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "State (*)",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          onTap: () {
                            chooseState();
                          },
                          readOnly: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "State",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          controller: state,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "State is must";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "City (*)",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          onTap: () async {
                            if (state.text.isNotEmpty) {
                              chooseCity();
                            }
                          },
                          readOnly: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "City",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          controller: city,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "City is must";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 10),
              SizedBox(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transport Name (*)",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Transport Name (*)",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              prefixIcon: Icon(Icons.local_shipping_outlined),
                            ),
                            controller: transportName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Transport Name is must";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Transport No",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xffEEEEEE),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Transport No",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              prefixIcon: Icon(Icons.local_shipping_outlined),
                            ),
                            controller: transportNumber,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Transport Number is must";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CupertinoSwitch(
                    value: copyAddress,
                    onChanged: (onChanged) {
                      if (onChanged) {
                        setState(() {
                          copyAddress = onChanged;
                          if (onChanged == true) {
                            deliveryAddress.text =
                                "${partyName.text}, ${address.text}, ${phone.text}";
                          }
                        });
                      } else {
                        setState(() {
                          copyAddress = onChanged;
                          deliveryAddress.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Same Deleivery Address",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery Address (*)",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xffEEEEEE),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Address",
                        // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      controller: deliveryAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Delivery Address is must";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column mobileView(BuildContext context) {
    return Column(
      children: [
        mobileViewCustomerForm(context),
        mobileViewProductsForm(context),
        mobileViewProducts(context),
      ],
    );
  }

  Visibility mobileViewProducts(BuildContext context) {
    return Visibility(
      visible: cartProductList.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Products List",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: cartProductList.length,
              reverse: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 0.5,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  cartProductList[index].productName ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (cartProductList[index].discountLock !=
                                        null &&
                                    !cartProductList[index].discountLock!)
                                  if (cartProductList[index].discount != null)
                                    Text(
                                      "(*)",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "QTY - ${cartProductList[index].qty ?? ""}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              "Rate - ${cartProductList[index].rate ?? ""}/${cartProductList[index].unit ?? ""}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Total - ${cartProductList[index].total ?? ""}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => InvoiceEditAlertView(
                                  productDataList: productDataList,
                                  editProduct: cartProductList[index],
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await confirmationDialog(context,
                                      title: "Alert",
                                      message:
                                          "Do you confim delete this product")
                                  .then((value) {
                                if (value != null && value) {
                                  setState(() {
                                    cartProductList.removeAt(index);
                                  });
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 5),
            Divider(
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Subtotal",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "\u{20B9} ${double.parse(InvoiceCalc.calculateSubTotal(productList: cartProductList))}",
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return InvoiceDiscountModal(cartDataModel: cartProductList);
                  },
                );
              },
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Discount",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Iconsax.info_circle,
                        size: 16,
                      )
                    ],
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      "- \u{20B9}${double.parse(InvoiceCalc.calculateDiscount(productList: cartProductList))}",
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return DiscountModal(
                        title: "Extra Discount",
                        symbol: extraDiscountSys,
                        value: extraDiscountInput.toString(),
                        isPackingCharge: false,
                        amount: InvoiceCalc.calculateCartTotal(
                          productList: cartProductList,
                          gstType: gstType ?? '',
                          extraDiscountType: extraDiscountSys,
                          extraDiscountInput: extraDiscountInput,
                          packingDiscountType: packingChargeSys,
                          packingDiscountInput: packingChargeInput,
                          taxType: taxType,
                        ),
                      );
                    }).then((value) {
                  if (value != null) {
                    setState(() {
                      extraDiscountSys = value["sys"];
                      extraDiscountInput = double.parse(value["value"]);
                    });
                  }
                });
              },
              child: Row(
                children: [
                  Text(
                    "Extra Discount - ${extraDiscountSys.toUpperCase()} $extraDiscountInput",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.edit,
                    size: 15,
                    color: Colors.green,
                  ),
                  Expanded(
                    child: Text(
                      "- \u{20B9}${InvoiceCalc.calculateExtraDiscount(productList: cartProductList, discountType: extraDiscountSys, inputValue: extraDiscountInput)}",
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return DiscountModal(
                        title: "Packing Charges",
                        symbol: packingChargeSys,
                        value: packingChargeInput.toString(),
                        amount: InvoiceCalc.calculateCartTotal(
                          productList: cartProductList,
                          gstType: gstType ?? '',
                          extraDiscountType: extraDiscountSys,
                          extraDiscountInput: extraDiscountInput,
                          packingDiscountType: packingChargeSys,
                          packingDiscountInput: packingChargeInput,
                          taxType: taxType,
                        ),
                        isPackingCharge: true,
                      );
                    }).then((value) {
                  if (value != null) {
                    setState(() {
                      packingChargeSys = value["sys"];
                      packingChargeInput = double.parse(value["value"]);
                    });
                  }
                });
              },
              child: Row(
                children: [
                  Text(
                    "Packing Charges - ${packingChargeSys.toUpperCase()} $packingChargeInput",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.edit,
                    color: Colors.green,
                    size: 15,
                  ),
                  Expanded(
                    child: Text(
                      "+ \u{20B9}${InvoiceCalc.calculatePackingCharges(productList: cartProductList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput)}",
                      textAlign: TextAlign.end,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            if (taxType)
              FutureBuilder(
                future: checkSameState(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return GestureDetector(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return TaxDetailModal(
                              data: InvoiceCalc.calculateTax(
                                  productList: cartProductList,
                                  extraDiscountType: extraDiscountSys,
                                  extraDiscountInput: extraDiscountInput,
                                  packingDiscountType: packingChargeSys,
                                  packingDiscountInput: packingChargeInput,
                                  gstType: gstType ?? ''),
                            );
                          },
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          if (snapshot.data ?? false)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "CGST",
                                      textAlign: TextAlign.start,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        "${gstType != null && gstType == "Exclusive" ? "+ " : ""}\u{20B9}${((InvoiceCalc.calculateTax(productList: cartProductList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput, gstType: gstType ?? '')["total_tax"]) / 2).toStringAsFixed(2)}",
                                        textAlign: TextAlign.end,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: gstType != null &&
                                                      gstType == "Exclusive"
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
                                      "SGST",
                                      textAlign: TextAlign.start,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        "${gstType != null && gstType == "Exclusive" ? "+ " : ""}\u{20B9}${((InvoiceCalc.calculateTax(productList: cartProductList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput, gstType: gstType ?? '')["total_tax"]) / 2).toStringAsFixed(2)}",
                                        textAlign: TextAlign.end,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: gstType != null &&
                                                      gstType == "Exclusive"
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
                                  "IGST",
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    "${gstType != null && gstType == "Exclusive" ? "+ " : ""}\u{20B9}${InvoiceCalc.calculateTax(productList: cartProductList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput, gstType: gstType ?? '')["total_tax"].toStringAsFixed(2)}",
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: gstType != null &&
                                                  gstType == "Exclusive"
                                              ? Colors.green
                                              : Colors.black,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "Round Off",
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "\u{20B9}${InvoiceCalc.calculateRoundOff(
                      productList: cartProductList,
                      extraDiscountType: extraDiscountSys,
                      extraDiscountInput: extraDiscountInput,
                      packingDiscountType: packingChargeSys,
                      packingDiscountInput: packingChargeInput,
                      taxType: taxType,
                      gstType: gstType ?? '',
                    )["round_off_value"]}",
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Divider(
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Total",
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "\u{20B9}${(InvoiceCalc.calculateRoundOff(
                      gstType: gstType ?? '',
                      productList: cartProductList,
                      extraDiscountType: extraDiscountSys,
                      extraDiscountInput: extraDiscountInput,
                      packingDiscountType: packingChargeSys,
                      packingDiscountInput: packingChargeInput,
                      taxType: taxType,
                    ))["total_amount"]}",
                    textAlign: TextAlign.end,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                createInvoice();
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  // color: const Color(0xffFF8989),
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "${widget.invoice != null ? "Update" : "Create New"} Invoice",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container mobileViewProductsForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 10),
      child: Form(
        key: productFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Products",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  style: const ButtonStyle(),
                  onPressed: () {
                    showCustomProducts();
                  },
                  label: const Text('Custom Product'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product Name",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffEEEEEE),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: null,
                        icon: Icon(Icons.arrow_drop_down_outlined),
                      ),
                      hintText: "Product Name",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    controller: productName,
                    onTap: () {
                      showProductAlert();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Product Name is must";
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "QTY",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "QTY",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          controller: qty,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "QTY is must";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Unit",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Unit",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          controller: unit,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Unit is must";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rate",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffEEEEEE),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Rate",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    controller: rate,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Rate is must";
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
                child: Text(
              "Total = ${currentProductTotal()}",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                if (invoiceFormKey.currentState!.validate()) {
                  addInvoiceProductFn();
                }
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  // color: const Color(0xffFF8989),
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Add Product",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container mobileViewCustomerForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Form(
        key: invoiceFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Invoice No",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      invoiceNumber,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(),
            const SizedBox(
              height: 5,
            ),
            if (taxType)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "GST Type",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  DropdownButtonFormField<String>(
                    menuMaxHeight: 300,
                    value: gstType,
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          "Select tax type",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Inclusive",
                        child: Text("Inclusive"),
                      ),
                      DropdownMenuItem(
                        value: "Exclusive",
                        child: Text("Exclusive"),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          gstType = v;
                        });
                      }
                    },
                    isExpanded: true,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffEEEEEE),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Gst Type",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "GST Type is must";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Party Details",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  style: const ButtonStyle(),
                  onPressed: () {
                    customerAddAlert();
                  },
                  label: const Text('Custom Party'),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Party Name (*)",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xffEEEEEE),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Party Name",
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: IconButton(
                        onPressed: () {
                          customerAlert();
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    controller: partyName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Party Name is must";
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Address (*)",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffEEEEEE),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Address",
                      // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    controller: address,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Address is must";
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phone Number (*)",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffEEEEEE),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Phone Number",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      prefixIcon: Icon(Icons.call),
                    ),
                    controller: phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone Number is must";
                      } else if (phone.text.length != 10) {
                        return "Phone Number is Not Valid";
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "State (*)",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          onTap: () {
                            chooseState();
                          },
                          readOnly: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "State",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          controller: state,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "State is must";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "City (*)",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          onTap: () async {
                            if (state.text.isNotEmpty) {
                              chooseCity();
                            }
                          },
                          readOnly: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "City",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          controller: city,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "City is must";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Transport Name (*)",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Transport Name (*)",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            prefixIcon: Icon(Icons.local_shipping_outlined),
                          ),
                          controller: transportName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Transport Name is must";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Transport No",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Transport No",
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                            prefixIcon: Icon(Icons.local_shipping_outlined),
                          ),
                          controller: transportNumber,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Transport Number is must";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CupertinoSwitch(
                  value: copyAddress,
                  onChanged: (onChanged) {
                    if (onChanged) {
                      setState(() {
                        copyAddress = onChanged;
                        if (onChanged == true) {
                          deliveryAddress.text =
                              "${partyName.text}, ${address.text}, ${phone.text}";
                        }
                      });
                    } else {
                      setState(() {
                        copyAddress = onChanged;
                        deliveryAddress.clear();
                      });
                    }
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  "Same Deleivery Address",
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivery Address (*)",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffEEEEEE),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Address",
                      // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    controller: deliveryAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Delivery Address is must";
                      } else {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () async {
          final value = await confirmationDialog(
            title: "Exit",
            context,
            message: "Are you sure you want to exit?",
          );
          if (value != null) {
            if (value) {
              Navigator.pop(context);
            }
          }
        },
      ),
      title: widget.fromEstimate
          ? const Text("Convert Enquiry to Invoice")
          : Text("${widget.invoice != null ? "Edit" : "New"} Invoice"),
    );
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

  showCustomProducts() async {
    await showDialog(
      context: context,
      builder: (context) => const InvoiceAddCustomProduct(),
    ).then((value) {
      if (value != null) {
        setState(() {
          InvoiceProductModel model = InvoiceProductModel();
          model.productID = DateTime.now().millisecondsSinceEpoch.toString();
          model.productName = value;
          model.rate = 0;
          productDataList.add(model);
          currentProduct = model;
          productName.text = value;
          rate.text = "0.0";
          model.categoryID = null;
        });
      }
    });
  }

  customerAddAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AddCustomerBox(
          isEdit: false,
          isInvoice: true,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          partyName.text = value.customerName ?? '';
          address.text = value.address ?? '';
          phone.text = value.mobileNo ?? '';
        });
      }
    });
  }

  chooseCity() async {
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
          child: CitySearch(
            state: state.text,
          ),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          city.text = value;
          setState(() {});
        }
      },
    );
  }

  chooseState() async {
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
          child: StateSearch(),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          state.text = value;
          setState(() {});
        }
      },
    );
  }

  customerAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const CustomerSearchView();
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          partyName.text = value.customerName ?? '';
          address.text = value.address ?? '';
          phone.text = value.mobileNo ?? '';
        });
      }
    });
  }

  showProductAlert() async {
    await showDialog(
      context: context,
      builder: (context) =>
          ProductListingDialog(productDataList: productDataList),
    ).then((value) {
      if (value != null) {
        InvoiceProductModel values = (value as InvoiceProductModel);

        setState(() {
          currentProduct = value;
          productName.text = values.productName ?? "";
          rate.text = gstType == "Inclusive"
              ? InvoiceCalc.inclusiveRate(values.rate!, values.taxValue!)
                  .toString()
              : values.rate.toString();
          unit.text = values.unit.toString();
          qty.text = "1";
        });
      }
    });
  }

  /// ******************** End of UI ***********************

  /// ******************** Cart Functions ***********************

  addInvoiceProductFn() {
    FocusManager.instance.primaryFocus!.unfocus();
    if (productFormKey.currentState!.validate()) {
      int index = cartProductList.indexWhere(
          (element) => element.productID == currentProduct!.productID);

      var getCategoryid = productDataList.indexWhere(
          (elements) => elements.productID == currentProduct!.productID);
      var categoryID = productDataList[getCategoryid].categoryID;
      if (index == -1) {
        InvoiceProductModel value = InvoiceProductModel();
        value = currentProduct!;
        value.qty = int.parse(qty.text);
        value.rate = double.parse(rate.text);
        value.unit = unit.text;
        value.categoryID = categoryID;
        value.total = double.parse(
            (double.parse(qty.text) * value.rate!).toStringAsFixed(2));
        value.docID = null;
        setState(() {
          cartProductList.add(value);
          currentProduct = null;
          productName.clear();
          qty.clear();
          unit.clear();
          rate.clear();
        });
      } else {
        snackbar(context, false, "This Product Already in Cart");
      }
    }
  }

  currentProductTotal() {
    String result = "0.00";
    double amount = 0.00;
    if (currentProduct != null && rate.text.isNotEmpty && qty.text.isNotEmpty) {
      amount = double.parse(qty.text) * double.parse(rate.text);
    }

    result = amount.toStringAsFixed(2);
    return result;
  }

  /// ******************** End of Cart Functions ***********************

  /// ******************** Invoice Create / Update ***********************

  Future createInvoice() async {
    FocusManager.instance.primaryFocus!.unfocus();

    try {
      scrollController.jumpTo(0.0);
      loading(context);
      await Future.delayed(const Duration(seconds: 1)).then((value) async {
        if (invoiceFormKey.currentState!.validate()) {
          InvoiceModel model = InvoiceModel();
          model.partyName = partyName.text;
          model.address = address.text;
          model.phoneNumber = phone.text;
          model.transportName = transportName.text;
          model.transportNumber = transportNumber.text;
          model.state = state.text;
          model.city = city.text;
          model.gstType = gstType;
          model.taxType = taxType;
          model.sameState = await checkSameState();
          model.totalBillAmount = (double.parse(InvoiceCalc.calculateCartTotal(
                    productList: cartProductList,
                    gstType: gstType ?? '',
                    extraDiscountType: extraDiscountSys,
                    extraDiscountInput: extraDiscountInput,
                    packingDiscountType: packingChargeSys,
                    packingDiscountInput: packingChargeInput,
                    taxType: taxType,
                  )) -
                  InvoiceCalc.calculateRoundOff(
                    productList: cartProductList,
                    extraDiscountType: extraDiscountSys,
                    extraDiscountInput: extraDiscountInput,
                    packingDiscountType: packingChargeSys,
                    packingDiscountInput: packingChargeInput,
                    taxType: taxType,
                    gstType: gstType ?? '',
                  )["round_off_value"])
              .toStringAsFixed(2);
          model.deliveryaddress = deliveryAddress.text;

          CustomerDataModel customerDataModel = CustomerDataModel();
          customerDataModel.customerName = partyName.text;
          customerDataModel.address = address.text;
          customerDataModel.mobileNo = phone.text;
          customerDataModel.city = city.text;
          customerDataModel.email = null;
          customerDataModel.state = state.text;
          customerDataModel.companyID =
              await LocalDB.fetchInfo(type: LocalData.companyid);

          var calc = BillingCalCulationModel();

          calc.discountValue = double.parse(
              InvoiceCalc.calculateDiscount(productList: cartProductList));
          calc.extraDiscount = extraDiscountInput;
          calc.extraDiscountValue = double.parse(
              InvoiceCalc.calculateExtraDiscount(
                  productList: cartProductList,
                  discountType: extraDiscountSys,
                  inputValue: extraDiscountInput));
          calc.extraDiscountsys = extraDiscountSys;
          calc.package = packingChargeInput;
          calc.packageValue = double.parse(InvoiceCalc.calculatePackingCharges(
              productList: cartProductList,
              extraDiscountType: extraDiscountSys,
              extraDiscountInput: extraDiscountInput,
              packingDiscountType: packingChargeSys,
              packingDiscountInput: packingChargeInput));
          calc.packagesys = packingChargeSys;
          calc.subTotal = double.parse(
              InvoiceCalc.calculateSubTotal(productList: cartProductList));
          calc.roundOff = InvoiceCalc.calculateRoundOff(
            productList: cartProductList,
            extraDiscountType: extraDiscountSys,
            extraDiscountInput: extraDiscountInput,
            packingDiscountType: packingChargeSys,
            packingDiscountInput: packingChargeInput,
            taxType: taxType,
            gstType: gstType ?? '',
          )["round_off_value"]
              .toDouble();

          calc.total = (double.parse(InvoiceCalc.calculateCartTotal(
            productList: cartProductList,
            gstType: gstType ?? '',
            extraDiscountType: extraDiscountSys,
            extraDiscountInput: extraDiscountInput,
            packingDiscountType: packingChargeSys,
            packingDiscountInput: packingChargeInput,
            taxType: taxType,
          )).roundToDouble());

          model.price = calc;

          model.listingProducts = [];
          model.listingProducts!.addAll(cartProductList);
          model.companyId = await LocalDB.fetchInfo(type: LocalData.companyid);
          model.taxCalc = InvoiceCalc.calculateTax(
              productList: cartProductList,
              extraDiscountType: extraDiscountSys,
              extraDiscountInput: extraDiscountInput,
              packingDiscountType: packingChargeSys,
              packingDiscountInput: packingChargeInput,
              gstType: gstType ?? '');
          model.createdDate = DateTime.now();
          model.billDate = DateTime.now();
          model.billNo = invoiceNumber;
          model.isEstimateConverted = widget.fromEstimate;

          if (!calc.total!.isNegative) {
            if (widget.invoice == null || widget.invoice!.docID == null) {
              model.billDate = DateTime.now();
              model.createdDate = DateTime.now();

              await FireStore()
                  .createNewInvoice(invoiceData: model)
                  .then((value) async {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (builder) {
                    return const Modal(
                      title: "Save Customer",
                      content: "Are you want to save customer?",
                      type: ModalType.info,
                    );
                  },
                ).then((value) async {
                  if (value != null) {
                    if (value) {
                      loading(context);
                      await FireStore()
                          .checkCustomerMobileNoRegistered(mobileNo: phone.text)
                          .then((value) async {
                        if (value) {
                          await FireStore()
                              .registerCustomer(customerData: customerDataModel)
                              .then((value) {
                            if (widget.invoice != null) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              snackbar(context, true,
                                  "Successfully Invoice Created");
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const InvoiceListing(),
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                              Navigator.pop(context, true);
                              snackbar(context, true,
                                  "Successfully Invoice Created");
                            }
                          });
                        } else {
                          if (widget.invoice != null) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            snackbar(
                                context, true, "Successfully Invoice Created");
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const InvoiceListing(),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                            snackbar(context, true,
                                "Successfully Invoice Created. But customer already registered.");
                          }
                        }
                      });
                    } else {
                      if (widget.invoice != null) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        snackbar(context, true, "Successfully Invoice Created");
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const InvoiceListing(),
                          ),
                        );
                      } else {
                        Navigator.pop(context, true);
                        snackbar(
                            context, true, "Successfully Invoice Created.");
                      }
                    }
                  }
                });
              });
            } else {
              await FireStore()
                  .updateInvoice(
                      docID: widget.invoice!.docID!,
                      invoiceData: model,
                      cartDataList: cartProductList)
                  .then((value) {
                Navigator.pop(context);
                Navigator.pop(context, true);
                snackbar(context, true, "Successfully Updated Invoice");
              });
            }
          } else {
            Navigator.pop(context);
            showToast(
              context,
              isSuccess: false,
              content: "Bill total is negative",
              top: false,
            );
          }
        } else {
          Navigator.pop(context);
          snackbar(context, false, "Check the All form");
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
      throw e.toString();
    }
  }

  /// ******************** End of Create / Update ***********************

  /// ******************** Variables ***********************

  changeRate(String gstType) {
    if (gstType == "Inclusive") {
    } else {}
  }

  TextEditingController partyName = TextEditingController();
  TextEditingController deliveryAddress = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController transportName = TextEditingController();
  TextEditingController transportNumber = TextEditingController();
  TextEditingController productName = TextEditingController();
  TextEditingController qty = TextEditingController();
  TextEditingController unit = TextEditingController();
  TextEditingController rate = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();

  List<InvoiceProductModel> cartProductList = [];
  List<InvoiceProductModel> productDataList = [];
  List<CategoryDataModel> categoryList = [];
  final productFormKey = GlobalKey<FormState>();
  final invoiceFormKey = GlobalKey<FormState>();
  bool copyAddress = false;
  String discountSys = "%";
  String extraDiscountSys = "%";
  String packingChargeSys = "%";
  double discountInput = 0;
  double extraDiscountInput = 0;
  double packingChargeInput = 0;
  ScrollController scrollController = ScrollController();
  InvoiceProductModel? currentProduct;
  String invoiceNumber = "";
  bool taxType = false;
  String? gstType;

  /// ******************** End of Variables ***********************

  /// ******************** Screen Intialization ***********************

  getEditInvoice() {
    if (widget.invoice != null) {
      setState(() {
        invoiceNumber = widget.invoice!.billNo ?? "";
        partyName.text = widget.invoice!.partyName ?? "";
        address.text = widget.invoice!.address ?? "";
        deliveryAddress.text = widget.invoice!.deliveryaddress ?? "";
        phone.text = widget.invoice!.phoneNumber ?? "";
        transportName.text = widget.invoice!.transportName ?? "";
        transportNumber.text = widget.invoice!.transportNumber ?? "";

        cartProductList.addAll(widget.invoice!.listingProducts ?? []);

        extraDiscountInput = widget.invoice!.price!.extraDiscount!;
        extraDiscountSys = widget.invoice!.price!.extraDiscountsys!;
        packingChargeInput = widget.invoice!.price!.package!;
        packingChargeSys = widget.invoice!.price!.packagesys!;
        state.text = widget.invoice!.state ?? '';
        city.text = widget.invoice!.city ?? '';
        // gstType = widget.invoice!.gstType!;
      });
    }
  }

  Future getInvoiceNo() async {
    invoiceNumber = await FireStore().getLastInvoiceNumber();
    taxType = await FireStore().getCompanyTax();
    setState(() {});
  }

  Future<bool> checkSameState() async {
    var companyState = await FireStore().getCompanyState();
    if (state.text.isNotEmpty) {
      if (state.text == companyState) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  initState() {
    getProductsList();
    getEditInvoice();
    if (widget.invoice == null || widget.fromEstimate) {
      getInvoiceNo();
    }
    super.initState();
  }

  getProductsList() async {
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
        await FireStore().productListing(cid: cid).then((productDataResult) {
          if (productDataResult != null && productDataResult.docs.isNotEmpty) {
            for (var element in productDataResult.docs) {
              InvoiceProductModel productModel = InvoiceProductModel();
              productModel.productID = element.id;
              productModel.productName = element["product_name"] ?? "";
              productModel.unit = element["product_content"] ?? "";
              productModel.rate = double.parse(element["price"].toString());
              productModel.discountLock = element["discount_lock"];
              productModel.discount = element["discount"];
              productModel.categoryID = element["category_id"];
              productModel.hsnCode = element["hsn_code"];
              productModel.taxValue = element["tax_value"];
              productModel.productType =
                  element["discount_lock"] || element["discount"] == null
                      ? ProductType.netRated
                      : ProductType.discounted;
              if (productModel.productType == ProductType.discounted) {
                productModel.discountedPrice =
                    double.parse(element["price"].toString()) -
                        (double.parse(element["price"].toString()) *
                            element["discount"] /
                            100);
              } else {
                productModel.discountedPrice =
                    double.parse(element["price"].toString());
              }
              setState(() {
                productDataList.add(productModel);
              });
            }
          } else {
            snackbar(context, false, "Product Not Avaliable");
          }
        });
      });
    } catch (e) {
      snackbar(context, false, e.toString());
      throw e.toString();
    }
  }

  /// ******************** End of Screen Intialization ***********************
}
