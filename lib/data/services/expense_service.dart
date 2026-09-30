import '../models/expense_model.dart';
import 'firebase_service.dart';

class ExpenseService {
  final FirebaseService? firebaseService;

  ExpenseService({this.firebaseService});

  /// Fetch expenses for a specific user ordered by date descending
  Future<List<ExpenseModel>> fetchExpenses({String? uid}) async {
    try {
      final collection = (firebaseService ?? FirebaseService()).getUserExpensesCollection(uid);
      final snapshot = await collection.orderBy('date', descending: true).get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream expenses real-time for a specific user
  Stream<List<ExpenseModel>> streamExpenses({String? uid}) {
    final collection = (firebaseService ?? FirebaseService()).getUserExpensesCollection(uid);
    return collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ExpenseModel.fromSnapshot(doc)).toList());
  }

  /// Add a new expense for a user
  Future<String> addExpense(ExpenseModel expense, {String? uid}) async {
    try {
      final collection = (firebaseService ?? FirebaseService()).getUserExpensesCollection(uid);
      final docRef = await collection.add(expense.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing expense for a user
  Future<void> updateExpense(ExpenseModel expense, {String? uid}) async {
    try {
      final collection = (firebaseService ?? FirebaseService()).getUserExpensesCollection(uid);
      await collection.doc(expense.id).update(expense.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an expense for a user
  Future<void> deleteExpense(String id, {String? uid}) async {
    try {
      final collection = (firebaseService ?? FirebaseService()).getUserExpensesCollection(uid);
      await collection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
