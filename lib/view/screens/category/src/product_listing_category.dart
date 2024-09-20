import 'package:flutter/material.dart';

import '/constants/constants.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';

class ProductListingCategory extends StatefulWidget {
  final String categoryID;
  final String categoryName;
  const ProductListingCategory({
    super.key,
    required this.categoryID,
    required this.categoryName,
  });

  @override
  State<ProductListingCategory> createState() => _ProductListingCategoryState();
}

class _ProductListingCategoryState extends State<ProductListingCategory> {
  List<ProductDataModel> productDataList = [];
  Future getCategoryWishProductInfo() async {
    try {
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        FireStoreProvider provider = FireStoreProvider();
        final result = await provider.productBilling(
            cid: cid, categoryId: widget.categoryID);
        if (result!.docs.isNotEmpty) {
          setState(() {
            productDataList.clear();
          });
          for (var element in result.docs) {
            ProductDataModel model = ProductDataModel();
            model.productName = element["product_name"].toString();
            model.postion = element["postion"];
            model.docid = element.id;
            setState(() {
              productDataList.add(model);
            });
          }

          return productDataList;
        }
      }
      return null;
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  Future rearrangecatvalid({
    required int newIndex,
    required String productID,
  }) async {
    loading(context);
    try {
      await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
        if (cid != null) {
          await FireStoreProvider()
              .getProductPostion(docID: productID)
              .then((productInfo) async {
            if (productInfo != null && productInfo.exists) {
              int startPostion = 0;
              int endPostion = 0;
              if (newIndex > productInfo["postion"]) {
                setState(() {
                  startPostion = productInfo["postion"] + 1;
                  endPostion = newIndex;
                });
                await FireStoreProvider()
                    .getProductLimit(
                  startPostion: startPostion,
                  endPostion: endPostion,
                  cid: cid,
                  categoryID: widget.categoryID,
                )
                    .then((changeCategory) async {
                  if (changeCategory != null &&
                      changeCategory.docs.isNotEmpty) {
                    for (var element in changeCategory.docs) {
                      await FireStoreProvider().updateProductPostion(
                        docId: element.id,
                        postionValue: element["postion"] - 1,
                      );
                    }
                  }
                });
              } else {
                setState(() {
                  startPostion = newIndex;
                  endPostion = productInfo["postion"] - 1;
                });
                await FireStoreProvider()
                    .getProductLimit(
                  startPostion: startPostion,
                  endPostion: endPostion,
                  cid: cid,
                  categoryID: widget.categoryID,
                )
                    .then((changeCategory) async {
                  if (changeCategory != null &&
                      changeCategory.docs.isNotEmpty) {
                    for (var element in changeCategory.docs) {
                      await FireStoreProvider().updateProductPostion(
                        docId: element.id,
                        postionValue: element["postion"] + 1,
                      );
                    }
                  }
                });
              }

              await FireStoreProvider()
                  .updateProductPostion(
                docId: productID,
                postionValue: newIndex,
              )
                  .then((value) {
                Navigator.pop(context);
                snackbar(context, true, "Successfully Updated");
              });
            } else {
              Navigator.pop(context);
            }
          });
        }
      });

      // await FireStoreProvider().
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  late Future productHandler;

  @override
  void initState() {
    super.initState();
    productHandler = getCategoryWishProductInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
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
                            productHandler = getCategoryWishProductInfo();
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
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      productHandler = getCategoryWishProductInfo();
                    });
                  },
                  child: ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {
                      print(oldIndex);
                      print(newIndex);

                      setState(() {
                        final index =
                            newIndex > oldIndex ? newIndex - 1 : newIndex;
                        var cargory = productDataList.removeAt(oldIndex);
                        productDataList.insert(
                          index,
                          cargory,
                        );
                        rearrangecatvalid(
                          newIndex: index + 1,
                          productID: productDataList[index].docid!,
                        );
                      });
                    },
                    itemCount: productDataList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        key: ValueKey(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: index > 0
                                ? const Border(
                                    top: BorderSide(
                                      width: 0.5,
                                      color: Color(0xffE0E0E0),
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(
                                  Icons.drag_handle,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "${productDataList[index].productName.toString()} - ${productDataList[index].postion ?? "Position not set yet"}",
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
