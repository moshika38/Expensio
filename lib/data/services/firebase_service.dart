import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore;

  FirebaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> getUserExpensesCollection(String? uid) {
    if (uid != null && uid.isNotEmpty) {
      return _firestore.collection('users').doc(uid).collection('expenses');
    }
    return _firestore.collection('expenses');
  }

  FirebaseFirestore get firestore => _firestore;
}
