import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '/func/calc.dart';
import '/model/model.dart';
import '/constants/constants.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import 'add_customer_box_inv.dart';
import 'order_summary_inv.dart';

class CartDrawerInv extends StatefulWidget {
  final bool? isEdit;
  final String? docId;
  final int pageType;
  final Color? backgroundColor;
  final bool isConnected;
  final String? billNo;
  const CartDrawerInv(
      {super.key,
      this.isEdit,
      this.docId,
      required this.pageType,
      this.backgroundColor,
      required this.isConnected,
      this.billNo});

  @override
  State<CartDrawerInv> createState() => _CartDrawerInvState();
}

class _CartDrawerInvState extends State<CartDrawerInv> {
  /// ******************** Cart UI ***********************

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: widget.backgroundColor ?? const Color(0xffEEEEEE),
      child: Column(
        children: [
          topBar(context),
          productView(),
          calculationView(context),
        ],
      ),
    );
  }

  Padding calculationView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                        "\u{20B9}${(double.parse(Calc.calculateCartTotal(productList: cartDataList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput)) - double.parse(Calc.calculateRoundOff(productList: cartDataList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput))).toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.green.shade600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.info_circle,
                        size: 12,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          "The above amount displayed by without tax",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
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
                  Flexible(
                    child: Text(
                      "\u{20B9}${Calc.calculateSubTotal(productList: cartDataList)}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.green.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () async {
                showDetailDiscount();
              },
              child: Container(
                color: Colors.transparent,
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
                    const Spacer(),
                    Text(
                      "- \u{20B9}${Calc.calculateDiscount(productList: cartDataList)}",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.red.shade600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return DiscountModal(
                        title: "Extra Discount",
                        symbol: extraDiscountSys,
                        value: extraDiscountInput.toString(),
                        isPackingCharge: false,
                        amount: Calc.calculateCartTotal(
                            productList: cartDataList,
                            extraDiscountType: extraDiscountSys,
                            extraDiscountInput: extraDiscountInput,
                            packingDiscountType: packingChargeSys,
                            packingDiscountInput: packingChargeInput),
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
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Extra Dis ${extraDiscountSys.toUpperCase()} $extraDiscountInput",
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.edit,
                      size: 15,
                      color: Colors.green,
                    ),
                    const Spacer(),
                    Text(
                      "- \u{20B9}${Calc.calculateExtraDiscount(productList: cartDataList, discountType: extraDiscountSys, inputValue: extraDiscountInput)}",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.red.shade600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return DiscountModal(
                        title: "Packing Charges",
                        symbol: packingChargeSys,
                        value: packingChargeInput.toString(),
                        isPackingCharge: true,
                        amount: Calc.calculateCartTotal(
                            productList: cartDataList,
                            extraDiscountType: extraDiscountSys,
                            extraDiscountInput: extraDiscountInput,
                            packingDiscountType: packingChargeSys,
                            packingDiscountInput: packingChargeInput),
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
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    // Packing Charges Text with ellipsis
                    Expanded(
                      child: Text(
                        "P Charge ${packingChargeSys.toUpperCase()} $packingChargeInput",
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.edit,
                      size: 15,
                      color: Colors.green,
                    ),
                    const Spacer(),
                    Text(
                      "+ \u{20B9}${Calc.calculatePackingCharges(productList: cartDataList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput)}",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.green.shade600,
                          ),
                      overflow: TextOverflow
                          .ellipsis, // Ensure amount can also overflow
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  Text(
                    "Round Off",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    "\u{20B9}${Calc.calculateRoundOff(productList: cartDataList, extraDiscountType: extraDiscountSys, extraDiscountInput: extraDiscountInput, packingDiscountType: packingChargeSys, packingDiscountInput: packingChargeInput)}",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.red.shade600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
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
                onPressed: cartDataList.isEmpty
                    ? null
                    : () {
                        if (widget.isConnected) {
                          if (widget.isEdit != null && widget.isEdit == true) {
                            updateInvoice();
                          } else {
                            placeOrder();
                          }
                        }
                      },
                // child: const Text("Checkout"),
                child: const Text("Place to Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded productView() {
    return Expanded(
      child: SingleChildScrollView(
        child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          reverse: true,
          padding: const EdgeInsets.all(0),
          itemCount: cartDataList.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(
                top: 5,
                left: 5,
                right: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cartDataList[index].productType == ProductType.netRated
                      ? widget.isConnected
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Banner(
                                message: "Net Rate",
                                location: BannerLocation.topStart,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  imageUrl: cartDataList[index].productImg ??
                                      Strings.productImg,
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
                                message: "Net Rate",
                                location: BannerLocation.topStart,
                                child: Container(
                                  height: 80.0,
                                  width: 80.0,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            )
                      : widget.isConnected
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Banner(
                                message:
                                    "${cartDataList[index].discount ?? 0}%",
                                color: Colors.green,
                                location: BannerLocation.topStart,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  imageUrl: cartDataList[index].productImg ??
                                      Strings.productImg,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                  height: 80.0,
                                  width: 80.0,
                                ),
                              ),
                            )
                          : Banner(
                              message: "${cartDataList[index].discount ?? 0}%",
                              location: BannerLocation.topStart,
                              color: Colors.green,
                              child: Container(
                                height: 80.0,
                                width: 80.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cartDataList[index].categoryName ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    cartDataList[index].productName ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                deleteProduct(index);
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red.shade600,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 0),
                                  height: 30,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Row(
                                      children: [
                                        // const Text("1"),

                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              lessQty(index);
                                              // tmpProductDetails.qty =
                                              //     tmpProductDetails.qty! - 1;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade400,
                                            ),
                                            height: 35,
                                            width: 35,
                                            child: const Center(
                                              child: Icon(
                                                Icons.remove_outlined,
                                                size: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                3,
                                              ),
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            controller:
                                                cartDataList[index].qtyForm,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 5,
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                cartDataList[index]
                                                    .qtyForm!
                                                    .clear();
                                              });
                                            },
                                            onChanged: (value) {
                                              formQtyChange(index, value);
                                            },
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              addQty(index);
                                              // tmpProductDetails.qty =
                                              //     tmpProductDetails.qty! + 1;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade400,
                                            ),
                                            height: 35,
                                            width: 35,
                                            child: const Center(
                                              child: Icon(
                                                Icons.add,
                                                size: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(
                              //   width: 10,
                              // ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (cartDataList[index].productType ==
                                      ProductType.discounted)
                                    Text(
                                      "\u{20B9}${cartDataList[index].price!.toStringAsFixed(2)}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                    ),
                                  const SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    cartDataList[index].productType ==
                                            ProductType.discounted
                                        ? "\u{20B9}${cartDataList[index].discountedPrice!.toStringAsFixed(2)}"
                                        : cartDataList[index]
                                            .price!
                                            .toStringAsFixed(2),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Total Product Price
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Total - \u{20B9}${double.parse(Calc.calculateEachProductTotal(index: index, productList: cartDataList)).toStringAsFixed(2)}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
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
    );
  }

  Container topBar(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(10),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          Text(
            "My Cart",
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "(${cartDataList.length})",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "Items-(${Calc.calculateCartItemCount(productList: cartDataList)})",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () async {
              if (cartDataList.isNotEmpty) {
                await showDialog(
                  context: context,
                  builder: (builder) {
                    return const Modal(
                      title: "Alert",
                      content: "Do you want clear cart ?",
                      type: ModalType.danger,
                    );
                  },
                ).then((value) async {
                  if (value != null) {
                    if (value) {
                      clearCart();
                    }
                  }
                });
              }
            },
            child: const Text(
              "Clear",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ******************** Cart Functions ***********************

  Future<Map<String, int>> findBillingIndexs(int cartIndex) async {
    int findBillingCategoryIndex = billingProductList.indexWhere(
      (element) {
        return element.category!.tmpcatid == cartDataList[cartIndex].categoryId;
      },
    );
    if (findBillingCategoryIndex != -1) {
      // Find Product Index
      int findBillingProductIndex =
          billingProductList[findBillingCategoryIndex].products!.indexWhere(
        (element) {
          return element.productId == cartDataList[cartIndex].productId;
        },
      );

      if (findBillingProductIndex != -1) {
        var result = {
          "categoryIndex": findBillingCategoryIndex,
          "productIndex": findBillingProductIndex,
        };
        return result;
      }
    }
    return {
      "categoryIndex": -1,
      "productIndex": -1,
    };
  }

  addQty(int cartIndex) async {
    int findBillingCategoryIndex = -1;
    int findBillingProductIndex = -1;

    await findBillingIndexs(cartIndex).then((value) {
      findBillingCategoryIndex = value["categoryIndex"] ?? -1;
      findBillingProductIndex = value["productIndex"] ?? -1;
    });
    if (findBillingProductIndex != -1 && findBillingCategoryIndex != -1) {
      // ini product variable
      var product = billingProductList[findBillingCategoryIndex]
          .products![findBillingProductIndex];
      setState(() {
        // add product qrt
        product.qty = product.qty! + 1;
        product.qtyForm!.text = product.qty.toString();

        // Cart Page Qty Change
        cartDataList[cartIndex].qty = cartDataList[cartIndex].qty! + 1;
        cartDataList[cartIndex].qtyForm!.text =
            cartDataList[cartIndex].qty.toString();

        // billing Page Refrace
        if (widget.pageType == 1) {
          billPageProvider.toggletab(true);
        } else {
          billPageProvider2.toggletab(true);
        }
      });
    }
  }

  lessQty(int cartIndex) async {
    int findBillingCategoryIndex = -1;
    int findBillingProductIndex = -1;

    await findBillingIndexs(cartIndex).then((value) async {
      findBillingCategoryIndex = value["categoryIndex"] ?? -1;
      findBillingProductIndex = value["productIndex"] ?? -1;

      if (findBillingProductIndex != -1) {
        // ini product variable
        var product = billingProductList[findBillingCategoryIndex]
            .products![findBillingProductIndex];

        if (cartDataList[cartIndex].qty == 1) {
          await confirmationDialog(
            context,
            title: "Warning",
            message: "Do you want to delete this product?",
          ).then(
            (value) {
              setState(() {
                if (value != null && value == true) {
                  // less product qrt
                  product.qty = product.qty! - 1;
                  product.qtyForm!.text = product.qty.toString();

                  // Remove From Cart
                  cartDataList.removeAt(cartIndex);
                  // billing Page Refrace
                  if (widget.pageType == 1) {
                    billPageProvider.toggletab(true);
                  } else {
                    billPageProvider2.toggletab(true);
                  }
                }
              });
            },
          );
        } else {
          setState(() {
            // less product qrt
            product.qty = product.qty! - 1;
            product.qtyForm!.text = product.qty.toString();

            //qty Page Change
            cartDataList[cartIndex].qty = cartDataList[cartIndex].qty! - 1;
            cartDataList[cartIndex].qtyForm!.text =
                cartDataList[cartIndex].qty.toString();

            // billing Page Refrace
            if (widget.pageType == 1) {
              billPageProvider.toggletab(true);
            } else {
              billPageProvider2.toggletab(true);
            }
          });
        }
      }
    });
  }

  formQtyChange(int cartIndex, String? value) async {
    int findBillingCategoryIndex = -1;
    int findBillingProductIndex = -1;

    await findBillingIndexs(cartIndex).then((value) {
      findBillingCategoryIndex = value["categoryIndex"] ?? -1;
      findBillingProductIndex = value["productIndex"] ?? -1;
    });
    if (findBillingProductIndex != -1 && findBillingCategoryIndex != -1) {
      // ini product variable
      var product = billingProductList[findBillingCategoryIndex]
          .products![findBillingProductIndex];
      if (value != null && value != "0" && value.isNotEmpty) {
        setState(() {
          // less product qrt
          product.qty = int.parse(value);
          product.qtyForm!.text = product.qty.toString();

          //qty Page Change
          cartDataList[cartIndex].qty = int.parse(value);

          // billing Page Refrace
          if (widget.pageType == 1) {
            billPageProvider.toggletab(true);
          } else {
            billPageProvider2.toggletab(true);
          }
        });
      } else {
        setState(() {
          // less product qrt
          product.qty = 1;
          product.qtyForm!.text = product.qty.toString();

          //qty Page Change
          cartDataList[cartIndex].qty = 1;
          cartDataList[cartIndex].qtyForm!.text =
              cartDataList[cartIndex].qty.toString();
          FocusManager.instance.primaryFocus!.unfocus();
          // billing Page Refrace
          if (widget.pageType == 1) {
            billPageProvider.toggletab(true);
          } else {
            billPageProvider2.toggletab(true);
          }
        });
      }
    }
  }

  deleteProduct(int cartIndex) async {
    int findBillingCategoryIndex = -1;
    int findBillingProductIndex = -1;

    await findBillingIndexs(cartIndex).then((value) async {
      findBillingCategoryIndex = value["categoryIndex"] ?? -1;
      findBillingProductIndex = value["productIndex"] ?? -1;

      if (findBillingCategoryIndex != -1 && findBillingProductIndex != -1) {
        var product = billingProductList[findBillingCategoryIndex]
            .products![findBillingProductIndex];
        await confirmationDialog(
          context,
          title: "Warning",
          message: "Do you want to delete this product?",
        ).then(
          (value) {
            setState(() {
              if (value != null && value == true) {
                // less product qrt
                product.qty = 0;
                product.qtyForm!.text = product.qty.toString();

                // Remove From Cart
                cartDataList.removeAt(cartIndex);
                // billing Page Refrace
                if (widget.pageType == 1) {
                  billPageProvider.toggletab(true);
                } else {
                  billPageProvider2.toggletab(true);
                }
              }
            });
          },
        );
      }
    });
  }

  clearCart() {
    setState(() {
      cartDataList.clear();
    });
    for (var element in billingProductList) {
      Iterable<ProductDataModel> cartTemp =
          element.products!.where((element) => element.qty! > 0);
      for (var product in cartTemp) {
        setState(() {
          product.qty = 0;
          product.qtyForm!.clear();
        });
      }
    }
    setState(() {
      if (widget.pageType == 1) {
        billPageProvider.toggletab(true);
      } else {
        billPageProvider2.toggletab(true);
      }
    });
  }

  /// ******************** Cart Alerts ***********************

  showDetailDiscount() async {
    await showDialog(
      context: context,
      builder: (context) {
        return DiscountDetailsModal(cartDataModel: cartDataList);
      },
    );
  }

  /// ******************** Cart Order ***********************
  placeOrder() async {
    await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
      if (cid != null) {
        var calc = BillingCalCulationModel();

        calc.discountValue =
            double.parse(Calc.calculateDiscount(productList: cartDataList));
        calc.extraDiscount = extraDiscountInput;
        calc.extraDiscountValue = double.parse(Calc.calculateExtraDiscount(
            productList: cartDataList,
            discountType: extraDiscountSys,
            inputValue: extraDiscountInput));
        calc.extraDiscountsys = extraDiscountSys;
        calc.package = packingChargeInput;
        calc.packageValue = double.parse(Calc.calculatePackingCharges(
            productList: cartDataList,
            extraDiscountType: extraDiscountSys,
            extraDiscountInput: extraDiscountInput,
            packingDiscountType: packingChargeSys,
            packingDiscountInput: packingChargeInput));
        calc.packagesys = packingChargeSys;
        calc.subTotal =
            double.parse(Calc.calculateSubTotal(productList: cartDataList));
        calc.roundOff = double.parse(Calc.calculateRoundOff(
            productList: cartDataList,
            extraDiscountType: extraDiscountSys,
            extraDiscountInput: extraDiscountInput,
            packingDiscountType: packingChargeSys,
            packingDiscountInput: packingChargeInput));
        calc.total = double.parse(Calc.calculateCartTotal(
                productList: cartDataList,
                extraDiscountType: extraDiscountSys,
                extraDiscountInput: extraDiscountInput,
                packingDiscountType: packingChargeSys,
                packingDiscountInput: packingChargeInput)) -
            double.parse(Calc.calculateRoundOff(
                productList: cartDataList,
                extraDiscountType: extraDiscountSys,
                extraDiscountInput: extraDiscountInput,
                packingDiscountType: packingChargeSys,
                packingDiscountInput: packingChargeInput));
        calc.netratedTotal = Calc.calculateOverallNetRatedTotal(cartDataList);
        calc.discountedTotal =
            Calc.calculateOverallDiscountedTotal(cartDataList);
        calc.discounts = Calc.discounts(cartDataList);
        calc.netPlusDisTotal =
            Calc.calculateOverallNetRatedTotal(cartDataList) +
                Calc.calculateOverallDiscountedTotal(cartDataList);

        if (!calc.total!.isNegative) {
          await LocalDB.getInvoiceParty().then((value) async {
            if (value != null) {
              List<InvoiceProductModel> model = [];
              for (var i in cartDataList) {
                var invoice = InvoiceProductModel();
                invoice.categoryID = i.categoryId;
                invoice.rate = i.price;
                invoice.total = i.price! * i.qty!;
                invoice.productID = i.productId;
                invoice.productName = i.productName;
                invoice.discountLock = i.discountLock;
                invoice.unit = i.productContent;
                invoice.taxValue = i.taxValue;
                invoice.hsnCode = i.hsnCode;
                invoice.qty = 1;
                invoice.discount = i.discount;
                invoice.qty = i.qty;
                invoice.productType = i.discountLock! || i.discount == null
                    ? ProductType.netRated
                    : ProductType.discounted;
                if (invoice.productType == ProductType.discounted) {
                  invoice.discountedPrice = i.price!.toDouble() -
                      (i.price! * i.discount!.toDouble() / 100);
                }

                setState(() {
                  model.add(invoice);
                });
              }

              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => OrderSummaryInv(
                    calc: calc,
                    cid: cid,
                    cart: model,
                    billType: BillType.invoice,
                    saveType: SaveType.create,
                  ),
                ),
              );
            } else {
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
              ).then((value) {
                if (value != null) {
                  if (value) {
                    List<InvoiceProductModel> model = [];
                    for (var i in cartDataList) {
                      var invoice = InvoiceProductModel();
                      invoice.categoryID = i.categoryId;
                      invoice.rate = i.price;
                      invoice.total = i.price! * i.qty!;
                      invoice.productID = i.productId;
                      invoice.productName = i.productName;
                      invoice.discountLock = i.discountLock;
                      invoice.unit = i.productContent;
                      invoice.taxValue = i.taxValue;
                      invoice.hsnCode = i.hsnCode;
                      invoice.qty = 1;
                      invoice.discount = i.discount;
                      invoice.qty = i.qty;
                      invoice.productType =
                          i.discountLock! || i.discount == null
                              ? ProductType.netRated
                              : ProductType.discounted;
                      if (invoice.productType == ProductType.discounted) {
                        invoice.discountedPrice = i.price!.toDouble() -
                            (i.price! * i.discount!.toDouble() / 100);
                      }

                      setState(() {
                        model.add(invoice);
                      });
                    }

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => OrderSummaryInv(
                          calc: calc,
                          cid: cid,
                          cart: model,
                          billType: BillType.invoice,
                          saveType: SaveType.create,
                        ),
                      ),
                    );
                  }
                }
              });
            }
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
      } else {
        Navigator.pop(context);
        snackbar(
          context,
          false,
          "Something went Wrong Please try again",
        );
      }
    });
  }

  updateInvoice() async {
    try {
      loading(context);
      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          var calc = BillingCalCulationModel();

          calc.discountValue =
              double.parse(Calc.calculateDiscount(productList: cartDataList));
          calc.extraDiscount = extraDiscountInput;
          calc.extraDiscountValue = double.parse(Calc.calculateExtraDiscount(
              productList: cartDataList,
              discountType: extraDiscountSys,
              inputValue: extraDiscountInput));
          calc.extraDiscountsys = extraDiscountSys;
          calc.package = packingChargeInput;
          calc.packageValue = double.parse(Calc.calculatePackingCharges(
              productList: cartDataList,
              extraDiscountType: extraDiscountSys,
              extraDiscountInput: extraDiscountInput,
              packingDiscountType: packingChargeSys,
              packingDiscountInput: packingChargeInput));
          calc.packagesys = packingChargeSys;
          calc.subTotal =
              double.parse(Calc.calculateSubTotal(productList: cartDataList));
          calc.roundOff = double.parse(Calc.calculateRoundOff(
              productList: cartDataList,
              extraDiscountType: extraDiscountSys,
              extraDiscountInput: extraDiscountInput,
              packingDiscountType: packingChargeSys,
              packingDiscountInput: packingChargeInput));
          calc.total = double.parse(Calc.calculateCartTotal(
                  productList: cartDataList,
                  extraDiscountType: extraDiscountSys,
                  extraDiscountInput: extraDiscountInput,
                  packingDiscountType: packingChargeSys,
                  packingDiscountInput: packingChargeInput)) -
              double.parse(Calc.calculateRoundOff(
                  productList: cartDataList,
                  extraDiscountType: extraDiscountSys,
                  extraDiscountInput: extraDiscountInput,
                  packingDiscountType: packingChargeSys,
                  packingDiscountInput: packingChargeInput));

          if (!calc.total!.isNegative) {
            if (widget.isConnected) {
              List<InvoiceProductModel> model = [];
              for (var i in cartDataList) {
                var invoice = InvoiceProductModel();
                invoice.categoryID = i.categoryId;
                invoice.rate = i.price;
                invoice.productID = i.productId;
                invoice.productName = i.productName;
                invoice.discountLock = i.discountLock;
                invoice.unit = i.productContent;
                invoice.total = i.price! * i.qty!;
                invoice.taxValue = i.taxValue;
                invoice.hsnCode = i.hsnCode;
                invoice.qty = 1;
                invoice.discount = i.discount;
                invoice.qty = i.qty;
                invoice.productType = i.discountLock! || i.discount == null
                    ? ProductType.netRated
                    : ProductType.discounted;
                if (invoice.productType == ProductType.discounted) {
                  invoice.discountedPrice = i.price!.toDouble() -
                      (i.price! * i.discount!.toDouble() / 100);
                }

                setState(() {
                  model.add(invoice);
                });
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => OrderSummaryInv(
                      calc: calc,
                      cid: cid,
                      cart: model,
                      billType: BillType.invoice,
                      saveType: SaveType.edit,
                      billNo: widget.billNo,
                      docId: widget.docId!,
                    ),
                  ),
                );
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
            snackbar(
              context,
              false,
              "Something went Wrong Please try again",
            );
          }
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }
}
