import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/constants/constants.dart';
import '/view/ui/src/modal.dart';
import 'firebase.dart';

final _instances = FirebaseFirestore.instance;

class LocalService {
  static Future<Map> checkTrialEnd({required String uid}) async {
    try {
      var result = await Firebase.profile.doc(uid).get();

      if (result.exists) {
        var data = result.data();
        if (data != null) {
          var freeTrial = data["free_trial"];
          if (freeTrial != null) {
            var endsInTimestamp = freeTrial["ends_in"];
            if (endsInTimestamp != null) {
              DateTime endsInDateTime = (endsInTimestamp as Timestamp).toDate();
              DateTime now = DateTime.now();
              if (endsInDateTime.isBefore(now)) {
                return {
                  "ends_in": endsInTimestamp,
                  "is_end": true,
                };
              } else {
                return {
                  "ends_in": endsInTimestamp,
                  "is_end": false,
                };
              }
            }
          }
        }
      }
      return {
        "ends_in": "",
        "is_end": false,
      };
    } catch (e) {
      print('Error: $e');
      return {
        "ends_in": "",
        "is_end": false,
      };
    }
  }

  static Future<bool> checkFileAvailable() async {
    try {
      final storage = FirebaseStorage.instance.ref();
      final cid = await LocalDB.fetchInfo(type: LocalData.companyid);
      final folderRef = storage.child('$cid/');
      final result = await folderRef.listAll();
      return result.items.isNotEmpty || result.prefixes.isNotEmpty;
    } catch (e) {
      print('Error checking file availability: $e');
      return false;
    }
  }

  static Future<Map<String, List<Map<String, String>>>> getFiles() async {
    final storage = FirebaseStorage.instance.ref();
    final cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    final result = <String, List<Map<String, String>>>{};

    try {
      final baseFolderRef = storage.child('$cid/');
      final listResult = await baseFolderRef.listAll();
      for (final prefix in listResult.prefixes) {
        final folderName = prefix.name;
        final fileListResult = await prefix.listAll();
        final fileDetails =
            await Future.wait(fileListResult.items.map((item) async {
          final fileName = item.name;
          final url = await item.getDownloadURL();
          return {
            'filename': fileName,
            'url': url,
          };
        }).toList());
        result[folderName] = fileDetails;
      }
    } catch (e) {
      print('Error fetching files: $e');
    }

    return result;
  }

  static updateLogin({required String uid}) async {
    var result = await Firebase.getId(collection: Firebase.profile, docId: uid);
    if (result != null && result.exists) {
      await Firebase.profile.doc(uid).update({
        "device.last_login": DateTime.now(),
      });
    }
  }

  static Future updateOpened({required String uid}) async {
    var result = await Firebase.getId(collection: Firebase.profile, docId: uid);
    if (result != null && result.exists) {
      if (result["free_trial"]["opened"] == null) {
        await Firebase.update(
          collection: Firebase.profile,
          data: {
            "free_trial": {
              "opened": DateTime.now(),
              "ends_in": DateTime.now().add(const Duration(days: 20))
            }
          },
          docId: uid,
        );
      }
    }
  }

  static Future<bool> deleteDevice({required String uid}) async {
    var result = await Firebase.profile.doc(uid).get();
    if (result.exists) {
      await Firebase.profile.doc(uid).update({
        "device": {
          "device_id": null,
          "device_name": null,
          "device_type": null,
          "last_login": null,
          "model_name": null
        },
      });
      return true;
    }
    return false;
  }

  static Future<bool> updateInvoice(
      {required String uid, required bool invoiceEntry}) async {
    var result = await Firebase.profile.doc(uid).get();
    if (result.exists) {
      await Firebase.profile.doc(uid).update(
        {"invoice_entry": invoiceEntry},
      );
      return true;
    }
    return false;
  }

