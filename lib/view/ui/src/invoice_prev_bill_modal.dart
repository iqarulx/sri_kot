import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/services/services.dart';

class InvoicePrevBillModal extends StatefulWidget {
  final bool? value;
  const InvoicePrevBillModal({
    super.key,
    required this.value,
  });

  @override
  State<InvoicePrevBillModal> createState() => _InvoicePrevBillModalState();
}

class _InvoicePrevBillModalState extends State<InvoicePrevBillModal> {
  bool invoicePrevBill = false;

  @override
  void initState() {
    setState(() {
      invoicePrevBill = widget.value ?? false;
    });
    super.initState();
  }

  formSubmit() {
    if (invoicePrevBill) {
      Navigator.pop(context, true);
      LocalDB.setPdfType(invoicePrevBill);
    } else {
      Navigator.pop(context, true);
      LocalDB.setPdfType(invoicePrevBill);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        "Invoice Prev Bill",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose yes or no for display previous bill record in pdf display",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Colors.black54),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    "No",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  )),
                  CupertinoSwitch(
                    value: invoicePrevBill,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (value) {
                      setState(() {
                        invoicePrevBill = value;
                      });
                    },
                  ),
                  Expanded(
                      child: Text(
                    "Yes",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
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
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  formSubmit();
                },
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xff2F4550),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Submit",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
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
