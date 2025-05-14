import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:teb_janelajohari/admin_area/user/adm_access_log.dart';

import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class AdmAccessLogController with ChangeNotifier {
  final _accessCollectionName = 'admAccessLog';

  Future<TebCustomReturn> add({required String email, required bool success, String observation = ''}) async {
    try {
      var accessLog = AccessLog(
        id: TebUidGenerator.accessLogUid,
        email: email,
        timestamp: DateTime.now(),
        success: success,
        observation: observation,
      );

      await FirebaseFirestore.instance.collection(_accessCollectionName).doc(accessLog.id).set(accessLog.toMap());

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
