import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '/constants/constants.dart';
import '/gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import '/provider/src/file_open.dart' as helper;

class ProductListing extends StatefulWidget {
  const ProductListing({super.key});

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      body: Consumer<ConnectionProvider>(
        builder: (context, connectionProvider, child) {
          return connectionProvider.isConnected ? body() : noInternet(context);
        },
      ),
    );
  }

  FutureBuilder<dynamic> body() {
    return FutureBuilder(
      future: productHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureLoading(context);
        } else if (snapshot.hasError) {
          return errorDisplay(snapshot);
        } else {
          return screenView(context);
        }
      },
    );
  }

  Center errorDisplay(AsyncSnapshot<dynamic> snapshot) {
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
  }

  Padding screenView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            filterOptions(),
            productList(context),
          ],
        ),
      ),
    );
  }

  Expanded productList(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            productHandler = getProductInfo();
          });
        },
        child: productDataList.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    for (int index =
                            ((crtpagelimit * crtpagenumber) - crtpagelimit);
                        index < ((crtpagelimit * crtpagenumber));
                        index++)
                      if (productDataList.length > index)
                        Column(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ProductDetails(
                                      title: 'Product Details',
                                      edit: true,
                                      productData: productDataList[index],
                                    ),
                                  ),
                                ).then((value) {
                                  if (value != null && value == true) {
                                    setState(() {
                                      productHandler = getProductInfo();
                                    });
                                  }
                                });
                              },
                              leading: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: productDataList[index].productImg !=
                                              null &&
                                          productDataList[index]
                                              .productImg!
                                              .isNotEmpty
                                      ? productDataList[index].productImg!
                                      : Strings.productImg,
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
                                productDataList[index].productName ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              subtitle: Text(
                                "Category - ${productDataList[index].categoryName ?? ""}",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    productDataList[index].price.toString(),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_right_outlined,
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 0,
                              color: Colors.grey.shade300,
                            ),
                          ],
                        ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        Assets.emptyList3,
                        height: 200,
                        width: 200,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "No Products",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Center(
                      child: Text(
                        "You have not create any product, so first you have create product using add product button below",
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
                              CupertinoPageRoute(
                                builder: (context) => const ProductDetails(
                                  title: 'Create Product',
                                  edit: false,
                                ),
                              ),
                            ).then((value) {
                              if (value != null && value == true) {
                                setState(() {
                                  productHandler = getProductInfo();
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Product"),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              productHandler = getProductInfo();
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
      ),
    );
  }

  Container filterOptions() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(
            height: 45,
            child: TextFormField(
              cursorColor: const Color(0xff7099c2),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: "Search Product",
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xff7099c2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchproduct(value);
                });
              },
              onEditingComplete: () {
                setState(() {
                  FocusManager.instance.primaryFocus!.unfocus();
                  searchproduct(searchform.text);
                });
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 45,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    items: categorylist,
                    onChanged: (v) {
                      setState(() {
                        category = v;
                      });
                      filter();
                    },
                    // cursorColor: const Color(0xff7099c2),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      hintText: "Choose Category",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 45,
                  child: DropdownButtonFormField(
                    value: crtpagelimit != 0 ? crtpagelimit : null,
                    isExpanded: true,
                    items: pagelimit,
                    onChanged: (value) {
                      setState(() {
                        crtpagenumber = 0;
                        crtpagelimit = value;
                        filter();
                      });
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      hintText: "No",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 45,
                  child: DropdownButtonFormField(
                    isExpanded: true,
                    items: noofpage,
                    value: crtpagenumber != 0 ? crtpagenumber : null,
                    onChanged: (value) {
                      setState(() {
                        crtpagenumber = value;
                      });
                    },
                    // cursorColor: const Color(0xff7099c2),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      hintText: "Page",
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Products"),
      actions: [
        IconButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final connectionProvider =
                  Provider.of<ConnectionProvider>(context, listen: false);
              if (connectionProvider.isConnected) {
                AccountValid.accountValid(context);

                productHandler = getProductInfo();
              }
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final connectionProvider =
                  Provider.of<ConnectionProvider>(context, listen: false);
              connectionProvider.addListener(() {
                if (connectionProvider.isConnected) {
                  AccountValid.accountValid(context);

                  productHandler = getProductInfo();
                }
              });
            });
          },
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: () {
            final connectionProvider =
                Provider.of<ConnectionProvider>(context, listen: false);
            if (connectionProvider.isConnected) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const ProductDetails(
                    title: 'Create Product',
                    edit: false,
                  ),
                ),
              ).then((value) {
                if (value != null && value == true) {
                  setState(() {
                    productHandler = getProductInfo();
                  });
                }
              });
            }
            // openModelBottomSheat(context);
          },
          splashRadius: 20,
          icon: const Icon(
            Icons.add,
          ),
        ),
        PopupMenuButton(
          splashRadius: 10,
          onSelected: (String item) async {
            final connectionProvider =
                Provider.of<ConnectionProvider>(context, listen: false);
            if (connectionProvider.isConnected) {
              switch (item) {
                case 'excel':
                  await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const UploadExcel(),
                    ),
                  ).then((value) {
                    if (value != null && value == true) {
                      productHandler = getProductInfo();
                    }
                  });
                  break;
                case 'download':
                  downloadTemplate();
                  break;
                case 'print':
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const PdfPriceListView(),
                    ),
                  );
                  break;
                default:
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'excel',
              child: ListTile(
                minVerticalPadding: 0,
                contentPadding: EdgeInsets.all(0),
                leading: Icon(Icons.description_outlined),
                title: Text("Excel Upload"),
              ),
            ),
            PopupMenuItem<String>(
              value: 'download',
              child: ListTile(
                minVerticalPadding: 0,
                contentPadding: const EdgeInsets.all(0),
                leading: const Icon(Icons.file_download_outlined),
                title: const Text("Download Template"),
                subtitle: Text(
                  'Download Template Excel File',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'print',
              child: ListTile(
                minVerticalPadding: 0,
                contentPadding: const EdgeInsets.all(0),
                leading: const Icon(Icons.print_outlined),
                title: const Text("Download Price List"),
                subtitle: Text(
                  'Download Overall Product Price List',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
          child: const IconButton(
            disabledColor: Colors.white,
            onPressed: null,
            splashRadius: 20,
            icon: Icon(
              Icons.more_vert,
            ),
          ),
        )
      ],
    );
  }

  List<ProductDataModel> productDataList = [];
  List<CategoryDataModel> categoryList = [];
  List<ProductDataModel> tmpProductDataList = [];

  FireStore provider = FireStore();

  Future<String?> getCategoryName({required String categoryId}) async {
    String? categoryName;
    try {
      var result = await provider.getCategorydocInfo(docid: categoryId);
      if (result!.exists) {
        categoryName = result["category_name"];
      }
    } catch (e) {
      throw e.toString();
    }
    return categoryName;
  }

  Future getProductInfo() async {
    try {
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        final result = await provider.productListing(cid: cid);
        final result2 = await provider.categoryListing(cid: cid);
        if (result!.docs.isNotEmpty && result2!.docs.isNotEmpty) {
          setState(() {
            productDataList.clear();
            tmpProductDataList.clear();
            categorylist.clear();
          });
          for (var element in result.docs) {
            ProductDataModel model = ProductDataModel();
            model.categoryid = element["category_id"] ?? "";
            // model.categoryName = element["category_name"] ?? "";
            model.categoryName = "";
            model.productName = element["product_name"] ?? "";
            model.productCode = element["product_code"] ?? "";
            model.productContent = element["product_content"] ?? "";
            model.qrCode = element["qr_code"] ?? "";
            model.price = double.parse(element["price"].toString());
            model.videoUrl = element["video_url"] ?? "";
            model.productImg = element["product_img"];
            model.active = element["active"];
            model.productId = element.id;
            model.discountLock = element['discount_lock'];
            model.hsnCode = element['hsn_code'] ?? '';

            setState(() {
              productDataList.add(model);
            });
          }
          categorylist.add(
            const DropdownMenuItem(
              value: "all",
              child: Text(
                "Show All",
              ),
            ),
          );
          for (var element in result2.docs) {
            CategoryDataModel model = CategoryDataModel();
            model.categoryName = element["category_name"].toString();
            model.postion = element["postion"];
            model.tmpcatid = element.id;
            setState(() {
              categoryList.add(model);
            });

            categorylist.add(
              DropdownMenuItem(
                value: element.id,
                child: Text(
                  element["category_name"].toString(),
                ),
              ),
            );
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

          filter();
          return productDataList;
        }
      }
      return null;
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  downloadTemplate() async {
    loading(context);
    try {
      var data = await http.get(Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/srisoftpos.appspot.com/o/product_templete%2Fproduct_template.xlsx?alt=media&token=a9aa597d-9bc2-4d79-b978-476bf0942e16'));
      var response = data.bodyBytes;
      Navigator.pop(context);
      helper.saveAndLaunchFile(response, "Product Template.xlsx");
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  searchproduct(String searchtext) async {
    setState(() {
      productDataList.clear();
      category = "";
      crtpagelimit = 10;
      totalrecord = 0;
      crtpagenumber = 1;

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
        } else {
          return false;
        }
      });
      for (var element in tmpList) {
        productDataList.add(element);
      }
    });
    filter();
  }

  // Filter
  filter() async {
    setState(() {
      if (category != null && category!.isNotEmpty && searchform.text.isEmpty) {
        productDataList.clear();
        List<ProductDataModel> data;
        if (category == "all") {
          //crtpagelimit = 10;
          totalrecord = 0;
          crtpagenumber = 1;

          data = tmpProductDataList;
        } else {
          data = tmpProductDataList
              .where((element) => element.categoryid == category)
              .toList();
        }

        for (var element in data) {
          setState(() {
            productDataList.add(element);
          });
        }
      }
      totalrecord = productDataList.length;
      crtpagenumber = 1;
      noofpage.clear();
      var tmp = (totalrecord / crtpagelimit);
      int count = tmp.ceil();
      if (count == 0) {
        count = 1;
      }
      for (var i = 1; i < count + 1; i++) {
        noofpage.add(
          DropdownMenuItem(
            value: i,
            child: Text(
              i.toString(),
            ),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);

        productHandler = getProductInfo();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);

          productHandler = getProductInfo();
        }
      });
    });
  }

  Future? productHandler;

  //search Varibale
  List<DropdownMenuItem> categorylist = [];
  int crtpagelimit = 10;
  int totalrecord = 0;
  int crtpagenumber = 1;
  List<DropdownMenuItem> noofpage = [];
  List<DropdownMenuItem> pagelimit = const [
    DropdownMenuItem(
      value: 10,
      child: Text("10"),
    ),
    DropdownMenuItem(
      value: 25,
      child: Text("25"),
    ),
    DropdownMenuItem(
      value: 50,
      child: Text("50"),
    ),
    DropdownMenuItem(
      value: 100,
      child: Text("100"),
    ),
  ];
  String? category;
  TextEditingController searchform = TextEditingController();
}
