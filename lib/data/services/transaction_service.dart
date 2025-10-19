import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction; // Hides Firestore's Transaction class
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';

class TransactionService {
  TransactionService._internal();
  static final TransactionService _instance = TransactionService._internal();
  static TransactionService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- REAL-TIME STREAM FOR TRANSACTION HISTORY ---
  // This provides a live list of all transactions, ordered by the newest first.
  Stream<List<Transaction>> getTransactionsStream() {
    return _firestore
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Transaction.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // --- REAL-TIME STOCK UPDATE USING A FIRESTORE TRANSACTION ---
  // This method is atomic, ensuring data integrity.
  Future<void> updateStock({
    required Product product,
    required int quantityChange,
    required String reason,
    required TransactionType type,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('You must be logged in to perform this action.');
    }

    final productRef = _firestore.collection('products').doc(product.id);
    final transactionRef = _firestore.collection('transactions').doc();

    // A Firestore Transaction reads data and then writes changes in a single atomic operation.
    return _firestore.runTransaction((firestoreTransaction) async {
      // 1. Get the most up-to-date product data from the database.
      final productSnapshot = await firestoreTransaction.get(productRef);
      if (!productSnapshot.exists) {
        throw Exception("Product does not exist!");
      }

      // 2. Calculate the new quantity.
      final currentQuantity = productSnapshot.data()!['quantity'] as int;
      final newQuantity = type == TransactionType.addition
          ? currentQuantity + quantityChange
          : currentQuantity - quantityChange;
      
      if (newQuantity < 0) {
        throw Exception('Stock quantity cannot be negative.');
      }

      // 3. Create the new transaction object to be recorded.
      final newTransaction = Transaction(
        id: transactionRef.id,
        productId: product.id,
        productName: product.name,
        changeInQuantity: type == TransactionType.addition ? quantityChange : -quantityChange,
        type: type,
        reason: reason,
        userId: currentUser.uid,
        timestamp: Timestamp.now(),
      );

      // 4. Perform the two writes: update the product and create the transaction record.
      // If either of these fails, Firestore will automatically roll back both changes.
      firestoreTransaction.update(productRef, {'quantity': newQuantity});
      firestoreTransaction.set(transactionRef, newTransaction.toMap());
    });
  }
}

