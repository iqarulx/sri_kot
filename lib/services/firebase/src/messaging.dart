import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '/constants/constants.dart';
import '/services/services.dart';
import '/model/model.dart';
import '/provider/provider.dart';

class Messaging extends FirebaseQuery {
  static const String fcmUrl =
      'https://fcm.googleapis.com/v1/projects/sri-kot/messages:send';

  static Future<Map<String, dynamic>> loadServiceAccount() async {
    return jsonDecode(serviceData);
  }

  static Future<String> getAccessToken() async {
    final credentials = await loadServiceAccount();
    var accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  static Future sendMessage(
      {required String fcmId,
      required String title,
      required String body,
      required String redirect,
      required String notificationId}) async {
    try {
      final accessToken = await getAccessToken();

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "message": {
            "token": fcmId,
            "notification": {"title": title, "body": body},
            "data": {"redirect": redirect, "notification_id": notificationId},
            "android": {"priority": "high"}
          }
        }),
      );
    } catch (e) {
      LogConfig.addLog("${DateTime.now()} : Error sending FCM message: $e");
    }
  }

  static Future sendCodeToAdmin(
      {required String code, required String docId}) async {
    DeviceModel? deviceInfo = await DeviceInformation().getDeviceInfo();
    var admins = await FirebaseQuery.admin.get();
    if (admins.docs.isNotEmpty) {
      for (var admin in admins.docs) {
        var fcmId = admin["fcm_id"];
        if (fcmId != null) {
          await sendMessage(
            title: "Access Code Request - Code : $code",
            body:
                "Device Name : ${deviceInfo!.deviceName}\nModel : ${deviceInfo.modelName}\nDevice Type : ${deviceInfo.deviceType}",
            fcmId: fcmId,
            redirect: "accesscode",
            notificationId: docId,
          );
        }
      }
    }
  }

  static Future sendPaymentToAdmin(
      {required String amount,
      required String product,
      required String docId}) async {
    var companyName = await LocalDB.fetchInfo(type: LocalData.companyName);
    var admins = await FirebaseQuery.admin.get();
    if (admins.docs.isNotEmpty) {
      for (var admin in admins.docs) {
        var fcmId = admin["fcm_id"];
        if (fcmId != null) {
          await sendMessage(
            title: "$product purchased",
            body: "$product $amount purchased by $companyName",
            fcmId: fcmId,
            redirect: "purchases",
            notificationId: docId,
          );
        }
      }
    }
  }

  static Future sendNewCompanyAdmin(
      {required String companyName, required String docId}) async {
    var companyName = await LocalDB.fetchInfo(type: LocalData.companyName);
    var admins = await FirebaseQuery.admin.get();
    if (admins.docs.isNotEmpty) {
      for (var admin in admins.docs) {
        var fcmId = admin["fcm_id"];
        if (fcmId != null) {
          await sendMessage(
            title: "New company registered",
            body: "$companyName is newly registered",
            fcmId: fcmId,
            redirect: "newcompany",
            notificationId: docId,
          );
        }
      }
    }
  }
}
