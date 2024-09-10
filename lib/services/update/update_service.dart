import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart' show PlatformException;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sri_kot/services/local/local_service.dart';

class GetUpdateFromDB {
  Future<String?> getUpdate({required String platform}) async {
    try {
      var snapshot = await LocalService.getAppversion();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first.data();

        if (platform == 'android') {
          return doc['playstore_version'];
        } else {
          return doc['appstore_version'];
        }
      } else {
        return null;
      }
    } catch (e) {
      log("Error: $e");
      return null;
    }
  }
}

class UpdateService {
  static Future<bool> isUpdateAvailable() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      String? latestVersion;
      if (Platform.isAndroid) {
        latestVersion = await GetUpdateFromDB().getUpdate(platform: 'android');
      } else if (Platform.isIOS) {
        latestVersion = await GetUpdateFromDB().getUpdate(platform: 'ios');
      }

      if (latestVersion != null) {
        if (latestVersion == currentVersion) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    } on PlatformException catch (e) {
      log("Error: ${e.message}");
      return false;
    }
  }
}
