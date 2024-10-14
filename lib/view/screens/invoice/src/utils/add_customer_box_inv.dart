import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/model/src/party_data_model.dart';
import '/services/services.dart';
import '/utils/utils.dart';
import '/view/ui/src/customer_search_view.dart';
import '/view/ui/ui.dart';

class AddCustomerBoxInv extends StatefulWidget {
  final bool edit;
  final PartyDataModel? party;
  const AddCustomerBoxInv({super.key, required this.edit, this.party});

  @override
  State<AddCustomerBoxInv> createState() => _AddCustomerBoxInvState();
}

class _AddCustomerBoxInvState extends State<AddCustomerBoxInv> {
  PartyDataModel customerInfo = PartyDataModel();
  bool taxType = false;
  String gstType = "Exclusive";
  bool copyAddress = false;
  bool gstChanged = false;

  chooseState() async {
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
          child: StateSearch(),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          state = value;
          setState(() {});
        }
      },
    );
  }

  chooseCity() async {
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
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: CitySearch(
            state: state.text,
          ),
        );
      },
    ).then(
      (value) {
        if (value != null) {
          city = value;
          setState(() {});
        }
      },
    );
  }

  gettaxType() async {
    taxType = await FireStore().getCompanyTax();
    setState(() {});
  }

  initParty() {
    var party = widget.party ?? PartyDataModel();
    customerName.text = party.partyName ?? '';
    address.text = party.address ?? '';
    mobileNo.text = party.mobileNo ?? '';
    state.text = party.state ?? '';
    city.text = party.city ?? '';
    deliveryAddress.text = party.deliveryAddress ?? '';
    transportName.text = party.transportName ?? '';
    transportNo.text = party.transportNo ?? '';
    gstType = party.gstType ?? '';
    taxType = party.taxType ?? false;
  }

  @override
  void initState() {
    gettaxType();
    if (widget.edit) {
      initParty();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
          child: Form(
            key: customerFormKey,
            child: ListView(
              children: [
                Visibility(
                  visible: taxType,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GST Details",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      DropdownButtonFormField<String>(
                        menuMaxHeight: 300,
                        value: gstType,
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              "Select gst type",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Inclusive",
                            child: Text("Inclusive"),
                          ),
                          DropdownMenuItem(
                            value: "Exclusive",
                            child: Text("Exclusive"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              if (v != gstType) {
                                gstChanged = true;
                              }
                              gstType = v;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Text(
                  "Party Details",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView(
                  primary: false,
                  shrinkWrap: true,
                  children: [
                    const Divider(
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    InputForm(
                      labelName: "Party Name (*)",
                      controller: customerName,
                      formName: "Party Name",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          chooseCustomer();
                        },
                      ),
                      validation: (input) {
                        return FormValidation().commonValidation(
                          input: input ?? '',
                          isMandatory: true,
                          formName: "Party name",
                          isOnlyCharter: true,
                        );
                      },
                    ),
                    InputForm(
                      labelName: "Mobile No (*)",
                      controller: mobileNo,
                      formName: "Mobile No",
                      validation: (input) {
                        return FormValidation().phoneValidation(
                          input: input ?? '',
                          isMandatory: true,
                          labelName: "Mobile No",
                        );
                      },
                    ),
                    InputForm(
                      labelName: "Address (*)",
                      controller: address,
                      formName: "Address",
                      maxLines: 2,
                      validation: (input) {
                        return FormValidation().commonValidation(
                          input: input ?? '',
                          isMandatory: true,
                          formName: "Address",
                          isOnlyCharter: true,
                        );
                      },
                    ),
                    InputForm(
                      readOnly: true,
                      labelName: "State (*)",
                      controller: state,
                      formName: "State",
                      validation: (input) {
                        return FormValidation().commonValidation(
                          input: input ?? '',
                          isMandatory: true,
                          formName: "State",
                          isOnlyCharter: true,
                        );
                      },
                      onTap: () {
                        chooseState();
                      },
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    InputForm(
                      readOnly: true,
                      labelName: "City (*)",
                      controller: city,
                      formName: "City",
                      validation: (input) {
                        return FormValidation().commonValidation(
                          input: input ?? '',
                          isMandatory: true,
                          formName: "City",
                          isOnlyCharter: true,
                        );
                      },
                      onTap: () {
                        chooseCity();
                      },
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    InputForm(
                      labelName: "Transport Name (*)",
                      controller: transportName,
                      formName: "Transport Name",
                      validation: (input) {
                        return FormValidation().commonValidation(
                          input: input ?? '',
                          isMandatory: true,
                          formName: "Transport Name",
                          isOnlyCharter: true,
                        );
                      },
                    ),
                    InputForm(
                      labelName: "Transport No (*)",
                      controller: transportNo,
                      formName: "Transport No",
                      validation: (input) {
                        return FormValidation().commonValidation(
                          input: input ?? '',
                          isMandatory: true,
                          formName: "Transport No",
                          isOnlyCharter: true,
                        );
                      },
                    ),
                    Row(
                      children: [
                        CupertinoSwitch(
                          value: copyAddress,
                          onChanged: (onChanged) {
                            if (onChanged) {
                              setState(() {
                                copyAddress = onChanged;
                                if (onChanged == true) {
                                  deliveryAddress.text =
                                      "${customerName.text}, ${address.text}, ${mobileNo.text}";
                                }
                              });
                            } else {
                              setState(() {
                                copyAddress = onChanged;
                                deliveryAddress.clear();
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Same Deleivery Address",
                        ),
                      ],
                    ),
                    InputForm(
                      labelName: "Delivery Address (*)",
                      controller: deliveryAddress,
                      maxLines: 2,
                      formName: "Delivery Address",
                      validation: (input) {
                        return FormValidation().commonValidation(
                          input: input ?? '',
                          isMandatory: true,
                          formName: "Delivery Address",
                          isOnlyCharter: false,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
                if (customerFormKey.currentState!.validate()) {
                  customerInfo.address = address.text;
                  customerInfo.state = state.text;
                  customerInfo.partyName = customerName.text;
                  customerInfo.mobileNo = mobileNo.text;
                  customerInfo.city = city.text;
                  customerInfo.transportName = transportName.text;
                  customerInfo.transportNo = transportNo.text;
                  customerInfo.deliveryAddress = deliveryAddress.text;
                  customerInfo.gstType = gstType;
                  customerInfo.taxType = taxType;
                  customerInfo.gstChanged = gstChanged;
                  await LocalDB.clearInvoiceParty();
                  await LocalDB.setInvoiceParty(customerInfo.toMap());
                  Navigator.pop(context, true);
                }
              },
              child: const Text("Submit"),
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
          customerInfo.docId = value.docID;
          state.text = value.state ?? '';
          city.text = value.city ?? '';
          mobileNo.text = value.mobileNo ?? '';
          customerName.text = value.customerName ?? '';
          address.text = value.address ?? '';
          setState(() {});
        }
      },
    );
  }

  final customerFormKey = GlobalKey<FormState>();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController customerName = TextEditingController();
  TextEditingController transportNo = TextEditingController();
  TextEditingController transportName = TextEditingController();
  TextEditingController deliveryAddress = TextEditingController();
}
