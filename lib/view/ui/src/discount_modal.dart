import 'package:flutter/material.dart';
import '/view/ui/src/toast.dart';

class DiscountModal extends StatefulWidget {
  final String title;
  final String symbol;
  final String value;
  final String amount;
  final bool isPackingCharge;
  const DiscountModal({
    super.key,
    required this.title,
    required this.value,
    required this.symbol,
    required this.amount,
    required this.isPackingCharge,
  });

  @override
  State<DiscountModal> createState() => _DiscountModalState();
}

class _DiscountModalState extends State<DiscountModal> {
  String sys = "%";
  TextEditingController value = TextEditingController();

  List<DropdownMenuItem> sysList = const [
    DropdownMenuItem(
      value: "%",
      child: Text("%"),
    ),
    DropdownMenuItem(
      value: "rs",
      child: Text("RS"),
    ),
  ];
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    sys = widget.symbol;
    if (widget.value != '0.0') {
      value.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      title: Text(widget.title),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField(
                  isExpanded: true,
                  value: sys,
                  items: sysList,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      sys = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: TextFormField(
                  controller: value,
                  cursorColor: Theme.of(context).primaryColor,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter discount",
                    filled: true,
                    fillColor: Color(0xfff1f5f9),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffF2F2F2),
                  ),
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xff575757),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  FocusManager.instance.primaryFocus!.unfocus();
                  if (widget.isPackingCharge) {
                    if (sys == "%") {
                      if (value.text.isEmpty) {
                        return showToast(context,
                            content: "Discount must be provided",
                            isSuccess: false,
                            top: false);
                      } else if (value.text.contains(RegExp(r'\s'))) {
                        return showToast(context,
                            content: "White spaces not allowed",
                            isSuccess: false,
                            top: false);
                      } else if (double.tryParse(value.text) == null) {
                        return showToast(context,
                            content: "Must be a valid number",
                            isSuccess: false,
                            top: false);
                      }
                    } else {
                      if (value.text.isEmpty) {
                        return showToast(context,
                            content: "Discount amount must be provided",
                            isSuccess: false,
                            top: false);
                      }
                    }
                  } else {
                    if (sys == "%") {
                      if (value.text.isEmpty) {
                        return showToast(context,
                            content: "Discount must be provided",
                            isSuccess: false,
                            top: false);
                      } else if (value.text.contains(RegExp(r'\s'))) {
                        return showToast(context,
                            content: "White spaces not allowed",
                            isSuccess: false,
                            top: false);
                      } else if (double.tryParse(value.text) == null) {
                        return showToast(context,
                            content: "Must be a valid number",
                            isSuccess: false,
                            top: false);
                      } else if (double.parse(value.text) >= 100) {
                        return showToast(context,
                            content: "Discount must be less than 100",
                            isSuccess: false,
                            top: false);
                      }
                    } else {
                      if (value.text.isEmpty) {
                        return showToast(context,
                            content: "Discount amount must be provided",
                            isSuccess: false,
                            top: false);
                      }

                      double? discountValue;
                      try {
                        discountValue = double.parse(value.text);
                      } catch (e) {
                        return showToast(context,
                            content:
                                "Invalid discount amount value. Please enter a valid number.",
                            isSuccess: false,
                            top: false);
                      }

                      if (discountValue >= double.parse(widget.amount)) {
                        return showToast(context,
                            content:
                                "Discount amount must be less than ${widget.amount}",
                            isSuccess: false,
                            top: false);
                      }
                    }
                  }
                  Navigator.pop(context, {
                    "sys": sys,
                    "value": double.parse(value.text).toStringAsFixed(2)
                  });
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Center(
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        color: Color(0xffF4F4F9),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
