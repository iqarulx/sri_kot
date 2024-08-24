import 'package:shared_preferences/shared_preferences.dart';

import '/constants/enum.dart';

class LocalDbProvider {
  Future<SharedPreferences> _connect() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences;
  }

  Future<bool> setCompanyCollection({
    required String collection,
  }) async {
    var db = await _connect();
    db.setString('company_collection', collection);
    return true;
  }

  Future<String?> getCompany() async {
    var db = await _connect();
    String? collection = db.getString('company_collection');
    return collection;
  }

  Future<bool> createNewUser({
    required String username,
    required String loginEmail,
    required String uID,
    required String companyID,
    required String companyUniqueId,
    required bool prCategory,
    required bool prCustomer,
    required bool prEstimate,
    required bool prOrder,
    required bool prProduct,
    required bool isAdmin,
    required bool prBillofSupply,
  }) async {
    var db = await _connect();
    db.setBool('login', true);
    db.setString('login_email', loginEmail);
    db.setString('user_name', username);
    db.setString('uid', uID);
    db.setString('company_id', companyID);
    db.setString('company_unique_id', companyUniqueId);
    db.setInt('billing', 1);
    db.setBool('pr_category', prCategory);
    db.setBool('pr_customer', prCustomer);
    db.setBool('pr_estimate', prEstimate);
    db.setBool('pr_order', prOrder);
    db.setBool('pr_product', prProduct);
    db.setBool('isAdmin', isAdmin);
    db.setBool('billofsupply', prBillofSupply);
    return true;
  }

  Future<bool> superAdminLogin() async {
    var db = await _connect();
    db.setBool('super_login', true);
    return true;
  }

  Future<List> checklogin() async {
    var db = await _connect();
    var result = db.getBool('login') ?? false;
    if (result) {
      return [result, 0];
    } else {
      result = db.getBool('super_login') ?? false;
      return [result, 1];
    }
  }

  Future<bool> changeBilling(int value) async {
    var db = await _connect();
    db.setInt('billing', value);
    return true;
  }

  Future<int?> getBillingIndex() async {
    var db = await _connect();
    int? index = db.getInt('billing');
    return index;
  }

  Future<dynamic> fetchInfo({required LocalData type}) async {
    var db = await _connect();
    if (type == LocalData.userName) {
      return db.getString('user_name');
    } else if (type == LocalData.uid) {
      return db.getString('uid');
    } else if (type == LocalData.loginEmail) {
      return db.getString('login_email');
    } else if (type == LocalData.login) {
      return db.getBool('login');
    } else if (type == LocalData.companyid) {
      return db.getString('company_id');
    } else if (type == LocalData.companyUniqueId) {
      return db.getString('company_unique_id');
    } else if (type == LocalData.all) {
      var data = {
        "login": db.getBool('login'),
        "login_email": db.getString('login_email'),
        "user_name": db.getString('user_name'),
        "uid": db.getString('uid'),
        "company_id": db.getString('company_id'),
        "billing": db.getInt('billing'),
        "pr_category": db.getBool('pr_category'),
        "pr_customer": db.getBool('pr_customer'),
        "pr_estimate": db.getBool('pr_estimate'),
        "pr_order": db.getBool('pr_order'),
        "pr_product": db.getBool('pr_product'),
        "isAdmin": db.getBool('isAdmin'),
        "billofsupply": db.getBool('billofsupply'),
      };
      return data;
    }
  }

  Future<bool> logout() async {
    var db = await _connect();
    await db.clear();
    return true;
  }
}
