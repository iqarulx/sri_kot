import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../services/services.dart';

class ProductCodeModal extends StatefulWidget {
  final bool? value;
  const ProductCodeModal({
    super.key,
    required this.value,
  });

  @override
  State<ProductCodeModal> createState() => _ProductCodeModalState();
}

class _ProductCodeModalState extends State<ProductCodeModal> {
  bool productCode = false;

  @override
  void initState() {
    setState(() {
      productCode = widget.value ?? false;
    });
    super.initState();
  }

  formSubmit() {
    if (productCode) {
      Navigator.pop(context, true);
      LocalDB.setProductCodeDisplay(productCode);
    } else {
      Navigator.pop(context, true);
      LocalDB.setProductCodeDisplay(productCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        "Product Code Display",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Choose yes or no for display\nproduct code in billing",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
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
                  value: productCode,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      productCode = value;
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
        ],
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
