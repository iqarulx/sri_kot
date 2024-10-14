import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/view/ui/src/pdf_alignment_modal.dart';
import '/view/ui/src/product_code_modal.dart';
import '/utils/src/utilities.dart';
import '/view/ui/ui.dart';
import '/provider/provider.dart';
import '/gen/assets.gen.dart';
import '/services/services.dart';
import '/constants/constants.dart';

class AppSettings extends StatefulWidget {
  final bool isAdmin, isHome;
  const AppSettings({super.key, required this.isAdmin, required this.isHome});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  int crtBillingTab = 1;
  String? lastSynced;
  bool? invoicePrevBill;
  String enquiryCount = "0";
  String estimateCount = "0";

  Future initFn() async {
    await LocalDB.getBillingIndex().then((value) async {
      if (value != null) {
        setState(() {
          crtBillingTab = value;
        });
      } else {
        await LocalDB.changeBilling(1);
        setState(() {
          crtBillingTab = 1;
        });
      }
    });

    var helper = DatabaseHelper();
    var dbEnquiryCount = await helper.countEnquiries();
    var dbEstimateCount = await helper.countEstimate();
    setState(() {
      estimateCount = dbEstimateCount.toString();
      enquiryCount = dbEnquiryCount.toString();
    });

    await LocalDB.getLastSync().then((value) async {
      if (value != null) {
        lastSynced = await LocalService.parseDate(value);
      }
    });

    await LocalDB.getPdfType().then((value) async {
      setState(() {
        invoicePrevBill = value ?? false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initHandler = initFn();
  }

  Future? initHandler;

  syncNow() async {
    loading(context);
    final connectionProvider =
        Provider.of<ConnectionProvider>(context, listen: false);
    if (connectionProvider.isConnected) {
      FireStore firebase = FireStore();
      await firebase
          .productListing(
              cid: await LocalDB.fetchInfo(type: LocalData.companyid))
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          LocalService.syncProducts(
            productData: value.docs,
            cid: await LocalDB.fetchInfo(type: LocalData.companyid),
          );
        }
      });

      await firebase
          .categoryListing(
              cid: await LocalDB.fetchInfo(type: LocalData.companyid))
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          LocalService.syncCategory(
            categoryData: value.docs,
            cid: await LocalDB.fetchInfo(
              type: LocalData.companyid,
            ),
          );
        }
      });

      await firebase.customerListing().then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          LocalService.syncCustomer(
            customerData: value.docs,
            cid: await LocalDB.fetchInfo(type: LocalData.companyid),
          );
        }
      });

      Navigator.pop(context);
      await LocalDB.setLastSync().then((value) {
        snackbar(context, true, "Successfully data synced");
        initFn();
      });
    } else {
      Navigator.pop(context);
      snackbar(context, false, "You need internet to sync your data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECECEC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            if (widget.isHome) {
              Navigator.pop(context, true);
            } else {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text("App Settings"),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.pop(context, true);
          }
        },
        child: FutureBuilder(
          future: initHandler,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  setState(() {
                    initHandler = initFn();
                  });
                },
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Billing Page",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        crtBillingTab = 1;
                                        LocalDB.changeBilling(1);
                                      });
                                    },
                                    child: Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: crtBillingTab == 1
                                            ? Colors.grey.shade100
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Center(
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: Assets.billing2.image(
                                                    height: 240,
                                                    fit: BoxFit.contain,
                                                  )),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                color: crtBillingTab == 1
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: crtBillingTab == 1
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        crtBillingTab = 2;
                                        LocalDB.changeBilling(2);
                                      });
                                    },
                                    child: Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: crtBillingTab == 2
                                            ? Colors.grey.shade100
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Assets.billing1.image(
                                                  height: 240,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                color: crtBillingTab == 2
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: crtBillingTab == 2
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: widget.isAdmin,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (builder) {
                                  return const HsnModal();
                                },
                              ).then((value) {
                                if (value != null) {
                                  if (value) {
                                    snackbar(context, true, "HSN Updated");
                                  }
                                }
                              });
                            },
                            child: Container(
                              height: 70,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.square,
                                          size: 25,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "HSN Update",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(CupertinoIcons.forward),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (estimateCount != "0" || enquiryCount != "0") {
                          confirmationDialog(context,
                                  title: "Upload offline bills",
                                  message:
                                      "You need a strong internet connection to upload bills")
                              .then((value) async {
                            if (value != null) {
                              if (value) {
                                loading(context);
                                await LocalService.syncNow().then((value) {
                                  Navigator.pop(context);
                                  if (value) {
                                    snackbar(context, true,
                                        "Successfully bills are uploaded");
                                  } else {
                                    snackbar(
                                        context, false, "An error occured");
                                  }
                                });
                              }
                            }
                          });
                        } else {
                          snackbar(context, false,
                              "No bills are available to upload");
                        }
                      },
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.cloud_upload,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Upload Local Bills",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "Estimate - $estimateCount, Enquiry - $enquiryCount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(CupertinoIcons.forward),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        syncNow();
                      },
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.arrow_3_trianglepath,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Sync Now",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          "Last Sync : ${lastSynced ?? '--:--:--'}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(CupertinoIcons.forward),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: widget.isAdmin,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (builder) {
                                  return InvoicePrevBillModal(
                                      value: invoicePrevBill);
                                },
                              ).then((value) {
                                if (value != null) {
                                  if (value) {
                                    snackbar(context, true,
                                        "Invoice Prev Bill Updated");
                                    initFn();
                                  }
                                }
                              });
                            },
                            child: Container(
                              height: 70,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.doc,
                                          size: 25,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Invoice Prev Bill Display",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(CupertinoIcons.forward),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        var alignment = await LocalDB.getPdfAlignment();
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return PdfAlignmentModal(pdfAlignment: alignment);
                            }).then((value) async {
                          if (value != null) {
                            if (value == "1") {
                              await LocalDB.setPdfAlignment(1);
                              snackbar(context, true, "Pdf Alignment Updated");
                            } else if (value == "2") {
                              await LocalDB.setPdfAlignment(2);
                              snackbar(context, true, "Pdf Alignment Updated");
                            } else if (value == "3") {
                              await LocalDB.setPdfAlignment(3);
                              snackbar(context, true, "Pdf Alignment Updated");
                            }
                          }
                        });
                      },
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.doc_text,
                                    size: 28,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Pdf Alignment",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(CupertinoIcons.forward),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var pdfCodeDisplay =
                            await LocalDB.getProductCodeDisplay();
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return ProductCodeModal(value: pdfCodeDisplay);
                            }).then((value) async {
                          if (value != null) {
                            if (value) {
                              snackbar(context, true,
                                  "Product Code Display Updated");
                            }
                          }
                        });
                      },
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.doc_checkmark,
                                    size: 28,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Product Code Display",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(CupertinoIcons.forward),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: widget.isAdmin,
                      child: GestureDetector(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return const Modal(
                                title: "Clear Bill Records",
                                content:
                                    "This action clear all your records of enquiry, estimate, invoice. Are you sure want to delete it?",
                                type: ModalType.danger,
                              );
                            },
                          ).then((value) async {
                            if (value != null) {
                              if (value) {
                                loading(context);
                                await FireStore()
                                    .clearBillRecords()
                                    .then((value) {
                                  Navigator.pop(context);
                                  if (value) {
                                    snackbar(
                                        context, true, "All bills cleared");
                                  }
                                });
                              }
                            }
                          });
                        },
                        child: Container(
                          height: 70,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.clear_circled,
                                      size: 30,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Clear Bill Records",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                CupertinoIcons.forward,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
