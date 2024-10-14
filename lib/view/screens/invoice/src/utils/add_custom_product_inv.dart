import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/model/model.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

class AddCustomProductInv extends StatefulWidget {
  const AddCustomProductInv({super.key});

  @override
  State<AddCustomProductInv> createState() => _AddCustomProductInvState();
}

class _AddCustomProductInvState extends State<AddCustomProductInv> {
  var addProductKey = GlobalKey<FormState>();
  TextEditingController productName = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController qnt = TextEditingController();
  String? discountLock = "yes";
  List<DropdownMenuItem<String>> discountLockList = const [
    DropdownMenuItem(
      value: "yes",
      child: Text("Yes"),
    ),
    DropdownMenuItem(
      value: "no",
      child: Text("No"),
    ),
  ];

  editaddtoCart(ProductDataModel product) {
    var cartDataInfo = CartDataModel();
    var tmpProductDetails = product;
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
    cartDataInfo.qty = tmpProductDetails.qty;
    cartDataInfo.qtyForm = TextEditingController(
      text: cartDataInfo.qty.toString(),
    );
    cartDataInfo.docID = tmpProductDetails.docid;
    setState(() {
      cartDataList.add(cartDataInfo);
    });
  }

  addCustomProduct() {
    try {
      if (addProductKey.currentState!.validate()) {
        int categoryIndex = -1;
        categoryIndex = billingProductList.indexWhere(
          (element) => element.category!.tmpcatid == "",
        );

        if (categoryIndex == -1) {
          // Ctagory Data Listing
          BillingDataModel billing = BillingDataModel();

          var category = CategoryDataModel();
          category.categoryName = "";
          category.tmpcatid = "";

          billing.category = category;
          billing.products = [];

          billingProductList.add(billing);
        }

        // Product Data Listing
        var product = ProductDataModel();
        product.categoryid = "";
        product.categoryName = "";
        product.productId = productName.text;
        product.productName = productName.text;
        product.price = double.parse(price.text);
        product.qty = int.parse(qnt.text);
        product.qtyForm = TextEditingController(
          text: product.qty.toString(),
        );
        product.discountLock = discountLock != null
            ? discountLock == "yes"
                ? true
                : false
            : false;

        setState(() {
          billingProductList[billingProductList.length - 1]
              .products!
              .add(product);
          editaddtoCart(product);
          billPageProvider.toggletab(true);
          billPageProvider2.toggletab(true);
        });
        Navigator.pop(context);
        snackbar(context, true, "Successfully added to Cart");
      } else {
        snackbar(context, false, "Fill all the form");
      }
    } catch (e) {
      snackbar(context, false, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Custom Product",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: addProductKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputForm(
                    autofocus: true,
                    controller: productName,
                    formName: "Product Name",
                    labelName: "Product Name",
                    keyboardType: TextInputType.text,
                    validation: (input) {
                      return FormValidation().commonValidation(
                        input: input,
                        isMandatory: true,
                        formName: "Product Name",
                        isOnlyCharter: false,
                      );
                    },
                  ),
                  InputForm(
                    controller: qnt,
                    formName: "QNT",
                    labelName: "QNT",
                    inputFormaters: [
                      FilteringTextInputFormatter.allow(
                        RegExp("[0-9]"),
                      ),
                      LengthLimitingTextInputFormatter(3),
                    ],
                    keyboardType: TextInputType.number,
                    validation: (input) {
                      if (input != null) {
                        if (input.isEmpty) {
                          return "QNT is must";
                        } else {
                          return null;
                        }
                      } else {
                        return "QNT is must";
                      }
                    },
                  ),
                  InputForm(
                    controller: price,
                    formName: "Price",
                    labelName: "Product Price",
                    keyboardType: TextInputType.number,
                  ),
                  DropDownForm(
                    onChange: (v) {
                      setState(() {
                        discountLock = v;
                      });
                    },
                    labelName: "Discount Lock",
                    value: discountLock,
                    listItems: discountLockList,
                    formName: 'Discount Lock',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xffF2F2F2),
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xff575757),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      FocusManager.instance.primaryFocus!.unfocus();
                      addCustomProduct();
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Center(
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                            color: Color(0xffF4F4F9),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
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
