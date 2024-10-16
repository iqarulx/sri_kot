import '/constants/constants.dart';
import '/model/model.dart';

class InvoiceCalc {
  static double inclusiveRate(double rate, String tax) {
    return ((rate * 100) / (100 + double.parse(tax.replaceAll('%', ''))));
  }

  static double exclusiveRate(double rate, String tax) {
    return (rate + ((rate * double.parse(tax.replaceAll('%', ''))) / 100));
  }

  /// Calculate the total discount for the product list
  static String calculateDiscount(
      {required List<InvoiceProductModel> productList}) {
    double totalDiscount = productList
        .where((product) => product.productType == ProductType.discounted)
        .fold(0.0, (sum, product) {
      final double productTotal = product.rate! * product.qty!;
      final double discountAmount =
          productTotal * (product.discount!.toDouble() / 100);
      return sum + discountAmount;
    });

    return totalDiscount.toStringAsFixed(2);
  }

  static String calculateDiscountInclusive(
      {required List<InvoiceProductModel> productList}) {
    double totalDiscount = productList
        .where((product) => product.productType == ProductType.discounted)
        .fold(0.0, (sum, product) {
      final double productTotal =
          inclusiveRate(product.rate!, product.taxValue!) * product.qty!;
      final double discountAmount =
          productTotal * (product.discount!.toDouble() / 100);
      return sum + discountAmount;
    });

    return totalDiscount.toStringAsFixed(2);
  }

  /// Calculate the extra discount based on the provided percentage or fixed amount
  static String calculateExtraDiscount({
    required List<InvoiceProductModel> productList,
    required String discountType,
    required double inputValue,
  }) {
    final double subTotalValue =
        double.parse(calculateSubTotal(productList: productList));
    final double discountValue =
        double.parse(calculateDiscount(productList: productList));

    final double extraDiscount = discountType == "%"
        ? (subTotalValue - discountValue) * (inputValue / 100)
        : inputValue;

    return extraDiscount.isNaN ? "0.00" : extraDiscount.toStringAsFixed(2);
  }

  static String calculateExtraDiscountInclusive({
    required List<InvoiceProductModel> productList,
    required String discountType,
    required double inputValue,
  }) {
    final double subTotalValue =
        double.parse(calculateSubTotalInclusive(productList: productList));
    final double discountValue =
        double.parse(calculateDiscountInclusive(productList: productList));

    final double extraDiscount = discountType == "%"
        ? (subTotalValue - discountValue) * (inputValue / 100)
        : inputValue;

    return extraDiscount.isNaN ? "0.00" : extraDiscount.toStringAsFixed(2);
  }

  /// Calculate the round-off value of the total amount
  static Map<String, dynamic> calculateRoundOff(
      {required List<InvoiceProductModel> productList,
      required String extraDiscountType,
      required double extraDiscountInput,
      required String packingDiscountType,
      required double packingDiscountInput,
      required bool taxType,
      required String gstType}) {
    // Calculate the total value
    final double totalValue = double.parse(calculateCartTotal(
        productList: productList,
        extraDiscountType: extraDiscountType,
        extraDiscountInput: extraDiscountInput,
        packingDiscountType: packingDiscountType,
        packingDiscountInput: packingDiscountInput,
        taxType: taxType,
        gstType: gstType));

    // Calculate the decimal part
    final double decimalPart = totalValue - totalValue.toInt();
    double roundOffValue = 0.0;
    String roundOffType = "";

    // Determine round off logic based on decimal part
    if (decimalPart > 0.5) {
      // Round down to the nearest integer by subtracting from 1
      roundOffValue = 1 - decimalPart;
      roundOffType = "plus";
    } else if (decimalPart > 0 && decimalPart <= 0.5) {
      // Round up to the nearest integer by subtracting the decimal part
      roundOffValue = decimalPart;
      roundOffType = "minus";
    }

    // Calculate the final total amount after round off
    double finalTotalAmount = (roundOffType == "plus")
        ? totalValue + roundOffValue
        : totalValue - roundOffValue;

    return {
      "round_off_value": double.parse(roundOffValue.toStringAsFixed(2)),
      "round_off_type": roundOffType,
      "total_amount": finalTotalAmount.toStringAsFixed(2),
    };
  }

