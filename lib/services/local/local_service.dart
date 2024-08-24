import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sri_kot/services/database/localdb.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/enum.dart';
import '../../view/ui/src/modal.dart';

final _instances = FirebaseFirestore.instance;

class LocalService {
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
      // Create a reference to the base folder with cid
      final baseFolderRef = storage.child('$cid/');

      // List all prefixes (folders) under the base folder
      final listResult = await baseFolderRef.listAll();

      // Iterate through all folders (prefixes)
      for (final prefix in listResult.prefixes) {
        final folderName = prefix.name;

        // List all items (files) within the current folder
        final fileListResult = await prefix.listAll();

        // Fetch file details (filename and URL)
        final fileDetails =
            await Future.wait(fileListResult.items.map((item) async {
          final fileName = item.name;
          final url = await item.getDownloadURL();
          return {
            'filename': fileName,
            'url': url,
          };
        }).toList());

        // Add folder and file details to the result map
        result[folderName] = fileDetails;
      }
    } catch (e) {
      print('Error fetching files: $e');
    }

    return result;
  }

  static updateLogin({required String uid}) async {
    var result = await _instances.collection('profile').doc(uid).get();
    if (result.exists) {
      await _instances.collection('profile').doc(uid).update({
        "device.last_login": DateTime.now(),
      });
    }
  }

  static Future updateOpened({required String uid}) async {
    var result = await _instances.collection('profile').doc(uid).get();
    if (result.exists) {
      if (result["free_trial"]["opened"] == null) {
        await _instances.collection('profile').doc(uid).update({
          "free_trial": {
            "opened": DateTime.now(),
            "ends_in": DateTime.now().add(const Duration(days: 20))
          }
        });
      }
    }
  }

  static Future<Map> checkTrialEnd({required String uid}) async {
    try {
      var result =
          await FirebaseFirestore.instance.collection('profile').doc(uid).get();

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

  static Future<bool> deleteDevice({required String uid}) async {
    var result = await _instances.collection('profile').doc(uid).get();
    if (result.exists) {
      await _instances.collection('profile').doc(uid).update({
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
    var result = await _instances.collection('profile').doc(uid).get();
    if (result.exists) {
      await _instances.collection('profile').doc(uid).update(
        {"invoice_entry": invoiceEntry},
      );
      return true;
    }
    return false;
  }

  static Future<bool> checkCount({
    required String uid,
    required ProfileType type,
  }) async {
    try {
      var result = await _instances.collection('profile').doc(uid).get();

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
}
