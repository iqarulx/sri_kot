import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';

class SearchProductBilling extends StatefulWidget {
  final bool isConnected;
  const SearchProductBilling({super.key, required this.isConnected});

  @override
  State<SearchProductBilling> createState() => _SearchProductBillingState();
}

class _SearchProductBillingState extends State<SearchProductBilling> {
  List<ProductDataModel> productDataList = [];
  List<ProductDataModel> tmpProductDataList = [];
  List<CategoryDataModel> categoryList = [];

  FireStore provider = FireStore();

  Future getProductInfo() async {
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
            categoryList.clear();
            productDataList.clear();
            tmpProductDataList.clear();
          });
          for (var element in result.docs) {
            ProductDataModel model = ProductDataModel();
            model.categoryid = element["category_id"] ?? "";
            model.categoryName = "";
            model.productName = element["product_name"] ?? "";
            model.productCode = element["product_code"] ?? "";
            model.productContent = element["product_content"] ?? "";
            model.qrCode = element["qr_code"] ?? "";
            model.price = double.parse(element["price"].toString());
            model.videoUrl = element["video_url"] ?? "";
            model.productImg = element["product_img"] ?? "";
            model.active = element["active"];
            model.productId = element.id;
            model.discountLock = element['discount_lock'];
            setState(() {
              productDataList.add(model);
            });
          }

          for (var element in result2.docs) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = element["category_name"].toString();
            model.postion = element["postion"];
            model.tmpcatid = element.id;
            setState(() {
              categoryList.add(model);
            });
          }

          for (var product in productDataList) {
            int findCategoryIndex = categoryList.indexWhere(
                (element) => element.tmpcatid == product.categoryid);
            if (findCategoryIndex != -1) {
              setState(() {
                product.categoryName =
                    categoryList[findCategoryIndex].categoryName;
              });
            }
          }
          setState(() {
            tmpProductDataList.addAll(productDataList);
          });

          return productDataList;
        }
      }
      return null;
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  searchproduct(String searchtext) async {
    setState(() {
      productDataList.clear();

      Iterable<ProductDataModel> tmpList = tmpProductDataList.where((element) {
        if (element.productName!
            .toLowerCase()
            .replaceAll(' ', '')
            .startsWith(searchtext.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.productCode!
            .toLowerCase()
            .replaceAll(' ', '')
            .startsWith(
              searchtext.toLowerCase().replaceAll(' ', ''),
            )) {
          return true;
        } else if (element.productName!
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(searchtext.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else {
          return false;
        }
      });
      for (var element in tmpList) {
        productDataList.add(element);
      }
    });
  }

  late Future productHandler;

  Future getOfflineProductList() async {
    try {
      setState(() {
        categoryList.clear();
        productDataList.clear();
        tmpProductDataList.clear();
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
          categoryList.add(model);
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
          productDataList.add(productInfo);
        });
      }
      for (var product in productDataList) {
        int findCategoryIndex = categoryList
            .indexWhere((element) => element.tmpcatid == product.categoryid);
        if (findCategoryIndex != -1) {
          setState(() {
            product.categoryName = categoryList[findCategoryIndex].categoryName;
          });
        }
      }
      setState(() {
        tmpProductDataList.addAll(productDataList);
      });

      return productDataList;
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
      productHandler = getProductInfo();
    } else {
      productHandler = getOfflineProductList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(15),
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.black),
                backgroundColor: Colors.white,
                elevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.transparent,
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
                titleSpacing: 0,
                title: TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Search Product",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    searchproduct(value);
                  },
                ),
              ),
              body: FutureBuilder(
                future: productHandler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return futureLoading(context);
                  } else if (snapshot.hasError) {
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
                                    productHandler = getProductInfo();
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
                  } else {
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          productHandler = getProductInfo();
                        });
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        itemCount: productDataList.length,
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
                                  productDataList[index].productId,
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                child: widget.isConnected
                                    ? productDataList[index].productImg ==
                                                null ||
                                            productDataList[index]
                                                    .productImg
                                                    .toString()
                                                    .toLowerCase() ==
                                                "null" ||
                                            productDataList[index]
                                                .productImg
                                                .toString()
                                                .isEmpty
                                        ? null
                                        : Image.network(
                                            productDataList[index].productImg!,
                                            fit: BoxFit.cover,
                                          )
                                    : null,
                              ),
                              title: Text(
                                productDataList[index].productName.toString(),
                              ),
                              subtitle: Text(
                                productDataList[index].categoryName.toString(),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