  static Map<String, dynamic> calculateRoundOffInclusive(
      {required List<InvoiceProductModel> productList,
      required String extraDiscountType,
      required double extraDiscountInput,
      required String packingDiscountType,
      required double packingDiscountInput,
      required bool taxType,
      required String gstType}) {
    // Calculate the total value
    final double totalValue = double.parse(calculateCartTotal(
        productList: productList,
        extraDiscountType: extraDiscountType,
        extraDiscountInput: extraDiscountInput,
        packingDiscountType: packingDiscountType,
        packingDiscountInput: packingDiscountInput,
        taxType: taxType,
        gstType: gstType));

    // Calculate the decimal part
    final double decimalPart = totalValue - totalValue.toInt();
    double roundOffValue = 0.0;
    String roundOffType = "";

    // Determine round off logic based on decimal part
    if (decimalPart > 0.5) {
      // Round down to the nearest integer by subtracting from 1
      roundOffValue = 1 - decimalPart;
      roundOffType = "plus";
    } else if (decimalPart > 0 && decimalPart <= 0.5) {
      // Round up to the nearest integer by subtracting the decimal part
      roundOffValue = decimalPart;
      roundOffType = "minus";
    }

    // Calculate the final total amount after round off
    double finalTotalAmount = (roundOffType == "plus")
        ? totalValue + roundOffValue
        : totalValue - roundOffValue;

    return {
      "round_off_value": double.parse(roundOffValue.toStringAsFixed(2)),
      "round_off_type": roundOffType,
      "total_amount": finalTotalAmount.toStringAsFixed(2),
    };
  }

  /// Count the total quantity of items in the cart
  static String calculateCartItemCount(
      {required List<InvoiceProductModel> productList}) {
    final int totalQuantity =
        productList.fold(0, (count, product) => count + product.qty!);
    return totalQuantity.toString();
  }

  /// Calculate the product price based on percentage or fixed input
  static String calculateMrpPrice({
    required double price,
    required String inputType,
    required double inputValue,
  }) {
    if (inputType == "%") {
      final double calculatedPrice = price / inputValue;
      return calculatedPrice.toStringAsFixed(2);
    }
    return "0.00";
  }

  /// Calculate the subtotal for all products in the list
  static String calculateSubTotal(
      {required List<InvoiceProductModel> productList}) {
    final double subTotal = productList.fold(
      0.0,
      (sum, product) => sum + (product.rate! * product.qty!),
    );
    return subTotal.toStringAsFixed(2);
  }

  static String calculateSubTotalInclusive(
      {required List<InvoiceProductModel> productList}) {
    final double subTotal = productList.fold(
      0.0,
      (sum, product) =>
          sum +
          (inclusiveRate(product.rate!, product.taxValue!) * product.qty!),
    );
    return subTotal.toStringAsFixed(2);
  }

  /// Calculate the packing charges
  static String calculatePackingCharges({
    required List<InvoiceProductModel> productList,
    required String extraDiscountType,
    required double extraDiscountInput,
    required String packingDiscountType,
    required double packingDiscountInput,
  }) {
    final double subTotalValue =
        double.parse(calculateSubTotal(productList: productList));
    final double discountValue =
        double.parse(calculateDiscount(productList: productList));
    final double extraDiscountValue = double.parse(calculateExtraDiscount(
      productList: productList,
      discountType: extraDiscountType,
      inputValue: extraDiscountInput,
    ));

    final double packingCharge = packingDiscountType == "%"
        ? (subTotalValue - discountValue - extraDiscountValue) *
            (packingDiscountInput / 100)
        : packingDiscountInput;

    return packingCharge.isNaN ? "0.00" : packingCharge.toStringAsFixed(2);
  }

