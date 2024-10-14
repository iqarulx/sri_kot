import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Future<void> getEnquiryTotal() async {
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

  Future<void> getOfflineTotal() async {
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
      });

      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

      if (cid != null) {
        start = currentPage * int.parse(selectedPageLimit);
        end = start + int.parse(selectedPageLimit);

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

                  setState(() {
                    tmpProducts.add(productDataModel);
                  });
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

      start = currentPage * int.parse(selectedPageLimit);
      end = start + int.parse(selectedPageLimit);

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

  searchEnquiryFun() async {
    if (searchForm.text.isNotEmpty) {
      setState(() {
        enquiryList.clear();
        tmpEnquiryList.clear();
      });

      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

      if (cid != null) {
        var enquiry = await FireStore().getAllEnquiry(cid: cid);
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
                  productDataModel.videoUrl = product["video_url"];
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
        } else if (element.enquiryid != null &&
            element.enquiryid!.toLowerCase().replaceAll(' ', '').startsWith(
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

  filtersEnquiryFun(
    DateTime? fromDate,
    DateTime? toDate,
    String? customerID,
  ) async {
    setState(() {
      enquiryList.clear();
      tmpEnquiryList.clear();
    });
    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

    if (cid != null) {
      var enquiry = await FireStore().getAllEnquiry(cid: cid);
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
                productDataModel.videoUrl = product["video_url"];
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
    }

    // Filter the list based on the provided inputs.
    Iterable<EstimateDataModel> tmpList = tmpEnquiryList.where((element) {
      final createdDate = element.createddate!;

      // Check each condition independently.
      bool matchesCustomer =
          customerID == null || element.customer!.docID == customerID;
      bool matchesFromDate = fromDate == null || createdDate.isAfter(fromDate);
      bool matchesToDate = toDate == null || createdDate.isBefore(toDate);

      // Return true if any of the conditions are met.
      return matchesCustomer && matchesFromDate && matchesToDate;
    });

    if (tmpList.isNotEmpty) {
      setState(() {
        searchApplied = true;
        enquiryList.clear();
        enquiryList.addAll(tmpList);
      });
    } else {
      showToast(context,
          content: "No records found", isSuccess: false, top: false);
    }
  }

  filtersEnquiryFunOffline(
    DateTime? fromDate,
    DateTime? toDate,
    String? customerID,
  ) async {
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
        var customerData = jsonDecode(data['customer']) as Map<String, dynamic>;
        customer.docID = customerData["customer_id"] ?? "";
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

    // Filter the list based on the provided inputs.
    Iterable<EstimateDataModel> tmpList = tmpEnquiryList.where((element) {
      final createdDate = element.createddate!;

      // Check each condition independently.
      bool matchesCustomer =
          customerID == null || element.customer!.docID == customerID;
      bool matchesFromDate = fromDate == null || createdDate.isAfter(fromDate);
      bool matchesToDate = toDate == null || createdDate.isBefore(toDate);

      // Return true if any of the conditions are met.
      return matchesCustomer && matchesFromDate && matchesToDate;
    });

    if (tmpList.isNotEmpty) {
      setState(() {
        searchApplied = true;
        enquiryList.clear();
        enquiryList.addAll(tmpList);
      });
    } else {
      showToast(context,
          content: "No records found", isSuccess: false, top: false);
    }
  }

  bool searchApplied = false;
  String? selectedText;

  showFilterSheet() async {
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return const EnquiryFilter();
      },
    ).then((result) {
      if (result != null) {
        final connectionProvider =
            Provider.of<ConnectionProvider>(context, listen: false);
        if (connectionProvider.isConnected) {
          filtersEnquiryFun(
            result["FromDate"],
            result["ToDate"],
            result["CustomerID"],
          );
        } else {
          filtersEnquiryFunOffline(
            result["FromDate"],
            result["ToDate"],
            result["CustomerID"],
          );
        }
      }
    });
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
  }

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
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          right: 10,
                          left: 10,
                          bottom: 10,
                        ),
                        child: TextFormField(
                          controller: searchForm,
                          cursorColor: Theme.of(context).primaryColor,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => {
                            if (searchForm.text.isNotEmpty)
                              {
                                setState(() {
                                  searchTriggred = true;
                                })
                              }
                            else
                              {
                                setState(() {
                                  searchTriggred = false;
                                })
                              }
                          },
                          decoration: InputDecoration(
                            hintText: "Search",
                            filled: true,
                            fillColor: const Color(0xfff1f5f9),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: searchTriggred
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            searchForm.text = "";
                                            searchTriggred = false;
                                            FocusManager.instance.primaryFocus!
                                                .unfocus();
                                          });
                                          if (connectionProvider.isConnected) {
                                            setState(() {
                                              enquiryHandler = getEnquiryInfo();
                                            });
                                          } else {
                                            setState(() {
                                              enquiryHandler =
                                                  getOfflineEnquiryInfo();
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          color: Colors.red,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (connectionProvider.isConnected) {
                                            setState(() {
                                              enquiryHandler =
                                                  searchEnquiryFun();
                                              FocusManager
                                                  .instance.primaryFocus!
                                                  .unfocus();
                                            });
                                          } else {
                                            setState(() {
                                              enquiryHandler =
                                                  searchEnquiryFunOffline();
                                              FocusManager
                                                  .instance.primaryFocus!
                                                  .unfocus();
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.search_rounded),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 0,
                                left: 10,
                                bottom: 5,
                              ),
                              child: DropdownButtonFormField(
                                value: selectedPageLimit,
                                isExpanded: true,
                                items: pagelimit,
                                onChanged: (value) {
                                  setState(() {
                                    setState(() {
                                      selectedPageLimit = value;
                                      currentPage = 0;
                                    });
                                  });
                                  if (connectionProvider.isConnected) {
                                    setState(() {
                                      getEnquiryTotal();
                                      enquiryHandler = getEnquiryInfo();
                                    });
                                  } else {
                                    setState(() {
                                      enquiryHandler = getOfflineEnquiryInfo();
                                      getOfflineTotal();
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  labelText: "Limit",
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 0,
                                right: 10,
                                bottom: 5,
                              ),
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                items: noofpage,
                                value: currentPage != 0 ? currentPage : null,
                                onChanged: (value) {
                                  setState(() {
                                    currentPage = value;
                                  });
                                  if (connectionProvider.isConnected) {
                                    setState(() {
                                      enquiryHandler = getEnquiryInfo();
                                    });
                                  } else {
                                    setState(() {
                                      enquiryHandler = getOfflineEnquiryInfo();
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  labelText: "Page",
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      body(connectionProvider)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  FutureBuilder<dynamic> body(ConnectionProvider connectionProvider) {
    return FutureBuilder(
      future: enquiryHandler,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return futureLoading(context);
        } else if (snapshot.hasError) {
          return errorDisplay(snapshot);
        } else {
          return enquiryList.isNotEmpty
              ? Expanded(
                  child: RefreshIndicator(
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
                      children: [
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 70),
                          itemCount: enquiryList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // if (enquiryList[index].dataType == DataTypes.cloud) {
                                setState(() {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => EnquiryDetails(
                                        cid: enquiryList[index].docID ??
                                            enquiryList[index].referenceId ??
                                            '',
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value != null && value == true) {
                                      setState(() {
                                        if (connectionProvider.isConnected) {
                                          enquiryHandler = getEnquiryInfo();
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
                                // } else {
                                // snackbar(context, false,
                                // "Please upload the data to view details");
                                // }
                              },
                              onLongPress: () {
                                billOptions(
                                    enquiryList[index].enquiryid != null
                                        ? enquiryList[index].enquiryid!
                                        : enquiryList[index].referenceId != null
                                            ? enquiryList[index].referenceId!
                                            : "Choose an option",
                                    index);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${enquiryList.length - index}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                const TextSpan(
                                                  text: "ORDERID - ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: connectionProvider
                                                          .isConnected
                                                      ? enquiryList[index]
                                                          .enquiryid
                                                      : enquiryList[index]
                                                              .referenceId ??
                                                          "",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: enquiryList[index]
                                                                .enquiryid ==
                                                            null
                                                        ? Colors.red
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              text: "CUSTOMER - ",
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 13,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "${enquiryList[index].customer != null && enquiryList[index].customer!.customerName != null ? enquiryList[index].customer!.customerName : "Counter Sales"}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (enquiryList[index]
                                                            .customer!
                                                            .customerName !=
                                                        null &&
                                                    enquiryList[index]
                                                        .customer!
                                                        .customerName!
                                                        .isEmpty)
                                                  TextSpan(
                                                    text: enquiryList[index]
                                                            .customer!
                                                            .mobileNo ??
                                                        '',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                          Text(
                                            "DATE - ${DateFormat('dd-MM-yyyy hh:mm a').format(enquiryList[index].createddate!)}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "Rs.${enquiryList[index].price!.total}",
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Center(
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 18,
                                          color: Color(0xff6B6B6B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Visibility(
                            visible: searchApplied,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        searchApplied = false;

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final connectionProvider =
                                              Provider.of<ConnectionProvider>(
                                                  context,
                                                  listen: false);
                                          if (connectionProvider.isConnected) {
                                            AccountValid.accountValid(context);

                                            enquiryHandler = getEnquiryInfo();
                                          } else {
                                            enquiryHandler =
                                                getOfflineEnquiryInfo();
                                          }
                                        });

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          final connectionProvider =
                                              Provider.of<ConnectionProvider>(
                                                  context,
                                                  listen: false);
                                          connectionProvider.addListener(() {
                                            if (connectionProvider
                                                .isConnected) {
                                              AccountValid.accountValid(
                                                  context);

                                              enquiryHandler = getEnquiryInfo();
                                            } else {
                                              enquiryHandler =
                                                  getOfflineEnquiryInfo();
                                            }
                                          });
                                        });
                                      });
                                    },
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.clear_rounded),
                                        SizedBox(width: 5),
                                        Text('Exit search'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                )
              : noData(context);
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
    return FloatingActionButton.extended(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () async {
        await showFilterSheet();
      },
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list_outlined),
          SizedBox(
            width: 10,
          ),
          Text("Filter"),
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
  int start = 0, end = 10, currentPage = 0, totalBills = 0;
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
}
