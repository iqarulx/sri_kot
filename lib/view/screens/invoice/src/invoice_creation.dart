import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

class InvoiceCreation extends StatefulWidget {
  final InvoiceModel? invoice;
  const InvoiceCreation({super.key, this.invoice});

  @override
  State<InvoiceCreation> createState() => _InvoiceCreationState();
}

class _InvoiceCreationState extends State<InvoiceCreation> {
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
              var getCategoryid = categoryList.indexWhere(
                  (elements) => elements.tmpcatid == element["category_id"]);
              productModel.discount = categoryList[getCategoryid].discount;
              productModel.categoryID = categoryList[getCategoryid].tmpcatid;
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
          rate.text = values.rate.toString();
          unit.text = values.unit.toString();
        });
      }
    });
  }

  addInvoiceProductFn() {
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
    } else {
      snackbar(context, false, "Fill the All Form");
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

  subtotal() {
    String result = "0.00";
    double amount = 0.00;
    for (var element in cartProductList) {
      amount += element.total!;
    }
    result = amount.toStringAsFixed(2);
    return result;
  }

  InvoiceProductModel? currentProduct;

  Future createInvoiceFn() async {
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
          model.totalBillAmount =
              (double.parse(cartTotal()) - double.parse(roundOff()))
                  .toStringAsFixed(2);
          model.deliveryaddress = deliveryAddress.text;

          CustomerDataModel customerDataModel = CustomerDataModel();
          customerDataModel.customerName = partyName.text;
          customerDataModel.address = address.text;
          customerDataModel.mobileNo = phone.text;
          customerDataModel.city = null;
          customerDataModel.email = null;
          customerDataModel.state = null;
          customerDataModel.companyID =
              await LocalDB.fetchInfo(type: LocalData.companyid);

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
          calcul.subTotal = double.parse(subtotal());
          calcul.roundOff = double.parse(roundOff());
          calcul.total = double.parse(cartTotal()) - double.parse(roundOff());
          model.price = calcul;

          model.listingProducts = [];
          model.listingProducts!.addAll(cartProductList);
          model.companyId = await LocalDB.fetchInfo(type: LocalData.companyid);

          if (!calcul.total!.isNegative) {
            if (widget.invoice == null || widget.invoice!.docID == null) {
              model.biilDate = DateTime.now();
              model.createdDate = DateTime.now();

              await FireStore()
                  .createNewInvoice(
                      invoiceData: model, cartDataList: cartProductList)
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
                          .checkCustomerAlreadyRegistered(mobileNo: phone.text)
                          .then((value) async {
                        if (value) {
                          await FireStore()
                              .registerCustomer(customerData: customerDataModel)
                              .then((value) {
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                            snackbar(
                                context, true, "Successfully Invoice Created");
                          });
                        } else {
                          Navigator.pop(context);
                          Navigator.pop(context, true);
                          snackbar(context, true,
                              "Successfully Invoice Created. But customer already registered.");
                        }
                      });
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                      snackbar(context, true, "Successfully Invoice Created.");
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

  geteditInvoice() {
    if (widget.invoice != null) {
      setState(() {
        partyName.text = widget.invoice!.partyName ?? "";
        address.text = widget.invoice!.address ?? "";
        deliveryAddress.text = widget.invoice!.deliveryaddress ?? "";
        phone.text = widget.invoice!.phoneNumber ?? "";
        transportName.text = widget.invoice!.transportName ?? "";
        transportNumber.text = widget.invoice!.transportNumber ?? "";

        cartProductList.addAll(widget.invoice!.listingProducts ?? []);
        // discountInput = widget.invoice!.price!.discount!;
        discountSys = widget.invoice!.price!.discountsys!;
        extraDiscountInput = widget.invoice!.price!.extraDiscount!;
        extraDiscountSys = widget.invoice!.price!.extraDiscountsys!;
        packingChargeInput = widget.invoice!.price!.package!;
        packingChargeSys = widget.invoice!.price!.packagesys!;
      });
    }
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

  Future<bool> onWillPop() async {
    return await dailog().then((value) async {
      if (value) {
        return await createInvoiceFn().then((value) {
          return true;
        });
      } else {
        Navigator.pop(context, true);
        return true;
      }
    });
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

  String discount() {
    String result = "0.00";
    double tmpDiscount = 0.00;
    for (var element in cartProductList) {
      if (element.discountLock != null && !element.discountLock!) {
        if (element.discount != null) {
          double total = element.rate! * element.qty!;
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
    double subTotalValue = double.parse(subtotal());
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
    double subTotalValue = double.parse(subtotal());
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
    double subTotalValue = double.parse(subtotal());
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

  String roundOff() {
    var result = cartTotal();
    double value = double.parse(result);
    double decimalPart = value - value.toInt();
    return decimalPart.toStringAsFixed(2);
  }

  @override
  void initState() {
    getProductsList();
    geteditInvoice();
    super.initState();
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

  customerAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const CustomerSearch(
          isConnected: true,
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.invoice != null) {
          return await onWillPop();
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("${widget.invoice != null ? "Edit" : "New"} Invoice"),
        ),
        body: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(10),
          children: [
            Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Customer option",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    customerAlert();
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "Choose",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    customerAddAlert();
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        color: Colors.white,
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
                                              color: Colors.white,
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Party Name (*)",
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
                              hintText: "Party Name",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              prefixIcon: Icon(Icons.person),
                            ),
                            controller: partyName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Party Name is Must";
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
                            maxLines: 5,
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
                                return "Address is Must";
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
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              prefixIcon: Icon(Icons.call),
                            ),
                            controller: phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Phone Number is Must";
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
                                return "Transport Name is Must";
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
                            "Transport Number",
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
                              hintText: "Transport Number",
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              prefixIcon: Icon(Icons.local_shipping_outlined),
                            ),
                            controller: transportNumber,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Transport Number is Must";
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
                      children: [
                        CupertinoSwitch(
                          value: copyAddress,
                          onChanged: (onChanged) {
                            setState(() {
                              copyAddress = onChanged;
                              if (onChanged == true) {
                                deliveryAddress = address;
                              }
                            });
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
                            maxLines: 5,
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
                                return "Delivery Address is Must";
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
            Container(
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
                    Text(
                      "Products",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Product Name",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
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
                                      icon:
                                          Icon(Icons.arrow_drop_down_outlined),
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
                                      return "Product Name is Must";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showCustomProducts();
                                },
                                child: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.8),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                      return "QTY is Must";
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
                                      return "Unit is Must";
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
                                return "Rate is Must";
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
                        addInvoiceProductFn();
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
                                    Row(
                                      children: [
                                        Text(
                                          cartProductList[index].productName ??
                                              "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        if (cartProductList[index]
                                                    .discountLock !=
                                                null &&
                                            !cartProductList[index]
                                                .discountLock!)
                                          if (cartProductList[index].discount !=
                                              null)
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
                            subtotal(),
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (builder) {
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
                      child: Row(
                        children: [
                          Text(
                            "Discount",
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
                              "\u{20B9}${(discount())}",
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.bodyLarge,
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
                              "\u{20B9}${extraDiscount()}",
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.bodyLarge,
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
                              "\u{20B9}${packingChareges()}",
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
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
                            "\u{20B9}${roundOff()}",
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
                            "\u{20B9}${(double.parse(cartTotal()) - double.parse(roundOff())).toStringAsFixed(2)}",
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
                        createInvoiceFn();
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
            ),
          ],
        ),
      ),
    );
  }
}
