import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/constants/constants.dart';
import '/services/services.dart';
import '/view/ui/src/commonwidget.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  String? companyName;
  DateTime? createdAt;
  String? userCount;
  String? staffCount;
  String? invoiceEntry;
  DateTime? expiredOn;

  @override
  void initState() {
    userHandler = getUserInfo();
    super.initState();
  }

  Future? userHandler;

  getUserInfo() async {
    var value = await LocalDB.fetchInfo(type: LocalData.uid);
    await FireStore()
        .getCompanyInfo(uid: await LocalDB.fetchInfo(type: LocalData.uid))
        .then((value) {
      if (value != null) {
        if (value.docs.isNotEmpty) {
          var data = value.docs.first;
          setState(() {
            companyName = data["company_name"].toString();
            createdAt = data["created"].toDate();
            userCount = data["max_user_count"].toString();
            staffCount = data["max_staff_count"].toString();
            invoiceEntry = data["invoice_entry"] ? "Yes" : "No";
            expiredOn = data["expiry_date"].toDate();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Account Information"),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  userHandler = getUserInfo();
                });
              },
              icon: const Icon(Icons.refresh),
            ),
          ]),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            Navigator.of(context).pop();
          }
        },
        child: FutureBuilder(
          future: userHandler,
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
                              userHandler = getUserInfo();
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
              return ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text("Account Information",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                        const SizedBox(
                          height: 15,
                        ),
                        Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                            },
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            children: [
                              _buildTableRow(
                                context,
                                "Company Name",
                                companyName ?? '',
                              ),
                              _buildTableRow(
                                context,
                                "Created at",
                                DateFormat('dd-MM-yyyy hh:mm a')
                                    .format(createdAt ?? DateTime.now()),
                              ),
                              _buildTableRow(
                                context,
                                "Users License",
                                userCount ?? '',
                              ),
                              _buildTableRow(
                                context,
                                "Staff License",
                                staffCount ?? '',
                              ),
                              _buildTableRow(
                                context,
                                "Invoice Entry",
                                invoiceEntry ?? '',
                              ),
                              _buildTableRow(
                                context,
                                "Expired On",
                                DateFormat('dd-MM-yyyy hh:mm a')
                                    .format(expiredOn ?? DateTime.now()),
                              ),
                            ])
                      ],
                    ),
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "$title : ",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
