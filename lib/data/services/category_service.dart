import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  CategoryService._internal();
  static final CategoryService _instance = CategoryService._internal();
  static CategoryService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches a live stream of all available categories.
  Stream<List<Category>> getCategoriesStream() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Category.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
