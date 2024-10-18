import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services.dart';
import '/constants/src/enum.dart';
import '/constants/constants.dart';
import '/model/model.dart';
import '/utils/src/utilities.dart';

final _instances = FirebaseFirestore.instance;

class FireStore {
  final _profile = _instances.collection('profile');
  final _admin = _instances.collection('users');
  final _staff = _instances.collection('staff');
  final _customer = _instances.collection('customer');
  final _products = _instances.collection('products');
  final _category = _instances.collection('category');
  final _enquiry = _instances.collection('enquiry');
  final _estimate = _instances.collection('estimate');
  final _invoice = _instances.collection('invoice');
  final _invoiceSettings = _instances.collection('invoice_settings');
  final _state = _instances.collection('state');

  Future<QuerySnapshot> getCompany({required String email}) async {
    try {
      var data = await _profile.where('user_login_id', isEqualTo: email).get();
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<QuerySnapshot?> getCompanyInfo({required String uid}) async {
    try {
      var data = await _profile.where('uid', isEqualTo: uid).get();
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> getCompanyTax() async {
    try {
      var uid = await LocalDB.fetchInfo(type: LocalData.companyid);
      var data = await _profile.doc(uid).get();
      if (data.exists) {
        if (data.data()!.containsKey('tax_type')) {
          return data["tax_type"];
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getCompanyState() async {
    try {
      var uid = await LocalDB.fetchInfo(type: LocalData.companyid);
      var data = await _profile.doc(uid).get();
      if (data.exists) {
        if (data.data()!.containsKey('state')) {
          return data["state"];
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String?> getCompanyProfileImg() async {
    try {
      var uid = await LocalDB.fetchInfo(type: LocalData.companyid);
      var data = await _profile.doc(uid).get();
      if (data.exists) {
        if (data.data()!.containsKey('profile_img')) {
          return data["profile_img"];
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<int> getInvoiceCount() async {
    try {
      var u = await LocalDB.fetchInfo(type: LocalData.companyid);
      var d = await _invoice.where('company_id', isEqualTo: u).get();
      return d.docs.length;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<QuerySnapshot?> getUserInfo({required String uid}) async {
    try {
      var data = await _admin.where('uid', isEqualTo: uid).get();
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getState() async {
    try {
      var data = await _state.get();

      if (data.docs.isNotEmpty) {
        var state = List<String>.from(data.docs.first.data().keys);
        state.sort();
        return state;
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getCity({required String state}) async {
    try {
      var data = await _state.get();

      for (var doc in data.docs) {
        if (doc.data().containsKey(state)) {
          var cities = List<String>.from(doc.data()[state]);
          cities.sort();
          return cities;
        }
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addCustomCity(
      {required String city, required String state}) async {
    try {
      var data = await _state.get();

      if (data.docs.isNotEmpty && data.docs.first.exists) {
        var currentDoc = data.docs.first.data();

        if (currentDoc.containsKey(state)) {
          var currentCities = List<String>.from(currentDoc[state]);

          var lowercaseCities =
              currentCities.map((c) => c.toLowerCase()).toList();

          if (lowercaseCities.contains(city.toLowerCase())) {
            return false;
          }

          await _state.doc(data.docs.first.id).set({
            state: FieldValue.arrayUnion([city])
          }, SetOptions(merge: true));

          return true;
        }
      }

      return false;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool?> getInvoiceAvailable({required String uid}) async {
    try {
      var data = await _profile.doc(uid).get();
      if (data.exists) {
        if (data["invoice_entry"]) {
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool?> isEnterpriseUser() async {
    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    try {
      var data = await _profile.doc(cid).get();
      if (data.exists) {
        if (data["user_type"] == "enterprise") {
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkComapanyEmailExists({required String email}) async {
    try {
      var company =
          await _profile.where('user_login_id', isEqualTo: email).get();
      if (company.docs.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> registerCompany(context,
      {required ProfileModel profileInfo}) async {
    try {
      return await _profile
          .add(profileInfo.initRegisterCompany())
          .then((value) {
        return value.id;
      });
    } catch (e) {
      snackbar(context, false, "Firestore: ${e.toString()}");
      return null;
    }
  }

  Future updateCompanyInfo({required ProfileModel profileInfo}) async {
    try {
      await _profile
          .doc(profileInfo.docId)
          .update(profileInfo.newRegisterCompany());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> initiCompanyaUpdate(context,
      {required ProfileModel profileInfo}) async {
    try {
      return await _profile.add(profileInfo.newRegisterCompany()).then((value) {
        return value.id;
      });
    } catch (e) {
      snackbar(context, false, "Firestore ${e.toString()}");
      return null;
    }
  }

  Future<DocumentSnapshot?> getCompanyDocInfo({required String cid}) async {
    try {
      return await _profile.doc(cid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getAllCompany() async {
    try {
      return await _profile.get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getAdminInfo({required String uid}) async {
    try {
      return await _admin.where('user_login_id', isEqualTo: uid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getStaffListing({required String cid}) async {
    try {
      return await _staff.where('company_id', isEqualTo: cid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getStaffInfo({
    required String uid,
    String? cid,
  }) async {
    try {
      if (cid == null) {
        return await _staff.where('user_login_id', isEqualTo: uid).get();
      } else {
        return await _admin.where('company_id', isEqualTo: cid).get();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot?> getStaffdocInfo({
    required String cid,
  }) async {
    try {
      return await _staff.doc(cid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot?> getEnquiryInfo({
    required String cid,
  }) async {
    try {
      return await _enquiry.doc(cid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot?> getEstimateInfo({
    required String cid,
  }) async {
    try {
      return await _estimate.doc(cid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot?> getInvoiceInfo({
    required String cid,
  }) async {
    try {
      return await _invoice.doc(cid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserType?> findWhichUserlogin({required String uid}) async {
    UserType? resultData;
    try {
      var result = await getStaffInfo(uid: uid);

      if (result != null && result.docs.isNotEmpty) {
        resultData = UserType.staff;
      } else {
        var result = await getAdminInfo(uid: uid);
        if (result != null && result.docs.isNotEmpty) {
          resultData = UserType.admin;
        } else {
          resultData = UserType.accountHolder;
        }
      }
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<bool?> registerNewDevice(
    context, {
    required DeviceModel deviceData,
    required UserType type,
    required String docid,
  }) async {
    var testMode = await LocalDB.checkTestMode();
    if (!testMode) {
      if (type == UserType.accountHolder) {
        try {
          final deviceDataMap = deviceData.toMap();
          final documentRef = _profile.doc(docid);
          await documentRef.update({
            'device': deviceDataMap,
          });
          return true;
        } catch (e) {
          LogConfig.addLog("${DateTime.now()} : Error updating document: $e");
          return false;
        }
      } else if (type == UserType.staff) {
        try {
          final deviceDataMap = deviceData.toMap();
          final documentRef = _staff.doc(docid);
          await documentRef.update({
            'device': deviceDataMap,
          });
          return true;
        } catch (e) {
          LogConfig.addLog("${DateTime.now()} : Error updating document: $e");
          return false;
        }
      } else if (type == UserType.admin) {
        try {
          final deviceDataMap = deviceData.toMap();
          final documentRef = _admin.doc(docid);
          await documentRef.update({
            'device': deviceDataMap,
          });
          return true;
        } catch (e) {
          LogConfig.addLog("${DateTime.now()} : Error updating document: $e");
          return false;
        }
      }
    } else {
      return true;
    }

    return false;
  }

  Future<QuerySnapshot?> checkLoginDeviceInfo(
    context, {
    required String uid,
    required DeviceModel deviceData,
    required UserType type,
  }) async {
    QuerySnapshot? resultData;
    try {
      if (type == UserType.accountHolder) {
        resultData = await _profile
            .where('user_login_id', isEqualTo: uid)
            .where('device.device_id', isEqualTo: deviceData.deviceId)
            .where('device.model_name', isEqualTo: deviceData.modelName)
            .where('device.device_name', isEqualTo: deviceData.deviceName)
            .get()
            .catchError((onError) {
          throw onError;
        });
      } else if (type == UserType.admin) {
        await getAdminInfo(uid: uid).then((value) async {
          if (value != null && value.docs.isNotEmpty) {
            resultData = await _admin
                .where('device.device_id', isEqualTo: deviceData.deviceId)
                .where('device.model_name', isEqualTo: deviceData.modelName)
                .where('device.device_name', isEqualTo: deviceData.deviceName)
                .get();
          } else {
            throw "Login Credential Not Match";
          }
        }).catchError((onError) {
          throw onError;
        });
      } else if (type == UserType.staff) {
        await getStaffInfo(uid: uid).then((value) async {
          if (value != null && value.docs.isNotEmpty) {
            resultData = await _staff
                .where('device.device_id', isEqualTo: deviceData.deviceId)
                .where('device.model_name', isEqualTo: deviceData.modelName)
                .where('device.device_name', isEqualTo: deviceData.deviceName)
                .get();
          } else {
            throw "Login Credential Not Match";
          }
        }).catchError((onError) {
          throw onError;
        });
      }
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<bool> checkExpiry(
      {required String uid, required UserType type}) async {
    try {
      if (type == UserType.accountHolder) {
        var result = await _profile.where('uid', isEqualTo: uid).get();
        if (result.docs.isNotEmpty) {
          var expiryDate = result.docs.first["expiry_date"].toDate();
          var now = DateTime.now();

          return expiryDate.isAfter(now);
        } else {
          return false;
        }
      } else {
        var result = await _profile.doc(uid).get();
        if (result.exists) {
          var expiryDate = result["expiry_date"].toDate();
          var now = DateTime.now();

          return expiryDate.isAfter(now);
        } else {
          return false;
        }
      }
    } on Exception catch (e) {
      LogConfig.addLog("${DateTime.now()} : ${e.toString()}");

      return false;
    }
  }

  Future<QuerySnapshot?> userListing({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _admin
          .where('company_id', isEqualTo: cid)
          .orderBy('created_date_time', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> customerListing() async {
    QuerySnapshot? resultData;

    try {
      var uid = await LocalDB.fetchInfo(type: LocalData.companyid);
      resultData = await _customer.where('company_id', isEqualTo: uid).get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future deleteAllCustomer() async {
    try {
      var uid = await LocalDB.fetchInfo(type: LocalData.companyid);

      var data = await _customer.where('company_id', isEqualTo: uid).get();
      if (data.docs.isNotEmpty) {
        for (var i in data.docs) {
          await _customer.doc(i.id).delete();
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<QuerySnapshot?> productListing({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _products
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('created_date_time', descending: true)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> productBilling(
      {required String cid, required String categoryId}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _products
          .where('company_id', isEqualTo: cid)
          .where('category_id', isEqualTo: categoryId)
          .orderBy('postion', descending: false)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<bool> checkCategoryExist({
    required String categoryName,
    String? docId,
  }) async {
    try {
      var u = await LocalDB.fetchInfo(type: LocalData.companyid);

      var query = _category
          .where('company_id', isEqualTo: u)
          .where('name', isEqualTo: categoryName);

      if (docId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: docId);
      }

      var docRef = await query.get();

      if (docRef.docs.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<QuerySnapshot?> categoryListing({required String cid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _category
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('postion', descending: false)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<DocumentSnapshot?> getCategorydocInfo({
    required String docid,
  }) async {
    try {
      return await _category.doc(docid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getcategoryLimit({
    required int startPostion,
    required int endPostion,
    required String cid,
  }) async {
    QuerySnapshot? querySnapshot;
    try {
      querySnapshot = await _category
          .where('postion', isGreaterThanOrEqualTo: startPostion)
          .where('postion', isLessThanOrEqualTo: endPostion)
          .where('company_id', isEqualTo: cid)
          .orderBy('postion', descending: false)
          .get();
    } catch (e) {
      rethrow;
    }
    return querySnapshot;
  }

  Future<DocumentReference> registerUserAdmin({
    required UserAdminModel userData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _admin.add(userData.toMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<QuerySnapshot?> checkStaffAlreadyExist(
      {required String loginID}) async {
    QuerySnapshot? docRef;
    try {
      docRef = await _staff.where('user_login_id', isEqualTo: loginID).get();
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<DocumentReference> registerStaff({
    required StaffDataModel staffData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _staff.add(staffData.toCreateMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<void> updateStaff({
    required StaffDataModel staffData,
    required String docID,
  }) async {
    try {
      return await _staff.doc(docID).update(staffData.toMapUpdate());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteStaffDevice({
    required String docID,
  }) async {
    try {
      return await _staff.doc(docID).update({"device": DeviceModel().toMap()});
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteUserDevice({required String docID}) async {
    try {
      await _admin.doc(docID).update({"device": DeviceModel().toMap()});
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateProfileStaff({
    required StaffDataModel staffData,
    required String docID,
  }) async {
    try {
      return await _staff.doc(docID).update(staffData.totoMapUpdateImage());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool?> updateUser({
    required String docID,
    required UserAdminModel userData,
  }) async {
    try {
      await _admin
          .doc(docID)
          .set(userData.updateMap(), SetOptions(merge: true))
          .then((value) {
        return true;
      }).catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    return false;
  }

  Future<DocumentReference> registerCustomer({
    required CustomerDataModel customerData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _customer.add(customerData.toMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<bool> checkCustomerMobileNoRegistered({
    required String mobileNo,
    String? docId,
  }) async {
    try {
      var u = await LocalDB.fetchInfo(type: LocalData.companyid);

      var query = _customer
          .where('company_id', isEqualTo: u)
          .where('mobile_no', isEqualTo: mobileNo);

      if (docId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: docId);
      }

      var docRef = await query.get();

      if (docRef.docs.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> checkCustomerIdentityRegistered({
    required String identificationNo,
    String? docId,
  }) async {
    try {
      var u = await LocalDB.fetchInfo(type: LocalData.companyid);

      var query = _customer
          .where('company_id', isEqualTo: u)
          .where('identification_no', isEqualTo: identificationNo);

      if (docId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: docId);
      }

      var docRef = await query.get();

      if (docRef.docs.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Future updateIdentification() async {
  //   var ref = await _customer.get();
  //   if (ref.docs.isNotEmpty) {
  //     for (var i in ref.docs) {
  //       await _customer.doc(i.id).update({"pincode": null});
  //     }
  //   }
  // }

  Future<DocumentReference> registerProduct({
    required ProductDataModel productsData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _products.add(productsData.toMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future<String?> getCategoryTax({required String categoryId}) async {
    try {
      var data = await _category.doc(categoryId).get();
      if (data.exists) {
        if (data.data()!.containsKey("tax_value")) {
          return data["tax_value"];
        }
      }
      return null;
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  Future<String?> getCategoryHsn({required String categoryId}) async {
    try {
      var data = await _category.doc(categoryId).get();
      if (data.exists) {
        if (data.data()!.containsKey("hsn_code")) {
          return data["hsn_code"];
        }
      }
      return null;
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  Future<bool?> excelMultiProduct({
    required List<ProductDataModel> productsData,
    required String cid,
  }) async {
    bool? result;
    var db = FirebaseFirestore.instance;
    var batch = db.batch();
    try {
      for (var element in productsData) {
        await _searchProduct(productName: element.productName!)
            .then((value) async {
          DocumentReference productDoc;
          if (value != null && value.docs.isNotEmpty) {
            productDoc = value.docs.first.reference;
            element.postion = value.docs.first["postion"];
          } else {
            productDoc = _products.doc();
            var resultData = await getLastPostionProduct(
              cid: cid,
              categoryID: element.categoryid!,
            ).catchError((onError) {
              throw onError.toString();
            });
            if (resultData != null && resultData.docs.isNotEmpty) {
              element.postion = resultData.docs.first["postion"] + 1;
            } else {
              element.postion = 1;
            }
          }
          batch.set(productDoc, element.toMap());
        });
      }
      await batch.commit().then((value) {
        result = true;
      }).catchError((onError) {
        throw onError;
      });
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<DocumentSnapshot?> getProductPostion({required String docID}) async {
    DocumentSnapshot? dataResult;
    try {
      dataResult = await _products.doc(docID).get();
    } catch (e) {
      throw e.toString();
    }
    return dataResult;
  }

  Future<QuerySnapshot?> getProductLimit({
    required int startPostion,
    required int endPostion,
    required String cid,
    required String categoryID,
  }) async {
    QuerySnapshot? querySnapshot;
    try {
      querySnapshot = await _products
          .where('postion', isGreaterThanOrEqualTo: startPostion)
          .where('postion', isLessThanOrEqualTo: endPostion)
          .where('company_id', isEqualTo: cid)
          .where('category_id', isEqualTo: categoryID)
          .orderBy('postion', descending: false)
          .get();
    } catch (e) {
      rethrow;
    }
    return querySnapshot;
  }

  Future updateProductPostion({
    required String docId,
    required int postionValue,
  }) async {
    try {
      return await _products.doc(docId).update({
        "postion": postionValue,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<DocumentSnapshot?> getCategoryPostion({required String docID}) async {
    DocumentSnapshot? dataResult;
    try {
      dataResult = await _category.doc(docID).get();
    } catch (e) {
      throw e.toString();
    }
    return dataResult;
  }

  Future updatePostion({
    required String docId,
    required int postionValue,
  }) async {
    try {
      return await _category.doc(docId).update({
        "postion": postionValue,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<QuerySnapshot?> getLastPostionCategory({required String cid}) async {
    QuerySnapshot? dataResult;
    try {
      dataResult = await _category
          .where('company_id', isEqualTo: cid)
          .orderBy('postion', descending: true)
          .limit(1)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return dataResult;
  }

  Future<QuerySnapshot?> getLastPostionProduct(
      {required String cid, required String categoryID}) async {
    QuerySnapshot? dataResult;
    try {
      dataResult = await _products
          .where('company_id', isEqualTo: cid)
          .where('category_id', isEqualTo: categoryID)
          .orderBy('postion', descending: true)
          .limit(1)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return dataResult;
  }

  Future<String?> excelGetCategory(
      {required String cid, required String categoryName}) async {
    String? categoryId;
    try {
      await _searchCategory(categoryName: categoryName, cid: cid)
          .then((value) async {
        if (value != null && value.docs.isNotEmpty) {
          categoryId = value.docs.first.id;
        } else {
          int postion = 1;
          var resultData =
              await getLastPostionCategory(cid: cid).catchError((onError) {
            throw onError.toString();
          });
          if (resultData != null && resultData.docs.isNotEmpty) {
            postion = resultData.docs.first["postion"] + 1;
          }

          var categoryData = CategoryDataModel();
          categoryData.categoryName = categoryName;
          categoryData.cid = cid;
          categoryData.postion = postion;
          categoryData.name =
              categoryName.replaceAll(' ', '').trim().toLowerCase();
          categoryData.deleteAt = false;

          await registerCategory(categoryData: categoryData)
              .then((value) async {
            if (value.id.isNotEmpty) {
              categoryId = value.id;
            } else {}
          }).catchError((onError) {
            throw onError;
          });
        }
      }).catchError((onError) {});
    } catch (e) {
      throw e.toString();
    }
    return categoryId;
  }

  Future<QuerySnapshot?> _searchCategory(
      {required String categoryName, required String cid}) async {
    QuerySnapshot? resultData;
    try {
      String tmpcate = categoryName.replaceAll(' ', '').trim().toLowerCase();
      resultData = await _category
          .where(
            'name',
            isEqualTo: tmpcate,
          )
          .where("company_id", isEqualTo: cid)
          .get()
          .catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> _searchProduct({required String productName}) async {
    QuerySnapshot? resultData;
    try {
      String tmpProduct = productName.replaceAll(' ', '').trim().toLowerCase();
      resultData = await _products
          .where(
            'name',
            isEqualTo: tmpProduct,
          )
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<DocumentReference> registerCategory({
    required CategoryDataModel categoryData,
  }) async {
    DocumentReference docRef;
    try {
      docRef = await _category.add(categoryData.toMap());
    } catch (e) {
      throw e.toString();
    }
    return docRef;
  }

  Future updateCategory({
    required String docID,
    required CategoryDataModel categoryData,
  }) async {
    try {
      await _category.doc(docID).update(categoryData.toUpdateMap());
      await updateProductTax(categoryData: categoryData, categoryId: docID);
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateProductTax(
      {required String categoryId,
      required CategoryDataModel categoryData}) async {
    try {
      var uid = await LocalDB.fetchInfo(type: LocalData.companyid);

      var productBatch = FirebaseFirestore.instance.batch();
      var products = await _products
          .where('company_id', isEqualTo: uid)
          .where('category_id', isEqualTo: categoryId)
          .get();
      for (var element in products.docs) {
        var document = _products.doc(element.id);
        productBatch.update(document, {
          "tax_value": categoryData.taxValue,
          "hsn_code": categoryData.hsnCode
        });
      }

      await productBatch.commit().catchError(
          (error) => throw ('Failed to execute batch write: $error'));
    } on Exception catch (e) {
      throw e.toString();
    }
  }

  Future categoryDiscountCreate(
      {required List<CategoryDataModel> unselectedCategory,
      required List<CategoryDataModel> uploadCategory}) async {
    try {
      var uid = await LocalDB.fetchInfo(type: LocalData.companyid);
      var categoryBatch = FirebaseFirestore.instance.batch();
      for (var element in uploadCategory) {
        var document = _category.doc(element.tmpcatid);
        categoryBatch.update(document, element.toDiscountUpdate());

        var productBatch = FirebaseFirestore.instance.batch();
        var products = await _products
            .where('company_id', isEqualTo: uid)
            .where('category_id', isEqualTo: element.tmpcatid)
            .get();
        for (var element in products.docs) {
          var document = _products.doc(element.id);
          productBatch
              .update(document, {"discount": uploadCategory.first.discount});
        }

        await productBatch.commit().catchError(
            (error) => throw ('Failed to execute batch write: $error'));
      }

      await categoryBatch.commit().catchError(
          (error) => throw ('Failed to execute batch write: $error'));

      var unselectedCategoryBatch = FirebaseFirestore.instance.batch();
      for (var element in unselectedCategory) {
        var document = _category.doc(element.tmpcatid);
        unselectedCategoryBatch.update(document, {"discount": null});

        await unselectedCategoryBatch.commit().catchError(
            (error) => throw ('Failed to execute batch write: $error'));

        var unselectedProductBatch = FirebaseFirestore.instance.batch();
        var unselectedProducts = await _products
            .where('company_id', isEqualTo: uid)
            .where('category_id', isEqualTo: element.tmpcatid)
            .get();
        for (var element in unselectedProducts.docs) {
          var document = _products.doc(element.id);
          unselectedProductBatch.update(document, {"discount": null});
        }

        await unselectedProductBatch.commit().catchError(
            (error) => throw ('Failed to execute batch write: $error'));
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> deleteCategory({
    required String docID,
  }) async {
    try {
      var p = await _products.where('category_id', isEqualTo: docID).get();
      if (p.docs.isEmpty) {
        await _category.doc(docID).delete();
        return {"success": true, "msg": "Successfully deleted"};
      } else {
        return {"success": false, "msg": "This category have products"};
      }
    } catch (e) {
      return {"success": false, "msg": "$e"};
    }
  }

  Future deleteEnquiry({
    required String docID,
  }) async {
    try {
      // return await _enquiry.doc(docID).update({"delete_at": true});
      return await _enquiry.doc(docID).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteStaff({
    required String docID,
  }) async {
    try {
      return await _staff.doc(docID).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteCustomer({
    required String docID,
  }) async {
    try {
      return await _customer.doc(docID).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteEstimate({
    required String docID,
  }) async {
    try {
      // return await _estimate.doc(docID).update({"delete_at": true});
      return await _estimate.doc(docID).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  Future duplicateEnquiry({required String docID, required String cid}) async {
    try {
      await _enquiry.doc(docID).get().catchError((onError) {
        throw onError;
      }).then((enquiry) async {
        if (enquiry.exists && enquiry.data() != null) {
          await _enquiry
              .add(enquiry.data()!)
              .catchError((onError) => throw onError)
              .then((newEnquiry) async {
            if (newEnquiry.id.isNotEmpty) {
              await _enquiry.doc(newEnquiry.id).update({
                'enquiry_id': null,
                'created_date': DateTime.now(),
                'estimate_id': null,
              });
              await _enquiry
                  .doc(docID)
                  .collection('products')
                  .get()
                  .then((oldEnquiryProducts) async {
                if (oldEnquiryProducts.docs.isNotEmpty) {
                  for (var element in oldEnquiryProducts.docs) {
                    if (element.exists) {
                      await _enquiry
                          .doc(newEnquiry.id)
                          .collection("products")
                          .add(element.data());
                    }
                  }
                }
              });

              return await updateEnquiryId(cid: cid, docID: newEnquiry.id);
            }
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future duplicateEstimate({required String docID, required String cid}) async {
    try {
      await _estimate.doc(docID).get().catchError((onError) {
        throw onError;
      }).then((estimate) async {
        if (estimate.exists && estimate.data() != null) {
          await _estimate
              .add(estimate.data()!)
              .catchError((onError) => throw onError)
              .then((newEstimate) async {
            if (newEstimate.id.isNotEmpty) {
              await _estimate.doc(newEstimate.id).update({
                'created_date': DateTime.now(),
                'estimate_id': null,
              });
              await _estimate
                  .doc(docID)
                  .collection('products')
                  .get()
                  .then((oldestimateProducts) async {
                if (oldestimateProducts.docs.isNotEmpty) {
                  for (var element in oldestimateProducts.docs) {
                    if (element.exists) {
                      await _estimate
                          .doc(newEstimate.id)
                          .collection("products")
                          .add(element.data());
                    }
                  }
                }
              });

              return await updateEstimateId(cid: cid, docID: newEstimate.id);
            }
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future orderToConvertEstimate({
    required String cid,
    required String docID,
  }) async {
    try {
      await _enquiry.doc(docID).get().catchError((onError) {
        throw onError;
      }).then((enquiry) async {
        await _estimate
            .add(
          enquiry.data()!,
        )
            .catchError((onError) {
          throw onError;
        }).then((estimate) async {
          if (estimate.id.isNotEmpty) {
            await _enquiry
                .doc(docID)
                .collection('products')
                .get()
                .then((tmpEnquiryProducts) async {
              if (tmpEnquiryProducts.docs.isNotEmpty) {
                for (var element in tmpEnquiryProducts.docs) {
                  await _estimate
                      .doc(estimate.id)
                      .collection('products')
                      .add(element.data());
                }
              }
            });

            await updateEstimateId(cid: cid, docID: estimate.id)
                .then((value) async {
              // await getEstimate(cid: cid, start: 0, end: 0, isLimitPage: false)
              //     .then((estimateInfo) async {
              //   if (estimateInfo.isNotEmpty) {
              //     return await _enquiry.doc(docID).update(
              //       {"estimate_id": estimateInfo.first["estimate_id"]},
              //     );
              //   }
              // });
            });
          }
        });
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<AggregateQuerySnapshot?> _getLastId({required String cid}) async {
    AggregateQuerySnapshot? resultData;
    try {
      resultData = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where('enquiry_id', isNull: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future updateEnquiryCustomer(
      {required String docId,
      required String address,
      required String city,
      required String companyId,
      required String customerId,
      required String customerName,
      required String email,
      required String mobileNo,
      required String state}) async {
    try {
      var data = await _enquiry.doc(docId).get();
      return await _enquiry.doc(docId).update({
        'customer.address': address,
        'customer.city': city,
        'customer.company_id': companyId,
        'customer.customer_id': customerId,
        'customer.customer_name': customerName,
        'customer.email': email,
        'customer.mobile_no': mobileNo,
        'customer.state': state,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<DocumentSnapshot?> getEstimateId({required String docid}) async {
    DocumentSnapshot? resultData;
    try {
      resultData = await _estimate.doc(docid).get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future updateEnquiryEstimateId({
    required String enquirdDocId,
    required String estimateId,
  }) async {
    try {
      await getEstimateId(docid: estimateId).then((value) async {
        if (value != null && value.exists) {
          return await _enquiry.doc(enquirdDocId).update({
            'estimate_id': value["estimate_id"],
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> getNextEnquiryId({
    required String cid,
  }) async {
    int? resultValue;
    try {
      var count = await _getLastId(cid: cid);
      if (count != null) {
        resultValue = count.count;
        var newEnquiryId = "${DateTime.now().year}ENQ${count.count! + 1}";
        return newEnquiryId;
      }
    } catch (e) {
      throw e.toString();
    }
    return null;
  }

  Future<int?> updateEnquiryId({
    required String cid,
    required String docID,
  }) async {
    int? resultValue;
    try {
      var count = await _getLastId(cid: cid);

      if (count != null) {
        resultValue = count.count;

        var newEnquiryId = "${DateTime.now().year}ENQ${count.count! + 1}";
        await _enquiry.doc(docID).set(
          {"enquiry_id": newEnquiryId},
          SetOptions(merge: true),
        );

        return resultValue;
      } else {
        print('Count is null for cid: $cid');
        return null;
      }
    } catch (e) {
      print('Error updating enquiry ID: $e');
      rethrow;
    }
  }

  Future<DocumentReference?> createnewEnquiry({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
    required String cid,
    required String billNo,
  }) async {
    DocumentReference? resultDocument;
    try {
      var data = {
        "customer": customerInfo?.toOrderMap(),
        "price": calCulation.toMap(),
        "enquiry_id": billNo,
        "estimate_id": null,
        "company_id": cid,
        "created_date": DateTime.now(),
        "delete_at": false,
      };
      resultDocument = await _enquiry.add(data);
      if (resultDocument.id.isNotEmpty) {
        await insertEnquiryProduct(
          productList: productList,
          docID: resultDocument.id,
        );
      }
    } catch (e) {
      throw e.toString();
    }
    return resultDocument;
  }

  Future insertEnquiryProduct({
    required List<CartDataModel> productList,
    required String docID,
  }) async {
    try {
      for (var product in productList) {
        await _enquiry.doc(docID).collection('products').add(
              product.toMap(),
            );
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getEnquiry(
      {required String cid, required int start, required int end}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('created_date', descending: true)
          .limit(end)
          .get();

      if (snapshot.docs.length <= start) {
        return [];
      }

      int docsToTake = (snapshot.docs.length - start);

      if (docsToTake > (end - start)) {
        docsToTake = end - start;
      }

      return snapshot.docs.skip(start).take(docsToTake).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEnquiryTotal({required String cid}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .get();
      var total = 0.0;
      for (var data in snapshot.docs) {
        total += data["price"]["total"].toDouble();
      }

      return {"total": total, "total_enquiry": snapshot.docs.length};
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getEstimate(
      {required String cid,
      required int start,
      required int end,
      required bool isLimitPage}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _estimate
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('created_date', descending: true)
          .limit(end)
          .get();

      if (snapshot.docs.length <= start) {
        return [];
      }

      int docsToTake = (snapshot.docs.length - start);

      if (docsToTake > (end - start)) {
        docsToTake = end - start;
      }

      return snapshot.docs.skip(start).take(docsToTake).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllEstimate(
      {required String cid}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _estimate
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('created_date', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllEnquiry(
      {required String cid}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .orderBy('created_date', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEstimateTotal({required String cid}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _estimate
          .where('company_id', isEqualTo: cid)
          .where('delete_at', isEqualTo: false)
          .get();
      var total = 0.0;
      for (var i = 0; i < snapshot.docs.length; i++) {
        var j = snapshot.docs[i];
        print("$i.${j["price"]["total"].toDouble()}");

        total += j["price"]["total"].toDouble();
      }

      return {"total": total, "total_estimate": snapshot.docs.length};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getInvoiceTotal({required String cid}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _invoice
          .where('company_id', isEqualTo: cid)
          .where("delete_at", isEqualTo: false)
          .get();
      var total = 0.0;
      for (var data in snapshot.docs) {
        total += data["price"]["total"].toDouble();
      }

      return {"total": total, "total_invoice": snapshot.docs.length};
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getInvoice(
      {required int start, required int end}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _invoice
          .where('company_id',
              isEqualTo: await LocalDB.fetchInfo(type: LocalData.companyid))
          .where("delete_at", isEqualTo: false)
          .orderBy('bill_date', descending: true)
          .limit(end)
          .get();

      if (snapshot.docs.length <= start) {
        return [];
      }

      int docsToTake = (snapshot.docs.length - start);

      if (docsToTake > (end - start)) {
        docsToTake = end - start;
      }

      return snapshot.docs.skip(start).take(docsToTake).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllInvoice() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _invoice
          .where('company_id',
              isEqualTo: await LocalDB.fetchInfo(type: LocalData.companyid))
          .where('delete_at', isEqualTo: false)
          .orderBy('bill_date', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot?> getEnquiryCustomer(
      {required String cid, required String customerID}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where('customer.customer_id', isEqualTo: customerID)
          .orderBy('created_date', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> getEnquiryProducts({required String docid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _enquiry.doc(docid).collection('products').get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<DocumentReference?> createNewEstimate({
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
    required String cid,
    required String billNo,
  }) async {
    DocumentReference? resultDocument;
    try {
      var data = {
        "customer": customerInfo?.toOrderMap(),
        "price": calCulation.toMap(),
        "estimate_id": billNo,
        "company_id": cid,
        "created_date": DateTime.now(),
        "delete_at": false,
      };
      resultDocument = await _estimate.add(data);
      if (resultDocument.id.isNotEmpty) {
        await insertEstimateProduct(
          productList: productList,
          docID: resultDocument.id,
        );
      }
    } catch (e) {
      throw e.toString();
    }
    return resultDocument;
  }

  Future insertEstimateProduct({
    required List<CartDataModel> productList,
    required String docID,
  }) async {
    try {
      for (var product in productList) {
        await _estimate.doc(docID).collection('products').add(
              product.toMap(),
            );
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> nextEstimateId({required String cid}) async {
    int? resultValue;
    try {
      var count = await getLastEstimateId(cid: cid);
      if (count != null) {
        resultValue = count.count;
        var newEnquiryId = "${DateTime.now().year}EST${count.count! + 1}";
        return newEnquiryId;
      }
    } catch (e) {
      throw e.toString();
    }
    return null;
  }

  Future<int?> updateEstimateId({
    required String cid,
    required String docID,
  }) async {
    int? resultValue;
    try {
      await getLastEstimateId(cid: cid).then((count) async {
        if (count != null) {
          resultValue = count.count;
          await _estimate.doc(docID).update(
            {
              "estimate_id": "${DateTime.now().year}EST${count.count! + 1}",
            },
          ).then((value) {
            return true;
          });
        }
      });
    } catch (e) {
      throw e.toString();
    }
    return resultValue;
  }

  Future<AggregateQuerySnapshot?> getLastEstimateId(
      {required String cid}) async {
    AggregateQuerySnapshot? resultData;
    try {
      resultData = await _estimate
          .where('company_id', isEqualTo: cid)
          .where('estimate_id', isNull: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> getEstimateCustomer(
      {required String cid, required String customerID}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _estimate
          .where('company_id', isEqualTo: cid)
          .where('customer.customer_id', isEqualTo: customerID)
          .orderBy('created_date', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<QuerySnapshot?> getEstimateProducts({required String docid}) async {
    QuerySnapshot? resultData;

    try {
      resultData = await _estimate.doc(docid).collection('products').get();
    } catch (e) {
      rethrow;
    }
    return resultData;
  }

  Future<bool?> deleteAdmin({required String docID}) async {
    try {
      await _admin.doc(docID).delete().then((value) {
        return true;
      });
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<AggregateQuerySnapshot?> getCustomerCount({
    required String cid,
  }) async {
    AggregateQuerySnapshot? result;

    try {
      result =
          await _customer.where('company_id', isEqualTo: cid).count().get();
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future updateCustomer({
    required String docID,
    required CustomerDataModel customerData,
  }) async {
    var result = await _customer.doc(docID).get();
    try {
      var customer = await _customer.doc(docID).get();
      if (customer.exists) {
        return await _customer.doc(docID).update(customerData.toUpdateMap());
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<AggregateQuerySnapshot?> getEnquiryCount({
    required String cid,
  }) async {
    AggregateQuerySnapshot? result;
    try {
      result = await _enquiry
          .where('company_id', isEqualTo: cid)
          .where("delete_at", isEqualTo: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<AggregateQuerySnapshot?> getEstimateCount({
    required String cid,
  }) async {
    AggregateQuerySnapshot? result;
    try {
      result = await _estimate
          .where('company_id', isEqualTo: cid)
          .where("delete_at", isEqualTo: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<AggregateQuerySnapshot?> getProductCount({
    required String cid,
  }) async {
    AggregateQuerySnapshot? result;
    try {
      result = await _products
          .where('company_id', isEqualTo: cid)
          .where("delete_at", isEqualTo: false)
          .count()
          .get();
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future updateCompany(
      {required String docId, required ProfileModel companyData}) async {
    try {
      await _profile
          .doc(docId)
          .update(companyData.updateCompany())
          .catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateCompanyPic(
      {required String docId, required String imageLink}) async {
    try {
      await _profile.doc(docId).update({
        "company_logo": imageLink,
      }).catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateProfilePic(
      {required String docId, required String imageLink}) async {
    try {
      await _profile.doc(docId).update({
        "profile_img": imageLink,
      }).catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateProduct({
    required String docid,
    required ProductDataModel product,
  }) async {
    try {
      await _products.doc(docid).update(product.updateMap()).catchError(
        (onError) {
          throw onError.toString();
        },
      );
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateProductPic(
      {required String docId, required String imageLink}) async {
    try {
      await _products.doc(docId).update({
        "product_img": imageLink,
      }).catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future deleteProduct({required String docId}) async {
    try {
      await _products.doc(docId).delete().catchError((onError) {
        throw onError.toString();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateEnquiryDetails({
    required String docID,
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
  }) async {
    try {
      await _enquiry
          .doc(docID)
          .update({
            "customer": customerInfo?.toOrderMap(),
            "price": calCulation.toMap(),
          })
          .catchError((onError) => throw onError)
          .then((value) async {
            return await updateEnquiryProduct(
              productList: productList,
              docID: docID,
            );
          });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateEnquiryProduct({
    required List<CartDataModel> productList,
    required String docID,
  }) async {
    try {
      var productData = await _enquiry.doc(docID).collection('products').get();
      for (var i in productData.docs) {
        await _enquiry.doc(docID).collection('products').doc(i.id).delete();
      }

      for (var product in productList) {
        await _enquiry.doc(docID).collection('products').add(
              product.toMap(),
            );
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Estimate Update
  Future updateEstimateDetails({
    required String docID,
    required List<CartDataModel> productList,
    CustomerDataModel? customerInfo,
    required BillingCalCulationModel calCulation,
  }) async {
    try {
      await _estimate
          .doc(docID)
          .update({
            "customer": customerInfo?.toOrderMap(),
            "price": calCulation.toMap(),
          })
          .catchError((onError) => throw onError)
          .then((value) async {
            return await updateEstimateProduct(
              productList: productList,
              docID: docID,
            );
          });
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateEstimateProduct({
    required List<CartDataModel> productList,
    required String docID,
  }) async {
    try {
      var productData = await _estimate.doc(docID).collection('products').get();
      for (var i in productData.docs) {
        await _estimate.doc(docID).collection('products').doc(i.id).delete();
      }

      for (var product in productList) {
        await _estimate.doc(docID).collection('products').add(
              product.toMap(),
            );
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<QuerySnapshot?> staffLogin(
      {required String email, required String password}) async {
    QuerySnapshot? resultData;
    try {
      resultData = await _staff
          .where('user_login_id', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<QuerySnapshot?> adminLogin({
    required String email,
    required String password,
  }) async {
    QuerySnapshot? resultData;
    try {
      resultData = await _admin
          .where('user_login_id', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();
    } catch (e) {
      throw e.toString();
    }
    return resultData;
  }

  Future<String?> deleteAllProducts({required cid}) async {
    String? result;
    try {
      await _products
          .where('company_id', isEqualTo: cid)
          .get()
          .then((productsList) async {
        if (productsList.docs.isNotEmpty) {
          var batch = FirebaseFirestore.instance.batch();
          for (var element in productsList.docs) {
            var document = _products.doc(element.id);
            batch.delete(document);
          }
          await batch.commit().then((_) {
            result = 'Batch write executed successfully';
          }).catchError(
              (error) => throw ('Failed to execute batch write: $error'));
        } else {
          result = "success";
        }
      });
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<String?> deleteAllCategorys({required cid}) async {
    String? result;
    try {
      await _category
          .where('company_id', isEqualTo: cid)
          .get()
          .then((categoryList) async {
        if (categoryList.docs.isNotEmpty) {
          var batch = FirebaseFirestore.instance.batch();
          for (var element in categoryList.docs) {
            var document = _category.doc(element.id);
            batch.delete(document);
          }
          await batch.commit().then((_) {
            result = 'Batch write executed successfully';
          }).catchError(
              (error) => throw ('Failed to execute batch write: $error'));
        } else {
          result = "success";
        }
      });
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Future<String?> bulkCategoryCreateFn(
      {required List<CategoryDataModel> categoryList}) async {
    String? result;
    try {
      var batch = FirebaseFirestore.instance.batch();
      for (var element in categoryList) {
        var document = _category.doc();
        batch.set(document, element.toMap());
      }
      await batch.commit().then((_) {
        result = 'Batch write executed successfully';
      }).catchError((error) => throw ('Failed to execute batch write: $error'));
    } catch (e) {
      throw e.toString();
    }
    return result;
  }

  Map<String, String> getFinancialYear() {
    DateTime currentDate = DateTime.now();
    var currentYearTwo = DateFormat("yy").format(currentDate);
    var currentYearFull = DateFormat("yyyy").format(currentDate);

    var nextyearTwo = (int.parse(currentYearTwo) + 1).toString();

    var shortYear = "$currentYearTwo-$nextyearTwo";

    String month = DateFormat("MM").format(currentDate);
    if (month == "01" || month == "02" || month == "03") {
      currentYearTwo = (int.parse(currentYearTwo) - 1).toString();
      currentYearFull = (int.parse(currentYearFull) - 1).toString();
      nextyearTwo = DateFormat("yy").format(currentDate);
      shortYear = "$currentYearTwo-$nextyearTwo";
    }

    Map<String, String> result = {
      "currentYearFull": currentYearFull,
      "fnYr": shortYear,
    };

    return result;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentFinType(
      {required String finYear}) async {
    try {
      finYear = finYear;

      return await _invoiceSettings.doc(finYear).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getInvoiceProductListing(
      {required String docID}) async {
    try {
      return await _invoice.doc(docID).collection('products').get();
    } catch (e) {
      rethrow;
    }
  }

  /*
   String option = "new";
      await getCurrentFinType(finYear: result["fnYr"]!).then((value) {
        if (value.id.isNotEmpty) {
          option = value["bill_type"];
        }
      });
      int queryYear = 0;
      if (option == "new") {
        queryYear = int.parse(result["currentYearFull"]!);
      } else {
        queryYear = int.parse(result["currentYearFull"]!) - 1;
      }
      await _invoice
          .where('bill_date',
              isGreaterThanOrEqualTo: DateTime(queryYear, 04, 01))
          .where('bill_date', isLessThanOrEqualTo: DateTime.now())
          .where('delete_at', isEqualTo: false)
          .get()
          .then((value) {
        var count = value.docs.where((element) => element["bill_no"] != null);
        invoiceNumber = (count.length + 1).toString();
        invoiceNumber = invoiceNumber!.length == 1
            ? "00$invoiceNumber/INV${result["fnYr"]}"
            : invoiceNumber!.length == 2
                ? "0$invoiceNumber/INV${result["fnYr"]}"
                : "$invoiceNumber/INV${result["fnYr"]}";
      });
      return invoiceNumber;
   
  */

  Future<double> getLastInvoiceAmount(
      {required DateTime billDate, required String billNo}) async {
    try {
      var tmpYear = billNo.split('/');
      var first = "20${tmpYear[1].substring(3, 5)}";
      return await _invoice
          .where('bill_date',
              isGreaterThanOrEqualTo: DateTime(int.parse(first), 04, 01))
          .where('bill_date', isLessThan: billDate)
          .where('delete_at', isEqualTo: false)
          .get()
          .then((value) {
        double total = 0.0;
        for (var element in value.docs) {
          total += double.parse(element["total_amount"]);
        }

        return total;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getCount() async {
    try {
      var result = getFinancialYear();
      String option = "new";
      await getCurrentFinType(finYear: result["fnYr"]!).then((value) {
        if (value.id.isNotEmpty) {
          option = value["bill_type"];
        }
      });
      int queryYear = 0;
      if (option == "new") {
        queryYear = int.parse(result["currentYearFull"]!);
      } else {
        queryYear = int.parse(result["currentYearFull"]!) - 1;
      }
      return await _invoice
          .where('bill_date',
              isGreaterThanOrEqualTo: DateTime(queryYear, 04, 01))
          .where('bill_date', isLessThanOrEqualTo: DateTime.now())
          .where('delete_at', isEqualTo: false)
          .get()
          .then((value) {
        var count = value.docs.where((element) => element["bill_no"] != null);
        return count.length;
      });
    } catch (e) {
      rethrow;
    }
  }

  // Future<String> createDoc() async {
  //   try {
  //     var year = getFinancialYear();
  //     int count = await getCount();
  //     var tmpID = "$count/INV${year["fnYr"]}";
  //     var tmpResult = _invoice.doc(tmpID);
  //     if (tmpResult.id.isNotEmpty) {
  //       return tmpResult.id;
  //     } else {
  //       return createDoc();
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<String> getLastInvoiceNumber() async {
    String invoiceNumber;
    try {
      var companyId = await LocalDB.fetchInfo(type: LocalData.companyid);
      var financialYear = getFinancialYear();
      var fyresult = financialYear["fnYr"]; // e.g., "24-25"

      var invoiceSnapshot = await _invoice
          .where('company_id', isEqualTo: companyId)
          .where('delete_at', isEqualTo: false)
          .get();

      List<int> invoiceNumbers = [];

      for (var data in invoiceSnapshot.docs) {
        String billNo = data["bill_no"];
        String numberPart = billNo.split('/')[0];
        invoiceNumbers.add(int.parse(numberPart));
      }

      int invoiceCount = invoiceNumbers.length;

      int nextInvoiceNumber = invoiceCount > 0
          ? invoiceNumbers.reduce((a, b) => a > b ? a : b) + 1
          : 1;

      invoiceNumber =
          '${nextInvoiceNumber.toString().padLeft(3, '0')}/INV$fyresult';

      var existingInvoice = await _invoice
          .where('bill_no', isEqualTo: invoiceNumber)
          .where('company_id', isEqualTo: companyId)
          .where('delete_at', isEqualTo: false)
          .get();

      if (existingInvoice.docs.isNotEmpty) {
        throw "Duplicate invoice number generated. $invoiceNumber";
      }
    } catch (e) {
      throw 'Error fetching invoice number: ${e.toString()}';
    }
    return invoiceNumber;
  }

  Future createNewInvoice({required InvoiceModel invoiceData}) async {
    try {
      // String invoiceNumber = await getLastInvoiceNumber();
      // invoiceData.billNo = invoiceNumber;
      print(invoiceData.toCreationMap());
      var invoiceRef = await _invoice.add(invoiceData.toCreationMap());
    } catch (e) {
      throw 'Error creating invoice: $e';
    }
  }

  Future updateInvoice({
    required String docID,
    required InvoiceModel invoiceData,
    required List<InvoiceProductModel> cartDataList,
  }) async {
    try {
      return await _invoice.doc(docID).update(invoiceData.toUpdateMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> filterInvoice({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    var companyId = await LocalDB.fetchInfo(type: LocalData.companyid);
    try {
      return await _invoice
          .where('company_id', isEqualTo: companyId)
          .where("bill_date",
              isGreaterThanOrEqualTo:
                  fromDate.subtract(const Duration(days: 1)))
          .where("bill_date",
              isLessThanOrEqualTo: toDate.add(const Duration(days: 1)))
          .get();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserAvailable({required String email}) async {
    try {
      var data = await _profile.where('user_login_id', isEqualTo: email).get();
      return data.docs.isNotEmpty;
    } catch (e) {
      throw e.toString();
    }
  }

  Future updatePassword(
      {required String email, required String password}) async {
    try {
      var data = await _profile.where('user_login_id', isEqualTo: email).get();
      if (data.docs.isNotEmpty) {
        await _profile.doc(data.docs.first.id).update({'password': password});
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, List<Map<String, String>>>> getFiles(
      {required String cid}) async {
    try {
      // Initialize the map to hold the results
      Map<String, List<Map<String, String>>> files = {
        'company': [],
        'user': [],
        'staff': [],
        'product': []
      };

      // Fetch user files
      var userFiles = await _admin.where("company_id", isEqualTo: cid).get();
      if (userFiles.docs.isNotEmpty) {
        for (var item in userFiles.docs) {
          files['user']!.add({'id': item.id, 'url': item["image_url"] ?? ''});
        }
      }

      // Fetch company files
      var companyFiles = await _profile.doc(cid).get();
      if (companyFiles.exists) {
        files['company']!
            .add({'id': cid, 'url': companyFiles["company_logo"] ?? ''});
      }

      // Fetch staff files
      var staffFiles = await _staff.where("company_id", isEqualTo: cid).get();
      if (staffFiles.docs.isNotEmpty) {
        for (var item in staffFiles.docs) {
          files['staff']!
              .add({'id': item.id, 'url': item["profile_img"] ?? ''});
        }
      }

      // Fetch product files
      var productFiles =
          await _products.where("company_id", isEqualTo: cid).get();
      if (productFiles.docs.isNotEmpty) {
        for (var item in productFiles.docs) {
          files['product']!
              .add({'id': item.id, 'url': item["product_img"] ?? ''});
        }
      }

      return files;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCompanyDetails({required String uid}) async {
    try {
      // Initialize the map with default values
      var map = {
        "company_id": "",
        "company": {},
        "product": [],
        "user": [],
        "staff": []
      };

      map['company_id'] = uid;

      // Fetch data from Firestore
      var companySnapshot = await _profile.doc(uid).get();
      var userSnapshot = await _admin.where('company_id', isEqualTo: uid).get();
      var productSnapshot =
          await _products.where('company_id', isEqualTo: uid).get();
      var staffSnapshot =
          await _staff.where('company_id', isEqualTo: uid).get();

      // Process and store the company data
      if (companySnapshot.exists) {
        map['company'] = companySnapshot.data() ?? {};
      }

      // Process and store the user data
      map['user'] = userSnapshot.docs.map((doc) => doc.data()).toList();

      // Process and store the product data
      map['product'] = productSnapshot.docs.map((doc) => doc.data()).toList();

      // Process and store the staff data
      map['staff'] = staffSnapshot.docs.map((doc) => doc.data()).toList();

      return map;
    } catch (e) {
      // Handle or log the error as necessary
      print('Error fetching company details: $e');
      rethrow;
    }
  }

  Future<bool> clearBillRecords() async {
    try {
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

      var enquiry = await _enquiry.where('company_id', isEqualTo: cid).get();
      if (enquiry.docs.isNotEmpty) {
        for (var data in enquiry.docs) {
          await _enquiry.doc(data.id).delete();
        }
      }

      var estimate = await _estimate.where('company_id', isEqualTo: cid).get();
      if (estimate.docs.isNotEmpty) {
        for (var data in estimate.docs) {
          await _estimate.doc(data.id).delete();
        }
      }

      var invoice = await _invoice.where('company_id', isEqualTo: cid).get();
      if (invoice.docs.isNotEmpty) {
        for (var data in invoice.docs) {
          await _invoice.doc(data.id).delete();
        }
      }
      return true;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future deleteDeviceLogout() async {
    try {
      var isTestMode = await LocalDB.checkTestMode();
      if (!isTestMode) {
        var isAdmin = await LocalDB.fetchInfo(type: LocalData.isAdmin);
        if (isAdmin) {
          await _profile
              .doc(await LocalDB.fetchInfo(type: LocalData.companyid))
              .update({"device": DeviceModel().toMap()});
        } else {
          var uid = await LocalDB.fetchInfo(type: LocalData.uid);

          var admin = await _admin.doc(uid).get();
          if (admin.exists) {
            await _admin.doc(uid).update({"device": DeviceModel().toMap()});
          } else {
            var staff = await _staff.doc(uid).get();
            if (staff.exists) {
              await _staff.doc(uid).update({"device": DeviceModel().toMap()});
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkUser() async {
    try {
      var isAdmin = await LocalDB.fetchInfo(type: LocalData.isAdmin);
      if (!isAdmin) {
        var uid = await LocalDB.fetchInfo(type: LocalData.uid);
        var admin = await _admin.doc(uid).get();
        var staff = await _staff.doc(uid).get();
        if (admin.exists) {
          return true;
        } else if (staff.exists) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkProductCode({
    required String code,
  }) async {
    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

    try {
      var docRef = await _products
          .where('company_id', isEqualTo: cid)
          .where('product_code', isEqualTo: code)
          .get();
      if (docRef.docs.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> checkQrCode({
    required String code,
  }) async {
    try {
      var cid = await LocalDB.fetchInfo(type: LocalData.companyid);

      var docRef = await _products
          .where('company_id', isEqualTo: cid)
          .where('qr_code', isEqualTo: code)
          .get();
      if (docRef.docs.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
