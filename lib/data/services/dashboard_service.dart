import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/pie_chart_data_model.dart';

class DashboardService {
  DashboardService._internal();
  static final DashboardService _instance = DashboardService._internal();
  static DashboardService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, Color> _categoryColors = {};
  Color _getColorForCategory(String categoryId) {
    if (!_categoryColors.containsKey(categoryId)) {
      _categoryColors[categoryId] = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    }
    return _categoryColors[categoryId]!;
  }

  Stream<int> getTotalProductCount() {
    return _firestore.collection('products').snapshots().map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getLowStockCount() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final product = Product.fromMap(doc.data(), doc.id);
        return product.quantity <= product.reorderLevel;
      }).length;
    });
  }
  
  Stream<String> getTotalInventoryValue() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      double totalValue = 0.0;
      for (var doc in snapshot.docs) {
        final product = Product.fromMap(doc.data(), doc.id);
        totalValue += product.quantity * product.unitPrice;
      }
      if (totalValue >= 1000) {
        return '\$${(totalValue / 1000).toStringAsFixed(1)}k';
      }
      return '\$${totalValue.toStringAsFixed(2)}';
    });
  }

  // --- FIX IS HERE: THIS IS NOW A BROADCAST STREAM ---
  Stream<List<PieChartCategoryData>> getPieChartData() {
    final productsStream = _firestore.collection('products').snapshots();
    final categoriesStream = _firestore.collection('categories').snapshots();

    // rxdart's CombineLatestStream is perfect for this, but to avoid adding a new
    // dependency, we can manually create a broadcast stream.
    late StreamController<List<PieChartCategoryData>> controller;
    
    // We need to store the latest data from each stream
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? lastProducts;
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? lastCategories;

    void update() {
      if (lastProducts == null || lastCategories == null) return;

      final allCategories = lastCategories!.map((doc) => Category.fromMap(doc.data(), doc.id)).toList();
      final categoryCounts = <String, int>{};

      for (var productDoc in lastProducts!) {
        final product = Product.fromMap(productDoc.data(), productDoc.id);
        categoryCounts[product.categoryId] = (categoryCounts[product.categoryId] ?? 0) + 1;
      }
      
      final pieData = allCategories.map((category) {
        return PieChartCategoryData(
          categoryName: category.name,
          productCount: categoryCounts[category.id] ?? 0,
          color: _getColorForCategory(category.id),
        );
      }).toList();

      controller.add(pieData);
    }

    controller = StreamController<List<PieChartCategoryData>>.broadcast(
      onListen: () {
        productsStream.listen((snapshot) {
          lastProducts = snapshot.docs;
          update();
        });
        categoriesStream.listen((snapshot) {
          lastCategories = snapshot.docs;
          update();
        });
      }
    );

    return controller.stream;
  }
}

