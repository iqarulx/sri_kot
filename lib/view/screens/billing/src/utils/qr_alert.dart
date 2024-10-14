import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/utils/utils.dart';

class QRAlertProduct extends StatefulWidget {
  final int count;
  final int index;
  const QRAlertProduct({super.key, required this.count, required this.index});

  @override
  State<QRAlertProduct> createState() => _QRAlertProductState();
}

class _QRAlertProductState extends State<QRAlertProduct> {
  TextEditingController qtyForm = TextEditingController();

  /// ******************** Cart Functions ***********************

  addProduct() {
    FocusManager.instance.primaryFocus!.unfocus();
    var tmpProductDetails =
        billingProductList[widget.count].products![widget.index];
    try {
      loading(context);
      if (qtyForm.text.isNotEmpty &&
          qtyForm.text != "0" &&
          qtyForm.text.toLowerCase() != "null") {
        setState(() {
          tmpProductDetails.qty = int.parse(qtyForm.text);
          tmpProductDetails.qtyForm = qtyForm;
        });
        int findCartIndex = cartDataList.indexWhere(
          (element) => element.productId == tmpProductDetails.productId,
        );
        if (findCartIndex != -1) {
          setState(() {
            //qty Page Change
            cartDataList[findCartIndex].qty = int.parse(qtyForm.text);
            cartDataList[findCartIndex].qtyForm!.text =
                cartDataList[findCartIndex].qty.toString();
          });
        } else {
          addtoCart();
        }
        Navigator.pop(context);
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  addtoCart() {
    var cartDataInfo = CartDataModel();

    var tmpProductDetails =
        billingProductList[widget.count].products![widget.index];
    cartDataInfo.categoryId = tmpProductDetails.categoryid;
    cartDataInfo.categoryName = tmpProductDetails.categoryName;
    cartDataInfo.price = tmpProductDetails.price;
    cartDataInfo.productId = tmpProductDetails.productId;
    cartDataInfo.productName = tmpProductDetails.productName;
    cartDataInfo.discountLock = tmpProductDetails.discountLock;
    cartDataInfo.productCode = tmpProductDetails.productCode;
    cartDataInfo.productContent = tmpProductDetails.productContent;
    cartDataInfo.productImg = tmpProductDetails.productImg;
    cartDataInfo.qrCode = tmpProductDetails.qrCode;
    cartDataInfo.qty = int.parse(qtyForm.text);
    cartDataInfo.qtyForm = TextEditingController(
      text: cartDataInfo.qty.toString(),
    );
    setState(() {
      cartDataList.add(cartDataInfo);
    });
  }

  /// ******************** Intialization ***********************

  initfun() async {
    var tmpProductDetails =
        billingProductList[widget.count].products![widget.index];
    if (tmpProductDetails.qty != null && tmpProductDetails.qty! >= 1) {
      setState(() {
        qtyForm.text = tmpProductDetails.qty.toString();
      });
    }
  }

  @override
  void initState() {
    initfun();
    super.initState();
  }

  /// ******************** Screen View ***********************

  @override
  Widget build(BuildContext context) {
    var tmpProductDetails =
        billingProductList[widget.count].products![widget.index];
    return Center(
      child: Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: tmpProductDetails.productImg ?? Strings.productImg,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tmpProductDetails.productName ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.grey,
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "\u{20B9}${tmpProductDetails.price ?? ""}",
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "\u{20B9}${tmpProductDetails.price ?? ""}",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.7,
                  child: Material(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          3,
                        ),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: qtyForm,
                      decoration: const InputDecoration(
                        hintText: "Product QTY",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                      ),
                      onChanged: (value) {
                        // formQtyChange(index, value);
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width / 1.7,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          addProduct();
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
