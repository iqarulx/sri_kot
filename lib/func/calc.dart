import '/constants/constants.dart';
import '/model/model.dart';

class Calc {
  /// Calculate the total discount for the product list
  static String calculateDiscount({required List<CartDataModel> productList}) {
    double totalDiscount = productList
        .where((product) => product.productType == ProductType.discounted)
        .fold(0.0, (sum, product) {
      final double productTotal = product.price! * product.qty!;
      final double discountAmount =
          productTotal * (product.discount!.toDouble() / 100);
      return sum + discountAmount;
    });

    return totalDiscount.toStringAsFixed(2);
  }

  /// Calculate the extra discount based on the provided percentage or fixed amount
  static String calculateExtraDiscount({
    required List<CartDataModel> productList,
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

  /// Calculate the round-off value of the total amount
  static String calculateRoundOff({
    required List<CartDataModel> productList,
    required String extraDiscountType,
    required double extraDiscountInput,
    required String packingDiscountType,
    required double packingDiscountInput,
  }) {
    final double totalValue = double.parse(calculateCartTotal(
      productList: productList,
      extraDiscountType: extraDiscountType,
      extraDiscountInput: extraDiscountInput,
      packingDiscountType: packingDiscountType,
      packingDiscountInput: packingDiscountInput,
    ));
    final double decimalPart = totalValue - totalValue.toInt();
    return decimalPart.toStringAsFixed(2);
  }

  /// Count the total quantity of items in the cart
  static String calculateCartItemCount(
      {required List<CartDataModel> productList}) {
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
  static String calculateSubTotal({required List<CartDataModel> productList}) {
    final double subTotal = productList.fold(
      0.0,
      (sum, product) => sum + (product.price! * product.qty!),
    );
    return subTotal.toStringAsFixed(2);
  }

  /// Calculate the packing charges
  static String calculatePackingCharges({
    required List<CartDataModel> productList,
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

  /// Calculate the total cart value including discounts and packing charges
  static String calculateCartTotal({
    required List<CartDataModel> productList,
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
  }

  /// Calculate the total for each product individually
  static String calculateEachProductTotal({
    required int index,
    required List<CartDataModel> productList,
  }) {
    final product = productList[index];
    final double productPrice = product.discountLock != null &&
            !product.discountLock!
        ? (product.discount != null
            ? (product.price! - (product.price! * (product.discount! / 100))) *
                product.qty!
            : product.price! * product.qty!)
        : product.price! * product.qty!;

    return productPrice.toStringAsFixed(2);
  }

  /// Calculate the overall total for net-rated products
  static double calculateOverallNetRatedTotal(List<CartDataModel> productList) {
    return productList
        .where((product) => product.productType == ProductType.netRated)
        .fold(0.0, (total, product) => total + (product.price! * product.qty!));
  }

  /// Calculate the overall total for discounted products
  static double calculateOverallDiscountedTotal(
      List<CartDataModel> productList) {
    return productList
        .where((product) => product.productType == ProductType.discounted)
        .fold(0.0, (total, product) {
      final double discountAmount =
          (product.price! * product.qty!) * (product.discount! / 100);
      return total + ((product.price! * product.qty!) - discountAmount);
    });
  }

  static Map<String, dynamic> discounts(List<CartDataModel> productList) {
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
        double productTotal = product.price! * product.qty!;

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
}
