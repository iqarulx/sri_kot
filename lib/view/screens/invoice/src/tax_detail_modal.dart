import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TaxDetailModal extends StatefulWidget {
  final Map<String, dynamic> data;

  const TaxDetailModal({super.key, required this.data});

  @override
  State<TaxDetailModal> createState() => _TaxDetailModalState();
}

class _TaxDetailModalState extends State<TaxDetailModal> {
  @override
  Widget build(BuildContext context) {
    var data = widget.data;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      title: const SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Icon(Iconsax.info_circle),
            SizedBox(width: 8),
            Text(
              "Tax Details",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "GST Type: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${data["tax_type"]}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border:
                      TableBorder.all(color: Colors.black38), // Added border
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        headerCell('Product Name'),
                        headerCell('Product Rate'),
                        headerCell('Inclusive Rate'),
                        headerCell('Tax'),
                        headerCell('Discount'),
                        headerCell('Extra Discount'),
                        headerCell('Extra Discount Tax Amount'),
                        headerCell('Product Tax Amount'),
                      ],
                    ),
                    for (var i in data["products"])
                      tableRow(
                        i["product_name"],
                        i["product_type"],
                        i.containsKey('product_inclusive_rate')
                            ? double.parse(i["product_inclusive_rate"])
                                .toStringAsFixed(2)
                            : "",
                        i["product_tax"],
                        i["product_discount"].toStringAsFixed(2),
                        i["extra_discount_input"].toStringAsFixed(2),
                        i["extra_discount_tax_amount"].toStringAsFixed(2),
                        i["product_tax_amount"].toStringAsFixed(2),
                        true,
                      )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Tax",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "\u{20B9} ${widget.data["total_tax"]}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                  Navigator.pop(context, false);
                },
                child: Container(
                  height: 55,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, true);
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

  /// Header Cell widget to avoid duplication
  Widget headerCell(String text) {
    return Container(
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Table row to display product data
  TableRow tableRow(
    String productName,
    String productRate,
    String productInclusiveRate,
    String productTax,
    String discount,
    String extraDiscountInput,
    String extraDiscountTaxAmount,
    String productTaxAmount,
    bool gstType,
  ) {
    return TableRow(
      children: [
        cellText(productName),
        cellText(productRate),
        if (gstType) cellText(productInclusiveRate),
        cellText(productTax),
        cellText(discount),
        cellText(extraDiscountInput),
        cellText(extraDiscountTaxAmount),
        cellText(productTaxAmount),
      ],
    );
  }

  /// Reusable cell text widget for table cells
  Widget cellText(String text) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
