import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '/services/firebase/src/bill_no.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '../../../screens.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';
import '/model/model.dart';

class OrderSummary extends StatefulWidget {
  final BillingCalCulationModel calc;
  final List<CartDataModel> cart;
  final String cid;
  final BillType billType;
  final SaveType saveType;
  final CustomerDataModel? customer;
  final String? billNo;
  final String? docId;
  const OrderSummary({
    super.key,
    required this.calc,
    required this.cart,
    required this.cid,
    required this.billType,
    required this.saveType,
    this.customer,
    this.billNo,
    this.docId,
  });

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  final ScrollController _scrollController = ScrollController();

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

  CustomerDataModel customerInfo = CustomerDataModel();
  final customerFormKey = GlobalKey<FormState>();

  Future? billNoHandler;
  String? billNo;
  bool counterSales = false;
  bool customerSales = false;

  @override
  void initState() {
    if (widget.saveType == SaveType.create) {
      billNoHandler = getBillNo();
    }
    if (widget.customer != null) {
      customerInfo = widget.customer!;
      state.text = customerInfo.state ?? '';
      city.text = customerInfo.city ?? '';
      address.text = customerInfo.address ?? '';
      customerName.text = customerInfo.customerName ?? '';
      mobileNo.text = customerInfo.mobileNo ?? '';
      customerSales = true;
      setState(() {});
    }
    if (widget.billNo != null) {
      billNo = widget.billNo ?? '';
      setState(() {});
    }
    super.initState();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  getBillNo() async {
    if (widget.billType == BillType.enquiry) {
      billNo = await BillNo.genBillNo(type: BillType.enquiry);
      setState(() {});
    } else if (widget.billType == BillType.estimate) {
      billNo = await BillNo.genBillNo(type: BillType.estimate);
      setState(() {});
    } else if (widget.billType == BillType.invoice) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TextEditingController customerName = TextEditingController();

  createEnquiry() async {
    if (!customerSales && !counterSales) {
      snackbar(context, false, "Choose either customer or counter sales");
      return;
    }

    if (customerSales) {
      if (!customerFormKey.currentState!.validate()) {
        return;
      }
    }

    if (customerSales) {
      customerInfo.address = address.text;
      customerInfo.state = state.text;
      customerInfo.city = city.text;
      customerInfo.mobileNo = mobileNo.text;
      customerInfo.customerName = customerName.text;
    }

    try {
      loading(context);

      var result = await FireStore().createnewEnquiry(
          cid: widget.cid,
          productList: widget.cart,
          customerInfo: customerInfo,
          calCulation: widget.calc);

      if (result != null && result) {
        if (customerInfo.docID != null) {
          await FireStore().updateCustomer(
              customerData: customerInfo, docID: customerInfo.docID ?? '');
        }
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        if (!(MediaQuery.of(context).size.width > 600)) {
          Navigator.pop(context);
        }
        snackbar(context, true, "Enquiry created successfully");
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const EnquiryListing(),
          ),
        );
      } else {
        Navigator.pop(context);
        snackbar(context, false, "Something went wrong please try again");
      }
    } catch (e) {
      snackbar(context, false, e.toString());
    }
  }

  updateEnquiry() async {
    if (!customerSales && !counterSales) {
      snackbar(context, false, "Choose either customer or counter sales");
      return;
    }

    if (customerSales) {
      if (!customerFormKey.currentState!.validate()) {
        return;
      }
    }

    if (customerSales) {
      customerInfo.address = address.text;
      customerInfo.state = state.text;
      customerInfo.city = city.text;
      customerInfo.mobileNo = mobileNo.text;
      customerInfo.customerName = customerName.text;
    }

    if (billNo != null) {
      try {
        loading(context);
        await FireStore().updateEnquiryDetails(
          docID: widget.docId ?? '',
          productList: widget.cart,
          customerInfo: customerInfo,
          calCulation: widget.calc,
        );
        if (customerInfo.docID != null) {
          await FireStore().updateCustomer(
              customerData: customerInfo, docID: customerInfo.docID ?? '');
        }
        Navigator.pop(context);
        Navigator.pop(context);
        if (!(MediaQuery.of(context).size.width > 600)) {
          Navigator.pop(context);
        }
        Navigator.pop(context, true);
        snackbar(context, true, "Enquiry updated successfully");
      } on Exception catch (e) {
        snackbar(context, false, e.toString());
      }
    } else {
      getBillNo();
      snackbar(context, false, "Please wait while generating bill number");
    }
  }

