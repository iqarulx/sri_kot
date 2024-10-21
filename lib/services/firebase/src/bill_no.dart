import 'package:cloud_firestore/cloud_firestore.dart';
import '/constants/constants.dart';
import '/services/database/localdb.dart';

final _instances = FirebaseFirestore.instance;

class BillNo {
  static final _enq = _instances.collection('enquiry');
  static final _est = _instances.collection('estimate');
  static final _inv = _instances.collection('invoice');

  static Future<String?> genBillNo({required BillType type}) async {
    if (type == BillType.enquiry) {
      return await genEnqNo();
    } else if (type == BillType.estimate) {
      return await genEstimateNo();
    } else if (type == BillType.invoice) {
      return await genInvNo();
    }
    return null;
  }

  static Future<String?> genEnqNo() async {
    String? nextEstimateNo;

    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    var estimateByLast = await _enq
        .where('company_id', isEqualTo: cid)
        .where('delete_at', isEqualTo: false)
        .where('enquiry_id', isNull: false)
        .orderBy('created_date', descending: true)
        .get();
    var totalEstimate = await _enq
        .where('company_id', isEqualTo: cid)
        .where('enquiry_id', isNull: false)
        .where('delete_at', isEqualTo: false)
        .get();

    var lastEstimate = estimateByLast.docs.first.data();
    var lastEstimateNo = lastEstimate['enquiry_id'].toString().substring(7);

    if (int.parse(lastEstimateNo) != totalEstimate.docs.length) {
      List<int> nos = [];
      for (var i in totalEstimate.docs) {
        nos.add(int.parse(i['enquiry_id'].toString().substring(7)));
      }
      List<int> missingNo = findMissingNumbers(nos);
      if (missingNo.isNotEmpty) {
        nextEstimateNo = "${DateTime.now().year}ENQ${missingNo.first}";
      } else {
        var nextNo = (totalEstimate.docs.length + 1);
        nextEstimateNo = '${DateTime.now().year}ENQ$nextNo';
      }
    } else {
      var nextNo = (int.parse(lastEstimateNo) + 1);
      nextEstimateNo = '${DateTime.now().year}ENQ$nextNo';
    }

    var checkBillNoExists = await _enq
        .where('company_id', isEqualTo: cid)
        .where('enquiry_id', isEqualTo: nextEstimateNo)
        .where('delete_at', isEqualTo: false)
        .get();

    if (checkBillNoExists.docs.isEmpty) {
      return nextEstimateNo;
    }

    return null;
  }

  static Future<String?> genEstimateNo() async {
    String? nextEstimateNo;

    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    var estimateByLast = await _est
        .where('company_id', isEqualTo: cid)
        .where('delete_at', isEqualTo: false)
        .where('estimate_id', isNull: false)
        .orderBy('created_date', descending: true)
        .get();
    var totalEstimate = await _est
        .where('company_id', isEqualTo: cid)
        .where('estimate_id', isNull: false)
        .where('delete_at', isEqualTo: false)
        .get();

    var lastEstimate = estimateByLast.docs.first.data();
    var lastEstimateNo = lastEstimate['estimate_id'].toString().substring(7);

    if (int.parse(lastEstimateNo) != totalEstimate.docs.length) {
      List<int> nos = [];
      for (var i in totalEstimate.docs) {
        nos.add(int.parse(i['estimate_id'].toString().substring(7)));
      }
      List<int> missingNo = findMissingNumbers(nos);
      if (missingNo.isNotEmpty) {
        nextEstimateNo = "${DateTime.now().year}EST${missingNo.first}";
      } else {
        var nextNo = (totalEstimate.docs.length + 1);
        nextEstimateNo = '${DateTime.now().year}EST$nextNo';
      }
    } else {
      var nextNo = (int.parse(lastEstimateNo) + 1);
      nextEstimateNo = '${DateTime.now().year}EST$nextNo';
    }

    var checkBillNoExists = await _est
        .where('company_id', isEqualTo: cid)
        .where('estimate_id', isEqualTo: nextEstimateNo)
        .where('delete_at', isEqualTo: false)
        .get();

    if (checkBillNoExists.docs.isEmpty) {
      return nextEstimateNo;
    }

    return null;
  }

  static Future<String?> genInvNo() async {
    String? nextEstimateNo;
    String? yearFormat =
        "${DateTime.now().year.toString().substring(2)}-${(DateTime.now().year + 1).toString().substring(2)}";

    var cid = await LocalDB.fetchInfo(type: LocalData.companyid);
    var estimateByLast = await _inv
        .where('company_id', isEqualTo: cid)
        .where('bill_no', isNull: false)
        .orderBy('bill_date', descending: true)
        .get();
    var totalEstimate = await _inv
        .where('company_id', isEqualTo: cid)
        .where('bill_no', isNull: false)
        .get();

    var lastEstimate = estimateByLast.docs.first.data();
    var lastEstimateNo = lastEstimate['bill_no']
        .toString()
        .replaceFirst(RegExp(r'/INV\d{2}-\d{2}'), '');

    if (int.parse(lastEstimateNo) != totalEstimate.docs.length) {
      List<int> nos = [];
      for (var i in totalEstimate.docs) {
        nos.add(int.parse(i['bill_no']
            .toString()
            .replaceFirst(RegExp(r'/INV\d{2}-\d{2}'), '')));
      }
      List<int> missingNo = findMissingNumbers(nos);
      if (missingNo.isNotEmpty) {
        nextEstimateNo =
            "${missingNo.first.toString().padLeft(3, '0')}/INV$yearFormat";
      } else {
        var nextNo = (totalEstimate.docs.length + 1);
        nextEstimateNo = '${nextNo.toString().padLeft(3, '0')}/INV$yearFormat';
      }
    } else {
      var nextNo = (int.parse(lastEstimateNo) + 1);
      nextEstimateNo = '${nextNo.toString().padLeft(3, '0')}/INV$yearFormat';
    }

    var checkBillNoExists = await _inv
        .where('company_id', isEqualTo: cid)
        .where('bill_no', isEqualTo: nextEstimateNo)
        .where('delete_at', isEqualTo: false)
        .get();

    if (checkBillNoExists.docs.isEmpty) {
      return nextEstimateNo;
    }

    return null;
  }

  static List<int> findMissingNumbers(List<int> numbers) {
    Set<int> numberSet = Set.from(numbers);

    int maxNumber = numberSet.reduce((a, b) => a > b ? a : b);

    List<int> missingNumbers = [];
    for (int i = 1; i <= maxNumber; i++) {
      if (!numberSet.contains(i)) {
        missingNumbers.add(i);
      }
    }
    if (missingNumbers.isNotEmpty) {
      return missingNumbers;
    } else {
      return [];
    }
  }
}
