import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import 'add_custom_product.dart';

class SearchProductBilling extends StatefulWidget {
  final bool isConnected;
  const SearchProductBilling({super.key, required this.isConnected});

  @override
  State<SearchProductBilling> createState() => _SearchProductBillingState();
}

class _SearchProductBillingState extends State<SearchProductBilling> {
  FireStore provider = FireStore();

  Future getProducts() async {
    try {
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        final result = await provider.productListing(cid: cid);
        final result2 = await provider.categoryListing(cid: cid);
        if (result != null &&
            result.docs.isNotEmpty &&
            result2 != null &&
            result2.docs.isNotEmpty) {
          setState(() {
            categories.clear();
            products.clear();
            allProducts.clear();
          });
          for (var element in result.docs) {
            ProductDataModel model = ProductDataModel();

            Map<String, dynamic> data = element.data() as Map<String, dynamic>;

            model.categoryid =
                data.containsKey("category_id") ? data["category_id"] : null;
            model.categoryName =
                data.containsKey("category_name") ? data["category_name"] : "";
            model.productName =
                data.containsKey("product_name") ? data["product_name"] : "";
            model.productCode =
                data.containsKey("product_code") ? data["product_code"] : "";
            model.productContent = data.containsKey("product_content")
                ? data["product_content"]
                : "";
            model.qrCode = data.containsKey("qr_code") ? data["qr_code"] : "";
            model.price = data.containsKey("price")
                ? double.parse(data["price"].toString())
                : 0.0;
            model.videoUrl =
                data.containsKey("video_url") ? data["video_url"] : "";
            model.productImg =
                data.containsKey("product_img") ? data["product_img"] : null;
            model.active = data.containsKey("active") ? data["active"] : false;
            model.productId = element.id;
            model.discountLock = data.containsKey('discount_lock')
                ? data['discount_lock']
                : false;
            model.hsnCode =
                data.containsKey('hsn_code') ? data['hsn_code'] : '';
            model.taxValue =
                data.containsKey('tax_value') ? data['tax_value'] : '';

            setState(() {
              products.add(model);
            });
          }

          for (var element in result2.docs) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = element["category_name"].toString();
            model.postion = element["postion"];
            model.tmpcatid = element.id;
            setState(() {
              categories.add(model);
            });
          }

          for (var product in products) {
            int findCategoryIndex = categories.indexWhere(
                (element) => element.tmpcatid == product.categoryid);
            if (findCategoryIndex != -1) {
              setState(() {
                product.categoryName =
                    categories[findCategoryIndex].categoryName;
              });
            }
          }
          setState(() {
            allProducts.addAll(products);
          });

          return products;
        }
      }
      return null;
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  searchProduct() {
    List<ProductDataModel> filteredList = allProducts.where((task) {
      return task.productName!
              .toLowerCase()
              .contains(searchForm.text.toLowerCase()) ||
          task.productName!
              .toLowerCase()
              .startsWith(searchForm.text.toLowerCase()) ||
          task.productCode!
              .toLowerCase()
              .contains(searchForm.text.toLowerCase());
    }).toList();
    setState(() {
      products = filteredList;
    });
  }

  Future? productHandler;

  Future getOfflineProductList() async {
    try {
      setState(() {
        categories.clear();
        products.clear();
        allProducts.clear();
      });

      var localProducts = await DatabaseHelper().getProducts();
      var localCategories = await DatabaseHelper().getCategory();

      for (var categorylist in localCategories) {
        CategoryDataModel model = CategoryDataModel();
        model.categoryName = categorylist["category_name"].toString();
        model.postion = int.parse(categorylist["postion"]);
        model.tmpcatid = categorylist["category_id"];
        model.discount = int.parse(categorylist["discount"]);
        setState(() {
          categories.add(model);
        });
      }

      for (var product in localProducts) {
        ProductDataModel productInfo = ProductDataModel();
        productInfo.categoryName = "";
        productInfo.categoryid = product["category_id"].toString();
        productInfo.discountLock = product["discount_lock"] == 1 ? true : false;
        productInfo.name = product["name"].toString();
        productInfo.productCode = product["product_code"];
        productInfo.productContent = product["product_content"];
        productInfo.qrCode = product["qr_code"];
        productInfo.videoUrl = product["video_url"];
        productInfo.productName = product["product_name"];
        productInfo.productImg = product["product_img"];
        productInfo.price = double.parse(product["price"].toString());
        productInfo.productId = product["product_id"];
        productInfo.qty = 0;
        productInfo.qtyForm =
            TextEditingController(text: productInfo.qty.toString());

        setState(() {
          products.add(productInfo);
        });
      }
      for (var product in products) {
        int findCategoryIndex = categories
            .indexWhere((element) => element.tmpcatid == product.categoryid);
        if (findCategoryIndex != -1) {
          setState(() {
            product.categoryName = categories[findCategoryIndex].categoryName;
          });
        }
      }
      setState(() {
        allProducts.addAll(products);
      });

      return products;
    } catch (e) {
      // setState(() {
      //   isLoading = false;
      // });
      snackbar(context, false, e.toString());
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isConnected) {
      productHandler = getProducts();
    } else {
      productHandler = getOfflineProductList();
    }
  }

