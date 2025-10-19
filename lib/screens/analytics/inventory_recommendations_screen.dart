import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/product_service.dart';
import '../../data/models/product_model.dart';

class InventoryRecommendationsScreen extends StatefulWidget {
  const InventoryRecommendationsScreen({super.key});

  @override
  State<InventoryRecommendationsScreen> createState() => _InventoryRecommendationsScreenState();
}

class _InventoryRecommendationsScreenState extends State<InventoryRecommendationsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _recommendations;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if server is running
      final serverHealthy = await AnalyticsService.instance.checkServerHealth();
      if (!serverHealthy) {
        throw Exception('Analytics server is not running. Please start the Python backend.');
      }

      // Get products
      _products = await ProductService.instance.getAllProducts();
      
      // Get recommendations
      final recommendations = await AnalyticsService.instance.getInventoryRecommendations(_products);
      
      setState(() {
        _recommendations = recommendations;
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
        title: const Text('Inventory Recommendations'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
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
            Text('Analyzing inventory data...'),
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
                'Error loading recommendations',
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
                onPressed: _loadRecommendations,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              if (_error!.contains('server is not running'))
                Card(
                  color: Colors.blue[50],
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Start the Python Backend:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('1. Open terminal in python_backend folder'),
                        Text('2. Activate virtual environment:'),
                        Text('   .\\inventory_env\\Scripts\\Activate.ps1'),
                        Text('3. Run: python main.py'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildUrgencyChart(),
          const SizedBox(height: 16),
          _buildRecommendationsList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _recommendations?['summary'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Products', '${summary['totalProducts'] ?? 0}', Colors.blue),
                _buildSummaryItem('High Urgency', '${summary['highUrgency'] ?? 0}', Colors.red),
                _buildSummaryItem('Medium Urgency', '${summary['mediumUrgency'] ?? 0}', Colors.orange),
                _buildSummaryItem('Low Urgency', '${summary['lowUrgency'] ?? 0}', Colors.green),
              ],
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

  Widget _buildUrgencyChart() {
    final summary = _recommendations?['summary'] ?? {};
    final high = (summary['highUrgency'] ?? 0).toDouble();
    final medium = (summary['mediumUrgency'] ?? 0).toDouble();
    final low = (summary['lowUrgency'] ?? 0).toDouble();
    final total = high + medium + low;

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
              'Urgency Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    if (high > 0)
                      PieChartSectionData(
                        value: high,
                        title: 'High\n${high.toInt()}',
                        color: Colors.red,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (medium > 0)
                      PieChartSectionData(
                        value: medium,
                        title: 'Medium\n${medium.toInt()}',
                        color: Colors.orange,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (low > 0)
                      PieChartSectionData(
                        value: low,
                        title: 'Low\n${low.toInt()}',
                        color: Colors.green,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
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

  Widget _buildRecommendationsList() {
    final recommendations = _recommendations?['recommendations'] as List? ?? [];

    if (recommendations.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No recommendations available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationItem(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    final urgency = recommendation['urgency'] ?? 'LOW';
    final action = recommendation['action'] ?? 'MONITOR';
    
    Color urgencyColor;
    IconData urgencyIcon;
    
    switch (urgency) {
      case 'HIGH':
        urgencyColor = Colors.red;
        urgencyIcon = Icons.warning;
        break;
      case 'MEDIUM':
        urgencyColor = Colors.orange;
        urgencyIcon = Icons.info;
        break;
      default:
        urgencyColor = Colors.green;
        urgencyIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: urgencyColor, width: 4)),
        color: urgencyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(urgencyIcon, color: urgencyColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation['productName'] ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                label: Text(urgency),
                backgroundColor: urgencyColor,
                labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('SKU: ${recommendation['sku']}'),
          Text('Current Stock: ${recommendation['currentStock']}'),
          Text('Avg Daily Sales: ${recommendation['avgDailySales']}'),
          if (recommendation['daysUntilStockout'] != null && 
              recommendation['daysUntilStockout'] != double.infinity)
            Text('Days Until Stockout: ${recommendation['daysUntilStockout']}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: urgencyColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Action: $action',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: urgencyColor,
              ),
            ),
          ),
          if (recommendation['recommendedQuantity'] > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Recommended Order: ${recommendation['recommendedQuantity']} units',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
        ],
      ),
    );
  }
}