  static Future<bool> checkCount({
    required ProfileType type,
  }) async {
    var uid = await LocalDB.fetchInfo(type: LocalData.companyid) ?? '';
    try {
      var result = await Firebase.profile.doc(uid).get();

      if (!result.exists) {
        return false;
      }

      int userCount = await _getCount('users', uid);
      int staffCount = await _getCount('staff', uid);

      if (type == ProfileType.admin) {
        int maxUserCount = result.data()?['max_user_count'] ?? 0;
        return maxUserCount >= (userCount + 1);
      }

      if (type == ProfileType.staff) {
        int maxStaffCount = result.data()?['max_staff_count'] ?? 0;
        return maxStaffCount >= (staffCount + 1);
      }

      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  static Future<int> _getCount(String collection, String companyId) async {
    try {
      var snapshot = await _instances
          .collection(collection)
          .where('company_id', isEqualTo: companyId)
          .get();

      return snapshot.size;
    } catch (e) {
      print('Error getting count for $collection: $e');
      return 0;
    }
  }

  static callService(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return const Modal(
          title: "Call Us",
          content:
              "Call our customer service and book a free demo and we will be happy to help you.",
          type: ModalType.call,
        );
      },
    ).then(
      (value) async {
        if (value != null) {
          if (value) {
            final Uri launchUri = Uri(
              scheme: 'tel',
              path: "+91 8610061844",
            );
            await launchUrl(launchUri);
          }
        }
      },
    );
  }

