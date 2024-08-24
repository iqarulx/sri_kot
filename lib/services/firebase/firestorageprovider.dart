import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import '/constants/enum.dart';
import '/services/services.dart';

final _instances = FirebaseFirestore.instance;

class FireStorageProvider {
  final storage = FirebaseStorage.instance.ref();

  Future<String?> checkImage({
    required String uid,
    required String collection,
  }) async {
    final admin = _instances.collection('users');
    final staff = _instances.collection('staff');
    final products = _instances.collection('products');
    final company = _instances.collection('company');
    try {
      if (collection == 'users') {
        var result = await admin.doc(uid).get();
        if (result.exists) {
          return result["image_url"];
        }
      }
      if (collection == 'staff') {
        var result = await staff.doc(uid).get();
        if (result.exists) {
          return result["profile_img"];
        }
      }
      if (collection == 'company') {
        var result = await company.doc(uid).get();
        if (result.exists) {
          return result["company_logo"];
        }
      }
      if (collection == 'products') {
        var result = await products.doc(uid).get();
        if (result.exists) {
          return result["product_img"];
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String?> uploadImage({
    required File fileData,
    required String fileName,
    required String filePath,
  }) async {
    final cid = await LocalDbProvider().fetchInfo(type: LocalData.companyid);
    String? downloadLink;
    final uploadDir = storage.child("$cid/$filePath/$fileName");
    try {
      await uploadDir.putFile(fileData);
      downloadLink = await uploadDir.getDownloadURL();
    } catch (e) {
      print(e);
    }
    return downloadLink;
  }

  Future<bool> saveLocal({
    required File fileData,
    required String id,
    required String folder,
  }) async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();

      // Define the folder path
      final folderPath = '${directory.path}/$folder';

      // Create the folder if it does not exist
      final folderDirectory = Directory(folderPath);
      if (!await folderDirectory.exists()) {
        await folderDirectory.create(recursive: true);
      }

      // Define the path where the file will be saved
      final filePath = '$folderPath/$id';

      // Copy the file to the new location
      await fileData.copy(filePath).then((value) {
        return true;
      });

      print(filePath);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
