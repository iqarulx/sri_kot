import 'package:flutter/material.dart';

import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';

class CategoryCreate extends StatefulWidget {
  final bool? isEdit;
  final String? categoryName;
  final String? hsnCode;
  final String? taxValue;
  final String? docID;
  const CategoryCreate(
      {super.key,
      this.isEdit,
      this.categoryName,
      this.docID,
      this.hsnCode,
      this.taxValue});

  @override
  State<CategoryCreate> createState() => _CategoryCreateState();
}

class _CategoryCreateState extends State<CategoryCreate> {
  TextEditingController categoryName = TextEditingController();
  TextEditingController hsnCode = TextEditingController();
  String? title;
  String? taxValue;
  bool taxType = false;
  bool commonHsn = false;
  String commonHsnValue = "";

  var addCategoryKey = GlobalKey<FormState>();

  inifun() async {
    await LocalService.getHSN().then((value) {
      if (value.isNotEmpty) {
        commonHsn = value["common_hsn"];
        if (commonHsn) {
          commonHsnValue = value["common_hsn_value"];
          hsnCode.text = commonHsnValue;
        }
      }
    });

    taxType = await FireStore().getCompanyTax();
    if (widget.isEdit != null && widget.isEdit == true) {
      title = "Edit Category";
      categoryName.text = widget.categoryName ?? "";

      if (taxType) {
        hsnCode.text = widget.hsnCode ?? '';
        taxValue = widget.taxValue;
      }
    } else {
      title = "Add New Category";
    }
    setState(() {});
  }

  checkValidation() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (addCategoryKey.currentState!.validate()) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStore()
                .checkCategoryExist(
                    docId: cid,
                    categoryName: categoryName.text
                        .replaceAll(' ', '')
                        .trim()
                        .toLowerCase())
                .then((result) async {
              if (result) {
                var categoryData = CategoryDataModel();

                categoryData.cid = cid;
                categoryData.categoryName = categoryName.text;
                categoryData.name =
                    categoryName.text.replaceAll(' ', '').trim().toLowerCase();
                categoryData.postion = 0;
                categoryData.deleteAt = false;
                categoryData.hsnCode = hsnCode.text;
                categoryData.taxValue = taxValue;

                await FireStore()
                    .getLastPostionCategory(cid: cid)
                    .then((value) {
                  if (value!.docs.isNotEmpty) {
                    categoryData.postion = value.docs.first["postion"] + 1;
                  }
                });
                await FireStore()
                    .registerCategory(categoryData: categoryData)
                    .then((value) {
                  Navigator.pop(context);
                  if (value.id.isNotEmpty) {
                    setState(() {
                      categoryName.clear();
                    });
                    Navigator.pop(context, true);
                    snackbar(
                        context, true, "Successfully Created New Category");
                  } else {
                    snackbar(context, false, "Failed to Create New Category");
                  }
                });
              } else {
                Navigator.pop(context);
                snackbar(context, false, "Category name already exists");
              }
            });
          } else {
            Navigator.pop(context);
            snackbar(context, false, "Company details not fetched");
          }
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  updateCategory() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (addCategoryKey.currentState!.validate()) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            var categoryData = CategoryDataModel();
            categoryData.cid = cid;
            categoryData.categoryName = categoryName.text;
            categoryData.name =
                categoryName.text.replaceAll(' ', '').trim().toLowerCase();
            categoryData.hsnCode = hsnCode.text;
            categoryData.taxValue = taxValue;

            await FireStore()
                .updateCategory(
                    categoryData: categoryData, docID: widget.docID!)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context, true);
              snackbar(context, true, "Category Updated Successfully");
            });
          } else {
            Navigator.pop(context);
            snackbar(context, false, "Company Details Not Fetch");
          }
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  deleteCategory() async {
    loading(context);
    try {
      await FireStore().deleteCategory(docID: widget.docID!).then((value) {
        if (value["success"]) {
          Navigator.pop(context);
          Navigator.pop(context, true);
          snackbar(context, true, value["msg"]);
        } else {
          Navigator.pop(context);
          snackbar(context, false, value["msg"]);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    inifun();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.98,
      initialChildSize: 0.98,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.transparent,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: appbar(context),
              body: body(context),
            ),
          ),
        );
      },
    );
  }

  Column body(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: addCategoryKey,
                  child: Column(
                    children: [
                      InputForm(
                        controller: categoryName,
                        labelName: "Category Name",
                        formName: "Category Name",
                        prefixIcon: Icons.person,
                        validation: (p0) {
                          return FormValidation().commonValidation(
                            input: p0,
                            isMandatory: true,
                            formName: 'Category Name',
                            isOnlyCharter: false,
                          );
                        },
                      ),
                      if (taxType)
                        Column(
                          children: [
                            InputForm(
                              controller: hsnCode,
                              labelName: "HSN Code",
                              formName: "HSN Code",
                              enabled: !commonHsn,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.person,
                              validation: (p0) {
                                return FormValidation().commonValidation(
                                    formName: "HSN Code",
                                    input: p0 ?? '',
                                    isMandatory: true,
                                    isOnlyCharter: false);
                              },
                            ),
                            DropDownForm(
                              formName: "Tax Value",
                              onChange: (v) {
                                if (v != null) {
                                  setState(() {
                                    taxValue = v;
                                  });
                                }
                              },
                              labelName: "Tax Value",
                              value: taxValue,
                              validator: (p0) {
                                if (p0 == null) {
                                  return "Tax Value is must";
                                }
                                return null;
                              },
                              listItems: const [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    "Select tax value",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "0%",
                                  child: Text("0%"),
                                ),
                                DropdownMenuItem(
                                  value: "5%",
                                  child: Text("5%"),
                                ),
                                DropdownMenuItem(
                                  value: "12%",
                                  child: Text("12%"),
                                ),
                                DropdownMenuItem(
                                  value: "18%",
                                  child: Text("18%"),
                                ),
                                DropdownMenuItem(
                                  value: "28%",
                                  child: Text("28%"),
                                ),
                              ],
                            ),
                          ],
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
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: fillButton(
            context,
            onTap: () {
              if (widget.isEdit!) {
                updateCategory();
              } else {
                checkValidation();
              }
            },
            btnName: "Submit",
          ),
        )
      ],
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      leading: IconButton(
        splashRadius: 20,
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.close,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        widget.isEdit != null && widget.isEdit == true
            ? "Edit Category"
            : "Add New Category",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      actions: [
        widget.isEdit != null && widget.isEdit == true
            ? IconButton(
                onPressed: () async {
                  await confirmationDialog(
                    context,
                    title: "Warning",
                    message: "Do you want to delete this product?",
                  ).then((value) {
                    setState(() {
                      if (value != null && value == true) {
                        deleteCategory();
                      }
                    });
                  });
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              )
            : const SizedBox(),
      ],
      bottom: const PreferredSize(
        preferredSize: Size(double.infinity, 10),
        child: Divider(
          height: 0,
          color: Colors.grey,
        ),
      ),
    );
  }
}
