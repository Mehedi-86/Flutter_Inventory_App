import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/product_service.dart';
import '../../data/models/product_model.dart';

class SalesForecastScreen extends StatefulWidget {
  const SalesForecastScreen({super.key});

  @override
  State<SalesForecastScreen> createState() => _SalesForecastScreenState();
}

class _SalesForecastScreenState extends State<SalesForecastScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _forecast;
  List<Product> _products = [];
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
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
      final forecast = await AnalyticsService.instance.getSalesForecast(_products);
      
      setState(() {
        _forecast = forecast;
        // Set selected product ID to the first product's ID from the forecast data
        if (forecast['forecasts'] != null && forecast['forecasts'].isNotEmpty) {
          _selectedProductId = forecast['forecasts'].first['productId'];
        } else {
          _selectedProductId = _products.isNotEmpty ? _products.first.id : null;
        }
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
        title: const Text('Sales Forecast'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadForecast,
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
            Text('Generating sales forecast...'),
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
                'Error loading forecast',
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
                onPressed: _loadForecast,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final forecasts = _forecast?['forecasts'] as List? ?? [];
    
    if (forecasts.isEmpty) {
      return const Center(
        child: Text('No forecast data available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadForecast,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProductSelector(forecasts),
          const SizedBox(height: 16),
          _buildForecastSummary(forecasts),
          const SizedBox(height: 16),
          _buildForecastChart(forecasts),
          const SizedBox(height: 16),
          _buildTopProductsCard(forecasts),
        ],
      ),
    );
  }

  Widget _buildProductSelector(List forecasts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Product for Detailed Forecast',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: forecasts.any((f) => f['productId'] == _selectedProductId) 
                  ? _selectedProductId 
                  : null,
              isExpanded: true,
              items: forecasts.map<DropdownMenuItem<String>>((forecast) {
                return DropdownMenuItem<String>(
                  value: forecast['productId'],
                  child: Text('${forecast['productName']} (${forecast['sku']})'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProductId = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastSummary(List forecasts) {
    final totalPredictedSales = forecasts.fold<double>(
      0, 
      (sum, forecast) => sum + (forecast['totalPredictedSales'] ?? 0).toDouble()
    );
    
    final totalPredictedRevenue = forecasts.fold<double>(
      0, 
      (sum, forecast) => sum + (forecast['totalPredictedRevenue'] ?? 0).toDouble()
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '30-Day Forecast Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total Predicted Sales',
                  '${totalPredictedSales.toInt()} units',
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'Total Predicted Revenue',
                  '\$${totalPredictedRevenue.toStringAsFixed(0)}',
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Products Analyzed',
                  '${forecasts.length}',
                  Colors.purple,
                ),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForecastChart(List forecasts) {
    if (_selectedProductId == null) return const SizedBox.shrink();

    final selectedForecast = forecasts.firstWhere(
      (f) => f['productId'] == _selectedProductId,
      orElse: () => null,
    );

    if (selectedForecast == null) return const SizedBox.shrink();

    final forecastData = selectedForecast['forecast'] as List? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Forecast - ${selectedForecast['productName']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < forecastData.length) {
                            return Text('Day ${value.toInt() + 1}', style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: forecastData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['predictedQuantity'] ?? 0).toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Predicted Sales: ${selectedForecast['totalPredictedSales']} units',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Predicted Revenue: \$${selectedForecast['totalPredictedRevenue']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsCard(List forecasts) {
    // Sort by predicted sales
    final sortedForecasts = List.from(forecasts);
    sortedForecasts.sort((a, b) => 
      (b['totalPredictedSales'] ?? 0).compareTo(a['totalPredictedSales'] ?? 0));
    
    final topProducts = sortedForecasts.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 5 Products by Predicted Sales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...topProducts.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['productName'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('SKU: ${product['sku']}'),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product['totalPredictedSales']} units',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${product['totalPredictedRevenue']?.toStringAsFixed(0) ?? '0'}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}