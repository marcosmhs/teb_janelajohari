import 'package:cloud_firestore/cloud_firestore.dart';

class AccessLog {
  late String id;
  late DateTime? timestamp;
  late String email;
  late bool success;
  late String observation;

  AccessLog({
    this.id = '',
    this.timestamp,
    this.email = '',
    this.success = false,
    this.observation = '',
  });

  factory AccessLog.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return AccessLog.fromMap(map: data);
  }

  static AccessLog fromMap({required Map<String, dynamic> map}) {
    var u = AccessLog();

    u = AccessLog(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      timestamp: map['timestamp'] == null ? null : DateTime.tryParse(map['timestamp']),
      success: map['success'] ?? false,
      observation: map['observation'] ?? '',
    );
    return u;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'email': email,
      'timestamp': timestamp.toString(),
      'success': success,
      'observation': observation,
    };

    return r;
  }
}
