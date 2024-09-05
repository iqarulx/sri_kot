import 'package:cloud_firestore/cloud_firestore.dart';

final _instances = FirebaseFirestore.instance;

class Firebase {
  static final profile = _instances.collection('profile');
  static final user = _instances.collection('admin');
  static final staff = _instances.collection('staff');
  static final enquiry = _instances.collection('enquiry');
  static final estimate = _instances.collection('estimate');
  static final product = _instances.collection('product');

  static Future<List<QueryDocumentSnapshot>?> get({
    required CollectionReference collection,
  }) async {
    try {
      var result = await collection.get();
      if (result.docs.isNotEmpty) {
        return result.docs;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  static Future<DocumentSnapshot?> getId({
    required CollectionReference collection,
    required String docId,
  }) async {
    try {
      var result = await collection.doc(docId).get();
      if (result.exists) {
        return result;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  static Future<List<QueryDocumentSnapshot>?> getParams({
    required CollectionReference collection,
    required String field,
    required String value,
  }) async {
    try {
      var result = await collection.where(field, isEqualTo: value).get();
      if (result.docs.isNotEmpty) {
        return result.docs;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  static Future<String?> insert({
    required CollectionReference collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      var result = await collection.add(data);
      if (result.id.isNotEmpty) {
        return result.id;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  static Future<bool?> update({
    required CollectionReference collection,
    required Map<String, dynamic> data,
    required String docId,
  }) async {
    try {
      var result = await collection.doc(docId).update(data);
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
