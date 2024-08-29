import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../gen/assets.gen.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import '/constants/enum.dart';

class CategoryDiscountView extends StatefulWidget {
  const CategoryDiscountView({super.key});

  @override
  State<CategoryDiscountView> createState() => _CategoryDiscountViewState();
}

class _CategoryDiscountViewState extends State<CategoryDiscountView> {
  List<CategoryDataModel> categoryList = [];
  List<CategoryDiscountModel> discountCategoryList = [];

  getCategory() async {
    try {
      setState(() {
        categoryList.clear();
        discountCategoryList.clear();
      });
      var cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        FireStoreProvider provider = FireStoreProvider();
        final result = await provider.categoryListing(cid: cid);
        if (result!.docs.isNotEmpty) {
          setState(() {
            categoryList.clear();
          });
          for (var element in result.docs) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = element["category_name"].toString();
            model.postion = element["postion"];
            model.tmpcatid = element.id;
            model.discount = element["discount"];
            model.discountEnable = element["discount"] != null ? true : false;
            setState(() {
              categoryList.add(model);
            });
          }
          for (var categoryElement in categoryList) {
            if (categoryElement.discount != null) {
              int index = discountCategoryList.indexWhere(
                (element) => element.discountValue == categoryElement.discount,
              );

              if (index == -1) {
                CategoryDiscountModel value = CategoryDiscountModel();
                value.categoryName = categoryElement.categoryName ?? "";
                value.discountValue = categoryElement.discount;
                discountCategoryList.add(value);
              } else {
                discountCategoryList[index].categoryName =
                    "${discountCategoryList[index].categoryName}, ${categoryElement.categoryName}";
              }
            }
          }
          return categoryList;
        }
      }
      return null;
    } catch (e) {
      snackBarCustom(context, false, e.toString());
      return null;
    }
  }

  Future? getDiscountHandler;

  @override
  void initState() {
    getDiscountHandler = getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Discount"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoryDiscountDetailsView(categoryList: categoryList),
                ),
              ).then((value) {
                if (value != null && value) {
                  setState(() {
                    getDiscountHandler = getCategory();
                  });
                }
              });
            },
            icon: const Icon(Icons.add),
            splashRadius: 20,
          ),
        ],
      ),
      body: FutureBuilder(
        future: getDiscountHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  getDiscountHandler = getCategory();
                });
              },
              child: discountCategoryList.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: discountCategoryList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CategoryDiscountDetailsView(
                                  categoryList: categoryList,
                                  discount:
                                      discountCategoryList[index].discountValue,
                                ),
                              ),
                            ).then((value) {
                              if (value != null && value) {
                                setState(() {
                                  getDiscountHandler = getCategory();
                                });
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${discountCategoryList[index].discountValue}%",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Category: ${discountCategoryList[index].categoryName}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.keyboard_arrow_right),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AspectRatio(
                              aspectRatio: (1 / 0.7),
                              child: SvgPicture.asset(
                                Assets.emptyList3,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "No Discounts",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Center(
                            child: Text(
                              "You have not create any discount, so first you have create discount using add discount button below",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryDiscountDetailsView(
                                              categoryList: categoryList),
                                    ),
                                  ).then((value) {
                                    if (value != null && value) {
                                      setState(() {
                                        getDiscountHandler = getCategory();
                                      });
                                    }
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Add Discount"),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    getDiscountHandler = getCategory();
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text("Refresh"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return futureLoading(context);
          }
        },
      ),
    );
  }
}
