import 'package:flutter/material.dart';
import '/model/model.dart';
import '/utils/src/utilities.dart';
import '/view/ui/src/commonwidget.dart';
import '/services/services.dart';

class DeletedItems extends StatefulWidget {
  const DeletedItems({super.key});

  @override
  State<DeletedItems> createState() => _DeletedItemsState();
}

class _DeletedItemsState extends State<DeletedItems> {
  Future? itemsHanlder;

  List<StaffDataModel> staffList = [];
  List<ProductDataModel> productList = [];
  List<EstimateDataModel> enquiryList = [];
  List<EstimateDataModel> estimateList = [];

  @override
  void initState() {
    itemsHanlder = getDeteledItems();
    super.initState();
  }

  Future getDeteledItems() async {
    try {
      setState(() {
        staffList.clear();
        productList.clear();
        enquiryList.clear();
        estimateList.clear();
      });
      await LocalService.getDeletedItems().then((onvalue) {
        if (onvalue.isNotEmpty) {
          if (onvalue[0].docs.isNotEmpty) {
            for (var data in onvalue[1].docs) {
              StaffDataModel staffDataModel = StaffDataModel();
              staffDataModel.userName = data["staff_name"];
              staffDataModel.phoneNo = data["phone_no"].toString();

              setState(() {
                staffList.add(staffDataModel);
              });
            }
          }
          if (onvalue[1].docs.isNotEmpty) {
            for (var data in onvalue[2].docs) {
              ProductDataModel productDataModel = ProductDataModel();
              productDataModel.name = data["staff_name"];
              productDataModel.productCode = data["phone_no"].toString();

              setState(() {
                productList.add(productDataModel);
              });
            }
          }
          if (onvalue[2].docs.isNotEmpty) {
            for (var data in onvalue[3].docs) {
              EstimateDataModel estimateDataModel = EstimateDataModel();
              estimateDataModel.enquiryid = data["enquiry_id"];
              estimateDataModel.createddate =
                  data["created_date_time"].toDate();

              setState(() {
                enquiryList.add(estimateDataModel);
              });
            }
          }
          if (onvalue[3].docs.isNotEmpty) {
            for (var data in onvalue[4].docs) {
              EstimateDataModel estimateDataModel = EstimateDataModel();
              estimateDataModel.enquiryid = data["estimate_id"];
              estimateDataModel.createddate =
                  data["created_date_time"].toDate();

              setState(() {
                estimateList.add(estimateDataModel);
              });
            }
          }
        }
      });
    } on Exception catch (e) {
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
      child: Scaffold(
        backgroundColor: const Color(0xffEEEEEE),
        appBar: appbar(context),
        body: FutureBuilder(
          future: itemsHanlder,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return futureLoading(context);
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return ListView(
                children: [
                  const Text("Staff"),
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 70),
                    itemCount: staffList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Text(staffList[index].userName ?? ''),
                          Text(staffList[index].phoneNo ?? ''),
                        ],
                      );
                    },
                  ),
                  const Text("Product"),
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 70),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Text(productList[index].name ?? ''),
                          Text(productList[index].productCode ?? ''),
                        ],
                      );
                    },
                  ),
                  const Text("Product"),
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 70),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Text(productList[index].name ?? ''),
                          Text(productList[index].productCode ?? ''),
                        ],
                      );
                    },
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              splashRadius: 20,
              constraints: const BoxConstraints(
                maxWidth: 40,
                maxHeight: 40,
                minWidth: 40,
                minHeight: 40,
              ),
              padding: const EdgeInsets.all(0),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        "Deleted Items",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