  static String calculatePackingChargesInclusive({
    required List<InvoiceProductModel> productList,
    required String extraDiscountType,
    required double extraDiscountInput,
    required String packingDiscountType,
    required double packingDiscountInput,
  }) {
    final double subTotalValue =
        double.parse(calculateSubTotalInclusive(productList: productList));
    final double discountValue =
        double.parse(calculateDiscountInclusive(productList: productList));
    final double extraDiscountValue =
        double.parse(calculateExtraDiscountInclusive(
      productList: productList,
      discountType: extraDiscountType,
      inputValue: extraDiscountInput,
    ));

    final double packingCharge = packingDiscountType == "%"
        ? (subTotalValue - discountValue - extraDiscountValue) *
            (packingDiscountInput / 100)
        : packingDiscountInput;

    return packingCharge.isNaN ? "0.00" : packingCharge.toStringAsFixed(2);
  }

  /// Calculate the total cart value including discounts and packing charges
  static String calculateCartTotal({
    required List<InvoiceProductModel> productList,
    required String extraDiscountType,
    required double extraDiscountInput,
    required String packingDiscountType,
    required double packingDiscountInput,
    required bool taxType,
    required String gstType,
  }) {
    if (!taxType) {
      final double subTotalValue =
          double.parse(calculateSubTotal(productList: productList));
      final double discountValue =
          double.parse(calculateDiscount(productList: productList));
      final double extraDiscountValue = double.parse(calculateExtraDiscount(
        productList: productList,
        discountType: extraDiscountType,
        inputValue: extraDiscountInput,
      ));
      final double packingChargeValue = double.parse(calculatePackingCharges(
        productList: productList,
        extraDiscountType: extraDiscountType,
        extraDiscountInput: extraDiscountInput,
        packingDiscountType: packingDiscountType,
        packingDiscountInput: packingDiscountInput,
      ));

      final double totalValue =
          (subTotalValue - discountValue - extraDiscountValue) +
              packingChargeValue;

      return totalValue.isNaN ? "0.00" : totalValue.toStringAsFixed(2);
    } else {
      var taxTotal = calculateTax(
        gstType: gstType,
        productList: productList,
        extraDiscountType: extraDiscountType,
        extraDiscountInput: extraDiscountInput,
        packingDiscountInput: packingDiscountInput,
        packingDiscountType: packingDiscountType,
      )["total_tax"];
      final double subTotalValue =
          double.parse(calculateSubTotal(productList: productList));
      final double discountValue =
          double.parse(calculateDiscount(productList: productList));
      final double extraDiscountValue = double.parse(calculateExtraDiscount(
        productList: productList,
        discountType: extraDiscountType,
        inputValue: extraDiscountInput,
      ));
      final double packingChargeValue = double.parse(calculatePackingCharges(
        productList: productList,
        extraDiscountType: extraDiscountType,
        extraDiscountInput: extraDiscountInput,
        packingDiscountType: packingDiscountType,
        packingDiscountInput: packingDiscountInput,
      ));

      final double totalValue =
          (subTotalValue - discountValue - extraDiscountValue) +
              packingChargeValue;

      return totalValue.isNaN
          ? "0.00"
          : (totalValue + taxTotal).toStringAsFixed(2);
    }
  }

