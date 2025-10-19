import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/models/pie_chart_data_model.dart';
import '../data/services/dashboard_service.dart';

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({super.key});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  // We now only need to listen to one, combined stream.
  final Stream<List<PieChartCategoryData>> _pieChartDataStream =
      DashboardService.instance.getPieChartData();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Product Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<PieChartCategoryData>>(
                stream: _pieChartDataStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No product data available.'));
                  }

                  final pieData = snapshot.data!;
                  final sections = pieData
                      .where((data) => data.productCount > 0) // Only show categories with products
                      .map((data) {
                    return PieChartSectionData(
                      color: data.color,
                      value: data.productCount.toDouble(),
                      title: data.productCount.toString(),
                      radius: 60,
                      titleStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                  
                  if (sections.isEmpty) {
                     return const Center(child: Text('No products in any category.'));
                  }

                  return PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // The legend is also built from the same, single stream.
            StreamBuilder<List<PieChartCategoryData>>(
              stream: _pieChartDataStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                final pieData = snapshot.data!;
                return Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: pieData.map((data) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: data.color,
                        ),
                        const SizedBox(width: 6),
                        Text(data.categoryName, style: const TextStyle(fontSize: 14)),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

