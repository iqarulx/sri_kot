import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../model/model.dart';
import '../../../services/services.dart';
import 'commonwidget.dart';

class CustomerSearchView extends StatefulWidget {
  const CustomerSearchView({super.key});

  @override
  State<CustomerSearchView> createState() => _CustomerSearchViewState();
}

class _CustomerSearchViewState extends State<CustomerSearchView> {
  TextEditingController search = TextEditingController();

  List<CustomerDataModel> customers = [];
  List<CustomerDataModel> allCustomers = []; // Add this list for original data
  Future? customerHandler;

  @override
  void initState() {
    customerHandler = getCustomers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
        child: Column(
          children: [
            InputForm(
              labelName: "Search by Name / Mobile No",
              controller: search,
              formName: "Customer",
              onChanged: (value) {
                searchCustomer();
              },
              suffixIcon: search.text.isNotEmpty
                  ? TextButton(
                      onPressed: () {
                        search.clear();
                        resetSearch();
                      },
                      child: const Text(
                        "Clear",
                        style: TextStyle(
                          color: Color(0xff2F4550),
                        ),
                      ),
                    )
                  : null,
            ),
            FutureBuilder(
              future: customerHandler,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return futureLoading(context);
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return customers.isNotEmpty
                      ? Flexible(
                          child: ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      Navigator.pop(context, customers[index]);
                                    },
                                    leading: const Icon(Iconsax.profile_2user),
                                    title: Text(
                                        "${customers[index].customerName} - ${customers[index].mobileNo}"),
                                    subtitle: Text(
                                        "${customers[index].city} - ${customers[index].state}"),
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                  )
                                ],
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Column(
                            children: [
                              const Text("No customer found"),
                              TextButton.icon(
                                icon: const Icon(Iconsax.refresh),
                                label: const Text("Refresh"),
                                onPressed: () {
                                  setState(() {
                                    customerHandler = getCustomers();
                                  });
                                },
                              )
                            ],
                          ),
                        );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  // Search function that works with original list (allCustomers)
  searchCustomer() {
    List<CustomerDataModel> filteredList = allCustomers.where((task) {
      return task.customerName!
              .toLowerCase()
              .contains(search.text.toLowerCase()) ||
          task.mobileNo!.toLowerCase().contains(search.text.toLowerCase());
    }).toList();
    setState(() {
      customers = filteredList; // Update displayed list with filtered results
    });
  }

  // Reset search to show all customers
  void resetSearch() {
    setState(() {
      customers = List.from(allCustomers); // Restore original data
    });
  }

  // Fetch customers and store them in both lists
  Future getCustomers() async {
    try {
      FireStore provider = FireStore();
      final result = await provider.customerListing();
      if (result!.docs.isNotEmpty) {
        setState(() {
          customers.clear();
          allCustomers.clear(); // Clear both lists before adding data
        });
        for (var element in result.docs) {
          CustomerDataModel model = CustomerDataModel();
          model.address = element["address"] ?? '';
          model.mobileNo = element["mobile_no"] ?? '';
          model.city = element["city"] ?? '';
          model.customerName = element["customer_name"] ?? '';
          model.email = element["email"] ?? '';
          model.state = element["state"] ?? '';
          model.docID = element.id;
          model.companyID = element["company_id"] ?? '';
          setState(() {
            customers.add(model);
            allCustomers.add(model); // Add to both lists
          });
        }
        return customers;
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }
}