  static String calculateCartTotalInclusive({
    required List<InvoiceProductModel> productList,
    required String extraDiscountType,
    required double extraDiscountInput,
    required String packingDiscountType,
    required double packingDiscountInput,
    required bool taxType,
    required String gstType,
  }) {
    if (!taxType) {
      final double subTotalValue =
          double.parse(calculateSubTotalInclusive(productList: productList));
      final double discountValue =
          double.parse(calculateDiscountInclusive(productList: productList));
      final double extraDiscountValue =
          double.parse(calculateExtraDiscountInclusive(
        productList: productList,
        discountType: extraDiscountType,
        inputValue: extraDiscountInput,
      ));
      final double packingChargeValue =
          double.parse(calculatePackingChargesInclusive(
        productList: productList,
        extraDiscountType: extraDiscountType,
        extraDiscountInput: extraDiscountInput,
        packingDiscountType: packingDiscountType,
        packingDiscountInput: packingDiscountInput,
      ));

      final double totalValue =
          (subTotalValue - discountValue - extraDiscountValue) +
              packingChargeValue;

      return totalValue.isNaN ? "0.00" : totalValue.toStringAsFixed(2);
    } else {
      var taxTotal = calculateTax(
        gstType: gstType,
        productList: productList,
        extraDiscountType: extraDiscountType,
        extraDiscountInput: extraDiscountInput,
        packingDiscountInput: packingDiscountInput,
        packingDiscountType: packingDiscountType,
      )["total_tax"];
      final double subTotalValue =
          double.parse(calculateSubTotalInclusive(productList: productList));
      final double discountValue =
          double.parse(calculateDiscountInclusive(productList: productList));
      final double extraDiscountValue =
          double.parse(calculateExtraDiscountInclusive(
        productList: productList,
        discountType: extraDiscountType,
        inputValue: extraDiscountInput,
      ));
      final double packingChargeValue =
          double.parse(calculatePackingChargesInclusive(
        productList: productList,
        extraDiscountType: extraDiscountType,
        extraDiscountInput: extraDiscountInput,
        packingDiscountType: packingDiscountType,
        packingDiscountInput: packingDiscountInput,
      ));

      final double totalValue =
          (subTotalValue - discountValue - extraDiscountValue) +
              packingChargeValue;

      return totalValue.isNaN
          ? "0.00"
          : (totalValue + taxTotal).toStringAsFixed(2);
    }
  }

  /// Calculate the total for each product individually
  static String calculateEachProductTotal({
    required int index,
    required List<InvoiceProductModel> productList,
  }) {
    final product = productList[index];
    final double productPrice = product.discountLock != null &&
            !product.discountLock!
        ? (product.discount != null
            ? (product.rate! - (product.rate! * (product.discount! / 100))) *
                product.qty!
            : product.rate! * product.qty!)
        : product.rate! * product.qty!;

    return productPrice.toStringAsFixed(2);
  }

  static String calculateEachProductTotalInclusive({
    required int index,
    required List<InvoiceProductModel> productList,
  }) {
    final product = productList[index];
    final double productPrice = product.discountLock != null &&
            !product.discountLock!
        ? (product.discount != null
            ? (inclusiveRate(product.rate!, product.taxValue!) -
                    (inclusiveRate(product.rate!, product.taxValue!) *
                        (product.discount! / 100))) *
                product.qty!
            : inclusiveRate(product.rate!, product.taxValue!) * product.qty!)
        : inclusiveRate(product.rate!, product.taxValue!) * product.qty!;

    return productPrice.toStringAsFixed(2);
  }

  /// Calculate the overall total for net-rated products
  static double calculateOverallNetRatedTotal(
      List<InvoiceProductModel> productList) {
    return productList
        .where((product) => product.productType == ProductType.netRated)
        .fold(0.0, (total, product) => total + (product.rate! * product.qty!));
  }

  static double calculateOverallNetRatedTotalInclusive(
      List<InvoiceProductModel> productList) {
    return productList
        .where((product) => product.productType == ProductType.netRated)
        .fold(
            0.0,
            (total, product) =>
                total +
                (inclusiveRate(product.rate!, product.taxValue!) *
                    product.qty!));
  }

  /// Calculate the overall total for discounted products
  static double calculateOverallDiscountedTotal(
      List<InvoiceProductModel> productList) {
    return productList
        .where((product) => product.productType == ProductType.discounted)
        .fold(0.0, (total, product) {
      final double discountAmount =
          (product.rate! * product.qty!) * (product.discount! / 100);
      return total + ((product.rate! * product.qty!) - discountAmount);
    });
  }

  static double calculateOverallDiscountedTotalInclusive(
      List<InvoiceProductModel> productList) {
    return productList
        .where((product) => product.productType == ProductType.discounted)
        .fold(0.0, (total, product) {
      final double discountAmount =
          (inclusiveRate(product.rate!, product.taxValue!) * product.qty!) *
              (product.discount! / 100);
      return total +
          ((inclusiveRate(product.rate!, product.taxValue!) * product.qty!) -
              discountAmount);
    });
  }

