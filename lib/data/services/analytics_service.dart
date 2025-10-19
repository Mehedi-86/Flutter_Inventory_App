import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class AnalyticsService {
  static const String baseUrl = 'http://localhost:8000';
  
  static AnalyticsService? _instance;
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._internal();
    return _instance!;
  }
  
  AnalyticsService._internal();

  Future<Map<String, dynamic>> getInventoryRecommendations(List<Product> products) async {
    try {
      final url = Uri.parse('$baseUrl/analytics/recommendations');
      
      // Convert Product to the format expected by the API
      final productsData = products.map((product) => {
        'id': product.id,
        'name': product.name,
        'sku': product.sku,
        'categoryId': product.categoryId,
        'quantity': product.quantity,
        'unitPrice': product.unitPrice,
        'reorderLevel': product.reorderLevel,
      }).toList();

      final requestBody = {
        'products': productsData,
        'timeRange': 30,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recommendations: $e');
    }
  }

  Future<Map<String, dynamic>> getSalesForecast(List<Product> products) async {
    try {
      final url = Uri.parse('$baseUrl/analytics/sales-forecast');
      
      final productsData = products.map((product) => {
        'id': product.id,
        'name': product.name,
        'sku': product.sku,
        'categoryId': product.categoryId,
        'quantity': product.quantity,
        'unitPrice': product.unitPrice,
        'reorderLevel': product.reorderLevel,
      }).toList();

      final requestBody = {
        'products': productsData,
        'timeRange': 30,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get forecast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting forecast: $e');
    }
  }

  Future<Map<String, dynamic>> getAbcAnalysis(List<Product> products) async {
    try {
      final url = Uri.parse('$baseUrl/analytics/abc-analysis');
      
      final productsData = products.map((product) => {
        'id': product.id,
        'name': product.name,
        'sku': product.sku,
        'categoryId': product.categoryId,
        'quantity': product.quantity,
        'unitPrice': product.unitPrice,
        'reorderLevel': product.reorderLevel,
      }).toList();

      final requestBody = {
        'products': productsData,
        'timeRange': 90,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get ABC analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting ABC analysis: $e');
    }
  }

  Future<Map<String, dynamic>> getPerformanceMetrics(List<Product> products) async {
    try {
      final url = Uri.parse('$baseUrl/analytics/performance-metrics');
      
      final productsData = products.map((product) => {
        'id': product.id,
        'name': product.name,
        'sku': product.sku,
        'categoryId': product.categoryId,
        'quantity': product.quantity,
        'unitPrice': product.unitPrice,
        'reorderLevel': product.reorderLevel,
      }).toList();

      final requestBody = {
        'products': productsData,
        'timeRange': 30,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get performance metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting performance metrics: $e');
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final url = Uri.parse('$baseUrl/');
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}