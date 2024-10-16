import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import '/constants/constants.dart';
import '/provider/src/file_open.dart' as helper;

class EnquiryListing extends StatefulWidget {
  const EnquiryListing({super.key});

  @override
  State<EnquiryListing> createState() => _EnquiryListingState();
}

class _EnquiryListingState extends State<EnquiryListing> {
  List<EstimateDataModel> enquiryList = [];
  List<EstimateDataModel> tmpEnquiryList = [];
  TextEditingController searchForm = TextEditingController();
  int? overallTotal;
  bool searchTriggred = false;

  Future getEnquiryTotal() async {
    setState(() {
      noofpage.clear();
    });

    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    var enquiry = await FireStore().getEnquiryTotal(cid: cid);
    var enquiryLength = enquiry["total_enquiry"];
    var enquiryTotal = enquiry["total"];

    setState(() {
      overallTotal = enquiryTotal.toInt();
      totalBills = enquiryLength;
    });

    var pagesLength =
        (enquiryLength.toInt() / int.parse(selectedPageLimit)).ceil();

    for (var i = 0; i < pagesLength; i++) {
      noofpage.add(
        DropdownMenuItem(
          value: i,
          child: Text((i + 1).toString()),
        ),
      );
    }
  }

  Future getOfflineTotal() async {
    setState(() {
      noofpage.clear();
    });

    var enquiry = await DatabaseHelper().getEnquiryTotal();
    var enquiryLength = enquiry["no_of_enquiry"];
    var enquiryTotal = enquiry["total"];

    setState(() {
      overallTotal = double.parse(enquiryTotal).toInt();
      totalBills = enquiryLength;
    });

    var pagesLength =
        (enquiryLength.toInt() / int.parse(selectedPageLimit)).ceil();

    for (var i = 0; i < pagesLength; i++) {
      noofpage.add(
        DropdownMenuItem(
          value: i,
          child: Text((i + 1).toString()),
        ),
      );
    }
  }

  Future getEnquiryInfo() async {
    try {
      setState(() {
        enquiryList.clear();
        isLoad = false;
        endOfDocument = false;
        start = 0;
        end = 10;
      });

      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

      if (cid != null) {
        var enquiry =
            await FireStore().getEnquiry(cid: cid, start: start, end: end);
        if (enquiry.isNotEmpty) {
          for (var value in enquiry) {
            var calc = BillingCalCulationModel();
            calc.discountValue = value["price"]["discount_value"];
            calc.extraDiscount = value["price"]["extra_discount"];
            calc.roundOff = value["price"]["round_off"];
            calc.extraDiscountValue = value["price"]["extra_discount_value"];
            calc.extraDiscountsys = value["price"]["extra_discount_sys"];
            calc.package = value["price"]["package"];
            calc.packageValue = value["price"]["package_value"];
            calc.packagesys = value["price"]["package_sys"];
            calc.subTotal = value["price"]["sub_total"];
            calc.total = value["price"]["total"];
            calc.netratedTotal = value["price"]["netrated_total"];
            calc.discountedTotal = value["price"]["discounted_total"];
            calc.netPlusDisTotal = value["price"]["net_plus_dis_total"];
            calc.discounts = value["price"]["discounts"];

            CustomerDataModel? customer = CustomerDataModel();
            if (value["customer"] != null) {
              customer.docID = value["customer"]["customer_id"];
              customer.address = value["customer"]["address"];
              customer.state = value["customer"]["state"];
              customer.city = value["customer"]["city"];
              customer.customerName = value["customer"]["customer_name"];
              customer.email = value["customer"]["email"];
              customer.mobileNo = value["customer"]["mobile_no"];
            } else {
              customer = null;
            }

            List<ProductDataModel> tmpProducts = [];

            setState(() {
              tmpProducts.clear();
            });

            await FireStore()
                .getEnquiryProducts(docid: value.id)
                .then((products) {
              if (products != null && products.docs.isNotEmpty) {
                for (var product in products.docs) {
                  var productDataModel = ProductDataModel();
                  productDataModel.categoryid = product["category_id"];
                  productDataModel.categoryName = product["category_name"];
                  productDataModel.price = product["price"];

                  productDataModel.productId = product["product_id"];
                  productDataModel.productName = product["product_name"];
                  productDataModel.qty = product["qty"];
                  productDataModel.productCode = product["product_code"] ?? "";
                  productDataModel.discountLock = product["discount_lock"];
                  productDataModel.docid = product.id;
                  productDataModel.name = product["name"];
                  productDataModel.hsnCode = product["hsn_code"];
                  productDataModel.taxValue = product["tax_value"];
                  productDataModel.productType =
                      product["discount_lock"] || product["discount"] == null
                          ? ProductType.netRated
                          : ProductType.discounted;
                  productDataModel.productContent = product["product_content"];
                  productDataModel.productImg = product["product_img"];
                  productDataModel.qrCode = product["qr_code"];
                  productDataModel.videoUrl = product["video_url"];
                  productDataModel.discount = product["discount"];

                  setState(() {
                    tmpProducts.add(productDataModel);
                  });
                }
              }
            });

            setState(() {
              enquiryList.add(
                EstimateDataModel(
                  docID: value.id,
                  createddate: DateTime.parse(
                    value["created_date"].toDate().toString(),
                  ),
                  enquiryid: value['enquiry_id'],
                  estimateid: value["estimate_id"],
                  price: calc,
                  customer: customer,
                  products: tmpProducts,
                  dataType: DataTypes.cloud,
                ),
              );
            });
          }
        }
        setState(() {
          tmpEnquiryList.addAll(enquiryList);
        });
        return enquiry;
      }
    } catch (e) {
      snackbar(context, false, e.toString());
      return null;
    }
  }

