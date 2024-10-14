import 'package:flutter/material.dart';
import '/utils/utils.dart';
import '/view/screens/screens.dart';

late TabController uploadExcelController;

class UploadExcel extends StatefulWidget {
  const UploadExcel({super.key});

  @override
  State<UploadExcel> createState() => _UploadExcelState();
}

class _UploadExcelState extends State<UploadExcel>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    excelData.clear();
    uploadExcelController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appbar(),
        body: body(),
      ),
    );
  }

  TabBarView body() {
    return TabBarView(
      controller: uploadExcelController,
      children: const [
        UploadExcelUI(),
        ExcelResultUI(),
      ],
    );
  }

  AppBar appbar() {
    return AppBar(
      title: const Text("Upload Excel"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size(double.infinity, 50),
        child: Container(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: uploadExcelController,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(
                text: "Upload Excel",
              ),
              Tab(
                text: "View Products",
              )
            ],
          ),
        ),
      ),
    );
  }
}
