import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:package_info_plus/package_info_plus.dart';
import '/services/firebase/firebase.dart';
import '/services/firebase/local_service.dart';
import '../../log/log.dart';
import '../../model/model.dart';
import '../../provider/provider.dart';

class GetUpdateFromDB {
  Future<String?> getUpdate({required String platform}) async {
    try {
      var snapshot = await LocalService.getAppversion();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first.data();

        if (platform == 'android') {
          return doc['playstore_version'];
        } else if (platform == 'ios') {
          return doc['appstore_version'];
        } else {
          return doc['windows_version'];
        }
      } else {
        return null;
      }
    } catch (e) {
      Log.addLog("${DateTime.now()} : ${e.toString()}");

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
      } else {
        latestVersion = await GetUpdateFromDB().getUpdate(platform: 'windows');
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
      Log.addLog("${DateTime.now()} : ${e.toString()}");
      return false;
    }
  }
}

class AccessCode extends Firebase {
  static String _generateAccessCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<Map<String, dynamic>> createAccessCode() async {
    try {
      DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();

      String code = _generateAccessCode();
      DocumentReference docRef = await Firebase.accessCode.add({
        'code': code,
        'created_at': DateTime.now(),
        'is_cleared': false,
        'expired_at': DateTime.now().add(const Duration(minutes: 5)),
        'device_id': deviceInfo!.deviceId,
        'device_name': deviceInfo.deviceName,
        'device_type': deviceInfo.deviceType,
        'device_model': deviceInfo.modelName,
      });

      return {"code": code, "doc_id": docRef.id};
    } on Exception catch (e) {
      Log.addLog("${DateTime.now()} : $e");
      rethrow;
    }
  }

  static Future sendCodeToAdmin({required String code}) async {}

  static Future expireCode({required String code}) async {
    try {
      var result =
          await Firebase.accessCode.where('code', isEqualTo: code).get();
      if (result.docs.isNotEmpty) {
        for (var data in result.docs) {
          await Firebase.accessCode.doc(data.id).update({'is_cleared': true});
        }
      }
    } on Exception catch (e) {
      Log.addLog("${DateTime.now()} : $e");
      rethrow;
    }
  }
}