  static Future<bool> updateCount({
    required String uid,
    required ProfileType type,
  }) async {
    try {
      var result = await Firebase.profile.doc(uid).get();

      if (!result.exists) {
        return false;
      } else {
        int previousCount = result["max_user_count"];
        print(previousCount);
        await Firebase.profile.doc(result.id).update({
          "max_user_count": previousCount + 1,
        });

        return true;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  static Future<bool> addPayment({
    required String uid,
    required PaymentType type,
  }) async {
    try {
      var result = await _instances.collection('payment').add({
        "company_id": uid,
        "created": DateTime.now(),
        "payment_type": type,
      });

      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // static Future insertCustomer(Map<String, dynamic> data) async {
  //   await Firebase.customer.add(data).then((value) {
  //     print("Data added");
  //   });
  // }

  static Future newEnquiry({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
    required String cid,
  }) async {
    try {
      List<Map<String, dynamic>> products =
          productList.map((item) => item.toMap()).toList();
      String productsJson = jsonEncode(products);

      var uniqueId = await LocalDB.fetchInfo(type: LocalData.loginEmail);
      final dbHelper = DatabaseHelper();
      var lastEnquiry = await LocalDB.getLastEnquiry();

      var data = {
        "customer": jsonEncode(customerInfo?.toOrderMap() ?? {}),
        "price": jsonEncode(calCulation.toMap()),
        "reference_id":
            "${uniqueId.toString().substring(0, 4).toUpperCase()}ENQ${lastEnquiry + 1}",
        "enquiry_id": null,
        "estimate_id": null,
        "company_id": cid,
        "created_date": DateTime.now().toIso8601String(),
        "delete_at": 0,
        "products": productsJson,
      };

      await dbHelper.checkAndCreateTable('enquiry');
      await dbHelper.insertEnquiry(orderData: data);
      await LocalDB.setLastEnquiry();
    } catch (e) {
      throw e.toString();
    }
  }

  static Future updateEnquiry({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
    required String cid,
    required String referenceId,
  }) async {
    try {
      List<Map<String, dynamic>> products =
          productList.map((item) => item.toMap()).toList();
      String productsJson = jsonEncode(products);

      final dbHelper = DatabaseHelper();

      var data = {
        "customer": jsonEncode(customerInfo?.toOrderMap() ?? {}),
        "price": jsonEncode(calCulation.toMap()),
        "enquiry_id": null,
        "estimate_id": null,
        "company_id": cid,
        "created_date": DateTime.now().toIso8601String(),
        "delete_at": 0,
        "products": productsJson,
      };

      await dbHelper.checkAndCreateTable('enquiry');
      await dbHelper.updateEnquiry(orderData: data, referenceId: referenceId);
    } catch (e) {
      print('Error updating enquiry: $e');
      rethrow;
    }
  }

  static Future newEstimate({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
    required String cid,
  }) async {
    try {
      final dbHelper = DatabaseHelper();

      List<Map<String, dynamic>> products =
          productList.map((item) => item.toMap()).toList();
      String productsJson = jsonEncode(products);

      var uniqueId = await LocalDB.fetchInfo(type: LocalData.loginEmail);
      var lastEstimate = await LocalDB.getLastEstimate();

      var data = {
        "customer": jsonEncode(customerInfo?.toOrderMap() ?? {}),
        "price": jsonEncode(calCulation.toMap()),
        "estimate_id": null,
        "reference_id":
            "${uniqueId.toString().substring(0, 4).toUpperCase()}EST${lastEstimate + 1}",
        "company_id": cid,
        "created_date": DateTime.now().toIso8601String(),
        "delete_at": 0,
        "products": productsJson,
      };

      await dbHelper.checkAndCreateTable('estimate');
      await dbHelper.insertEstimate(orderData: data);
      await LocalDB.setLastEstimate();
    } catch (e) {
      throw e.toString();
    }
  }

  static Future updateEstimate({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
    required String cid,
    required String referenceId,
  }) async {
    try {
      List<Map<String, dynamic>> products =
          productList.map((item) => item.toMap()).toList();
      String productsJson = jsonEncode(products);
      final dbHelper = DatabaseHelper();

      var data = {
        "customer": jsonEncode(customerInfo?.toOrderMap() ?? {}),
        "price": jsonEncode(calCulation.toMap()),
        "estimate_id": null,
        "company_id": cid,
        "created_date": DateTime.now().toIso8601String(),
        "delete_at": 0,
        "products": productsJson,
      };

      await dbHelper.checkAndCreateTable('estimate');
      await dbHelper.updateEstimate(orderData: data, referenceId: referenceId);
    } catch (e) {
      print('Error updating estimate: $e');
      rethrow;
    }
  }

  static Future enquiryToEstimate({
    required String referenceId,
    required String cid,
  }) async {
    try {
      final dbHelper = DatabaseHelper();
      var result = await dbHelper.getEnquiryWithId(referenceId);
      List<dynamic> products = jsonDecode(result['products']) as List<dynamic>;

      Map<String, dynamic> customer =
          jsonDecode(result['customer']) as Map<String, dynamic>;

      Map<String, dynamic> price =
          jsonDecode(result['price']) as Map<String, dynamic>;

      String productsJson = jsonEncode(products);

      var uniqueId = await LocalDB.fetchInfo(type: LocalData.loginEmail);
      var lastEstimate = await LocalDB.getLastEstimate();

      var data = {
        "customer": jsonEncode(customer),
        "price": jsonEncode(price),
        "estimate_id": null,
        "reference_id":
            "${uniqueId.toString().substring(0, 4).toUpperCase()}EST${lastEstimate + 1}",
        "company_id": cid,
        "created_date": DateTime.now().toIso8601String(),
        "delete_at": 0,
        "products": productsJson,
      };

      await dbHelper.checkAndCreateTable('estimate');
      await dbHelper.insertEstimate(orderData: data);
      await dbHelper.removeEnquiry(referenceId);
      await LocalDB.setLastEstimate();
    } catch (e) {
      throw e.toString();
    }
  }

  static Future deleteEnquiry({required String referenceId}) async {
    try {
      final dbHelper = DatabaseHelper();
      var result = await dbHelper.removeEnquiry(referenceId);
      await LocalDB.reverseEnquiry();
    } catch (e) {
      throw e.toString();
    }
  }

  static Future duplicateEnquiry({required String referenceId}) async {
    try {
      final dbHelper = DatabaseHelper();
      var result = await dbHelper.getEnquiryWithId(referenceId);

      var uniqueId = await LocalDB.fetchInfo(type: LocalData.loginEmail);
      var lastEnquiry = await LocalDB.getLastEnquiry();

      var data = {
        "customer": result['customer'],
        "price": result['price'],
        "estimate_id": null,
        "enquiry_id": null,
        "reference_id":
            "${uniqueId.toString().substring(0, 4).toUpperCase()}ENQ${lastEnquiry + 1}",
        "company_id": result['company_id'],
        "created_date": DateTime.now().toIso8601String(),
        "delete_at": 0,
        "products": result['products'],
      };

      await dbHelper.checkAndCreateTable('enquiry');
      await dbHelper.insertEnquiry(orderData: data);
      await LocalDB.setLastEnquiry();
    } catch (e) {
      throw e.toString();
    }
  }

  static Future updateCustomerInfo(
      {required CustomerDataModel? customerInfo,
      required String referenceId}) async {
    try {
      final dbHelper = DatabaseHelper();
      var result = await dbHelper.updateEnquiryCustomer(
          referenceId, jsonEncode(customerInfo?.toOrderMap() ?? {}));
    } catch (e) {
      throw e.toString();
    }
  }

  static Future deleteEstimate({required String referenceId}) async {
    try {
      final dbHelper = DatabaseHelper();
      var result = await dbHelper.removeEstimate(referenceId);
      await LocalDB.reverseEstimate();
    } catch (e) {
      throw e.toString();
    }
  }

  static Future duplicateEstimate({required String referenceId}) async {
    try {
      final dbHelper = DatabaseHelper();
      var result = await dbHelper.getEstimateWithId(referenceId);

      var uniqueId = await LocalDB.fetchInfo(type: LocalData.loginEmail);
      var lastEstimate = await LocalDB.getLastEstimate();

      var data = {
        "customer": result['customer'],
        "price": result['price'],
        "estimate_id": null,
        "reference_id":
            "${uniqueId.toString().substring(0, 4).toUpperCase()}EST${lastEstimate + 1}",
        "company_id": result['company_id'],
        "created_date": DateTime.now().toIso8601String(),
        "delete_at": 0,
        "products": result['products'],
      };

      await dbHelper.checkAndCreateTable('estimate');
      await dbHelper.insertEstimate(orderData: data);
      await LocalDB.setLastEstimate();
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<bool> syncNow() async {
    try {
      var localEnquiry = await DatabaseHelper().getEnquiry();
      var localEstimate = await DatabaseHelper().getEstimate();

      if (localEnquiry.isNotEmpty) {
        for (var data in localEnquiry) {
          var map = {
            "customer": jsonDecode(data['customer']) as Map<String, dynamic>,
            "price": jsonDecode(data['price']) as Map<String, dynamic>,
            "enquiry_id": null,
            "reference_id": data['reference_id'],
            "estimate_id": null,
            "company_id":
                await LocalDB.fetchInfo(type: LocalData.companyid) ?? '',
            "created_date": DateTime.now(),
            "delete_at": false,
          };

          await Firebase.insert(collection: Firebase.enquiry, data: map)
              .then((value) async {
            if (value != null) {
              final productsJson = data['products'] as String;
              final List<dynamic> productsList = jsonDecode(productsJson);

              for (var product in productsList) {
                await Firebase.enquiry
                    .doc(value)
                    .collection('products')
                    .add(product);
              }

              var count = await LocalService.getLastIdEnquiry();
              await Firebase.update(
                collection: Firebase.enquiry,
                docId: value,
                data: {
                  "enquiry_id":
                      "${DateTime.now().year}ENQ${(count!.count ?? 0) + 1}"
                },
              );
            }
          });
        }
      }

      if (localEstimate.isNotEmpty) {
        for (var data in localEstimate) {
          var map = {
            "customer": jsonDecode(data['customer']) as Map<String, dynamic>,
            "price": jsonDecode(data['price']) as Map<String, dynamic>,
            "estimate_id": null,
            "company_id":
                await LocalDB.fetchInfo(type: LocalData.companyid) ?? '',
            "created_date": DateTime.now(),
            "delete_at": false,
          };

          await Firebase.insert(collection: Firebase.estimate, data: map)
              .then((value) async {
            if (value != null) {
              final productsJson = data['products'] as String;
              final List<dynamic> productsList = jsonDecode(productsJson);

              for (var product in productsList) {
                await Firebase.estimate
                    .doc(value)
                    .collection('products')
                    .add(product);
              }

              var count = await LocalService.getLastIdEstimate();
              await Firebase.update(
                collection: Firebase.estimate,
                docId: value,
                data: {
                  "estimate_id":
                      "${DateTime.now().year}EST${(count!.count ?? 0) + 1}"
                },
              );
            }
          });
        }
      }

      await DatabaseHelper().clearBillRecords();

      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  static Future<AggregateQuerySnapshot?> getLastIdEnquiry() async {
    AggregateQuerySnapshot? resultData;
    try {
      resultData = await Firebase.enquiry
          .where('company_id',
              isEqualTo:
                  await LocalDB.fetchInfo(type: LocalData.companyid) ?? '')
          .where('enquiry_id', isNull: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  static Future<AggregateQuerySnapshot?> getLastIdEstimate() async {
    AggregateQuerySnapshot? resultData;
    try {
      resultData = await Firebase.estimate
          .where('company_id',
              isEqualTo:
                  await LocalDB.fetchInfo(type: LocalData.companyid) ?? '')
          .where('estimate_id', isNull: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  static Future syncProducts({
    required List<QueryDocumentSnapshot> productData,
    required String cid,
  }) async {
    final dbHelper = DatabaseHelper();

    try {
      await dbHelper.dropTable('product').then((value) async {
        await dbHelper.checkAndCreateTable('product').then((value) async {
          for (var value in productData) {
            var data = {
              "product_id": value.id,
              "active": value["active"] ? 1 : 0,
              "category_id": value["category_id"],
              "category_name": value["category_name"],
              "company_id": value["company_id"],
              "created_date_time": value["created_date_time"],
              "delete_at": value["delete_at"] ? 1 : 0,
              "discount_lock": value["discount_lock"] ? 1 : 0,
              "name": value["name"],
              "postion": value["postion"],
              "price": value["price"],
              "product_code": value["product_code"],
              "product_content": value["product_content"],
              "product_img": value["product_img"],
              "product_name": value["product_name"],
              "qr_code": value["qr_code"],
              "video_url": value["video_url"],
            };

            await dbHelper.insertProduct(data: data).then((value) {
              print("inserted");
            });
          }
        });
      });
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  static Future syncCategory({
    required List<QueryDocumentSnapshot> categoryData,
    required String cid,
  }) async {
    final dbHelper = DatabaseHelper();

    try {
      await dbHelper.dropTable('category').then((value) async {
        await dbHelper.checkAndCreateTable('category').then((value) async {
          if (categoryData.isNotEmpty) {
            for (var value in categoryData) {
              var data = {
                "category_id": value.id,
                "category_name": value["category_name"],
                "company_id": value["company_id"],
                "delete_at": value["delete_at"] ? 1 : 0,
                "discount": value["discount"],
                "name": value["name"],
                "postion": value["postion"],
              };

              await dbHelper.insertCategory(data: data).then((value) {
                print("inserted");
              });
            }
          }
        });
      });
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  static Future syncCustomer({
    required List<QueryDocumentSnapshot> customerData,
    required String cid,
  }) async {
    final dbHelper = DatabaseHelper();

    try {
      await dbHelper.dropTable('customer').then((value) async {
        await dbHelper.checkAndCreateTable('customer').then((value) async {
          if (customerData.isNotEmpty) {
            for (var value in customerData) {
              var data = {
                "customer_id": value.id,
                "address": value["address"],
                "city": value["city"],
                "company_id": value["company_id"],
                "customer_name": value["customer_name"],
                "email": value["email"],
                "mobile_no": value["mobile_no"],
                "state": value["state"],
              };

              await dbHelper.insertCustomer(data: data).then((value) {
                print("inserted");
              });
            }
          }
        });
      });
    } catch (e) {
      print(e);
      throw e.toString();
    }
  }

  static Future<String> parseDate(String? date) async {
    if (date != null) {
      var value = DateTime.parse(date);
      var result = DateFormat('dd-MM-yyyy h:m a').format(value);
      return result.toString();
    } else {
      return "--:--:--";
    }
  }

  static Future<List<QuerySnapshot>> getDeletedItems() async {
    var uid = await LocalDB.fetchInfo(type: LocalData.companyid);
    List<QuerySnapshot> result = [];

    try {
      var staff = await Firebase.staff
          .where('company_id', isEqualTo: uid)
          .where('deleted_at', isEqualTo: false)
          .get();
      result.add(staff);
      var product = await Firebase.product
          .where('company_id', isEqualTo: uid)
          .where('deleted_at', isEqualTo: false)
          .get();
      result.add(product);
      var enquiry = await Firebase.enquiry
          .where('company_id', isEqualTo: uid)
          .where('deleted_at', isEqualTo: false)
          .get();
      result.add(enquiry);
      var estimate = await Firebase.estimate
          .where('company_id', isEqualTo: uid)
          .where('deleted_at', isEqualTo: false)
          .get();
      result.add(estimate);
      return result;
    } on Exception catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAppversion() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await Firebase.appVersion
          .orderBy('created', descending: true)
          .limit(1)
          .get();

      return snapshot;
    } on Exception catch (e) {
      print(e);
      rethrow;
    }
  }
}
