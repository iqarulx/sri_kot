import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '/model/model.dart';

class DiscountDetailProduct extends StatefulWidget {
  final List<ProductDataModel> productData;

  const DiscountDetailProduct({super.key, required this.productData});

  @override
  State<DiscountDetailProduct> createState() => _DiscountDetailProductState();
}

class _DiscountDetailProductState extends State<DiscountDetailProduct> {
  @override
  Widget build(BuildContext context) {
    // Calculate the total discounted price
    double totalDiscountedPrice =
        widget.productData.fold(0.0, (total, product) {
      double discountedPrice = product.discountLock != null &&
              !product.discountLock! &&
              product.discount != null
          ? product.price! * (product.discount! / 100)
          : 0;
      return total + discountedPrice;
    });

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
              "Discount Details",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...widget.productData.map((product) {
                double discountedPrice = product.discountLock != null &&
                        !product.discountLock! &&
                        product.discount != null
                    ? product.price! * (product.discount! / 100)
                    : 0;

                return ListTile(
                  title: Text(
                    product.productName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "\u{20B9} ${product.price!.toStringAsFixed(2)}"), // Original price
                  trailing: Text(
                    "- \u{20B9} ${discountedPrice.toStringAsFixed(2)}", // Discounted price
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        product.discountLock != null && !product.discountLock!
                            ? product.discount != null
                                ? "${product.discount}"
                                : "NR"
                            : "NR",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10), // Space before the total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Discounted Price:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "\u{20B9} ${totalDiscountedPrice.toStringAsFixed(2)}",
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
                  )),
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
}
