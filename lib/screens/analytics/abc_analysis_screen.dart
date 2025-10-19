import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/product_service.dart';
import '../../data/models/product_model.dart';

class AbcAnalysisScreen extends StatefulWidget {
  const AbcAnalysisScreen({super.key});

  @override
  State<AbcAnalysisScreen> createState() => _AbcAnalysisScreenState();
}

class _AbcAnalysisScreenState extends State<AbcAnalysisScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _analysis;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final serverHealthy = await AnalyticsService.instance.checkServerHealth();
      if (!serverHealthy) {
        throw Exception('Analytics server is not running. Please start the Python backend.');
      }

      _products = await ProductService.instance.getAllProducts();
      final analysis = await AnalyticsService.instance.getAbcAnalysis(_products);
      
      setState(() {
        _analysis = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABC Analysis'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalysis,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Performing ABC analysis...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading ABC analysis',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAnalysis,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnalysis,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildCategoryChart(),
          const SizedBox(height: 16),
          _buildMethodologyCard(),
          const SizedBox(height: 16),
          _buildProductsList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _analysis?['summary'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ABC Analysis Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Products', '${summary['totalProducts'] ?? 0}', Colors.blue),
                _buildSummaryItem('Category A', '${summary['categoryA'] ?? 0}', Colors.red),
                _buildSummaryItem('Category B', '${summary['categoryB'] ?? 0}', Colors.orange),
                _buildSummaryItem('Category C', '${summary['categoryC'] ?? 0}', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total Revenue: \$${summary['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryChart() {
    final summary = _analysis?['summary'] ?? {};
    final categoryA = (summary['categoryA'] ?? 0).toDouble();
    final categoryB = (summary['categoryB'] ?? 0).toDouble();
    final categoryC = (summary['categoryC'] ?? 0).toDouble();
    final total = categoryA + categoryB + categoryC;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    if (categoryA > 0)
                      PieChartSectionData(
                        value: categoryA,
                        title: 'A\n${categoryA.toInt()}',
                        color: Colors.red,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (categoryB > 0)
                      PieChartSectionData(
                        value: categoryB,
                        title: 'B\n${categoryB.toInt()}',
                        color: Colors.orange,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (categoryC > 0)
                      PieChartSectionData(
                        value: categoryC,
                        title: 'C\n${categoryC.toInt()}',
                        color: Colors.green,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodologyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ABC Analysis Methodology',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildMethodologyItem(
              'Category A',
              'High Value Items (80% of revenue)',
              'Require tight control and accurate records',
              Colors.red,
              Icons.star,
            ),
            const SizedBox(height: 12),
            _buildMethodologyItem(
              'Category B',
              'Medium Value Items (15% of revenue)',
              'Require good control with regular monitoring',
              Colors.orange,
              Icons.trending_up,
            ),
            const SizedBox(height: 12),
            _buildMethodologyItem(
              'Category C',
              'Low Value Items (5% of revenue)',
              'Can use simple controls and periodic review',
              Colors.green,
              Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodologyItem(String title, String description, String recommendation, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                Text(description, style: const TextStyle(fontSize: 14)),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    final analysis = _analysis?['analysis'] as List? ?? [];

    if (analysis.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No analysis data available'),
        ),
      );
    }

    // Group by category
    final Map<String, List> categorizedProducts = {
      'A': [],
      'B': [],
      'C': [],
    };

    for (var product in analysis) {
      final category = product['category'] ?? 'C';
      categorizedProducts[category]?.add(product);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Classification',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...categorizedProducts.entries.map((entry) {
              final category = entry.key;
              final products = entry.value;
              
              if (products.isEmpty) return const SizedBox.shrink();
              
              Color categoryColor;
              switch (category) {
                case 'A':
                  categoryColor = Colors.red;
                  break;
                case 'B':
                  categoryColor = Colors.orange;
                  break;
                default:
                  categoryColor = Colors.green;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Category $category (${products.length} products)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  ...products.map((product) => _buildProductItem(product, categoryColor)),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, Color categoryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: categoryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['productName'] ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('SKU: ${product['sku']}'),
                Text('Quantity Sold: ${product['quantity']}'),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product['revenue']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${product['revenuePercentage']?.toStringAsFixed(1) ?? '0.0'}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product['category'] ?? 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}