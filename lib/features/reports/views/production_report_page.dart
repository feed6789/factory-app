import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/production_report_controller.dart';

class ProductionReportPage extends ConsumerWidget {
  const ProductionReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = DateTime.now();
    final electricityAsync = ref.watch(monthlyElectricityProvider(month));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Báo Cáo & Thống Kê",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            Colors.purple.shade800, // Màu nhận diện riêng cho Báo cáo
        foregroundColor: Colors.white,
      ),
      body: electricityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Lỗi tải dữ liệu: $e")),
        data: (readings) {
          if (readings.isEmpty) {
            return const Center(
              child: Text("Chưa có dữ liệu thống kê trong tháng này."),
            );
          }

          // Tổng hợp dữ liệu vẽ biểu đồ
          final dailyTotals = <int, double>{};
          for (var r in readings) {
            dailyTotals.update(
              r.recordedAt.day,
              (value) => value + r.readingValue,
              ifAbsent: () => r.readingValue,
            );
          }
          final spots = dailyTotals.entries
              .map((e) => FlSpot(e.key.toDouble(), e.value))
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.insights, color: Colors.purple),
                            const SizedBox(width: 8),
                            Text(
                              "Biểu đồ Điện năng - Tháng ${month.month}/${month.year}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  barWidth: 4,
                                  color: Colors.purple.shade600,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.purple.shade100.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
