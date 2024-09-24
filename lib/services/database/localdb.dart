import 'package:shared_preferences/shared_preferences.dart';
import '/constants/constants.dart';

class LocalDB {
  static Future<SharedPreferences> _connect() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences;
  }

  static Future<bool> checkTestMode() async {
    var db = await _connect();
    var result = db.getBool('test_mode') ?? false;
    return result;
  }

  static Future setTestMode() async {
    var db = await _connect();
    var result = db.setBool('test_mode', true);
  }

  static Future<bool> createNewUser({
    required String username,
    required String loginEmail,
    required String uID,
    required String companyID,
    required String companyUniqueId,
    required String companyName,
    required String companyAddress,
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
    db.setString('company_name', companyName);
    db.setString('company_address', companyAddress);
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

  static Future<bool> superAdminLogin() async {
    var db = await _connect();
    db.setBool('super_login', true);
    return true;
  }

  static Future<bool> checklogin() async {
    var db = await _connect();
    var result = db.getBool('login') ?? false;
    return result;
  }

  static Future<bool> changeBilling(int value) async {
    var db = await _connect();
    db.setInt('billing', value);
    return true;
  }

  static Future<String?> getLastSync() async {
    var db = await _connect();
    var result = db.getString('last_sync');
    return result;
  }

  static Future setLastSync() async {
    var db = await _connect();
    db.setString('last_sync', DateTime.now().toString());
  }

  static Future setPdfType(bool type) async {
    var db = await _connect();
    return db.setBool('invoice_pdf_type', type);
  }

  static Future<bool?> getPdfType() async {
    var db = await _connect();
    return db.getBool('invoice_pdf_type');
  }

  static Future setPdfAlignment(int type) async {
    var db = await _connect();
    return db.setInt('pdf_product_name_alignment', type);
  }

  static Future<int> getPdfAlignment() async {
    var db = await _connect();
    return db.getInt('pdf_product_name_alignment') ?? 1;
  }

  static Future<int> getLastEnquiry() async {
    var db = await _connect();
    var result = db.getInt("last_enquiry");
    return result ?? 0;
  }

  static Future<int> getLastEstimate() async {
    var db = await _connect();
    var result = db.getInt("last_estimate");
    return result ?? 0;
  }

  static Future setLastEnquiry() async {
    var db = await _connect();
    var lastEnquiry = await LocalDB.getLastEnquiry();
    db.setInt('last_enquiry', lastEnquiry + 1);
  }

  static Future reverseEnquiry() async {
    var db = await _connect();
    var lastEnquiry = await LocalDB.getLastEstimate();
    db.setInt('last_enquiry', lastEnquiry - 1);
  }

  static Future setLastEstimate() async {
    var db = await _connect();
    var lastEstimate = await LocalDB.getLastEstimate();
    db.setInt('last_estimate', lastEstimate + 1);
  }

  static Future reverseEstimate() async {
    var db = await _connect();
    var lastEstimate = await LocalDB.getLastEstimate();
    db.setInt('last_estimate', lastEstimate - 1);
  }

  static Future<int?> getBillingIndex() async {
    var db = await _connect();
    int? index = db.getInt('billing');
    return index;
  }

  static Future<dynamic> fetchInfo({required LocalData type}) async {
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
    } else if (type == LocalData.companyName) {
      return db.getString('company_name');
    } else if (type == LocalData.companyAddress) {
      return db.getString('company_address');
    } else if (type == LocalData.isAdmin) {
      return db.getBool('isAdmin');
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

  static Future<bool> logout() async {
    var db = await _connect();
    await db.clear();
    return true;
  }
}