  createEstimate() async {
    if (!customerFormKey.currentState!.validate()) {
      return;
    }

    customerInfo.address = address.text;
    customerInfo.state = state.text;
    customerInfo.city = city.text;
    customerInfo.mobileNo = mobileNo.text;
    customerInfo.customerName = customerName.text;

    try {
      loading(context);
      var result = await FireStore().createNewEstimate(
          cid: widget.cid,
          productList: widget.cart,
          customerInfo: customerInfo,
          calCulation: widget.calc);

      if (result != null && result) {
        if (customerInfo.docID != null) {
          await FireStore().updateCustomer(
              customerData: customerInfo, docID: customerInfo.docID ?? '');
        }
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        if (!(MediaQuery.of(context).size.width > 600)) {
          Navigator.pop(context);
        }
        snackbar(context, true, "Estimate created successfully");
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const EstimateListing(),
          ),
        );
      } else {
        Navigator.pop(context);
        snackbar(context, false, "Something went wrong please try again");
      }
    } catch (e) {
      snackbar(context, false, e.toString());
    }
  }

  updateEstimate() async {
    if (!customerFormKey.currentState!.validate()) {
      return;
    }

    customerInfo.address = address.text;
    customerInfo.state = state.text;
    customerInfo.city = city.text;
    customerInfo.mobileNo = mobileNo.text;
    customerInfo.customerName = customerName.text;

    if (billNo != null) {
      try {
        loading(context);
        await FireStore().updateEstimateDetails(
          docID: widget.docId ?? '',
          productList: widget.cart,
          customerInfo: customerInfo,
          calCulation: widget.calc,
        );
        if (customerInfo.docID != null) {
          await FireStore().updateCustomer(
              customerData: customerInfo, docID: customerInfo.docID ?? '');
        }
        Navigator.pop(context);
        Navigator.pop(context);
        if (!(MediaQuery.of(context).size.width > 600)) {
          Navigator.pop(context);
        }
        Navigator.pop(context, true);
        snackbar(context, true, "Estimate updated successfully");
      } on Exception catch (e) {
        snackbar(context, false, e.toString());
      }
    } else {
      getBillNo();
      snackbar(context, false, "Please wait while generating bill number");
    }
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
              print(widget.billType);
              if (widget.billType == BillType.enquiry) {
                if (widget.saveType == SaveType.create) {
                  createEnquiry();
                } else {
                  updateEnquiry();
                }
              } else {
                if (widget.saveType == SaveType.create) {
                  createEstimate();
                } else {
                  updateEstimate();
                }
              }
            },
            child: Text(widget.saveType == SaveType.create
                ? widget.billType == BillType.enquiry
                    ? "Submit Enquiry"
                    : "Submit Estimate"
                : widget.billType == BillType.enquiry
                    ? "Update Enquiry"
                    : "Update Estimate"),
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
                        "\u{20B9}${widget.calc.subTotal}",
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
                              return DiscountDetailsModal(
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
                        "\u{20B9}${widget.calc.discountValue}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                        "\u{20B9}${widget.calc.extraDiscountValue}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                        "\u{20B9}${widget.calc.packageValue}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.green.shade600,
                            ),
                      ),
                    ],
                  ),
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
                                        imageUrl:
                                            widget.cart[index].productImg ??
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
                                      message:
                                          "${widget.cart[index].discount ?? 0}%",
                                      color: Colors.green,
                                      location: BannerLocation.topStart,
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        imageUrl:
                                            widget.cart[index].productImg ??
                                                Strings.productImg,
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
                                              widget.cart[index].categoryName ??
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
                                              width: 130,
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
                                                          "${widget.cart[index].price} X ${widget.cart[index].qty} = ${(widget.cart[index].price! * widget.cart[index].qty!).toStringAsFixed(2)}",
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
                                                          "${(widget.cart[index].price! - ((widget.cart[index].price! * widget.cart[index].discount!) / 100)).toStringAsFixed(2)} X ${widget.cart[index].qty} = ${((widget.cart[index].price! * widget.cart[index].qty!) - (((widget.cart[index].price! * widget.cart[index].qty!) * widget.cart[index].discount!) / 100)).toStringAsFixed(2)}",
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
                                              "\u{20B9}${(widget.cart[index].price! * widget.cart[index].qty!).toStringAsFixed(2)}",
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
                                              "\u{20B9}${(widget.cart[index].price! * widget.cart[index].qty!).toStringAsFixed(2)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey),
                                            ),
                                            Text(
                                              "\u{20B9}${((widget.cart[index].price! * widget.cart[index].qty!) - (((widget.cart[index].price! * widget.cart[index].qty!) * widget.cart[index].discount!) / 100)).toStringAsFixed(2)}",
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
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Form(
              key: customerFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.billType != BillType.estimate
                        ? "Customer Type"
                        : "Customer Details",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (widget.billType != BillType.estimate)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Counter Sales"),
                            const SizedBox(
                              width: 8,
                            ),
                            CupertinoSwitch(
                              value: counterSales,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) {
                                _scrollToBottom();
                                setState(() {
                                  counterSales = value;
                                  customerSales = !value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Customer"),
                            const SizedBox(
                              width: 8,
                            ),
                            CupertinoSwitch(
                              value: customerSales,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) {
                                _scrollToBottom();
                                setState(() {
                                  counterSales = !value;
                                  customerSales = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  Visibility(
                    visible:
                        customerSales || widget.billType == BillType.estimate,
                    child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      children: [
                        const Divider(
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        InputForm(
                          labelName: "Customer Name",
                          controller: customerName,
                          formName: "Customer Name",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              chooseCustomer();
                            },
                          ),
                          validation: (input) {
                            return FormValidation().commonValidation(
                              input: input ?? '',
                              isMandatory: false,
                              formName: "Customer name",
                              isOnlyCharter: true,
                            );
                          },
                        ),
                        InputForm(
                          labelName: "Mobile No (*)",
                          controller: mobileNo,
                          formName: "Mobile No",
                          validation: (input) {
                            return FormValidation().phoneValidation(
                              input: input ?? '',
                              isMandatory: true,
                              labelName: "Mobile No",
                            );
                          },
                        ),
                        InputForm(
                          labelName: "Address",
                          controller: address,
                          formName: "Address",
                          validation: (input) {
                            return FormValidation()
                                .addressValidation(input ?? '', false);
                          },
                        ),
                        InputForm(
                          readOnly: true,
                          labelName: "State",
                          controller: state,
                          formName: "State",
                          validation: (input) {
                            return FormValidation().commonValidation(
                              input: input ?? '',
                              isMandatory: false,
                              formName: "State",
                              isOnlyCharter: true,
                            );
                          },
                          onTap: () {
                            chooseState();
                          },
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        InputForm(
                          readOnly: true,
                          labelName: "City",
                          controller: city,
                          formName: "City",
                          validation: (input) {
                            return FormValidation().commonValidation(
                              input: input ?? '',
                              isMandatory: false,
                              formName: "Address",
                              isOnlyCharter: true,
                            );
                          },
                          onTap: () {
                            chooseCity();
                          },
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
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

  chooseCustomer() async {
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
          child: CustomerSearchView(),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          customerInfo = value;
          state.text = customerInfo.state ?? '';
          city.text = customerInfo.city ?? '';
          mobileNo.text = customerInfo.mobileNo ?? '';
          customerName.text = customerInfo.customerName ?? '';
          address.text = customerInfo.address ?? '';
          setState(() {});
        }
      },
    );
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
          child: ViewAllProducts(
            cart: widget.cart,
          ),
        );
      },
    );
  }

  TextEditingController mobileNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
}