  TextEditingController searchForm = TextEditingController();
  List<ProductDataModel> products = [];
  List<ProductDataModel> allProducts = [];
  List<CategoryDataModel> categories = [];

  Future? productsHandler;

  void resetSearch() {
    setState(() {
      products = List.from(allProducts);
    });
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
          children: [
            InputForm(
              labelName: "Search by Name / Code",
              controller: searchForm,
              formName: "Product",
              onChanged: (value) {
                searchProduct();
              },
              suffixIcon: searchForm.text.isNotEmpty
                  ? TextButton(
                      onPressed: () {
                        searchForm.clear();
                        resetSearch();
                      },
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                          color: Color(0xff2F4550),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
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
                              child: AddCustomProduct(),
                            );
                          },
                        );
                      },
                      child: const Text(
                        "Custom Product",
                        style: TextStyle(
                          color: Color(0xff2F4550),
                        ),
                      ),
                    ),
            ),
            FutureBuilder(
              future: productHandler,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return futureLoading(context);
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return products.isNotEmpty
                      ? Flexible(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 5,
                              left: 5,
                              right: 5,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                ),
                                margin: const EdgeInsets.only(top: 5),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.pop(
                                      context,
                                      products[index].productId,
                                    );
                                  },
                                  leading: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: products[index].productImg ??
                                          Strings.productImg,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      fit: BoxFit.cover,
                                      width: 45.0,
                                      height: 45.0,
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                  title: Text(
                                    "${products[index].productName.toString()} (${products[index].productCode.toString()})",
                                  ),
                                  subtitle: Text(
                                    products[index].categoryName.toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Column(
                            children: [
                              const Text("No products found"),
                              TextButton.icon(
                                icon: const Icon(Iconsax.refresh),
                                label: const Text("Refresh"),
                                onPressed: () {
                                  setState(() {
                                    productHandler = getProducts();
                                  });
                                },
                              )
                            ],
                          ),
                        );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //     onWillPop: () async => false,
  //     child: SafeArea(
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         margin: const EdgeInsets.all(15),
  //         constraints: BoxConstraints(
  //           maxWidth: 600,
  //           maxHeight: MediaQuery.of(context).size.height * 0.85,
  //         ),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(10),
  //           child: Scaffold(
  //             appBar: AppBar(
  //               iconTheme: const IconThemeData(color: Colors.black),
  //               backgroundColor: Colors.white,
  //               elevation: 0,
  //               systemOverlayStyle: const SystemUiOverlayStyle(
  //                 statusBarIconBrightness: Brightness.dark,
  //                 statusBarColor: Colors.transparent,
  //               ),
  //               leading: IconButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 splashRadius: 20,
  //                 icon: const Icon(
  //                   Icons.close,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               titleSpacing: 0,
  //               title: TextFormField(
  //                 autofocus: true,
  //                 decoration: const InputDecoration(
  //                   hintText: "Search Product",
  //                   filled: true,
  //                   fillColor: Colors.white,
  //                 ),
  //                 onChanged: (value) {
  //                   searchProduct();
  //                 },
  //               ),
  //             ),
  //             body: FutureBuilder(
  //               future: productHandler,
  //               builder: (context, snapshot) {
  //                 if (snapshot.connectionState == ConnectionState.waiting) {
  //                   return futureLoading(context);
  //                 } else if (snapshot.hasError) {
  //                   return Center(
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       margin: const EdgeInsets.all(20),
  //                       padding: const EdgeInsets.all(10),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           const Center(
  //                             child: Text(
  //                               "Failed",
  //                               style: TextStyle(
  //                                 color: Colors.red,
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(
  //                             height: 15,
  //                           ),
  //                           Text(
  //                             snapshot.error.toString() == "null"
  //                                 ? "Something went Wrong"
  //                                 : snapshot.error.toString(),
  //                             textAlign: TextAlign.center,
  //                             style: const TextStyle(
  //                               color: Colors.black54,
  //                               fontSize: 13,
  //                             ),
  //                           ),
  //                           Center(
  //                             child: TextButton.icon(
  //                               onPressed: () {
  //                                 setState(() {
  //                                   productHandler = getProductInfo();
  //                                 });
  //                               },
  //                               icon: const Icon(Icons.refresh),
  //                               label: const Text(
  //                                 "Refresh",
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 } else {
  //                   return RefreshIndicator(
  //                     color: Theme.of(context).primaryColor,
  //                     onRefresh: () async {
  //                       setState(() {
  //                         productHandler = getProductInfo();
  //                       });
  //                     },
  //                     child:
  //                   );
  //                 }
  //               },
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
