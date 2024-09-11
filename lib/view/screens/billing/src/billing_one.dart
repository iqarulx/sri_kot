// import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

BilingPageProvider billPageProvider = BilingPageProvider();

class BillingOne extends StatefulWidget {
  final bool? isEdit;
  final EstimateDataModel? enquiryData;
  final EstimateDataModel? estimateData;
  const BillingOne({
    super.key,
    this.isEdit,
    this.enquiryData,
    this.estimateData,
  });

  @override
  State<BillingOne> createState() => _BillingOneState();
}

class _BillingOneState extends State<BillingOne>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await dialogBox();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: billingOneKey,
        backgroundColor: const Color(0xffEEEEEE),
        endDrawer: cartDrawer(),
        appBar: appbar(context),
        floatingActionButton:
            isLoading == false ? floatingButton(context) : null,
        body: Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            return connectionProvider.isConnected
                ? body()
                : synced
                    ? body()
                    : notSync(context);
          },
        ),
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: billingHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureLoading(context);
        } else if (snapshot.hasError) {
          return noProductsError(snapshot);
        } else {
          if (productDataList.isNotEmpty) {
            return screenView();
          } else {
            return noCategoryError(snapshot);
          }
        }
      },
    );
  }

  OrientationBuilder screenView() {
    return OrientationBuilder(
      builder: (context, orientations) {
        orientation = orientations;
        return Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(5),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: getTabSize(),
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: (1 / 1.35),
                    ),
                    itemCount: keyboardValue.isEmpty
                        ? billingProductList[crttab].products!.length
                        : tmpProductDataList.length,
                    itemBuilder: (context, index) {
                      ProductDataModel? tmpProductDetails;
                      if (keyboardValue.isEmpty) {
                        tmpProductDetails =
                            billingProductList[crttab].products![index];
                      } else {
                        tmpProductDetails = tmpProductDataList[index];
                      }

                      return GestureDetector(
                        onTap: () {
                          tapQty(
                            index,
                            proData: keyboardValue.isNotEmpty
                                ? tmpProductDetails
                                : null,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: isConnected
                                        ? CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            imageUrl:
                                                tmpProductDetails.productImg ??
                                                    Strings.productImg,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : Container(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                productName(tmpProductDetails, context),
                                const SizedBox(
                                  height: 5,
                                ),
                                productBottomButtons(
                                    tmpProductDetails, index, context),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // MediaQuery.of(context).size.width > 600 && orientation == Orientation.portrait ||
                  //         MediaQuery.of(context).size.width > 800 &&
                  //             orientation == Orientation.landscape &&
                  //             keyboardVisable == false
                  //     ? Align(
                  //         alignment: Alignment.bottomRight,
                  //         child: Container(
                  //           padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  //           margin: const EdgeInsets.only(
                  //             bottom: 15,
                  //             right: 15,
                  //           ),
                  //           height: MediaQuery.of(context).size.width * 0.4,
                  //           width: MediaQuery.of(context).size.width * 0.4,
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           child: const Icon(
                  //             Icons.keyboard_arrow_up_outlined,
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //       )
                  //     : const SizedBox(),
                  // MediaQuery.of(context).size.width > 600 && orientation == Orientation.portrait ||
                  //         MediaQuery.of(context).size.width > 800 &&
                  //             orientation == Orientation.landscape &&
                  //             keyboardVisable
                  //     ? Align(
                  //         alignment: Alignment.bottomRight,
                  //         child: Container(
                  //           padding: const EdgeInsets.all(10),
                  //           margin: const EdgeInsets.only(
                  //             bottom: 15,
                  //             right: 15,
                  //           ),
                  //           height: MediaQuery.of(context).size.width * 0.4,
                  //           width: MediaQuery.of(context).size.width * 0.4,
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(10),
                  //           ),
                  //           child: Column(
                  //             children: [
                  //               Row(
                  //                 children: [
                  //                   Expanded(
                  //                     child: RadioListTile(
                  //                       value: true,
                  //                       groupValue: isPrice,
                  //                       onChanged: (onChanged) {
                  //                         setState(() {
                  //                           isPrice = onChanged!;
                  //                         });
                  //                       },
                  //                       title: const Text("Price"),
                  //                     ),
                  //                   ),
                  //                   Expanded(
                  //                     child: RadioListTile(
                  //                       value: false,
                  //                       groupValue: isPrice,
                  //                       onChanged: (onChanged) {
                  //                         setState(() {
                  //                           isPrice = onChanged!;
                  //                         });
                  //                       },
                  //                       title: const Text("Code"),
                  //                     ),
                  //                   ),
                  //                   IconButton(
                  //                     onPressed: () {
                  //                       setState(() {
                  //                         keyboardVisable = false;
                  //                       });
                  //                     },
                  //                     icon: const Icon(Icons.close),
                  //                   ),
                  //                 ],
                  //               ),
                  //               Expanded(
                  //                 child: Center(
                  //                   child: Text(
                  //                     keyboardValue,
                  //                     style: Theme.of(context).textTheme.headlineSmall,
                  //                   ),
                  //                 ),
                  //               ),
                  //               GridView(
                  //                 shrinkWrap: true,
                  //                 physics: const NeverScrollableScrollPhysics(),
                  //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //                   crossAxisCount: 3,
                  //                   mainAxisSpacing: 10,
                  //                   crossAxisSpacing: 10,
                  //                   childAspectRatio: (1 / 0.57),
                  //                 ),
                  //                 children: [
                  //                   for (int i = 0; i < 9; i++)
                  //                     GestureDetector(
                  //                       onTap: () {
                  //                         setState(() {
                  //                           keyboardValue = "$keyboardValue${i + 1}";
                  //                         });
                  //                         filterProductCrtTab();
                  //                       },
                  //                       child: Container(
                  //                         decoration: BoxDecoration(
                  //                           color: Colors.grey.shade300,
                  //                           borderRadius: BorderRadius.circular(8),
                  //                         ),
                  //                         child: Center(
                  //                           child: Text(
                  //                             (i + 1).toString(),
                  //                             style: Theme.of(context).textTheme.titleLarge,
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   GestureDetector(
                  //                     onLongPress: () {
                  //                       setState(() {
                  //                         if (keyboardValue.isNotEmpty) {
                  //                           keyboardValue = "";
                  //                         }
                  //                       });
                  //                     },
                  //                     onTap: () {
                  //                       setState(() {
                  //                         if (keyboardValue.isNotEmpty) {
                  //                           keyboardValue =
                  //                               keyboardValue.substring(0, keyboardValue.length - 1);
                  //                         }
                  //                       });
                  //                       filterProductCrtTab();
                  //                     },
                  //                     child: Container(
                  //                       decoration: BoxDecoration(
                  //                         color: Colors.grey.shade300,
                  //                         borderRadius: BorderRadius.circular(8),
                  //                       ),
                  //                       child: const Center(
                  //                         child: Icon(Icons.backspace_outlined),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   GestureDetector(
                  //                     onTap: () {
                  //                       setState(() {
                  //                         keyboardValue = "$keyboardValue" "0";
                  //                       });
                  //                       filterProductCrtTab();
                  //                     },
                  //                     child: Container(
                  //                       decoration: BoxDecoration(
                  //                         color: Colors.grey.shade300,
                  //                         borderRadius: BorderRadius.circular(8),
                  //                       ),
                  //                       child: Center(
                  //                         child: Text(
                  //                           "0",
                  //                           style: Theme.of(context).textTheme.titleLarge,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   GestureDetector(
                  //                     onTap: () {
                  //                       activeProduct();
                  //                       // Navigator.push(
                  //                       //   context,
                  //                       //   MaterialPageRoute(
                  //                       //     builder: (context) =>
                  //                       //         ClockView(),
                  //                       //   ),
                  //                       // );
                  //                     },
                  //                     child: Container(
                  //                       decoration: BoxDecoration(
                  //                         color: Colors.grey.shade300,
                  //                         borderRadius: BorderRadius.circular(8),
                  //                       ),
                  //                       child: Center(
                  //                         child: Column(
                  //                           mainAxisSize: MainAxisSize.min,
                  //                           children: [
                  //                             const Icon(
                  //                               Icons.keyboard_return_outlined,
                  //                               color: Colors.blue,
                  //                             ),
                  //                             Text(
                  //                               "ENTER",
                  //                               style: Theme.of(context)
                  //                                   .textTheme
                  //                                   .titleLarge!
                  //                                   .copyWith(color: Colors.blue),
                  //                             ),
                  //                           ],
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       )
                  //     : const SizedBox(),
                ],
              ),
            ),
            showcart()
                ? Container(
                    height: double.infinity,
                    width: 300,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CartDrawer(
                        isEdit: widget.isEdit,
                        enquiryDocId: widget.enquiryData?.docID,
                        estimateDocId: widget.estimateData?.docID,
                        pageType: 1,
                        backgroundColor: Colors.grey.shade300,
                        isConnected: isConnected,
                        enquiryReferenceId: widget.enquiryData?.referenceId,
                        estimateReferenceId: widget.estimateData?.referenceId,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }

  Column productName(ProductDataModel tmpProductDetails, BuildContext context) {
    return Column(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tmpProductDetails.discount != null
                  ? "\u{20B9}${(tmpProductDetails.price! - (tmpProductDetails.price! * (tmpProductDetails.discount!.toDouble() / 100))).toStringAsFixed(2)}"
                  : "\u{20B9}${tmpProductDetails.price ?? ""}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                "\u{20B9}${tmpProductDetails.price ?? ""}",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  GestureDetector productBottomButtons(
      ProductDataModel? tmpProductDetails, int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tmpProductDetails.qty == 0) {
          addtoCart(
            index,
            proData: keyboardValue.isNotEmpty ? tmpProductDetails : null,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 0),
        height: 35,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            width: 0.5,
            color: Colors.grey.shade300,
          ),
        ),
        child: tmpProductDetails!.qty == 0
            ? addToCartButton(context)
            : quantityEditButton(index, tmpProductDetails),
      ),
    );
  }

  ClipRRect quantityEditButton(int index, ProductDataModel? tmpProductDetails) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              lessQty(
                index,
                proData: keyboardValue.isNotEmpty ? tmpProductDetails : null,
              );
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
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: tmpProductDetails!.qtyForm,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
              ),
              onChanged: (value) {
                formQtyChange(index, value);
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              addQty(
                index,
                proData: keyboardValue.isNotEmpty ? tmpProductDetails : null,
              );
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
    );
  }

  Center addToCartButton(BuildContext context) {
    return Center(
      child: Text(
        "Add To Cart",
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.blue.shade700,
            ),
      ),
    );
  }

  FloatingActionButton? floatingButton(BuildContext context) {
    return MediaQuery.of(context).size.width > 600
        ? null
        : FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              scanBarCode();
            },
            child: const Icon(
              Icons.qr_code,
            ),
          );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: widget.isEdit == null || widget.isEdit == false
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () async {
                await dialogBox();
              },
            )
          : null,
      title: const Text("Billing"),
      actions: isLoading == false
          ? [
              IconButton(
                splashRadius: 20,
                onPressed: () {
                  searchProductAlert();
                },
                icon: const Icon(Icons.search),
              ),
              IconButton(
                splashRadius: 20,
                onPressed: () {
                  if (isConnected) {
                    addCustomProductAlert();
                  }
                },
                icon: const Icon(Icons.add),
              ),
              MediaQuery.of(context).size.width < 600
                  ? IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        billingOneKey.currentState!.openEndDrawer();
                      },
                      icon: Badge(
                        label: Text(cartDataList.length.toString()),
                        child: const Icon(Icons.shopping_cart),
                      ),
                    )
                  : IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        scanBarCode();
                      },
                      icon: const Icon(Icons.qr_code),
                    ),
            ]
          : const [
              SizedBox(),
            ],
      bottom: controller != null
          ? PreferredSize(
              preferredSize: const Size(double.infinity, 50),
              child: Container(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  onTap: (value) {
                    setState(() {
                      crttab = value;
                    });
                  },
                  controller: controller,
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  indicatorPadding: const EdgeInsets.all(5),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey.shade500,
                  tabs: [
                    for (var cateList in billingProductList)
                      if (cateList.category!.tmpcatid!.isNotEmpty)
                        Tab(
                          text: cateList.category!.categoryName.toString(),
                        ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  CartDrawer cartDrawer() {
    return CartDrawer(
      isEdit: widget.isEdit,
      enquiryDocId: widget.enquiryData?.docID,
      estimateDocId: widget.estimateData?.docID,
      pageType: 1,
      isConnected: isConnected,
      enquiryReferenceId: widget.enquiryData?.referenceId ?? "",
      estimateReferenceId: widget.estimateData?.referenceId ?? "",
    );
  }

  Center noCategoryError(AsyncSnapshot<dynamic> snapshot) {
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
                  ? "Create Product and Category then Used Billing"
                  : snapshot.error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () {},
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
  }

  Center noProductsError(AsyncSnapshot<dynamic> snapshot) {
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
                    billingHandler = getProductList();
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
  }

  Future getProductList() async {
    try {
      setState(() {
        isLoading = true;
        categoryList.clear();
        billingProductList.clear();
      });

      var storeProvider = FireStoreProvider();

      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        var categoryAPI = await storeProvider.categoryListing(cid: cid);
        var productAPI = await storeProvider.productListing(cid: cid);
        if (categoryAPI != null &&
            categoryAPI.docs.isNotEmpty &&
            productAPI != null &&
            productAPI.docs.isNotEmpty) {
          for (var category in categoryAPI.docs) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = category["category_name"].toString();
            model.postion = category["postion"];
            model.tmpcatid = category.id;
            model.discount = category["discount"];
            setState(() {
              categoryList.add(model);
            });
          }
          for (var product in productAPI.docs) {
            ProductDataModel productInfo = ProductDataModel();
            productInfo.categoryName = "";
            productInfo.categoryid = product["category_id"];
            productInfo.discountLock = product["discount_lock"];
            productInfo.name = product["name"];
            productInfo.productCode = product["product_code"];
            productInfo.productContent = product["product_content"];
            productInfo.qrCode = product["qr_code"];
            productInfo.videoUrl = product["video_url"];
            productInfo.productName = product["product_name"];
            productInfo.productImg = product["product_img"];
            productInfo.price = double.parse(product["price"].toString());
            productInfo.productId = product.id;
            productInfo.qty = 0;
            productInfo.qtyForm =
                TextEditingController(text: productInfo.qty.toString());

            setState(() {
              productDataList.add(productInfo);
            });
          }
          // Add TMP Array on Product Data List
          tmpProductDataList.addAll(productDataList);

          // Category & Product Merge
          for (var category in categoryList) {
            Iterable<ProductDataModel> products = productDataList
                .where((element) => element.categoryid == category.tmpcatid);
            for (var element in products) {
              setState(() {
                element.categoryName = category.categoryName;
                element.discount = category.discount;
              });
            }
            var data = BillingDataModel(
              category: category,
              products: [for (var product in products) product],
            );
            setState(() {
              billingProductList.add(data);
            });
          }

          setState(() {
            controller = TabController(
              length: billingProductList.length,
              vsync: this,
            );
          });

          if (widget.isEdit != null && widget.isEdit! == true) {
            if (widget.enquiryData != null) {
              for (var elements in widget.enquiryData!.products!) {
                int catId = billingProductList.indexWhere((element) =>
                    element.category!.tmpcatid == elements.categoryid);
                int proId = -1;
                if (catId != -1) {
                  proId = billingProductList[catId].products!.indexWhere(
                      (element) => element.productId == elements.productId);
                }

                if (catId != -1 && proId != -1) {
                  setState(() {
                    elements.discount =
                        billingProductList[catId].products![proId].discount;
                    billingProductList[catId].products![proId].qty =
                        elements.qty;
                    billingProductList[catId].products![proId].qtyForm!.text =
                        elements.qty.toString();
                  });

                  editaddtoCart(elements);

                  /// Add to Cart Function Creation Work Pending
                } else {
                  BillingDataModel billing = BillingDataModel();

                  var category = CategoryDataModel();
                  category.categoryName = "";
                  category.tmpcatid = "";

                  billing.category = category;
                  billing.products = [];

                  setState(() {
                    billingProductList.add(billing);
                    editaddtoCart(elements);
                  });
                }
              }
              // Update Discount & Packing Charges
              setState(() {
                discountSys = widget.enquiryData!.price!.discountsys ?? "%";
                extraDiscountSys =
                    widget.enquiryData!.price!.extraDiscountsys ?? "%";
                packingChargeSys = widget.enquiryData!.price!.packagesys ?? "%";
                discountInput = widget.enquiryData!.price!.discount ?? 0;
                extraDiscountInput =
                    widget.enquiryData!.price!.extraDiscount ?? 0;
                packingChargeInput = widget.enquiryData!.price!.package ?? 0;

                customerInfo = widget.enquiryData!.customer;
              });
            } else if (widget.estimateData != null) {
              for (var elements in widget.estimateData!.products!) {
                int catId = billingProductList.indexWhere((element) =>
                    element.category!.tmpcatid == elements.categoryid);
                int proId = -1;
                if (catId != -1) {
                  proId = billingProductList[catId].products!.indexWhere(
                      (element) => element.productId == elements.productId);
                }
                if (catId != -1 && proId != -1) {
                  setState(() {
                    elements.discount =
                        billingProductList[catId].products![proId].discount;
                    billingProductList[catId].products![proId].qty =
                        elements.qty;
                    billingProductList[catId].products![proId].qtyForm!.text =
                        elements.qty.toString();
                  });

                  editaddtoCart(elements);
                } else {
                  BillingDataModel billing = BillingDataModel();

                  var category = CategoryDataModel();
                  category.categoryName = "";
                  category.tmpcatid = "";

                  billing.category = category;
                  billing.products = [];

                  setState(() {
                    billingProductList.add(billing);
                    editaddtoCart(elements);
                  });
                }
              }
              // Update Discount & Packing Charges
              setState(() {
                discountSys = widget.estimateData!.price!.discountsys ?? "%";
                extraDiscountSys =
                    widget.estimateData!.price!.extraDiscountsys ?? "%";
                packingChargeSys =
                    widget.estimateData!.price!.packagesys ?? "%";
                discountInput = widget.estimateData!.price!.discount ?? 0;
                extraDiscountInput =
                    widget.estimateData!.price!.extraDiscount ?? 0;
                packingChargeInput = widget.estimateData!.price!.package ?? 0;

                customerInfo = widget.estimateData!.customer;
              });
            }
          }

          setState(() {
            isLoading = false;
          });
          return true;
        }
      } else {
        setState(() {
          isLoading = false;
        });
        return null;
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  Future getOfflineProductList() async {
    try {
      setState(() {
        isLoading = true;
        categoryList.clear();
        billingProductList.clear();
      });

      var localProducts = await DatabaseHelper().getProducts();
      var localCategories = await DatabaseHelper().getCategory();

      if (localCategories.isNotEmpty && localProducts.isNotEmpty) {
        for (var i = 0; i < localCategories.length; i++) {
          CategoryDataModel model = CategoryDataModel();
          model.categoryName =
              localCategories[i]["category_name"]?.toString() ?? "";
          model.postion = int.parse(localCategories[i]["postion"]);
          model.tmpcatid = localCategories[i]["category_id"];
          model.discount =
              int.tryParse(localCategories[i]["discount"]?.toString() ?? "0") ??
                  0;
          setState(() {
            categoryList.add(model);
          });
        }

        for (var product in localProducts) {
          ProductDataModel productInfo = ProductDataModel();
          productInfo.categoryName = "";
          productInfo.categoryid = product["category_id"];
          productInfo.discountLock =
              product["discount_lock"] == 1 ? false : true;
          productInfo.name = product["name"] ?? "";
          productInfo.productCode = product["product_code"] ?? "";
          productInfo.productContent = product["product_content"] ?? "";
          productInfo.qrCode = product["qr_code"] ?? "";
          productInfo.videoUrl = product["video_url"] ?? "";
          productInfo.productName = product["product_name"] ?? "";
          productInfo.productImg = product["product_img"] ?? "";
          productInfo.price =
              double.tryParse(product["price"]?.toString() ?? "0.0") ?? 0.0;
          productInfo.productId = product["product_id"] ?? 0;
          productInfo.qty = 0;
          productInfo.qtyForm =
              TextEditingController(text: productInfo.qty.toString());

          setState(() {
            productDataList.add(productInfo);
          });
        }

        tmpProductDataList.addAll(productDataList);

        // Category & Product Merge
        for (var category in categoryList) {
          Iterable<ProductDataModel> products = productDataList
              .where((element) => element.categoryid == category.tmpcatid);
          for (var element in products) {
            setState(() {
              element.categoryName = category.categoryName;
              element.discount = category.discount;
            });
          }
          var data = BillingDataModel(
            category: category,
            products: [for (var product in products) product],
          );
          setState(() {
            billingProductList.add(data);
          });
        }

        setState(() {
          controller = TabController(
            length: billingProductList.length,
            vsync: this,
          );
        });

        if (widget.isEdit != null && widget.isEdit! == true) {
          if (widget.enquiryData != null) {
            for (var elements in widget.enquiryData!.products!) {
              int catId = billingProductList.indexWhere((element) =>
                  element.category!.tmpcatid == elements.categoryid);
              int proId = -1;
              if (catId != -1) {
                proId = billingProductList[catId].products!.indexWhere(
                    (element) => element.productId == elements.productId);
              }

              if (catId != -1 && proId != -1) {
                setState(() {
                  elements.discount =
                      billingProductList[catId].products![proId].discount;
                  billingProductList[catId].products![proId].qty = elements.qty;
                  billingProductList[catId].products![proId].qtyForm!.text =
                      elements.qty.toString();
                });

                editaddtoCart(elements);

                /// Add to Cart Function Creation Work Pending
              } else {
                BillingDataModel billing = BillingDataModel();

                var category = CategoryDataModel();
                category.categoryName = "";
                category.tmpcatid = "";

                billing.category = category;
                billing.products = [];

                setState(() {
                  billingProductList.add(billing);
                  editaddtoCart(elements);
                });
              }
            }
            // Update Discount & Packing Charges
            setState(() {
              discountSys = widget.enquiryData!.price!.discountsys ?? "%";
              extraDiscountSys =
                  widget.enquiryData!.price!.extraDiscountsys ?? "%";
              packingChargeSys = widget.enquiryData!.price!.packagesys ?? "%";
              discountInput = widget.enquiryData!.price!.discount ?? 0;
              extraDiscountInput =
                  widget.enquiryData!.price!.extraDiscount ?? 0;
              packingChargeInput = widget.enquiryData!.price!.package ?? 0;

              customerInfo = widget.enquiryData!.customer;
            });
          } else if (widget.estimateData != null) {
            for (var elements in widget.estimateData!.products!) {
              int catId = billingProductList.indexWhere((element) =>
                  element.category!.tmpcatid == elements.categoryid);
              int proId = -1;
              if (catId != -1) {
                proId = billingProductList[catId].products!.indexWhere(
                    (element) => element.productId == elements.productId);
              }
              if (catId != -1 && proId != -1) {
                setState(() {
                  elements.discount =
                      billingProductList[catId].products![proId].discount;
                  billingProductList[catId].products![proId].qty = elements.qty;
                  billingProductList[catId].products![proId].qtyForm!.text =
                      elements.qty.toString();
                });

                editaddtoCart(elements);
              } else {
                BillingDataModel billing = BillingDataModel();

                var category = CategoryDataModel();
                category.categoryName = "";
                category.tmpcatid = "";

                billing.category = category;
                billing.products = [];

                setState(() {
                  billingProductList.add(billing);
                  editaddtoCart(elements);
                });
              }
            }
            // Update Discount & Packing Charges
            setState(() {
              discountSys = widget.estimateData!.price!.discountsys ?? "%";
              extraDiscountSys =
                  widget.estimateData!.price!.extraDiscountsys ?? "%";
              packingChargeSys = widget.estimateData!.price!.packagesys ?? "%";
              discountInput = widget.estimateData!.price!.discount ?? 0;
              extraDiscountInput =
                  widget.estimateData!.price!.extraDiscount ?? 0;
              packingChargeInput = widget.estimateData!.price!.package ?? 0;

              customerInfo = widget.estimateData!.customer;
            });
          }
        }

        setState(() {
          isLoading = false;
        });
        return true;
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  tapQty(int index, {ProductDataModel? proData}) {
    var tmpProductDetails = keyboardValue.isEmpty
        ? billingProductList[crttab].products![index]
        : proData!;

    int findCartIndex = cartDataList.indexWhere(
      (element) => element.productId == tmpProductDetails.productId,
    );

    if (findCartIndex != -1) {
      setState(() {
        cartDataList[findCartIndex].qty = cartDataList[findCartIndex].qty! + 1;
        cartDataList[findCartIndex].qtyForm!.text =
            cartDataList[findCartIndex].qty!.toString();
        tmpProductDetails.qty = tmpProductDetails.qty! + 1;
        tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
      });
    } else {
      addtoCart(
        index,
        proData: keyboardValue.isNotEmpty ? tmpProductDetails : null,
      );
    }
  }

  addtoCart(int index, {ProductDataModel? proData}) {
    var cartDataInfo = CartDataModel();
    var tmpProductDetails = keyboardValue.isEmpty
        ? billingProductList[crttab].products![index]
        : proData!;
    cartDataInfo.categoryId = tmpProductDetails.categoryid;
    cartDataInfo.categoryName = tmpProductDetails.categoryName;
    cartDataInfo.mrp = "500.00";
    cartDataInfo.price = tmpProductDetails.price;
    cartDataInfo.productId = tmpProductDetails.productId;
    cartDataInfo.productName = tmpProductDetails.productName;
    cartDataInfo.discountLock = tmpProductDetails.discountLock;
    cartDataInfo.productCode = tmpProductDetails.productCode;
    cartDataInfo.productContent = tmpProductDetails.productContent;
    cartDataInfo.productImg = tmpProductDetails.productImg;
    cartDataInfo.qrCode = tmpProductDetails.qrCode;
    cartDataInfo.qty = 1;
    cartDataInfo.discount = tmpProductDetails.discount;
    cartDataInfo.qtyForm = TextEditingController(
      text: cartDataInfo.qty.toString(),
    );
    setState(() {
      tmpProductDetails.qty = tmpProductDetails.qty! + 1;
      tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
      cartDataList.add(cartDataInfo);
    });
  }

  editaddtoCart(ProductDataModel product) {
    var cartDataInfo = CartDataModel();
    var tmpProductDetails = product;
    cartDataInfo.categoryId = tmpProductDetails.categoryid;
    cartDataInfo.categoryName = tmpProductDetails.categoryName;
    cartDataInfo.mrp = "500.00";
    cartDataInfo.price = tmpProductDetails.price;
    cartDataInfo.productId = tmpProductDetails.productId;
    cartDataInfo.productName = tmpProductDetails.productName;
    cartDataInfo.discountLock = tmpProductDetails.discountLock;
    cartDataInfo.productCode = tmpProductDetails.productCode;
    cartDataInfo.productContent = tmpProductDetails.productContent;
    cartDataInfo.productImg = tmpProductDetails.productImg;
    cartDataInfo.qrCode = tmpProductDetails.qrCode;
    cartDataInfo.qty = tmpProductDetails.qty;
    cartDataInfo.discount = tmpProductDetails.discount;
    cartDataInfo.qtyForm = TextEditingController(
      text: cartDataInfo.qty.toString(),
    );
    cartDataInfo.docID = tmpProductDetails.docid;
    setState(() {
      cartDataList.add(cartDataInfo);
    });
  }

  addQty(int index, {ProductDataModel? proData}) {
    var tmpProductDetails = keyboardValue.isEmpty
        ? billingProductList[crttab].products![index]
        : proData!;
    int findCartIndex = cartDataList.indexWhere(
      (element) => element.productId == tmpProductDetails.productId,
    );
    if (findCartIndex != -1) {
      setState(() {
        //Cart Product Qty Added
        cartDataList[findCartIndex].qty = cartDataList[findCartIndex].qty! + 1;
        cartDataList[findCartIndex].qtyForm!.text =
            cartDataList[findCartIndex].qty.toString();

        // Product Qty Added
        tmpProductDetails.qty = tmpProductDetails.qty! + 1;
        tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
      });
    }
  }

  lessQty(int index, {ProductDataModel? proData}) {
    var tmpProductDetails = keyboardValue.isEmpty
        ? billingProductList[crttab].products![index]
        : proData!;

    int findCartIndex = cartDataList.indexWhere(
      (element) => element.productId == tmpProductDetails.productId,
    );
    setState(() {
      if (findCartIndex != -1) {
        if (cartDataList[findCartIndex].qty == 1) {
          // Remove At Cart
          cartDataList.removeAt(findCartIndex);

          // Less Qty in Product Page
          tmpProductDetails.qty = tmpProductDetails.qty! - 1;
          tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
        } else {
          // Less Qty in Cart Page
          cartDataList[findCartIndex].qty =
              cartDataList[findCartIndex].qty! - 1;
          cartDataList[findCartIndex].qtyForm!.text =
              cartDataList[findCartIndex].qty.toString();

          // Less Qty in Product Page
          tmpProductDetails.qty = tmpProductDetails.qty! - 1;
          tmpProductDetails.qtyForm!.text = tmpProductDetails.qty.toString();
        }
      }
    });
  }

  formQtyChange(int index, String? value) async {
    var tmpProductDetails = billingProductList[crttab].products![index];

    int findCartIndex = cartDataList.indexWhere(
      (element) => element.productId == tmpProductDetails.productId,
    );

    if (findCartIndex != -1) {
      // ini product variable

      if (value != null && value != "0" && value.isNotEmpty) {
        setState(() {
          //  product qrt
          tmpProductDetails.qty = int.parse(value);

          //qty Page Change
          cartDataList[findCartIndex].qty = int.parse(value);
          cartDataList[findCartIndex].qtyForm!.text =
              cartDataList[findCartIndex].qty.toString();

          // billing Page Refrace
          billPageProvider.toggletab(true);
        });
      } else {
        setState(() {
          //  product qrt
          tmpProductDetails.qty = 1;
          tmpProductDetails.qtyForm!.text = "1";
          //qty Page Change
          cartDataList[findCartIndex].qty = 1;
          cartDataList[findCartIndex].qtyForm!.text =
              cartDataList[findCartIndex].qty.toString();
          cartDataList[findCartIndex].qtyForm!.text =
              cartDataList[findCartIndex].qty.toString();
          FocusManager.instance.primaryFocus!.unfocus();
        });
      }
    }
  }

  searchProductAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SearchProductBilling(isConnected: isConnected);
      },
    ).then((value) {
      if (value != null && value.isNotEmpty) {
        int productIndex = -1;
        int count = 0;
        for (var products in billingProductList) {
          productIndex = products.products!
              .indexWhere((element) => element.productId == value);
          if (productIndex != -1) {
            break;
          }
          count += 1;
        }
        if (productIndex != -1) {
          var tmpProductDetails =
              billingProductList[count].products![productIndex];

          int findCartIndex = cartDataList.indexWhere(
            (element) => element.productId == tmpProductDetails.productId,
          );
          if (findCartIndex != -1) {
            setState(() {
              crttab = count;
              controller!.animateTo(crttab);
              scrollToPosition(findPostionRow(productIndex), 0);
              tmpProductDetails.qty = tmpProductDetails.qty! + 1;
              tmpProductDetails.qtyForm!.text =
                  tmpProductDetails.qty.toString();
              //qty Page Change
              cartDataList[findCartIndex].qty =
                  billingProductList[count].products![productIndex].qty;
              cartDataList[findCartIndex].qtyForm!.text =
                  cartDataList[findCartIndex].qty.toString();
            });
          } else {
            setState(() {
              crttab = count;
              controller!.animateTo(crttab);
              scrollToPosition(findPostionRow(productIndex), 0);
            });
            addtoCart(productIndex);
          }
          // showQRBox(index: productIndex, count: count);
        }
      }
    });
  }

  addCustomProductAlert() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AddCustomProduct();
      },
    );
    // ).then((value) {
    //   if (value != null && value.isNotEmpty) {
    //     int productIndex = -1;
    //     int count = 0;
    //     for (var products in billingProductList) {
    //       productIndex = products.products!
    //           .indexWhere((element) => element.productId == value);
    //       if (productIndex != -1) {
    //         break;
    //       }
    //       count += 1;
    //     }
    //     if (productIndex != -1) {
    //       showQRBox(index: productIndex, count: count);
    //     }
    //   }
    // });
  }

  filterProductCrtTab() {
    if (isPrice) {
      dataList = productDataList
          .where((element) => element.price.toString().contains(keyboardValue));
    } else {
      dataList = productDataList.where(
          (element) => element.productCode.toString().contains(keyboardValue));
    }

    setState(() {
      tmpProductDataList.clear();
    });
    if (dataList.isNotEmpty) {
      setState(() {
        tmpProductDataList.addAll(dataList);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    customerInfo = null;
    cartDataList.clear();
    discountSys = "%";
    extraDiscountSys = "%";
    packingChargeSys = "%";
    discountInput = 0;
    extraDiscountInput = 0;
    packingChargeInput = 0;
    billPageProvider.addListener(pageRefrce);
  }

  @override
  void initState() {
    super.initState();
    // Check initial connection and perform actions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);
        billingHandler = getProductList();
        billPageProvider.addListener(pageRefrce);
        setState(() {
          isConnected = true;
        });
      } else {
        billingHandler = getOfflineProductList();
        billPageProvider.addListener(pageRefrce);
        setState(() {
          isConnected = false;
        });
      }
    });

    // Add listener to ConnectionProvider for connection changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);
          billingHandler = getProductList();
          billPageProvider.addListener(pageRefrce);
          setState(() {
            isConnected = true;
          });
        } else {
          billingHandler = getOfflineProductList();
          billPageProvider.addListener(pageRefrce);
          setState(() {
            isConnected = false;
          });
        }
      });
    });

    initSync();
  }

  initSync() async {
    var lastSync = await LocalDB.getLastSync();
    if (lastSync == null) {
      setState(() {
        synced = false;
      });
    } else {
      setState(() {
        synced = true;
      });
    }
  }

  pageRefrce() {
    if (mounted) {
      setState(() {});
    }
  }

  dialogBox() {
    return confirmationDialog(
      context,
      title: "Alert",
      message: "Do you want exit this page ?",
    ).then((value) {
      if (value != null) {
        if (value) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  showQRBox({required int index, required int count}) async {
    await showDialog(
      context: context,
      builder: (context) {
        return QRAlertProduct(count: count, index: index);
      },
    ).then((value) {
      if (value != null && value == true) {
        setState(() {
          controller!.animateTo(count);
          crttab = count;
        });
      }
    });
  }

  scanBarCode() async {
    try {
      await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      ).then((barcodeScanRes) async {
        loading(context);
        barcodeScanRes = barcodeScanRes.replaceFirst(RegExp(r']C1'), '');
        // final player = AudioPlayer();
        // await player.play(AssetSource('audio/store-scanner.mp3'), volume: 1);
        if (barcodeScanRes.isNotEmpty) {
          int productIndex = -1;
          int count = 0;
          for (var products in billingProductList) {
            productIndex = products.products!
                .indexWhere((element) => element.qrCode == barcodeScanRes);
            if (productIndex != -1) {
              break;
            }
            count += 1;
          }
          Navigator.pop(context);
          if (productIndex != -1) {
            var tmpProductDetails =
                billingProductList[count].products![productIndex];

            int findCartIndex = cartDataList.indexWhere(
              (element) => element.productId == tmpProductDetails.productId,
            );
            if (findCartIndex != -1) {
              setState(() {
                crttab = count;
                tmpProductDetails.qty = tmpProductDetails.qty! + 1;
                tmpProductDetails.qtyForm!.text =
                    tmpProductDetails.qty.toString();
                //qty Page Change
                cartDataList[findCartIndex].qty =
                    billingProductList[count].products![productIndex].qty;
                cartDataList[findCartIndex].qtyForm!.text =
                    cartDataList[findCartIndex].qty.toString();
              });
            } else {
              setState(() {
                crttab = count;
              });
              addtoCart(productIndex);
            }
            // showQRBox(index: productIndex, count: count);
            // setState(() {
            //   controller!.animateTo(
            //     count,
            //     duration: const Duration(milliseconds: 300),
            //     curve: Curves.ease,
            //   );
            //   crttab = count;
            //   if (billingProductList[count].products![productIndex].qty !=
            //           null &&
            //       billingProductList[count].products![productIndex].qty! >= 1) {
            //     log("is Worked");
            //     addQty(productIndex);
            //     // billingProductList[count].products![productIndex].qty = 10;
            //     // billingProductList[count]
            //     //     .products![productIndex]
            //     //     .qtyForm!
            //     //     .text = "10";
            //   } else {
            //     // billingProductList[count].products![productIndex].qty = 1;
            //     addtoCart(productIndex);
            //   }
            // });
          } else {
            snackBarCustom(context, false, "No Product Available");
          }
        }
      });
    } catch (e) {
      snackBarCustom(context, false, e.toString());
    }
  }

  int getTabSize() {
    int count = 2;

    if (orientation == Orientation.portrait) {
      if (MediaQuery.of(context).size.width > 600) {
        if (cartDataList.isEmpty) {
          count = 4;
        } else {
          count = 3;
        }
      }
    }
    if (orientation == Orientation.landscape) {
      if (MediaQuery.of(context).size.width > 800) {
        count = 5;
      } else if (MediaQuery.of(context).size.width > 700) {
        count = 3;
      }
    }
    return count;
  }

  activeProduct() {
    if (tmpProductDataList.isNotEmpty && keyboardValue.isNotEmpty) {
      tapQty(0, proData: tmpProductDataList[0]);
      setState(() {
        keyboardValue = "";
      });
    }
  }

  int findPostionRow(int index) {
    int result = 0;

    result = (index / getTabSize()).floor();
    return result;
  }

  scrollToPosition(int row, int column) {
    final itemIndex = row * 2 + column;
    final itemExtent = MediaQuery.of(context).size.width /
        3.02; // Replace with your item's height or width

    scrollController.animateTo(
      itemIndex * itemExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool showcart() {
    bool result = false;
    if (cartDataList.isNotEmpty) {
      if (MediaQuery.of(context).size.width > 700 &&
          orientation == Orientation.portrait) {
        result = true;
      } else if (MediaQuery.of(context).size.width > 600 &&
          orientation == Orientation.landscape) {
        result = true;
      }
    }

    return result;
  }

  List<ProductDataModel> tmpProductDataList = [], productDataList = [];
  List<CategoryDataModel> categoryList = [];
  bool isLoading = false;
  bool isPrice = true;
  bool keyboardVisable = false;
  bool synced = false;
  bool isConnected = false;
  TabController? controller;
  Future? billingHandler;
  int crttab = 0;
  var billingOneKey = GlobalKey<ScaffoldState>();
  Iterable<ProductDataModel> dataList = [];
  late Orientation orientation;
  String keyboardValue = "";
  ScrollController scrollController = ScrollController();
}

class QRAlertProduct extends StatefulWidget {
  final int count;
  final int index;
  const QRAlertProduct({super.key, required this.count, required this.index});

  @override
  State<QRAlertProduct> createState() => _QRAlertProductState();
}

class _QRAlertProductState extends State<QRAlertProduct> {
  TextEditingController qtyForm = TextEditingController();
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
      snackBarCustom(context, false, e.toString());
    }
  }

  addtoCart() {
    var cartDataInfo = CartDataModel();

    var tmpProductDetails =
        billingProductList[widget.count].products![widget.index];
    cartDataInfo.categoryId = tmpProductDetails.categoryid;
    cartDataInfo.categoryName = tmpProductDetails.categoryName;
    cartDataInfo.mrp = "500.00";
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
