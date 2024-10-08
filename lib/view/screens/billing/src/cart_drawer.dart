import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/model/model.dart';
import '/constants/constants.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

class CartDrawer extends StatefulWidget {
  final bool? isEdit;
  final String? enquiryDocId;
  final String? estimateDocId;
  final int pageType;
  final Color? backgroundColor;
  final bool isConnected;
  final String? enquiryReferenceId;
  final String? estimateReferenceId;
  const CartDrawer({
    super.key,
    this.isEdit,
    this.enquiryDocId,
    this.estimateDocId,
    required this.pageType,
    this.backgroundColor,
    required this.isConnected,
    required this.enquiryReferenceId,
    required this.estimateReferenceId,
  });

  @override
  State<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends State<CartDrawer> {
  FocusNode myFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: widget.backgroundColor ?? const Color(0xffEEEEEE),
      child: Column(
        children: [
          Container(
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
                  "Items-(${cartItemCount()})",
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
          ),
          Expanded(
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
                        cartDataList[index].discountLock == true ||
                                cartDataList[index].discount == null
                            ? widget.isConnected
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
                                          imageUrl:
                                              cartDataList[index].productImg ??
                                                  Strings.productImg,
                                          fit: BoxFit.cover,
                                          height: 80.0,
                                          width: 80.0,
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        )),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  )
                            : widget.isConnected
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      imageUrl:
                                          cartDataList[index].productImg ??
                                              Strings.productImg,
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                      height: 80.0,
                                      width: 80.0,
                                    ),
                                  )
                                : Container(
                                    height: 80.0,
                                    width: 80.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartDataList[index].categoryName ??
                                              "",
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    LengthLimitingTextInputFormatter(
                                                      3,
                                                    ),
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  controller:
                                                      cartDataList[index]
                                                          .qtyForm,
                                                  decoration:
                                                      const InputDecoration(
                                                    filled: true,
                                                    fillColor:
                                                        Colors.transparent,
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
                                                    color:
                                                        Colors.green.shade400,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          cartDataList[index].discountLock !=
                                                      null &&
                                                  !cartDataList[index]
                                                      .discountLock!
                                              ? "\u{20B9}${cartDataList[index].discount != null ? cartDataList[index].price! : ""}"
                                              : "NR",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                decoration: cartDataList[index]
                                                                .discountLock !=
                                                            null &&
                                                        !cartDataList[index]
                                                            .discountLock!
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: 1,
                                        ),
                                        Text(
                                          cartDataList[index].discountLock !=
                                                      null &&
                                                  !cartDataList[index]
                                                      .discountLock!
                                              ? "\u{20B9}${cartDataList[index].discount != null ? (cartDataList[index].price! - (cartDataList[index].price! * (cartDataList[index].discount! / 100))).toStringAsFixed(2) : cartDataList[index].price}"
                                              : "${cartDataList[index].price}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
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
                                  "Total - \u{20B9}${eachProductTotal(index)}",
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
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 5,
              left: 5,
              right: 5,
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: customerInfo == null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Customer",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (widget.isConnected)
                          GestureDetector(
                            onTap: () {
                              customerAddAlert();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Theme.of(context).primaryColor,
                                    size: 15,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Add",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: customerInfo == null,
                    child: const SizedBox(
                      height: 10,
                    ),
                  ),
                  Visibility(
                    visible: customerInfo == null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      child: Center(
                        child: Text(
                          "No Customer Selected",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: customerInfo == null,
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          customerAlert();
                        },
                        child: const Text("Choose Customer"),
                      ),
                    ),
                  ),
                  customerInfo != null
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                            ),
                            title: Text(
                              customerInfo!.customerName!.isNotEmpty
                                  ? customerInfo!.customerName!
                                  : "No name",
                            ),
                            subtitle: Wrap(
                              spacing: 5,
                              runSpacing: 2,
                              children: [
                                Text(
                                  "Phone : ${customerInfo!.mobileNo ?? ""}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                                if (customerInfo!.city != null)
                                  Text(
                                    "City : ${customerInfo!.city ?? ""}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                if (customerInfo!.state != null)
                                  Text(
                                    "State : ${customerInfo!.state ?? ""}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    customerUpdateAlert();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await confirmationDialog(
                                      context,
                                      title: "Warning",
                                      message:
                                          "Do you want to remove this Customer?",
                                    ).then(
                                      (value) {
                                        if (value != null && value == true) {
                                          setState(() {
                                            customerInfo = null;
                                          });
                                        }
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          Padding(
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
                              "\u{20B9}${(double.parse(cartTotal()) - double.parse(roundOff())).toStringAsFixed(2)}",
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
                        Flexible(
                          child: Text(
                            "\u{20B9}${subTotal()}",
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
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return DiscountModal(
                              title: "Discount",
                              symbol: discountSys,
                              value: discountInput.toString(),
                            );
                          }).then((value) {
                        if (value != null) {
                          setState(() {
                            discountSys = value["sys"];
                            discountInput = double.parse(value["value"]);
                          });
                        }
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Text(
                            // "Discount - ${discountSys.toUpperCase()} $discountInput",
                            "Discount",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          // const SizedBox(width: 5),
                          // const Icon(
                          //   Icons.edit,
                          //   size: 15,
                          // ),
                          const Spacer(),
                          Text(
                            "\u{20B9}${discount()}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
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
                      // var result = await formDialog(
                      //   context,
                      //   title: "Extra Discount",
                      //   sysmbol: extraDiscountSys,
                      //   value: extraDiscountInput.toString(),
                      // );
                      // if (result != null) {
                      //   setState(() {
                      //     extraDiscountSys = result["sys"];
                      //     extraDiscountInput = double.parse(result["value"]);
                      //   });
                      // }

                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return DiscountModal(
                              title: "Extra Discount",
                              symbol: extraDiscountSys,
                              value: extraDiscountInput.toString(),
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
                            "\u{20B9}${extraDiscount()}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
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
                            "\u{20B9}${packingChareges()}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
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
                          "\u{20B9}${roundOff()}",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                                if (widget.isEdit != null &&
                                    widget.isEdit == true &&
                                    widget.enquiryDocId != null) {
                                  updateEnquiryApi();
                                } else if (widget.isEdit != null &&
                                    widget.isEdit == true &&
                                    widget.estimateDocId != null) {
                                  updateEstimateApi();
                                } else {
                                  orderApi();
                                }
                              } else {
                                if (widget.isEdit != null &&
                                    widget.isEdit == true &&
                                    widget.enquiryReferenceId!.isNotEmpty) {
                                  updateEnquiryApi();
                                } else if (widget.isEdit != null &&
                                    widget.isEdit == true &&
                                    widget.estimateReferenceId!.isNotEmpty) {
                                  updateEstimateApi();
                                } else {
                                  orderApi();
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
          ),
        ],
      ),
    );
  }

  String formatText(String text, {int startLength = 10, int endLength = 10}) {
    if (text.length <= startLength + endLength) {
      return text; // Not enough length to hide middle
    }
    String start = text.substring(0, startLength);
    String end = text.substring(text.length - endLength);
    return '$start...$end';
  }

  String subTotal() {
    String result = "0.00";
    double tmpSubTotal = 0.00;
    for (var element in cartDataList) {
      tmpSubTotal += element.price! * element.qty!;
    }
    result = tmpSubTotal.toStringAsFixed(2);
    return result;
  }

  String discount() {
    String result = "0.00";
    double tmpDiscount = 0.00;

    for (var element in cartDataList) {
      if (element.discountLock != null && !element.discountLock!) {
        if (element.discount != null) {
          double total = element.price! * element.qty!;
          if (discountInput == 0) {
            tmpDiscount += total * (element.discount!.toDouble() / 100);
          } else {
            tmpDiscount += (total * (discountInput.toDouble() / 100));
          }
        }
      }
    }

    if (tmpDiscount.isNaN) {
      tmpDiscount = 0.00;
    }

    result = tmpDiscount.toStringAsFixed(2);
    return result;
  }

  String extraDiscount() {
    String result = "0.00";
    double subTotalValue = double.parse(subTotal());
    double discountValue = double.parse(discount());
    double tmpExtraDiscount = 0.00;

    if (extraDiscountSys == "%") {
      double tmpsubtotal = (subTotalValue - discountValue);
      tmpExtraDiscount = tmpsubtotal * (extraDiscountInput / 100);
    } else {
      tmpExtraDiscount = extraDiscountInput;
    }

    if (tmpExtraDiscount.isNaN) {
      tmpExtraDiscount = 0.00;
    }
    result = tmpExtraDiscount.toStringAsFixed(2);
    return result;
  }

  String packingChareges() {
    String result = "0.00";
    double subTotalValue = double.parse(subTotal());
    double discountValue = double.parse(discount());
    double extradiscountValue = double.parse(extraDiscount());
    double tmppackingcharge = 0.00;

    if (packingChargeSys == "%") {
      double tmpsubtotal = (subTotalValue + discountValue + extradiscountValue);
      tmppackingcharge = tmpsubtotal * (packingChargeInput / 100);
    } else {
      tmppackingcharge = packingChargeInput;
    }

    if (tmppackingcharge.isNaN) {
      tmppackingcharge = 0.00;
    }
    result = tmppackingcharge.toStringAsFixed(2);
    return result;
  }

  String cartTotal() {
    String result = "0.00";
    double subTotalValue = double.parse(subTotal());
    double discountValue = double.parse(discount());
    double extradiscountValue = double.parse(extraDiscount());
    double packingChargeValue = double.parse(packingChareges());
    double tmptotal = 0.00;
    tmptotal = ((subTotalValue - discountValue) - extradiscountValue) +
        packingChargeValue;
    if (tmptotal.isNaN) {
      tmptotal = 0.00;
    }

    result = tmptotal.toStringAsFixed(2);
    return result;
  }

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

  // String discountCart() {
  //   String result = "0.00";
  //   double tmpSubTotal = 0.00;
  //   for (var element in cartDataList) {
  //     tmpSubTotal += element.price! * element.qty!;
  //   }
  //   result = tmpSubTotal.toStringAsFixed(2);
  //   return result;
  // }

  convertEstimate({required String cid}) async {
    var calcul = BillingCalCulationModel();
    calcul.discount = 0;
    if (discountInput != 0) {
      calcul.discount = discountInput;
    } else {
      for (var item in cartDataList) {
        if (item.discount != null) {
          calcul.discount = item.discount!.toDouble();
          break;
        }
      }
    }
    calcul.discountValue = double.parse(discount());
    calcul.discountsys = discountSys;
    calcul.extraDiscount = extraDiscountInput;
    calcul.extraDiscountValue = double.parse(extraDiscount());
    calcul.extraDiscountsys = extraDiscountSys;
    calcul.package = packingChargeInput;
    calcul.packageValue = double.parse(packingChareges());
    calcul.packagesys = packingChargeSys;
    calcul.subTotal = double.parse(subTotal());
    calcul.roundOff = double.parse(roundOff());
    calcul.total = double.parse(cartTotal()) - double.parse(roundOff());

    if (!calcul.total!.isNegative) {
      if (widget.isConnected) {
        var cloud = FireStore();

        await cloud
            .createNewEstimate(
          calCulation: calcul,
          cid: cid,
          productList: cartDataList,
          customerInfo: customerInfo,
        )
            .then((estimateData) async {
          if (estimateData != null && estimateData.id.isNotEmpty) {
            await cloud
                .updateEstimateId(
              cid: cid,
              docID: estimateData.id,
            )
                .then((resultFinal) async {
              if (resultFinal != null) {
                Navigator.pop(context);
                Navigator.pop(context);

                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                snackbar(context, true, "Successfully Order Placed");
                setState(() {
                  cartDataList.clear();
                });
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const EstimateListing(),
                  ),
                );
              }
            });
          } else {
            Navigator.pop(context);
            snackbar(
              context,
              false,
              "Something went Wrong Please try again",
            );
          }
        });
      } else {
        await LocalService.newEstimate(
          productList: cartDataList,
          calCulation: calcul,
          cid: cid,
          customerInfo: customerInfo,
        ).then((value) {
          Navigator.pop(context);
          Navigator.pop(context);

          // Navigator.of(context).pop();
          // Navigator.of(context).pop();
          snackbar(context, true, "SuccessFully Order Placed");
          setState(() {
            cartDataList.clear();
          });
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const EstimateListing(),
            ),
          );
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
  }

  orderApi() async {
    await orderDialog(
      context,
      title: "Alert",
      message: "Do you want convert to Estimate",
    ).then((value) async {
      if (value != null) {
        if (value == true && customerInfo == null) {
          showToast(context,
              content: "Customer is Must", isSuccess: false, top: false);
        } else {
          try {
            loading(context);

            await LocalDB.fetchInfo(type: LocalData.companyid)
                .then((cid) async {
              if (cid != null) {
                if (value == true) {
                  convertEstimate(cid: cid);
                } else {
                  var calcul = BillingCalCulationModel();
                  calcul.discount = 0;
                  if (discountInput != 0) {
                    calcul.discount = discountInput;
                  } else {
                    for (var item in cartDataList) {
                      if (item.discount != null) {
                        calcul.discount = item.discount!.toDouble();
                        break;
                      }
                    }
                  }

                  calcul.discountValue = double.parse(discount());
                  calcul.discountsys = discountSys;
                  calcul.extraDiscount = extraDiscountInput;
                  calcul.extraDiscountValue = double.parse(extraDiscount());
                  calcul.extraDiscountsys = extraDiscountSys;
                  calcul.package = packingChargeInput;
                  calcul.packageValue = double.parse(packingChareges());
                  calcul.packagesys = packingChargeSys;
                  calcul.subTotal = double.parse(subTotal());
                  calcul.roundOff = double.parse(roundOff());
                  calcul.total =
                      double.parse(cartTotal()) - double.parse(roundOff());

                  if (!calcul.total!.isNegative) {
                    if (widget.isConnected) {
                      var cloud = FireStore();
                      await cloud
                          .createnewEnquiry(
                        calCulation: calcul,
                        cid: cid,
                        productList: cartDataList,
                        customerInfo: customerInfo,
                      )
                          .then((enquryData) async {
                        if (enquryData != null && enquryData.id.isNotEmpty) {
                          await cloud
                              .updateEnquiryId(cid: cid, docID: enquryData.id)
                              .then((resultFinal) {
                            if (resultFinal != null) {
                              // Successfuly Order Placed
                              Navigator.pop(context);
                              Navigator.pop(context);
                              // Navigator.of(context).pop();
                              snackbar(
                                  context, true, "Successfully order placed");
                              setState(() {
                                cartDataList.clear();
                              });
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const EnquiryListing(),
                                ),
                              );
                            }
                          });
                        } else {
                          Navigator.pop(context);
                          snackbar(
                            context,
                            false,
                            "Something went Wrong Please try again",
                          );
                        }
                      });
                    } else {
                      await LocalService.newEnquiry(
                              calCulation: calcul,
                              cid: cid,
                              productList: cartDataList,
                              customerInfo: customerInfo)
                          .then((value) {
                        snackbar(context, true, "Successfully order placed");
                        setState(() {
                          cartDataList.clear();
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const EnquiryListing(),
                          ),
                        );
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
          } catch (e) {
            Navigator.pop(context);
            snackbar(context, false, e.toString());
          }
        }
      }
    });

    // Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   CupertinoPageRoute(
    //     builder: (context) => OrderSummary(
    //       total: cartTotal(),
    //       subtotal: subTotal(),
    //       discountsys: discountSys,
    //       discountInput: discountInput.toString(),
    //       discountValue: discount(),
    //       extraDicountsys: extraDiscountSys,
    //       extraDiscountInput: extraDiscountInput.toString(),
    //       extraDiscountValue: extraDiscount(),
    //       packingChargesys: packingChargeSys,
    //       packingChargeInput: packingChargeInput.toString(),
    //       packingChargeValue: packingChareges(),
    //     ),
    //   ),
    // );
  }

  customerAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomerSearch(
          isConnected: widget.isConnected,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          customerInfo = value;
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
          isInvoice: false,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          customerInfo = value;
        });
      }
    });
  }

  customerUpdateAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AddCustomerBox(
          isEdit: true,
          customerData: customerInfo,
          isInvoice: false,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          customerInfo = value;
        });
      }
    });
  }

  updateEnquiryApi() async {
    try {
      loading(context);
      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          var calcul = BillingCalCulationModel();
          calcul.discount = 0;
          if (discountInput != 0) {
            calcul.discount = discountInput;
          } else {
            for (var item in cartDataList) {
              if (item.discount != null) {
                calcul.discount = item.discount!.toDouble();
                break;
              }
            }
          }
          calcul.discountValue = double.parse(discount());
          calcul.discountsys = discountSys;
          calcul.extraDiscount = extraDiscountInput;
          calcul.extraDiscountValue = double.parse(extraDiscount());
          calcul.extraDiscountsys = extraDiscountSys;
          calcul.package = packingChargeInput;
          calcul.packageValue = double.parse(packingChareges());
          calcul.packagesys = packingChargeSys;
          calcul.subTotal = double.parse(subTotal());
          calcul.roundOff = double.parse(roundOff());
          calcul.total = double.parse(cartTotal()) - double.parse(roundOff());

          if (!calcul.total!.isNegative) {
            if (widget.isConnected) {
              var cloud = FireStore();
              await cloud
                  .updateEnquiryDetails(
                docID: widget.enquiryDocId!,
                calCulation: calcul,
                productList: cartDataList,
                customerInfo: customerInfo,
              )
                  .then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context, true);
                snackbar(context, true, "Successfully Order Updated");
              });
            } else {
              // print(widget.enquiryReferenceId);
              await LocalService.updateEnquiry(
                cid: await LocalDB.fetchInfo(type: LocalData.companyid),
                calCulation: calcul,
                productList: cartDataList,
                customerInfo: customerInfo,
                referenceId: widget.enquiryReferenceId ?? '',
              ).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context, true);
                snackbar(context, true, "Successfully Order Updated");
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
          snackbar(
            context,
            false,
            "Something went Wrong Please try again",
          );
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  String roundOff() {
    var result = cartTotal();
    double value = double.parse(result);
    double decimalPart = value - value.toInt();
    return decimalPart.toStringAsFixed(2);
  }

  updateEstimateApi() async {
    try {
      loading(context);

      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          var calcul = BillingCalCulationModel();
          calcul.discount = 0;
          if (discountInput != 0) {
            calcul.discount = discountInput;
          } else {
            for (var item in cartDataList) {
              if (item.discount != null) {
                calcul.discount = item.discount!.toDouble();
                break;
              }
            }
          }
          calcul.discountValue = double.parse(discount());
          calcul.discountsys = discountSys;
          calcul.extraDiscount = extraDiscountInput;
          calcul.extraDiscountValue = double.parse(extraDiscount());
          calcul.extraDiscountsys = extraDiscountSys;
          calcul.package = packingChargeInput;
          calcul.packageValue = double.parse(packingChareges());
          calcul.packagesys = packingChargeSys;
          calcul.subTotal = double.parse(subTotal());
          calcul.roundOff = double.parse(roundOff());
          calcul.total = double.parse(cartTotal()) - double.parse(roundOff());
          if (!calcul.total!.isNegative) {
            if (widget.isConnected) {
              var cloud = FireStore();
              await cloud
                  .updateEstimateDetails(
                docID: widget.estimateDocId!,
                calCulation: calcul,
                productList: cartDataList,
                customerInfo: customerInfo,
              )
                  .then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context, true);
                snackbar(context, true, "SuccessFully Estimate Updated");
              });
            } else {
              await LocalService.updateEstimate(
                cid: await LocalDB.fetchInfo(type: LocalData.companyid),
                calCulation: calcul,
                productList: cartDataList,
                customerInfo: customerInfo,
                referenceId: widget.estimateReferenceId ?? '',
              ).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context, true);
                snackbar(context, true, "Successfully Estimate Updated");
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
          snackbar(
            context,
            false,
            "Something went Wrong Please try again",
          );
        }
      });
    } catch (e) {
      Navigator.pop(context);
      showToast(context, isSuccess: false, content: e.toString(), top: false);
    }
  }

  // String eachProductTotal(int index) {
  //   String result = "0.00";
  //   double? price = cartDataList[index].price;
  //   int? qnt = cartDataList[index].qty;
  //   double tmpTotal = price! * qnt!;
  //   result = tmpTotal.toStringAsFixed(2);
  //   return result;
  // }

  String eachProductTotal(int index) {
    String result = "0.00";
    double? price = cartDataList[index].price;
    int? qnt = cartDataList[index].qty;
    double tmpTotal = cartDataList[index].discountLock != null &&
            !cartDataList[index].discountLock!
        ? cartDataList[index].discount != null
            ? (price! - (price * (cartDataList[index].discount! / 100))) * qnt!
            : price! * qnt!
        : price! * qnt!;
    result = tmpTotal.toStringAsFixed(2);
    return result;
  }

  String cartItemCount() {
    String result = "0";
    int count = 0;
    for (var element in cartDataList) {
      count += element.qty!;
    }
    result = count.toString();
    return result;
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

  String findMrpPriceCal({required double price}) {
    String result = "0.00";
    double tmpProduct = 0.00;

    if (discountSys == "%") {
      tmpProduct = price / discountInput;
    }
    result = tmpProduct.toStringAsFixed(2);
    return result;
  }
}
