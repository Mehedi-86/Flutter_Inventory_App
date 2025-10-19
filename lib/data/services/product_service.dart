import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  ProductService._internal();
  static final ProductService _instance = ProductService._internal();
  static ProductService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- REAL-TIME STREAMS ---
  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<Product>> getProductsByCategoryStream(String categoryId) {
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
    });
  }
  
  Stream<List<Product>> getLowStockProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
       return snapshot.docs
        .map((doc) => Product.fromMap(doc.data(), doc.id))
        .where((product) => product.quantity <= product.reorderLevel)
        .toList();
    });
  }

  // --- GET OPERATIONS ---
  Future<List<Product>> getAllProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
  }

  // --- CRUD OPERATIONS ---
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}
