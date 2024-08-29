import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/model/model.dart';
import '/services/services.dart';
import '/constants/enum.dart';
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
      final cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
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
    final cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
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
    var uid =
        await LocalDbProvider().fetchInfo(type: LocalData.companyid) ?? '';
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

      final dbHelper = DatabaseHelper();
      await dbHelper.checkAndCreateTable('enquiry');
      await dbHelper.insertEnquiry(orderData: data);
    } catch (e) {
      throw e.toString();
    }
  }

  static Future newEstimate({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
    required String cid,
  }) async {
    try {
      List<Map<String, dynamic>> products =
          productList.map((item) => item.toMap()).toList();
      String productsJson = jsonEncode(products);

      var data = {
        "customer": jsonEncode(customerInfo?.toOrderMap() ?? {}),
        "price": jsonEncode(calCulation.toMap()),
        "estimate_id": null,
        "company_id": cid,
        "created_date": DateTime.now().toIso8601String(),
        "delete_at": 0,
        "products": productsJson,
      };

      final dbHelper = DatabaseHelper();
      await dbHelper.checkAndCreateTable('estimate');
      await dbHelper.insertEstimate(orderData: data);
      print("Inserted");
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<bool> syncNow() async {
    var localEnquiry = await DatabaseHelper().getEnquiry();
    var localEstimate = await DatabaseHelper().getEstimate();

    for (var data in localEnquiry) {
      var map = {
        "customer": jsonDecode(data['customer']) as Map<String, dynamic>,
        "price": jsonDecode(data['price']) as Map<String, dynamic>,
        "enquiry_id": null,
        "estimate_id": null,
        "company_id":
            await LocalDbProvider().fetchInfo(type: LocalData.companyid) ?? '',
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

    for (var data in localEstimate) {
      var map = {
        "customer": jsonDecode(data['customer']) as Map<String, dynamic>,
        "price": jsonDecode(data['price']) as Map<String, dynamic>,
        "estimate_id": null,
        "company_id":
            await LocalDbProvider().fetchInfo(type: LocalData.companyid) ?? '',
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

    await DatabaseHelper().clearTableRecords();

    return true;
  }

  static Future<AggregateQuerySnapshot?> getLastIdEnquiry() async {
    AggregateQuerySnapshot? resultData;
    try {
      resultData = await Firebase.enquiry
          .where('company_id',
              isEqualTo: await LocalDbProvider()
                      .fetchInfo(type: LocalData.companyid) ??
                  '')
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
              isEqualTo: await LocalDbProvider()
                      .fetchInfo(type: LocalData.companyid) ??
                  '')
          .where('estimate_id', isNull: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }
}
