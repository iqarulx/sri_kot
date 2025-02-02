import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../../../gen/assets.gen.dart';
import '/model/model.dart';
import '/provider/provider.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';
import '/constants/constants.dart';
import '/provider/src/file_open.dart' as helper;

class CustomerEstimate extends StatefulWidget {
  final String? customerID;
  const CustomerEstimate({super.key, required this.customerID});

  @override
  State<CustomerEstimate> createState() => _CustomerEstimateState();
}

class _CustomerEstimateState extends State<CustomerEstimate> {
  List<EstimateDataModel> enquiryList = [];
  TextEditingController searchForm = TextEditingController();
  bool tmpLoading = false;
  Future getEnquiryInfo() async {
    try {
      setState(() {
        tmpLoading = true;
        enquiryList.clear();
      });
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        var enquiry = await FireStore()
            .getEstimateCustomer(cid: cid, customerID: widget.customerID!);
        if (enquiry != null && enquiry.docs.isNotEmpty) {
          for (var enquiryData in enquiry.docs) {
            var calcula = BillingCalCulationModel();
            calcula.discountValue = enquiryData["price"]["discount_value"];
            calcula.extraDiscount = enquiryData["price"]["extra_discount"];
            calcula.extraDiscountValue =
                enquiryData["price"]["extra_discount_value"];
            calcula.extraDiscountsys =
                enquiryData["price"]["extra_discount_sys"];
            calcula.package = enquiryData["price"]["package"];
            calcula.packageValue = enquiryData["price"]["package_value"];
            calcula.packagesys = enquiryData["price"]["package_sys"];
            calcula.subTotal = enquiryData["price"]["sub_total"];
            calcula.total = enquiryData["price"]["total"];

            var customer = CustomerDataModel();
            if (enquiryData["customer"] != null) {
              customer.address = enquiryData["customer"]["address"].toString();
              customer.state = enquiryData["customer"]["state"].toString();
              customer.city = enquiryData["customer"]["city"].toString();
              customer.customerName =
                  enquiryData["customer"]["customer_name"].toString();
              customer.email = enquiryData["customer"]["email"].toString();
              customer.mobileNo =
                  enquiryData["customer"]["mobile_no"].toString();
            }

            List<ProductDataModel> tmpProducts = [];

            setState(() {
              tmpProducts.clear();
            });

            // await FireStore()
            //     .getEstimateProducts(docid: enquiryData.id)
            //     .then((products) {
            //   if (products != null && products.docs.isNotEmpty) {
            //     for (var product in products.docs) {
            //       var productDataModel = ProductDataModel();
            //       productDataModel.categoryid = product["category_id"];
            //       productDataModel.categoryName = product["category_name"];
            //       productDataModel.price = product["price"];
            //       productDataModel.productId = product["product_id"];
            //       productDataModel.productName = product["product_name"];
            //       productDataModel.qty = product["qty"];
            //       productDataModel.productCode = product["product_code"];

            //       setState(() {
            //         tmpProducts.add(productDataModel);
            //       });
            //     }
            //   }
            // });

            setState(() {
              enquiryList.add(
                EstimateDataModel(
                  docID: enquiryData.id,
                  createddate: DateTime.parse(
                    enquiryData["created_date"].toDate().toString(),
                  ),
                  enquiryid: null,
                  estimateid: enquiryData["estimate_id"],
                  price: calcula,
                  customer: customer,
                  products: tmpProducts,
                ),
              );
            });
          }
        }
        setState(() {
          tmpLoading = false;
        });
        return enquiry;
      }
    } catch (e) {
      setState(() {
        tmpLoading = false;
      });
      snackbar(context, false, e.toString());
      return null;
    }
  }

  downloadExcelData() async {
    try {
      loading(context);
      await EnquiryExcel(enquiryData: enquiryList, isEstimate: true)
          .createCustomerExcel()
          .then((value) async {
        if (value != null) {
          Uint8List fileData = Uint8List.fromList(value);
          Navigator.pop(context);
          await helper.saveAndLaunchFile(fileData, 'Customer Estimate.xlsx');
        } else {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  late Future enquiryHandler;

  @override
  void initState() {
    super.initState();
    enquiryHandler = getEnquiryInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: enquiryList.isNotEmpty && tmpLoading == false
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: () {
                downloadExcelData();
              },
              label: const Text("Download"),
              icon: const Icon(Icons.file_download_outlined),
            )
          : null,
      body: FutureBuilder(
        future: enquiryHandler,
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
          } else {
            return enquiryList.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
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
                            padding: const EdgeInsets.only(
                              top: 10,
                              right: 10,
                              left: 10,
                              bottom: 5,
                            ),
                            child: InputForm(
                              controller: searchForm,
                              formName: "Search Estimate",
                              prefixIcon: Icons.search,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: enquiryList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => EstimateDetails(
                                            cid: enquiryList[index].docID ?? '',
                                          ),
                                        ),
                                      );
                                      // crtlistview =
                                      //     orderlist[index];
                                    });
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
                                          child: const Center(
                                            child: Icon(
                                              Icons.shopping_cart,
                                              color: Colors.grey,
                                              size: 20,
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
                                              Text(
                                                "ESTIMATE ID - ${enquiryList[index].estimateid}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "CUSTOMER - ${enquiryList[index].customer != null && enquiryList[index].customer!.customerName != null ? enquiryList[index].customer!.customerName : ""}",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                "DATE - ${DateFormat('dd-MM-yyyy HH:mm a').format(enquiryList[index].createddate!)}",
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
                          )
                        ],
                      ),
                    ),
                  )
                : noData(context);
          }
        },
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
            "No estimate",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(),
          ),
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Text(
              "Customer does not exist with any estimate",
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
        ],
      ),
    );
  }
}
