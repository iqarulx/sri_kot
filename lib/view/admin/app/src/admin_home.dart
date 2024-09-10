import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/model.dart';
import '../../../../services/services.dart';
import '/view/admin/admin.dart';

var adminHomeKey = GlobalKey<ScaffoldState>();

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Future? companyHandler;
  List<ProfileModel> companyList = [];

  @override
  void initState() {
    super.initState();
    companyHandler = companyListView();
  }

  Future companyListView() async {
    setState(() {
      companyList.clear();
    });
    try {
      FireStoreProvider provider = FireStoreProvider();
      final result = await provider.getAllCompany();

      if (result!.docs.isNotEmpty) {
        for (var data in result.docs) {
          ProfileModel profileModel = ProfileModel();
          profileModel.docId = data.id.toString();
          profileModel.companyName = data["company_name"].toString();
          profileModel.companyLogo = data["company_logo"].toString();

          setState(() {
            companyList.add(profileModel);
          });
        }

        return result;
      }

      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: adminHomeKey,
      backgroundColor: const Color(0xffEEEEEE),
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 20,
          onPressed: () {
            adminHomeKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: const Text("Dashboard"),
      ),
      drawer: const SideBar(),
      body: FutureBuilder(
        future: companyHandler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  companyHandler = companyListView();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Total Company List",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: companyList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => Company(
                                        uid: companyList[index].docId!,
                                      ),
                                    ),
                                  );
                                },
                                leading: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: NetworkImage(companyList[index]
                                                  .companyLogo !=
                                              "null"
                                          ? companyList[index].companyLogo!
                                          : 'https://img.icons8.com/?size=160&id=95101&format=png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  companyList[index].companyName ?? "",
                                ),
                                trailing: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Text(
                                    //   productDataList[index].price.toString(),
                                    // ),
                                    Icon(
                                      Icons.keyboard_arrow_right_outlined,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Divider(
                                  height: 0,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