  /// Calculate the discount data
  static Map<String, dynamic> discounts(List<InvoiceProductModel> productList) {
    double netRatedTotal = calculateOverallNetRatedTotal(productList);
    double discountedTotal = calculateOverallDiscountedTotal(productList);

    // Map to store each unique discount and its totals
    Map<String, Map<String, dynamic>> discountMap = {};

    // Loop through each product in the product list
    for (var product in productList) {
      if (product.productType == ProductType.discounted &&
          product.discount != null) {
        // Convert discount to a percentage string (e.g., "80%")
        String discountKey = product.discount!.toStringAsFixed(0);

        // Calculate the total for the current product without discount
        double productTotal = product.rate! * product.qty!;

        // Calculate the discount amount for the current product
        double discountAmount = productTotal * (product.discount! / 100);

        // Calculate the remaining amount after applying the discount
        double remainingAmount = productTotal - discountAmount;

        // Add or accumulate the discount totals in the map
        if (discountMap.containsKey(discountKey)) {
          discountMap[discountKey]!["without_applied_discount_total"] +=
              productTotal;
          discountMap[discountKey]!["subtracted_discount_from_total"] +=
              discountAmount;
          discountMap[discountKey]!["remaining_amount"] += remainingAmount;
        } else {
          discountMap[discountKey] = {
            "without_applied_discount_total": productTotal,
            "subtracted_discount_from_total": discountAmount,
            "remaining_amount": remainingAmount
          };
        }
      }
    }

    // Convert the discount map into a list for consistency with your structure
    List<Map<String, dynamic>> discountList = discountMap.entries.map((entry) {
      return {
        "discount_percentage": entry.key,
        "without_applied_discount_total":
            entry.value["without_applied_discount_total"],
        "subtracted_discount_from_total":
            entry.value["subtracted_discount_from_total"],
        "remaining_amount": entry.value["remaining_amount"]
      };
    }).toList();

    return {
      "overall_netrated_total": netRatedTotal,
      "overall_discounted_total": discountedTotal,
      "discounts": discountList
    };
  }

  static Map<String, dynamic> discountsInclusive(
      List<InvoiceProductModel> productList) {
    double netRatedTotal = calculateOverallNetRatedTotalInclusive(productList);
    double discountedTotal =
        calculateOverallDiscountedTotalInclusive(productList);

    // Map to store each unique discount and its totals
    Map<String, Map<String, dynamic>> discountMap = {};

    // Loop through each product in the product list
    for (var product in productList) {
      if (product.productType == ProductType.discounted &&
          product.discount != null) {
        // Convert discount to a percentage string (e.g., "80%")
        String discountKey = product.discount!.toStringAsFixed(0);

        // Calculate the total for the current product without discount
        double productTotal =
            (inclusiveRate(product.rate!, product.taxValue!)) * product.qty!;

        // Calculate the discount amount for the current product
        double discountAmount = productTotal * (product.discount! / 100);

        // Calculate the remaining amount after applying the discount
        double remainingAmount = productTotal - discountAmount;

        // Add or accumulate the discount totals in the map
        if (discountMap.containsKey(discountKey)) {
          discountMap[discountKey]!["without_applied_discount_total"] +=
              productTotal;
          discountMap[discountKey]!["subtracted_discount_from_total"] +=
              discountAmount;
          discountMap[discountKey]!["remaining_amount"] += remainingAmount;
        } else {
          discountMap[discountKey] = {
            "without_applied_discount_total": productTotal,
            "subtracted_discount_from_total": discountAmount,
            "remaining_amount": remainingAmount
          };
        }
      }
    }

    // Convert the discount map into a list for consistency with your structure
    List<Map<String, dynamic>> discountList = discountMap.entries.map((entry) {
      return {
        "discount_percentage": entry.key,
        "without_applied_discount_total":
            entry.value["without_applied_discount_total"],
        "subtracted_discount_from_total":
            entry.value["subtracted_discount_from_total"],
        "remaining_amount": entry.value["remaining_amount"]
      };
    }).toList();

    return {
      "overall_netrated_total": netRatedTotal,
      "overall_discounted_total": discountedTotal,
      "discounts": discountList
    };
  }