  Future getOfflineEnquiryInfo() async {
    try {
      setState(() {
        enquiryList.clear();
      });

      var localEnquiry = await DatabaseHelper()
          .getEnquiry(start: start, end: end, limitApplied: true);
      for (var enquiryData in localEnquiry) {
        var calc = BillingCalCulationModel();
        calc.discountValue = enquiryData["price"]["discount_value"];
        calc.extraDiscount = enquiryData["price"]["extra_discount"];
        calc.roundOff = enquiryData["price"]["round_off"];
        calc.extraDiscountValue = enquiryData["price"]["extra_discount_value"];
        calc.extraDiscountsys = enquiryData["price"]["extra_discount_sys"];
        calc.package = enquiryData["price"]["package"];
        calc.packageValue = enquiryData["price"]["package_value"];
        calc.packagesys = enquiryData["price"]["package_sys"];
        calc.subTotal = enquiryData["price"]["sub_total"];
        calc.total = enquiryData["price"]["total"];
        calc.netratedTotal = enquiryData["price"]["netrated_total"];
        calc.discountedTotal = enquiryData["price"]["discounted_total"];
        calc.netPlusDisTotal = enquiryData["price"]["net_plus_dis_total"];
        calc.discounts = enquiryData["price"]["discounts"];

        CustomerDataModel? customer = CustomerDataModel();
        if (enquiryData["customer"] != null) {
          customer.docID = enquiryData["customer"]["customer_id"];
          customer.address = enquiryData["customer"]["address"];
          customer.state = enquiryData["customer"]["state"];
          customer.city = enquiryData["customer"]["city"];
          customer.customerName = enquiryData["customer"]["customer_name"];
          customer.email = enquiryData["customer"]["email"];
          customer.mobileNo = enquiryData["customer"]["mobile_no"];
        }

        List<ProductDataModel> tmpProducts = [];

        if (enquiryData["products"] != null) {
          var productData =
              jsonDecode(enquiryData['products']) as List<dynamic>;
          for (var product in productData) {
            var productDataModel = ProductDataModel();
            productDataModel.categoryid = product["category_id"];
            productDataModel.categoryName = product["category_name"];
            productDataModel.price = product["price"];
            productDataModel.productId = product["product_id"];
            productDataModel.productName = product["product_name"];
            productDataModel.qty = product["qty"];
            productDataModel.productCode = product["product_code"] ?? "";
            productDataModel.discountLock = product["discount_lock"];
            productDataModel.docid = product["product_id"];
            productDataModel.name = product["name"];
            productDataModel.productContent = product["product_content"];
            productDataModel.productImg = product["product_img"];
            productDataModel.qrCode = product["qr_code"];
            productDataModel.videoUrl = product["video_url"];
            tmpProducts.add(productDataModel);
          }
        }

        enquiryList.add(
          EstimateDataModel(
            docID: null,
            createddate: DateTime.parse(enquiryData['created_date']),
            enquiryid: null,
            estimateid: null,
            price: calc,
            customer: customer,
            products: tmpProducts,
            dataType: DataTypes.local,
            referenceId: enquiryData["reference_id"],
          ),
        );
      }

      return enquiryList
          .sort((a, b) => b.createddate!.compareTo(a.createddate!));
    } catch (e) {
      snackbar(context, false, e.toString());
      return;
    }
  }

