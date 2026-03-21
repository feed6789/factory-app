import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/production_report_controller.dart';
// import các tab con sẽ tạo ở dưới

class ProductionReportPage extends StatelessWidget {
  const ProductionReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic kiểm tra quyền để hiển thị tab "Cấu hình"
    // final user = ref.watch(currentProfileProvider).valueOrNull;
    // final canConfigure = user?.role == 'admin' || user is Trưởng bộ phận điện;

    return DefaultTabController(
      length: 3, // Nhập liệu, Thống kê, Cấu hình
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Báo Cáo Sản Xuất"),
          backgroundColor: Colors.blue.shade800,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: "Nhập Liệu"),
              Tab(icon: Icon(Icons.show_chart), text: "Thống Kê"),
              Tab(icon: Icon(Icons.settings), text: "Cấu Hình Tủ Điện"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DataEntryTab(), // Sẽ tạo ở dưới
            StatisticsTab(), // Sẽ tạo ở dưới
            CabinetManagementTab(), // Sẽ tạo ở dưới
          ],
        ),
      ),
    );
  }
}

// 1. TAB NHẬP LIỆU
class DataEntryTab extends ConsumerStatefulWidget {
  const DataEntryTab({super.key});
  @override
  ConsumerState<DataEntryTab> createState() => _DataEntryTabState();
}

class _DataEntryTabState extends ConsumerState<DataEntryTab> {
  String? _selectedCabinetId;
  final _readingCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cabinetsAsync = ref.watch(electricalCabinetsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nhập số điện tiêu thụ trong ngày",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              cabinetsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text("Lỗi tải danh sách tủ: $e"),
                data: (cabinets) => DropdownButtonFormField<String>(
                  value: _selectedCabinetId,
                  hint: const Text("Chọn tủ điện..."),
                  items: cabinets
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCabinetId = val),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _readingCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nhập số điện (kWh)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("LƯU SỐ LIỆU"),
                  onPressed: () async {
                    if (_selectedCabinetId != null &&
                        _readingCtrl.text.isNotEmpty) {
                      final value = double.tryParse(_readingCtrl.text) ?? 0.0;
                      final success = await ref
                          .read(productionReportActionProvider)
                          .upsertElectricityReading(
                            _selectedCabinetId!,
                            value,
                            DateTime.now(),
                          );

                      if (mounted && success) {
                        _readingCtrl.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đã lưu thành công!")),
                        );
                      }
                    }
                  },
                ),
              ),
              const Divider(height: 40),
              // TODO: Thêm form nhập liệu cho Khí nén tương tự
            ],
          ),
        ),
      ),
    );
  }
}

// 2. TAB THỐNG KÊ
class StatisticsTab extends ConsumerWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = DateTime.now(); // Lấy tháng hiện tại
    final electricityAsync = ref.watch(monthlyElectricityProvider(month));

    return electricityAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Lỗi tải dữ liệu thống kê: $e")),
      data: (readings) {
        if (readings.isEmpty)
          return const Center(child: Text("Chưa có dữ liệu trong tháng này."));

        // Xử lý dữ liệu để vẽ biểu đồ
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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Tổng điện tiêu thụ tháng ${month.month}/${month.year}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            // TODO: Thêm các biểu đồ, thống kê khác...
          ],
        );
      },
    );
  }
}

// 3. TAB CẤU HÌNH TỦ ĐIỆN (Đã sửa lỗi Scaffold và thêm Dialog Thêm Tủ)
class CabinetManagementTab extends ConsumerWidget {
  const CabinetManagementTab({super.key});

  // Hàm hiển thị Form thêm Tủ điện
  void _showAddCabinetDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Thêm Tủ Điện Mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Tên tủ điện (*)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(labelText: "Vị trí / Khu vực"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng nhập tên tủ điện")),
                );
                return;
              }
              // Gọi hàm addCabinet từ Controller
              final success = await ref
                  .read(productionReportActionProvider)
                  .addCabinet(nameCtrl.text, locationCtrl.text);
              if (context.mounted) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Đã thêm tủ điện thành công!"
                          : "Lỗi khi thêm tủ điện.",
                    ),
                  ),
                );
              }
            },
            child: const Text("LƯU"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinetsAsync = ref.watch(electricalCabinetsProvider);

    // SỬA LỖI Ở ĐÂY: Phải bọc body và floatingActionButton bên trong một Scaffold
    return Scaffold(
      body: cabinetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Lỗi: $e")),
        data: (cabinets) {
          if (cabinets.isEmpty)
            return const Center(child: Text("Chưa có cấu hình tủ điện nào."));

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 80,
            ), // Cách lề dưới để không bị nút đè lên
            itemCount: cabinets.length,
            itemBuilder: (context, index) {
              final cabinet = cabinets[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 1,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.electrical_services, color: Colors.white),
                  ),
                  title: Text(
                    cabinet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    cabinet.location != null && cabinet.location!.isNotEmpty
                        ? cabinet.location!
                        : "Chưa có vị trí",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    tooltip: "Sửa tủ điện",
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tính năng sửa đang phát triển"),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // Đặt FloatingActionButton ở đúng vị trí của Scaffold
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCabinetDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Thêm Tủ Điện"),
      ),
    );
  }
}
