import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '/provider/provider.dart';
import '/constants/constants.dart';
import '/gen/assets.gen.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/ui.dart';
import '/view/screens/screens.dart';

PageController userListingcontroller = PageController();

class UserListing extends StatefulWidget {
  const UserListing({super.key});

  @override
  State<UserListing> createState() => _UserListingState();
}

class _UserListingState extends State<UserListing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Users"),
        actions: [
          Provider.of<ConnectionProvider>(context, listen: false).isConnected
              ? IconButton(
                  onPressed: () async {
                    await LocalService.checkCount(type: ProfileType.admin)
                        .then((value) async {
                      if (value) {
                        await openModelBottomSheat(context).then((result) {
                          if (result != null && result == true) {
                            setState(() {
                              userlistingHandler = getUserInfo();
                            });
                          }
                        });
                      } else {
                        snackbar(context, false, "Reached max user count");
                      }
                    });
                  },
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.add,
                  ),
                )
              : Container()
        ],
      ),
      body: Consumer<ConnectionProvider>(
        builder: (context, connectionProvider, child) {
          return connectionProvider.isConnected
              ? screenView()
              : noInternet(context);
        },
      ),
    );
  }

  FutureBuilder<dynamic> screenView() {
    return FutureBuilder(
      future: userlistingHandler,
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
                          userlistingHandler = getUserInfo();
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
          return PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: userListingcontroller,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: userListData.isNotEmpty
                      ? RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              userlistingHandler = getUserInfo();
                            });
                          },
                          child: ListView.builder(
                            itemCount: userListData.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    onTap: () {
                                      setState(() {
                                        adminuid = userListData[index].uid;
                                        adminDocId = userListData[index].docid;
                                        adminPagetitle =
                                            userListData[index].adminName;
                                        adminuserName.text =
                                            userListData[index].adminName ?? "";
                                        adminphoneno.text =
                                            userListData[index].phoneNo ?? "";
                                        adminuserid.text =
                                            userListData[index].adminLoginId ??
                                                "";
                                        adminpassword.text =
                                            userListData[index].password ?? "";
                                        adminProfileImage =
                                            userListData[index].imageUrl;
                                        userListingcontroller.animateToPage(
                                          1,
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          curve: Curves.linear,
                                        );
                                      });
                                    },
                                    leading: ClipRRect(
                                      clipBehavior: Clip.hardEdge,
                                      borderRadius: BorderRadius.circular(25.0),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        imageUrl:
                                            userListData[index].imageUrl ??
                                                Strings.productImg,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      userListData[index].adminName.toString(),
                                    ),
                                    subtitle: Text(
                                      userListData[index]
                                          .adminLoginId
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right_outlined,
                                    ),
                                  ),
                                  Divider(
                                    height: 0,
                                    color: Colors.grey.shade300,
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : Padding(
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
                                "No Users",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Center(
                                child: Text(
                                  "You have not create any user, so first you have create user using add user button below",
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      openModelBottomSheat(context);
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text("Add User"),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        userlistingHandler = getUserInfo();
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text("Refresh"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const UserDetails(),
            ],
          );
        }
      },
    );
  }

  Future getUserInfo() async {
    try {
      FireStoreProvider provider = FireStoreProvider();
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      if (cid != null) {
        final result = await provider.userListing(cid: cid);
        if (result!.docs.isNotEmpty) {
          setState(() {
            userListData.clear();
          });
          for (var element in result.docs) {
            var model = UserAdminModel();
            model.adminName = element["admin_name"].toString();
            model.phoneNo = element["phone_no"].toString();
            model.adminLoginId = element["user_login_id"].toString();
            model.password = element["password"].toString();
            model.imageUrl = element["image_url"];

            // var directory = await getApplicationDocumentsDirectory();
            // model.imageUrl = path.join(
            //   directory.path,
            //   'user',
            //   element.id,
            // );

            model.docid = element.id;
            model.uid = element["uid"].toString();
            setState(() {
              userListData.add(model);
            });
          }
          return userListData;
        }
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      if (connectionProvider.isConnected) {
        AccountValid.accountValid(context);

        userlistingHandler = getUserInfo();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionProvider =
          Provider.of<ConnectionProvider>(context, listen: false);
      connectionProvider.addListener(() {
        if (connectionProvider.isConnected) {
          userlistingHandler = getUserInfo();
        }
      });
    });
  }

  List<UserAdminModel> userListData = [];
  Future? userlistingHandler;
}
