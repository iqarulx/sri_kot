import 'package:flutter/material.dart';

import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/constants/constants.dart';

class CategoryCreate extends StatefulWidget {
  final bool? isEdit;
  final String? categoryName;
  final String? docID;
  const CategoryCreate({
    super.key,
    this.isEdit,
    this.categoryName,
    this.docID,
  });

  @override
  State<CategoryCreate> createState() => _CategoryCreateState();
}

class _CategoryCreateState extends State<CategoryCreate> {
  TextEditingController categoryName = TextEditingController();
  String? title;

  var addCategoryKey = GlobalKey<FormState>();

  inifun() {
    setState(() {
      if (widget.isEdit != null && widget.isEdit == true) {
        title = "Edit Category";
        categoryName.text = widget.categoryName ?? "";
      } else {
        title = "Add New Category";
      }
    });
  }

  checkValidation() async {
    loading(context);
    FocusManager.instance.primaryFocus!.unfocus();
    try {
      if (addCategoryKey.currentState!.validate()) {
        await LocalDB.fetchInfo(type: LocalData.companyid).then((cid) async {
          if (cid != null) {
            await FireStore()
                .findCategory(
                    cid: cid,
                    categoryName: categoryName.text
                        .replaceAll(' ', '')
                        .trim()
                        .toLowerCase())
                .then((result) async {
              if (result != null && result.docs.isEmpty) {
                var categoryData = CategoryDataModel();

                categoryData.cid = cid;
                categoryData.categoryName = categoryName.text;
                categoryData.name =
                    categoryName.text.replaceAll(' ', '').trim().toLowerCase();
                categoryData.postion = 0;
                categoryData.deleteAt = false;
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
                    snackbar(
                        context, true, "Successfully Created New Category");
                  } else {
                    snackbar(context, false, "Failed to Create New Category");
                  }
                });
              } else {
                snackbar(context, false, "Category Name Already Exists");
              }
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

            await FireStore()
                .updateCategory(
                    categoryData: categoryData, docID: widget.docID!)
                .then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
              snackbar(context, true, "Category Update Successfully");
              // if (value.id.isNotEmpty) {
              //   setState(() {
              //     categoryName.clear();
              //   });
              // } else {
              //   snackbar(context, false, "Failed to Create New Category");
              // }
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
        Navigator.pop(context);
        Navigator.pop(context, true);
        snackbar(context, true, "Successfully Deleted");
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
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
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
              ),
              body: Column(
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
                                  lableName: "Category Name",
                                  formName: "Category Name",
                                  prefixIcon: Icons.person,
                                  validation: (p0) {
                                    return FormValidation().commonValidation(
                                      input: p0,
                                      isMandorty: true,
                                      formName: 'Category Name',
                                      isOnlyCharter: false,
                                    );
                                  },
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
              ),
            ),
          ),
        );
      },
    );
  }
}
