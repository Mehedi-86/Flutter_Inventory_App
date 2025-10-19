import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { addition, removal }

class Transaction {
  final String id;
  final String productId;
  final String productName; // Denormalized for easy display
  final int changeInQuantity; // e.g., +50 or -5
  final TransactionType type;
  final String reason; // e.g., "Sale #101", "Shipment from Supplier X"
  final String userId; // Who made the change
  final Timestamp timestamp;

  Transaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.changeInQuantity,
    required this.type,
    required this.reason,
    required this.userId,
    required this.timestamp,
  });

  factory Transaction.fromMap(Map<String, dynamic> data, String documentId) {
    return Transaction(
      id: documentId,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      changeInQuantity: data['changeInQuantity'] ?? 0,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${data['type']}',
        orElse: () => TransactionType.removal,
      ),
      reason: data['reason'] ?? 'No reason provided',
      userId: data['userId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'changeInQuantity': changeInQuantity,
      'type': type.name,
      'reason': reason,
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}