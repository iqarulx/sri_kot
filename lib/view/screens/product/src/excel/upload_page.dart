import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/services/services.dart';
import '/constants/constants.dart';
import '/gen/assets.gen.dart';
import '/provider/provider.dart';
import '/utils/utils.dart';
import '/view/screens/screens.dart';
import '/provider/src/file_open.dart' as helper;

class UploadExcelUI extends StatefulWidget {
  const UploadExcelUI({super.key});

  @override
  State<UploadExcelUI> createState() => _UploadExcelUIState();
}

class _UploadExcelUIState extends State<UploadExcelUI> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Upload Excel",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.info_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5),
                      padding: const EdgeInsets.all(0),
                      dashPattern: const [6, 3],
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 50,
                          horizontal: 30,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.images.excel.image(
                              height: 100,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Select a Excel file to upload",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "First download temple add modeify data to upload",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                uploadExcel();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.file_upload_outlined,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Upload",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
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
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Download Templete",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.info_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          onTap: () {},
                          contentPadding: const EdgeInsets.all(0),
                          leading: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Assets.images.excel.image(
                                height: 35,
                              ),
                            ),
                          ),
                          title: Text(
                            "Product Template",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            "Download Sample Product Excel File",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              downloadTemplate();
                            },
                            icon: const Icon(Icons.file_download_outlined),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          contentPadding: const EdgeInsets.all(0),
                          leading: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Assets.images.excel.image(
                                height: 35,
                              ),
                            ),
                          ),
                          title: Text(
                            "Product Template With Data",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            "Download Sample Product Excel File With Dummy Data",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              downloadTemplateWithData();
                            },
                            icon: const Icon(Icons.file_download_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  uploadExcel() async {
    // loading(context);
    try {
      await FilePickerProviderExcel()
          .openGalary(fileType: FileProviderType.excel)
          .then((value) async {
        if (value != null) {
          await ExcelReaderProvider()
              .readExcelData(file: value)
              .then((excelResult) {
            if (excelResult != null) {
              setState(() {
                excelData.clear();
                excelData.addAll(excelResult);
                uploadExcelController.animateTo(
                  1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.linear,
                );
              });
            } else {
              Navigator.pop(context);
            }
          }).catchError((onError) {
            snackbar(context, false, onError);
            LogConfig.addLog("${DateTime.now()} : ${onError.toString()}");
          });
        } else {
          snackbar(context, false, "Something went wrong. Please try again");

          Navigator.pop(context);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, "e.toString()");
    }
  }

  downloadTemplate() async {
    loading(context);
    try {
      var data = await http.get(Uri.parse(Strings.productTemplate));
      var response = data.bodyBytes;
      Navigator.pop(context);
      helper.saveAndLaunchFile(response, "Product Template.xlsx");
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }

  downloadTemplateWithData() async {
    loading(context);
    try {
      var data = await http.get(Uri.parse(Strings.productTemplateWithData));
      var response = data.bodyBytes;
      Navigator.pop(context);
      helper.saveAndLaunchFile(response, "Product Template With Data.xlsx");
    } catch (e) {
      Navigator.pop(context);
      snackbar(context, false, e.toString());
    }
  }
}