  static Map<String, dynamic> calculateTax(
      {required String gstType,
      required List<InvoiceProductModel> productList,
      required String extraDiscountType,
      required double extraDiscountInput,
      required String packingDiscountType,
      required double packingDiscountInput}) {
    Map<String, dynamic> tax = {};
    List<Map<String, dynamic>> products = [];
    List<Map<String, dynamic>> productTaxDetails = [];
    double totalTaxAmount = 0;

    for (var product in productList) {
      double discountedAmount = product.rate! * product.qty!;
      double productTaxAmount = 0;
      double extraDiscountTaxAmount = 0;

      // Apply product discount
      if (product.productType == ProductType.discounted) {
        discountedAmount -= product.discount! * product.rate! / 100;
      }

      // Apply extra discount (if % based)
      if (extraDiscountInput != 0.0 && extraDiscountType == "%") {
        extraDiscountTaxAmount = discountedAmount * extraDiscountInput / 100;
        discountedAmount -= extraDiscountTaxAmount;
      }

      // Calculate tax amount for product
      productTaxAmount = discountedAmount *
          double.parse(product.taxValue!.replaceAll('%', '')) /
          100;

      products.add({
        "product_name": product.productName,
        "product_rate": product.rate,
        "product_qty": product.qty,
        "product_tax": product.taxValue,
        "product_hsn": product.hsnCode,
        "discounted_amount": discountedAmount,
        "product_tax_amount": productTaxAmount,
      });

      productTaxDetails.add({
        "product_rate": discountedAmount,
        "product_tax": product.taxValue,
        "product_hsn": product.hsnCode,
      });

      totalTaxAmount += productTaxAmount;
    }

    // Step 2: Add packing charges if applicable (without adding to product tax amounts)
    if (packingDiscountInput != 0) {
      double highestTax = 0;
      double chargesTax = 0;

      // Find the highest tax rate in productList
      for (var product in productList) {
        double currentTax = double.parse(product.taxValue!.replaceAll('%', ''));
        if (currentTax > highestTax) {
          highestTax = currentTax;
        }
      }

      // Calculate packing charges and apply tax
      var packingCharges = calculatePackingCharges(
          productList: productList,
          extraDiscountType: extraDiscountType,
          extraDiscountInput: extraDiscountInput,
          packingDiscountInput: packingDiscountInput,
          packingDiscountType: packingDiscountType);
      chargesTax = double.parse(packingCharges) * highestTax / 100;
      totalTaxAmount += chargesTax;

      tax["packing_charges"] = {
        "highest_tax": highestTax,
        "packing_charges": packingCharges,
        "charges_tax": chargesTax,
      };
    }

    // Step 3: Serialize products based on HSN code and tax rate
    Map<String, Map<String, dynamic>> serializedProducts = {};

    for (var product in products) {
      String key = "${product['product_hsn']}_${product['product_tax']}";

      if (serializedProducts.containsKey(key)) {
        // Combine product amounts for the same HSN code and tax rate
        serializedProducts[key]!["product_rate"] +=
            product["discounted_amount"];
        serializedProducts[key]!["product_tax_amount"] +=
            product["product_tax_amount"];
      } else {
        // Add unique products to the map
        serializedProducts[key] = {
          "product_hsn": product["product_hsn"],
          "product_tax": product["product_tax"],
          "product_rate": product["discounted_amount"],
          "product_tax_amount": product["product_tax_amount"],
        };
      }
    }

    tax["tax_details"] = {
      "total_tax": totalTaxAmount,
      "products": serializedProducts.values.toList(),
    };

    tax["tax_type"] = gstType;
    tax["products"] = products;
    tax["total_tax"] = totalTaxAmount;
    return tax;
  }
}
