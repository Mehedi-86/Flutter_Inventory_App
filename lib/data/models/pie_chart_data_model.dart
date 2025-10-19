import 'package:flutter/material.dart';

// This new model will hold the combined data needed for a single pie chart slice.
class PieChartCategoryData {
  final String categoryName;
  final int productCount;
  final Color color;

  PieChartCategoryData({
    required this.categoryName,
    required this.productCount,
    required this.color,
  });
}