  searchEnquiryFunOffline() async {
    if (searchForm.text.isNotEmpty) {
      setState(() {
        enquiryList.clear();
        tmpEnquiryList.clear();
      });

      var localEnquiry = await DatabaseHelper()
          .getEnquiry(start: 0, end: 0, limitApplied: false);
      for (var data in localEnquiry) {
        var calc = BillingCalCulationModel();
        var price = jsonDecode(data['price']) as Map<String, dynamic>;
        calc.discountValue = price["discount_value"];
        calc.extraDiscount = price["extra_discount"];
        calc.extraDiscountValue = price["extra_discount_value"];
        calc.extraDiscountsys = price["extra_discount_sys"];
        calc.package = price["package"];
        calc.packageValue = price["package_value"];
        calc.packagesys = price["package_sys"];
        calc.subTotal = price["sub_total"];
        calc.total = price["total"];
        calc.roundOff = price["round_off"];

        CustomerDataModel? customer = CustomerDataModel();
        if (data["customer"] != null) {
          var customerData =
              jsonDecode(data['customer']) as Map<String, dynamic>;
          customer.address = customerData["address"] ?? "";
          customer.state = customerData["state"] ?? "";
          customer.city = customerData["city"] ?? "";
          customer.customerName = customerData["customer_name"] ?? "";
          customer.email = customerData["email"] ?? "";
          customer.mobileNo = customerData["mobile_no"] ?? "";
        }

        List<ProductDataModel> tmpProducts = [];

        if (data["products"] != null) {
          var productData = jsonDecode(data['products']) as List<dynamic>;
          for (var product in productData) {
            var productDataModel = ProductDataModel();
            productDataModel.categoryid = product["category_id"];
            productDataModel.categoryName = product["category_name"];
            productDataModel.price = product["price"];
            productDataModel.productId = product["product_id"];
            productDataModel.productName = product["product_name"];
            productDataModel.qty = product["qty"];
            productDataModel.productCode = product["product_code"] ?? "";
            productDataModel.discountLock = product["discount_lock"];
            productDataModel.docid = product["product_id"];
            productDataModel.name = product["name"];
            productDataModel.productContent = product["product_content"];
            productDataModel.productImg = product["product_img"];
            productDataModel.qrCode = product["qr_code"];
            productDataModel.videoUrl = product["video_url"];
            tmpProducts.add(productDataModel);
          }
        }

        tmpEnquiryList.add(
          EstimateDataModel(
            docID: null,
            createddate: DateTime.parse(data['created_date']),
            enquiryid: null,
            estimateid: null,
            price: calc,
            customer: customer,
            products: tmpProducts,
            dataType: DataTypes.local,
            referenceId: data["reference_id"],
          ),
        );
      }

      Iterable<EstimateDataModel> tmpList = tmpEnquiryList.where((element) {
        if (element.customer != null &&
            element.customer!.customerName != null &&
            element.customer!.customerName!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(
                    searchForm.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.customer != null &&
            element.customer!.mobileNo != null &&
            element.customer!.mobileNo!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(
                    searchForm.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.customer != null &&
            element.customer!.city != null &&
            element.customer!.city!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(
                    searchForm.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.customer != null &&
            element.customer!.state != null &&
            element.customer!.state!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(
                    searchForm.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (element.referenceId != null &&
            element.referenceId!.toLowerCase().replaceAll(' ', '').startsWith(
                searchForm.text.toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else {
          return false;
        }
      });
      if (tmpList.isNotEmpty) {
        for (var element in tmpList) {
          setState(() {
            enquiryList.add(element);
          });
        }
      }
      return enquiryList;
    } else {
      setState(() {
        enquiryList.clear();
        enquiryList.addAll(tmpEnquiryList);
      });
    }
  }

  downloadExcelData() async {
    try {
      loading(context);
      await EnquiryExcel(enquiryData: enquiryList, isEstimate: false)
          .createCustomerExcel()
          .then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          Navigator.pop(context);
          await helper.saveAndLaunchFile(fileData, 'Estimate Listing.xlsx');
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  filter(Map<String, dynamic> search) async {
    setState(() {
      enquiryList.clear();
      tmpEnquiryList.clear();
      isLoad = false;
      endOfDocument = false;
    });

    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

    if (cid != null) {
      var enquiry = await FireStore().getAllEnquiry(cid: cid);
      for (var enquiryData in enquiry) {
        var calc = BillingCalCulationModel();
        calc.discountValue = enquiryData["price"]["discount_value"];
        calc.extraDiscount = enquiryData["price"]["extra_discount"];
        calc.roundOff = enquiryData["price"]["round_off"];
        calc.extraDiscountValue = enquiryData["price"]["extra_discount_value"];
        calc.extraDiscountsys = enquiryData["price"]["extra_discount_sys"];
        calc.package = enquiryData["price"]["package"];
        calc.packageValue = enquiryData["price"]["package_value"];
        calc.packagesys = enquiryData["price"]["package_sys"];
        calc.subTotal = enquiryData["price"]["sub_total"];
        calc.total = enquiryData["price"]["total"];
        calc.netratedTotal = enquiryData["price"]["netrated_total"];
        calc.discountedTotal = enquiryData["price"]["discounted_total"];
        calc.netPlusDisTotal = enquiryData["price"]["net_plus_dis_total"];
        calc.discounts = enquiryData["price"]["discounts"];

        CustomerDataModel? customer = CustomerDataModel();
        if (enquiryData["customer"] != null) {
          customer.docID = enquiryData["customer"]["customer_id"];
          customer.address = enquiryData["customer"]["address"];
          customer.state = enquiryData["customer"]["state"];
          customer.city = enquiryData["customer"]["city"];
          customer.customerName = enquiryData["customer"]["customer_name"];
          customer.email = enquiryData["customer"]["email"];
          customer.mobileNo = enquiryData["customer"]["mobile_no"];
        }

        List<ProductDataModel> tmpProducts = [];

        setState(() {
          tmpProducts.clear();
        });

        await FireStore()
            .getEnquiryProducts(docid: enquiryData.id)
            .then((products) {
          if (products != null && products.docs.isNotEmpty) {
            for (var product in products.docs) {
              var productDataModel = ProductDataModel();
              productDataModel.categoryid = product["category_id"];
              productDataModel.categoryName = product["category_name"];
              productDataModel.price = product["price"];

              productDataModel.productId = product["product_id"];
              productDataModel.productName = product["product_name"];
              productDataModel.qty = product["qty"];
              productDataModel.productCode = product["product_code"] ?? "";
              productDataModel.discountLock = product["discount_lock"];
              productDataModel.docid = product.id;
              productDataModel.name = product["name"];
              productDataModel.productContent = product["product_content"];
              productDataModel.productImg = product["product_img"];
              productDataModel.qrCode = product["qr_code"];
              productDataModel.productType =
                  product["discount_lock"] || product["discount"] == null
                      ? ProductType.netRated
                      : ProductType.discounted;
              if (productDataModel.productType == ProductType.discounted) {
                productDataModel.discountedPrice =
                    double.parse(product["price"].toString()) -
                        (double.parse(product["price"].toString()) *
                            product["discount"] /
                            100);
              } else {
                productDataModel.discountedPrice =
                    double.parse(product["price"].toString());
              }

              setState(() {
                tmpProducts.add(productDataModel);
              });
            }
          }
        });

        setState(() {
          tmpEnquiryList.add(
            EstimateDataModel(
              docID: enquiryData.id,
              createddate: DateTime.parse(
                enquiryData["created_date"].toDate().toString(),
              ),
              enquiryid: enquiryData['enquiry_id'],
              estimateid: enquiryData["estimate_id"],
              price: calc,
              customer: customer,
              products: tmpProducts,
              dataType: DataTypes.cloud,
            ),
          );
        });
      }
    }

    List<EstimateDataModel> filteredList = tmpEnquiryList.where((enquiry) {
      if (search["search_text"].isNotEmpty) {
        if (enquiry.customer != null &&
            enquiry.customer!.customerName != null &&
            enquiry.customer!.customerName!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(
                    search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.customer != null &&
            enquiry.customer!.mobileNo != null &&
            enquiry.customer!.mobileNo!
                .toLowerCase()
                .replaceAll(' ', '')
                .startsWith(
                    search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.customer != null &&
            enquiry.customer!.city != null &&
            enquiry.customer!.city!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.customer != null &&
            enquiry.customer!.state != null &&
            enquiry.customer!.state!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.enquiryid != null &&
            enquiry.enquiryid!.toLowerCase().replaceAll(' ', '').startsWith(
                search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else if (enquiry.enquiryid != null &&
            enquiry.enquiryid!
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(search["search_text"].toLowerCase().replaceAll(' ', ''))) {
          return true;
        } else {
          return false;
        }
      } else if (search["from_date"] != null && search["to_date"] != null) {
        if (enquiry.createddate != null &&
            enquiry.createddate!.isAfter(search["from_date"]) &&
            enquiry.createddate!.isBefore(DateTime(
                search["to_date"].year,
                search["to_date"].month,
                search["to_date"].day,
                23,
                59,
                59,
                999))) {
          return true;
        } else {
          return false;
        }
      } else if (search["customer"]["doc_id"] != null) {
        if (enquiry.customer != null &&
            enquiry.customer!.docID == search["customer"]["doc_id"]) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }).toList();
    setState(() {
      enquiryList = filteredList;
    });
  }

  Future? enquiryHandler;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);
        getEnquiryTotal();
        enquiryHandler = getEnquiryInfo();
      } else {
        getOfflineTotal();
        enquiryHandler = getOfflineEnquiryInfo();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          AccountValid.accountValid(context);

          enquiryHandler = getEnquiryInfo();
          getEnquiryTotal();
        } else {
          getOfflineTotal();
          enquiryHandler = getOfflineEnquiryInfo();
        }
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadBills();
      }
    });
  }

  bool isLoad = false;
  bool endOfDocument = false;

  loadBills() async {
    setState(() {
      isLoad = true;
      start += 10;
      end += 10;
      endOfDocument = false;
    });
    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

    if (cid != null) {
      var enquiry =
          await FireStore().getEnquiry(cid: cid, start: start, end: end);
      if (enquiry.isNotEmpty) {
        for (var enquiryData in enquiry) {
          var calc = BillingCalCulationModel();
          calc.discountValue = enquiryData["price"]["discount_value"];
          calc.extraDiscount = enquiryData["price"]["extra_discount"];
          calc.roundOff = enquiryData["price"]["round_off"];
          calc.extraDiscountValue =
              enquiryData["price"]["extra_discount_value"];
          calc.extraDiscountsys = enquiryData["price"]["extra_discount_sys"];
          calc.package = enquiryData["price"]["package"];
          calc.packageValue = enquiryData["price"]["package_value"];
          calc.packagesys = enquiryData["price"]["package_sys"];
          calc.subTotal = enquiryData["price"]["sub_total"];
          calc.total = enquiryData["price"]["total"];
          calc.netratedTotal = enquiryData["price"]["netrated_total"];
          calc.discountedTotal = enquiryData["price"]["discounted_total"];
          calc.netPlusDisTotal = enquiryData["price"]["net_plus_dis_total"];
          calc.discounts = enquiryData["price"]["discounts"];

          CustomerDataModel? customer = CustomerDataModel();
          if (enquiryData["customer"] != null) {
            customer.docID = enquiryData["customer"]["customer_id"];
            customer.address = enquiryData["customer"]["address"];
            customer.state = enquiryData["customer"]["state"];
            customer.city = enquiryData["customer"]["city"];
            customer.customerName = enquiryData["customer"]["customer_name"];
            customer.email = enquiryData["customer"]["email"];
            customer.mobileNo = enquiryData["customer"]["mobile_no"];
          }

          List<ProductDataModel> tmpProducts = [];

          setState(() {
            tmpProducts.clear();
          });

          await FireStore()
              .getEnquiryProducts(docid: enquiryData.id)
              .then((products) {
            if (products != null && products.docs.isNotEmpty) {
              for (var product in products.docs) {
                var productDataModel = ProductDataModel();
                productDataModel.categoryid = product["category_id"];
                productDataModel.categoryName = product["category_name"];
                productDataModel.price = product["price"];

                productDataModel.productId = product["product_id"];
                productDataModel.productName = product["product_name"];
                productDataModel.qty = product["qty"];
                productDataModel.productCode = product["product_code"] ?? "";
                productDataModel.discountLock = product["discount_lock"];
                productDataModel.docid = product.id;
                productDataModel.name = product["name"];
                productDataModel.productContent = product["product_content"];
                productDataModel.productImg = product["product_img"];
                productDataModel.qrCode = product["qr_code"];
                productDataModel.productType =
                    product["discount_lock"] || product["discount"] == null
                        ? ProductType.netRated
                        : ProductType.discounted;
                if (productDataModel.productType == ProductType.discounted) {
                  productDataModel.discountedPrice =
                      double.parse(product["price"].toString()) -
                          (double.parse(product["price"].toString()) *
                              product["discount"] /
                              100);
                } else {
                  productDataModel.discountedPrice =
                      double.parse(product["price"].toString());
                }
              }
            }
          });

          setState(() {
            enquiryList.add(
              EstimateDataModel(
                docID: enquiryData.id,
                createddate: DateTime.parse(
                  enquiryData["created_date"].toDate().toString(),
                ),
                enquiryid: enquiryData['enquiry_id'],
                estimateid: enquiryData["estimate_id"],
                price: calc,
                customer: customer,
                products: tmpProducts,
                dataType: DataTypes.cloud,
              ),
            );
          });
        }
      } else {
        setState(() {
          isLoad = false;
          endOfDocument = true;
        });
      }
    }
    setState(() {
      isLoad = false;
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      floatingActionButton: floatingButtons(context),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Consumer<ConnectionProvider>(
          builder: (context, connectionProvider, child) {
            return RefreshIndicator(
              color: Theme.of(context).primaryColor,
              onRefresh: () async {
                setState(() {
                  if (connectionProvider.isConnected) {
                    enquiryHandler = getEnquiryInfo();
                  } else {
                    enquiryHandler = getOfflineEnquiryInfo();
                  }
                });
              },
              child: ListView(
                padding: const EdgeInsets.all(8),
                controller: _scrollController,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Overall Bill Total",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "($totalBills Bills)",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "\u{20B9}${overallTotal ?? 0}",
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder(
                      future: enquiryHandler,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return futureLoading(context);
                        } else if (snapshot.hasError) {
                          return errorDisplay(snapshot);
                        } else {
                          return enquiryList.isNotEmpty
                              ? ListView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  itemCount: enquiryList.length,
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemBuilder: (context, index) {
                                    if (enquiryList[index].enquiryid == null) {
                                      return const SizedBox();
                                    } else {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    EnquiryDetails(
                                                  cid: enquiryList[index]
                                                          .docID ??
                                                      enquiryList[index]
                                                          .referenceId ??
                                                      '',
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value != null &&
                                                  value == true) {
                                                setState(() {
                                                  if (connectionProvider
                                                      .isConnected) {
                                                    enquiryHandler =
                                                        getEnquiryInfo();
                                                  } else {
                                                    enquiryHandler =
                                                        getOfflineEnquiryInfo();
                                                  }
                                                });
                                              }
                                            });
                                            // crtlistview =
                                            //     orderlist[index];
                                          });
                                        },
                                        onLongPress: () {
                                          billOptions(
                                              enquiryList[index].enquiryid !=
                                                      null
                                                  ? enquiryList[index]
                                                      .enquiryid!
                                                  : enquiryList[index]
                                                              .referenceId !=
                                                          null
                                                      ? enquiryList[index]
                                                          .referenceId!
                                                      : "Choose an option",
                                              index);
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 18,
                                                        width: 18,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade300,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "${index + 1}",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        connectionProvider
                                                                .isConnected
                                                            ? enquiryList[index]
                                                                    .enquiryid ??
                                                                ''
                                                            : enquiryList[index]
                                                                    .referenceId ??
                                                                "",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(enquiryList[
                                                                    index]
                                                                .createddate ??
                                                            DateTime.now()),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: 10),
                                                        if (enquiryList[index]
                                                                    .customer !=
                                                                null &&
                                                            enquiryList[index]
                                                                    .customer!
                                                                    .customerName !=
                                                                null &&
                                                            enquiryList[index]
                                                                .customer!
                                                                .customerName!
                                                                .isNotEmpty)
                                                          Text(
                                                            "${enquiryList[index].customer!.customerName}",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleLarge!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          )
                                                        else
                                                          Text(
                                                            "Counter Sales",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleLarge!
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                        const SizedBox(
                                                            height: 5),
                                                        if (enquiryList[index]
                                                                    .customer
                                                                    ?.city !=
                                                                null ||
                                                            enquiryList[index]
                                                                    .customer
                                                                    ?.mobileNo !=
                                                                null)
                                                          Row(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                      Iconsax
                                                                          .location,
                                                                      size: 10),
                                                                  Text(
                                                                    enquiryList[index]
                                                                            .customer
                                                                            ?.city ??
                                                                        "",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall,
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const Icon(
                                                                      Iconsax
                                                                          .call,
                                                                      size: 10),
                                                                  Text(
                                                                    enquiryList[index]
                                                                            .customer
                                                                            ?.mobileNo ??
                                                                        "",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Iconsax
                                                                    .calendar,
                                                                size: 10),
                                                            Text(
                                                              DateFormat(
                                                                      'dd-MM-yyyy hh:mm a')
                                                                  .format(enquiryList[
                                                                              index]
                                                                          .createddate ??
                                                                      DateTime
                                                                          .now()),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "\u{20B9}${enquiryList[index].price?.total?.toStringAsFixed(2) ?? ""}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                )
                              : noData(context);
                        }
                      }),
                  // FutureBuilder(
                  //   future: enquiryHandler,
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return futureLoading(context);
                  //     } else if (snapshot.hasError) {
                  //       return errorDisplay(snapshot);
                  //     } else {
                  //       return enquiryList.isNotEmpty
                  //           ? ListView.builder(
                  //               primary: false,
                  //               shrinkWrap: true,
                  //               padding: const EdgeInsets.only(bottom: 20),
                  //               itemCount: enquiryList.length,
                  //               itemBuilder: (context, index) {
                  //                 return GestureDetector(
                  //                   child: Container(
                  //                     padding: const EdgeInsets.all(10),
                  //                     decoration: BoxDecoration(
                  //                       color: Colors.white,
                  //                       border: index > 0
                  //                           ? const Border(
                  //                               top: BorderSide(
                  //                                 width: 0.5,
                  //                                 color: Color(0xffE0E0E0),
                  //                               ),
                  //                             )
                  //                           : null,
                  //                     ),
                  //                     child: Row(
                  //                       children: [
                  //                         Container(
                  //                           height: 40,
                  //                           width: 40,
                  //                           decoration: BoxDecoration(
                  //                             color: Colors.grey.shade300,
                  //                             shape: BoxShape.circle,
                  //                           ),
                  //                           child: Center(
                  //                             child: Text(
                  //                               "${index + 1}",
                  //                               style: const TextStyle(
                  //                                 color: Colors.grey,
                  //                                 fontSize: 15,
                  //                                 fontWeight: FontWeight.bold,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                         const SizedBox(
                  //                           width: 10,
                  //                         ),
                  //                         Expanded(
                  //                           child: Column(
                  //                             mainAxisSize: MainAxisSize.min,
                  //                             crossAxisAlignment:
                  //                                 CrossAxisAlignment.start,
                  //                             children: [
                  //                               RichText(
                  //                                 text: TextSpan(
                  //                                   children: [
                  //                                     const TextSpan(
                  //                                       text: "ORDERID - ",
                  //                                       style: TextStyle(
                  //                                         fontWeight:
                  //                                             FontWeight.bold,
                  //                                         color: Colors.black,
                  //                                       ),
                  //                                     ),
                  //                                     TextSpan(
                  //                                       text: ,
                  //                                       style: TextStyle(
                  //                                         fontWeight:
                  //                                             FontWeight.bold,
                  //                                         color: enquiryList[
                  //                                                         index]
                  //                                                     .enquiryid ==
                  //                                                 null
                  //                                             ? Colors.red
                  //                                             : Colors.black,
                  //                                       ),
                  //                                     ),
                  //                                   ],
                  //                                 ),
                  //                               ),
                  //                               const SizedBox(
                  //                                 height: 3,
                  //                               ),
                  //                               RichText(
                  //                                 textAlign: TextAlign.center,
                  //                                 text: TextSpan(
                  //                                   text: "CUSTOMER - ",
                  //                                   style: const TextStyle(
                  //                                     color: Colors.black87,
                  //                                     fontSize: 13,
                  //                                   ),
                  //                                   children: [
                  //                                     const TextSpan(
                  //                                       text:
                  //                                           "",
                  //                                       style: TextStyle(
                  //                                         color: Colors.black,
                  //                                         fontWeight:
                  //                                             FontWeight.bold,
                  //                                       ),
                  //                                     ),
                  //                                     if (enquiryList[index]
                  //                                                 .customer!
                  //                                                 .customerName !=
                  //                                             null &&
                  //                                         enquiryList[index]
                  //                                             .customer!
                  //                                             .customerName!
                  //                                             .isEmpty)
                  //                                       TextSpan(
                  //                                         text: enquiryList[
                  //                                                     index]
                  //                                                 .customer!
                  //                                                 .mobileNo ??
                  //                                             '',
                  //                                         style:
                  //                                             const TextStyle(
                  //                                           fontSize: 13,
                  //                                           fontWeight:
                  //                                               FontWeight.bold,
                  //                                         ),
                  //                                       )
                  //                                   ],
                  //                                 ),
                  //                               ),
                  //                               Text(
                  //                                 "DATE - ${DateFormat('dd-MM-yyyy hh:mm a').format(enquiryList[index].createddate!)}",
                  //                                 style: const TextStyle(
                  //                                   fontSize: 13,
                  //                                 ),
                  //                               ),
                  //                             ],
                  //                           ),
                  //                         ),
                  //                         Center(
                  //                           child: Text(
                  //                             "Rs.${enquiryList[index].price!.total}",
                  //                           ),
                  //                         ),
                  //                         Container(
                  //                           padding: const EdgeInsets.all(10),
                  //                           child: const Center(
                  //                             child: Icon(
                  //                               Icons.arrow_forward_ios,
                  //                               size: 18,
                  //                               color: Color(0xff6B6B6B),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 );
                  //               },
                  //             )
                  //           : noData(context);
                  //     }
                  //   },
                  // ),

                  Visibility(
                    visible: isLoad,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: endOfDocument,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop_rounded, color: Colors.red.shade300),
                        Text("End of Document",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Colors.red.shade300,
                                    fontWeight: FontWeight.bold))
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
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
                    enquiryHandler = getEnquiryInfo();
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

  Padding noData(BuildContext context) {
    return Padding(
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
            "No Enquiry",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              "You have not create any enquiry, so first you have create enquiry",
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
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     TextButton.icon(
          //       onPressed: () async {
          //         await LocalDB
          //             .getBillingIndex()
          //             .then((value) async {
          //           if (value != null) {
          //             Navigator.push(
          //               context,
          //               CupertinoPageRoute(builder: (context) {
          //                 if (value == 1) {
          //                   return const BillingOne(
          //                     isEdit: true,
          //                     enquiryData: null,
          //                   );
          //                 } else {
          //                   return const BillingTwo(
          //                     isEdit: true,
          //                     enquiryData: null,
          //                   );
          //                 }
          //               }),
          //             );
          //           }
          //         });
          //       },
          //       icon: const Icon(Icons.add),
          //       label: const Text("Add Enquiry"),
          //     ),
          //     TextButton.icon(
          //       onPressed: () {
          //         setState(() {
          //           enquiryHandler = getEnquiryInfo();
          //         });
          //       },
          //       icon: const Icon(Icons.refresh),
          //       label: const Text("Refresh"),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  FloatingActionButton floatingButtons(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () {
        billFilters();
      },
      child: const Icon(Icons.filter_list_outlined),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Enquiry"),
      actions: [
        IconButton(
          tooltip: "Add Enquiry",
          onPressed: () async {
            Navigator.pop(context);
            await LocalDB.getBillingIndex().then((value) async {
              if (value != null) {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) {
                    if (value == 1) {
                      return const BillingOne();
                    } else {
                      return const BillingTwo();
                    }
                  }),
                );
              }
            });
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final connectionProvider =
                  Provider.of<ConnectionProvider>(context, listen: false);
              if (connectionProvider.isConnected) {
                AccountValid.accountValid(context);

                enquiryHandler = getEnquiryInfo();
              } else {
                enquiryHandler = getOfflineEnquiryInfo();
              }
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final connectionProvider =
                  Provider.of<ConnectionProvider>(context, listen: false);
              connectionProvider.addListener(() {
                if (connectionProvider.isConnected) {
                  AccountValid.accountValid(context);

                  enquiryHandler = getEnquiryInfo();
                } else {
                  enquiryHandler = getOfflineEnquiryInfo();
                }
              });
            });
          },
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: "Download Excel File",
          onPressed: () {
            downloadExcelData();
          },
          icon: const Icon(Icons.file_download_outlined),
        ),
      ],
    );
  }

  var companyData = ProfileModel();
  int start = 0, end = 10, totalBills = 0;
  List<DropdownMenuItem> noofpage = [];
  String selectedPageLimit = "10";
  List<DropdownMenuItem> pagelimit = const [
    DropdownMenuItem(
      value: "10",
      child: Text("10"),
    ),
    DropdownMenuItem(
      value: "25",
      child: Text("25"),
    ),
    DropdownMenuItem(
      value: "50",
      child: Text("50"),
    ),
    DropdownMenuItem(
      value: "100",
      child: Text("100"),
    ),
  ];

  billOptions(String title, int index) async {
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
          heightFactor: 0.4,
          child: BillOptions(
            title: title,
            billType: BillType.enquiry,
            enquiry: enquiryList[index],
          ),
        );
      },
    );
  }

  billFilters() async {
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
          child: BillingFilters(),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          enquiryHandler = filter(value);
        });
      }
    });
  }
}
