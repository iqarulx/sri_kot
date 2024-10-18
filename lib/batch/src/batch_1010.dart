// Update function for version 1.0.10

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/services/func/func.dart';

final _instances = FirebaseFirestore.instance;

class Version1110Function {
  static final _profile = _instances.collection('profile');
  static final _products = _instances.collection('products');
  static final _category = _instances.collection('category');
  static final _enquiry = _instances.collection('enquiry');
  static final _estimate = _instances.collection('estimate');
  static final _invoice = _instances.collection('invoice');

  static Future<List<String>> getCompany() async {
    try {
      var p = await _profile.get();
      List<String> l = [];
      for (var i in p.docs) {
        l.add(i.id);
      }
      return l;
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  static Future updateCategory() async {
    try {
      // pl = profile list
      var pl = await getCompany();

      if (pl.isNotEmpty) {
        for (var i in pl) {
          // cl = category list
          var cl = await _category.where('company_id', isEqualTo: i).get();
          for (var j in cl.docs) {
            Map<String, dynamic> c = j.data();
            if (!c.containsKey('hsn_code') && !c.containsKey('tax_value')) {
              await _category
                  .doc(j.id)
                  .update({'hsn_code': null, 'tax_value': null});
              print(
                  "Category tax updated : ${j['category_name']}${j['company_id']}");

              productTaxUpdate(j.id);
            }
            // if (c.containsKey('discount')) {
            //   //product list
            //   var pdl =
            //       await _products.where('category_id', isEqualTo: j.id).get();
            //   for (var k in pdl.docs) {
            //     await _products.doc(k.id).update({'discount': j['discount']});
            //     print(
            //         "Product discount updated : ${k['product_name']} ${c['discount']}");
            //   }
            // }
          }
        }
      }
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  static Future productTaxUpdate(String cid) async {
    try {
      var pl = await _products.where('category_id', isEqualTo: cid).get();
      if (pl.docs.isNotEmpty) {
        for (var m in pl.docs) {
          await _products
              .doc(m.id)
              .update({'hsn_code': null, 'tax_value': null});

          print("Product tax updated : ${m['product_name']}");
        }
      }
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  static Future<int?> getDiscount(String d) async {
    var dis = await _products.doc(d).get();
    if (dis.exists) {
      var data = dis.data();
      return data!.containsKey("discount") ? dis["discount"] : null;
    }
    return null;
  }

  static Future<String?> getTax(String d) async {
    var tax = await _products.doc(d).get();
    if (tax.exists) {
      var data = tax.data();
      return data!.containsKey("tax_value") ? tax["tax_value"] : null;
    }
    return null;
  }

  static Future<String?> getHSN(String d) async {
    var hsn = await _products.doc(d).get();
    if (hsn.exists) {
      var data = hsn.data();
      return data!.containsKey("hsn_code") ? hsn["hsn_code"] : null;
    }
    return null;
  }

  static Future<String?> getCategoryId(String d) async {
    var dis = await _products.doc(d).get();
    if (dis.exists) {
      return dis["category_id"];
    }
    return null;
  }

  static updateEnquiry() async {
    try {
      var cl = await getCompany();

      var el = await _enquiry.get();
      print(el.docs.length);

      for (var d = 0; d < el.docs.length; d++) {
        var i = el.docs[d];

        if (i.exists) {
          List<CartDataModel> cartList = [];
          var pc = await _enquiry.doc(i.id).collection('products').get();
          for (var p in pc.docs) {
            CartDataModel cart = CartDataModel();
            cart.categoryId = await getCategoryId(p["product_id"]);
            cart.categoryName = p["category_name"];
            cart.price = p["price"];
            cart.productId = p["product_id"];
            cart.productName = p["product_name"];
            cart.discountLock = p["discount_lock"];
            cart.productCode = p["product_code"];
            cart.productContent = p["product_content"];
            cart.productImg = p["product_img"];
            cart.qrCode = p["qr_code"];
            cart.qty = p["qty"];
            cart.discount = await getDiscount(p["product_id"]);
            cart.taxValue = await getTax(p["product_id"]);
            cart.hsnCode = await getHSN(p["product_id"]);
            cart.qtyForm = TextEditingController(
              text: cart.qty.toString(),
            );
            cart.docID = p.id;
            cart.productType = cart.discountLock! || cart.discount == null
                ? ProductType.netRated
                : ProductType.discounted;
            cartList.add(cart);

            await _enquiry
                .doc(i.id)
                .collection('products')
                .doc(p.id)
                .update({'discount': await getDiscount(p["product_id"])});
          }

          var calc = BillingCalCulationModel();
          var cd = i["price"];

          calc.discountValue =
              double.parse(Calc.calculateDiscount(productList: cartList));
          calc.extraDiscount = cd["extra_discount"];
          calc.extraDiscountValue = double.parse(Calc.calculateExtraDiscount(
              productList: cartList,
              discountType: cd["extra_discount_sys"],
              inputValue: cd["extra_discount"]));
          calc.extraDiscountsys = cd["extra_discount_sys"];
          calc.package = cd["package"];
          calc.packageValue = double.parse(Calc.calculatePackingCharges(
              productList: cartList,
              extraDiscountType: cd["extra_discount_sys"],
              extraDiscountInput: cd["extra_discount"],
              packingDiscountType: cd["package_sys"],
              packingDiscountInput: cd["package"]));
          calc.packagesys = cd["package_sys"];
          calc.subTotal =
              double.parse(Calc.calculateSubTotal(productList: cartList));
          calc.roundOff = double.parse(Calc.calculateRoundOff(
              productList: cartList,
              extraDiscountType: cd["extra_discount_sys"],
              extraDiscountInput: cd["extra_discount"],
              packingDiscountType: cd["package_sys"],
              packingDiscountInput: cd["package"]));
          calc.total = double.parse(Calc.calculateCartTotal(
                  productList: cartList,
                  extraDiscountType: cd["extra_discount_sys"],
                  extraDiscountInput: cd["extra_discount"],
                  packingDiscountType: cd["package_sys"],
                  packingDiscountInput: cd["package"])) -
              double.parse(Calc.calculateRoundOff(
                  productList: cartList,
                  extraDiscountType: cd["extra_discount_sys"],
                  extraDiscountInput: cd["extra_discount"],
                  packingDiscountType: cd["package_sys"],
                  packingDiscountInput: cd["package"]));
          calc.netratedTotal = Calc.calculateOverallNetRatedTotal(cartList);
          calc.discountedTotal = Calc.calculateOverallDiscountedTotal(cartList);
          calc.discounts = Calc.discounts(cartList);
          calc.netPlusDisTotal = Calc.calculateOverallNetRatedTotal(cartList) +
              Calc.calculateOverallDiscountedTotal(cartList);

          await _enquiry.doc(i.id).update({
            "price": calc.toMap(),
          });

          print(
              "${d + 1}.Enquiry updated : ${i["enquiry_id"]}(${i["company_id"]})");
        }
      }
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  static updateEstimate() async {
    try {
      var el = await _estimate.get();
      print(el.docs.length);
      for (var d = 0; d < el.docs.length; d++) {
        var i = el.docs[d];
        if (i.exists) {
          List<CartDataModel> cartList = [];
          var pc = await _estimate.doc(i.id).collection('products').get();
          for (var p in pc.docs) {
            CartDataModel cart = CartDataModel();
            cart.categoryId = p["category_id"];
            cart.categoryName = p["category_name"];
            cart.price = p["price"];
            cart.productId = p["product_id"];
            cart.productName = p["product_name"];
            cart.discountLock = p["discount_lock"];
            cart.productCode = p["product_code"];
            cart.productContent = p["product_content"];
            cart.productImg = p["product_img"];
            cart.qrCode = p["qr_code"];
            cart.qty = p["qty"];
            cart.discount = await getDiscount(p["product_id"]);
            cart.taxValue = await getTax(p["product_id"]);
            cart.hsnCode = await getHSN(p["product_id"]);
            cart.productType = cart.discountLock! || cart.discount == null
                ? ProductType.netRated
                : ProductType.discounted;
            cart.qtyForm = TextEditingController(
              text: cart.qty.toString(),
            );
            cart.docID = p.id;

            cartList.add(cart);

            await _estimate
                .doc(i.id)
                .collection('products')
                .doc(p.id)
                .update({'discount': await getDiscount(p["product_id"])});
          }

          var calc = BillingCalCulationModel();
          var cd = i["price"];

          calc.discountValue =
              double.parse(Calc.calculateDiscount(productList: cartList));

          calc.extraDiscount = cd["extra_discount"];
          calc.extraDiscountValue = double.parse(Calc.calculateExtraDiscount(
              productList: cartList,
              discountType: cd["extra_discount_sys"],
              inputValue: cd["extra_discount"]));
          calc.extraDiscountsys = cd["extra_discount_sys"];
          calc.package = cd["package"];
          calc.packageValue = double.parse(Calc.calculatePackingCharges(
              productList: cartList,
              extraDiscountType: cd["extra_discount_sys"],
              extraDiscountInput: cd["extra_discount"],
              packingDiscountType: cd["package_sys"],
              packingDiscountInput: cd["package"]));
          calc.packagesys = cd["package_sys"];
          calc.subTotal =
              double.parse(Calc.calculateSubTotal(productList: cartList));
          calc.roundOff = double.parse(Calc.calculateRoundOff(
              productList: cartList,
              extraDiscountType: cd["extra_discount_sys"],
              extraDiscountInput: cd["extra_discount"],
              packingDiscountType: cd["package_sys"],
              packingDiscountInput: cd["package"]));
          calc.total = double.parse(Calc.calculateCartTotal(
                  productList: cartList,
                  extraDiscountType: cd["extra_discount_sys"],
                  extraDiscountInput: cd["extra_discount"],
                  packingDiscountType: cd["package_sys"],
                  packingDiscountInput: cd["package"])) -
              double.parse(Calc.calculateRoundOff(
                  productList: cartList,
                  extraDiscountType: cd["extra_discount_sys"],
                  extraDiscountInput: cd["extra_discount"],
                  packingDiscountType: cd["package_sys"],
                  packingDiscountInput: cd["package"]));
          calc.netratedTotal = Calc.calculateOverallNetRatedTotal(cartList);
          calc.discountedTotal = Calc.calculateOverallDiscountedTotal(cartList);
          calc.discounts = Calc.discounts(cartList);
          calc.netPlusDisTotal = Calc.calculateOverallNetRatedTotal(cartList) +
              Calc.calculateOverallDiscountedTotal(cartList);

          await _estimate.doc(i.id).update({"price": calc.toMap()});

          print(
              "${d + 1}.Estimate updated : ${i["estimate_id"]}(${i["company_id"]})");
        }
      }
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  static Future updateInvoice() async {
    var il = await _invoice.get();

    print(il.docs.length);
    for (var d = 0; d < il.docs.length; d++) {
      var i = il.docs[d];
      if (i.exists) {
        Map<String, dynamic> c = i.data();

        if (!c.containsKey('state') && !c.containsKey('city')) {
          List<InvoiceProductModel> model = [];
          var pc = i["products"];
          for (var j in pc) {
            var invoice = InvoiceProductModel();
            invoice.categoryID = j["category_id"];
            invoice.rate = j["rate"];
            invoice.total = j["rate"] * j["qty"];
            invoice.productID = j["product_id"];
            invoice.productName = j["product_name"];
            invoice.discountLock = j["discount_lock"];
            invoice.unit = j["unit"];
            invoice.taxValue = await getTax(j["product_id"]);
            invoice.hsnCode = await getHSN(j["product_id"]);
            invoice.discount = await getDiscount(j["product_id"]);
            invoice.qty = j["qty"];
            invoice.productType =
                invoice.discountLock ?? false || invoice.discount == null
                    ? ProductType.netRated
                    : ProductType.discounted;
            if (invoice.productType == ProductType.discounted) {
              invoice.discountedPrice = j["rate"].toDouble() -
                  (j["rate"] * invoice.discount!.toDouble() / 100);
            }

            model.add(invoice);
          }

          InvoiceModel invoice = InvoiceModel();
          var cd = i["price"];

          invoice.totalBillAmount =
              (double.parse(InvoiceCalc.calculateCartTotal(
                        productList: model,
                        gstType: '',
                        extraDiscountType: cd["extra_discount_sys"],
                        extraDiscountInput: cd["extra_discount"],
                        packingDiscountType: cd["package_sys"],
                        packingDiscountInput: cd["package"],
                        taxType: false,
                      )) -
                      InvoiceCalc.calculateRoundOff(
                        productList: model,
                        gstType: '',
                        extraDiscountType: cd["extra_discount_sys"],
                        extraDiscountInput: cd["extra_discount"],
                        packingDiscountType: cd["package_sys"],
                        packingDiscountInput: cd["package"],
                        taxType: false,
                      )["round_off_value"])
                  .toStringAsFixed(2);

          var calc = BillingCalCulationModel();

          calc.discountValue =
              double.parse(InvoiceCalc.calculateDiscount(productList: model));
          calc.extraDiscount = cd["extra_discount"];
          calc.extraDiscountValue = double.parse(
              InvoiceCalc.calculateExtraDiscount(
                  productList: model,
                  discountType: cd["extra_discount_sys"],
                  inputValue: cd["extra_discount"]));
          calc.extraDiscountsys = cd["extra_discount_sys"];
          calc.package = cd["package"];
          calc.packageValue = double.parse(InvoiceCalc.calculatePackingCharges(
              productList: model,
              extraDiscountType: cd["extra_discount_sys"],
              extraDiscountInput: cd["extra_discount"],
              packingDiscountType: cd["package_sys"],
              packingDiscountInput: cd["package"]));
          calc.packagesys = cd["package_sys"];
          calc.subTotal =
              double.parse(InvoiceCalc.calculateSubTotal(productList: model));
          calc.roundOff = InvoiceCalc.calculateRoundOff(
            productList: model,
            gstType: '',
            extraDiscountType: cd["extra_discount_sys"],
            extraDiscountInput: cd["extra_discount"],
            packingDiscountType: cd["package_sys"],
            packingDiscountInput: cd["package"],
            taxType: false,
          )["round_off_value"]
              .toDouble();

          calc.total = (double.parse(InvoiceCalc.calculateCartTotal(
            productList: model,
            gstType: '',
            extraDiscountType: cd["extra_discount_sys"],
            extraDiscountInput: cd["extra_discount"],
            packingDiscountType: cd["package_sys"],
            packingDiscountInput: cd["package"],
            taxType: false,
          )).roundToDouble());

          invoice.price = calc;

          await _invoice.doc(i.id).update({
            'price': calc.toMap(),
            'products': [
              for (var data in model) data.toCreateMap(),
            ],
            'tax_type': false,
            'gst_type': null,
            'is_same_state': false,
            'state': null,
            'city': null
          });

          print(
              "${d + 1}.Invoice updated : ${i["bill_no"]}(${i["company_id"]})");
          if (d == il.docs.length) {
            print('Completed');
          }
        }
      }
    }
  }
}

class Update1110 extends StatefulWidget {
  const Update1110({super.key});

  @override
  State<Update1110> createState() => _Update1110State();
}

class _Update1110State extends State<Update1110> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1.1.10'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: Version1110Function.updateCategory,
            child: Text('Category Update'),
          ),
          ElevatedButton(
            onPressed: Version1110Function.updateEnquiry,
            child: Text('Enquiry Update'),
          ),
          ElevatedButton(
            onPressed: Version1110Function.updateEstimate,
            child: Text('Estimate Update'),
          )
        ],
      ),
    );
  }
}
