import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '/constants/constants.dart';
import '/services/services.dart';

final _instances = FirebaseFirestore.instance;

class Storage {
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
    final cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    String? downloadLink;
    final uploadDir = storage.child("$cid/$filePath/$fileName.webp");

    try {
      final originalImageBytes = await fileData.readAsBytes();

      final compressedImageBytes = await FlutterImageCompress.compressWithList(
        originalImageBytes,
        format: CompressFormat.webp,
        quality: 75,
      );

      final compressedFile = File('${fileData.path}.webp')
        ..writeAsBytesSync(compressedImageBytes);

      if (!await compressedFile.exists()) {
        return null;
      }

      await uploadDir.putFile(compressedFile);
      downloadLink = await uploadDir.getDownloadURL();

      await compressedFile.delete();
    } catch (e) {
      print("Error: ${e.toString()}");
    }

    return downloadLink;
  }

  Future deleteImage(String? imageUrl) async {
    try {
      if (imageUrl != null) {
        final Reference storageRef =
            FirebaseStorage.instance.refFromURL(imageUrl);

        await storageRef.delete();
      }
    } catch (e) {
      print("Error deleting image: ${e.toString()}");
    }
  }

  Future<bool> saveLocal({
    required File fileData,
    required String id,
    required String folder,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final folderPath = '${directory.path}/$folder';

      final folderDirectory = Directory(folderPath);
      if (!await folderDirectory.exists()) {
        await folderDirectory.create(recursive: true);
      }

      final filePath = '$folderPath/$id';

      await fileData.copy(filePath).then((value) {
        return true;
      });

      print(filePath);
      return false;
    } catch (e) {
      LogConfig.addLog("${DateTime.now()} : ${e.toString()}");
      return false;
    }
  }
}
