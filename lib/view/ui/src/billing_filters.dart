import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import '/view/ui/src/toast.dart';
import '/model/model.dart';
import 'commonwidget.dart';
import 'customer_search_view.dart';

class BillingFilters extends StatefulWidget {
  const BillingFilters({super.key});

  @override
  State<BillingFilters> createState() => _BillingFiltersState();
}

class _BillingFiltersState extends State<BillingFilters> {
  TextEditingController search = TextEditingController();
  TextEditingController customer = TextEditingController();
  CustomerDataModel customerInfo = CustomerDataModel();
  DateRange? selectedDateRange;
  final searchKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  side: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                FocusManager.instance.primaryFocus!.unfocus();
                if (search.text.isNotEmpty ||
                    selectedDateRange != null ||
                    customer.text.isNotEmpty) {
                  var result = {
                    "search_text": search.text,
                    "from_date": selectedDateRange?.start,
                    "to_date": selectedDateRange?.end,
                    "customer": customerInfo.toOrderMap()
                  };
                  Navigator.pop(context, result);
                } else {
                  showToast(
                    context,
                    content: "Please choose aleast one filter",
                    isSuccess: false,
                    top: false,
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
          child: Form(
            key: searchKey,
            child: Column(
              children: [
                InputForm(
                  labelName: "Search by bill no, name, city, mobile no",
                  controller: search,
                  formName: "Search",
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date Range",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    DateRangeFormField(
                      decoration: const InputDecoration(
                        hintText: "Select Date",
                        suffixIcon: Icon(
                          Icons.date_range,
                          color: Color(0xff7099c2),
                        ),
                      ),
                      pickerBuilder: (x, y) => datePickerBuilder(x, y, false),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
                InputForm(
                  labelName: "Customer",
                  controller: customer,
                  formName: "Customer",
                  readOnly: true,
                  onTap: () {
                    chooseCustomer();
                  },
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  chooseCustomer() async {
    await showModalBottomSheet(
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (builder) {
        return const FractionallySizedBox(
          heightFactor: 0.9,
          child: CustomerSearchView(),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          customerInfo = value;
          customer.text =
              "${customerInfo.customerName} - ${customerInfo.mobileNo}";
          setState(() {});
        }
      },
    );
  }

  Widget datePickerBuilder(
      BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
      [bool doubleMonth = true]) {
    return DateRangePickerWidget(
      doubleMonth: doubleMonth,
      minimumDateRangeLength: 1,
      initialDateRange: selectedDateRange,
      initialDisplayedDate: selectedDateRange?.start ?? DateTime.now(),
      onDateRangeChanged: (DateRange? newRange) {
        setState(() {
          selectedDateRange = newRange;
        });
        onDateRangeChanged(newRange);
      },
      height: 350,
      theme: const CalendarTheme(
        selectedColor: Colors.blue,
        dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
        inRangeColor: Color(0xFFD9EDFA),
        inRangeTextStyle: TextStyle(color: Colors.blue),
        selectedTextStyle: TextStyle(color: Colors.white),
        todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
        defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
        radius: 10,
        tileSize: 40,
        disabledTextStyle: TextStyle(color: Colors.grey),
        quickDateRangeBackgroundColor: Color(0xFFFFF9F9),
        selectedQuickDateRangeColor: Colors.blue,
      ),
    );
  }
}
