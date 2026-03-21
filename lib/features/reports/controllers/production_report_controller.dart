import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_nm/core/services/supabase_provider.dart';
import 'package:ung_dung_nm/features/reports/models/electrical_cabinet_model.dart';
import 'package:ung_dung_nm/features/reports/models/electricity_reading_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/views/main_navigation_page.dart'; // Import để dùng rolePermissionsProviderUser
import '../controllers/production_report_controller.dart';

class ProductionReportPage extends ConsumerWidget {
  const ProductionReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentProfileProvider).valueOrNull;
    final userRole = currentUser?.role ?? '';

    // Lấy danh sách quyền của người dùng hiện tại
    final permissionsAsync = ref.watch(rolePermissionsProviderUser(userRole));

    return permissionsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text("Lỗi tải quyền: $e"))),
      data: (myFeatures) {
        // Tự động build danh sách Tab dựa trên quyền
        List<Widget> tabs = [];
        List<Widget> tabViews = [];

        if (currentUser?.role == 'admin' ||
            myFeatures.contains('bao_cao_enter_data')) {
          tabs.add(const Tab(icon: Icon(Icons.edit_note), text: "Nhập Liệu"));
          tabViews.add(const DataEntryTab());
        }
        if (currentUser?.role == 'admin' ||
            myFeatures.contains('bao_cao_view_stats')) {
          tabs.add(const Tab(icon: Icon(Icons.show_chart), text: "Thống Kê"));
          tabViews.add(const StatisticsTab());
        }
        if (currentUser?.role == 'admin' ||
            myFeatures.contains('bao_cao_config_cabinet')) {
          tabs.add(
            const Tab(icon: Icon(Icons.settings), text: "Cấu Hình Tủ Điện"),
          );
          tabViews.add(const CabinetManagementTab());
        }

        if (tabs.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text("Bạn không có quyền truy cập tính năng này."),
            ),
          );
        }

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Báo Cáo Sản Xuất"),
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
              bottom: TabBar(isScrollable: true, tabs: tabs),
            ),
            body: TabBarView(children: tabViews),
          ),
        );
      },
    );
  }
}

// =======================================================
// CÁC WIDGET TAB CON (Không thay đổi, giữ nguyên như cũ)
// =======================================================

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

// 3. TAB CẤU HÌNH TỦ ĐIỆN
class CabinetManagementTab extends ConsumerWidget {
  const CabinetManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinetsAsync = ref.watch(electricalCabinetsProvider);
    return Scaffold(
      // Bọc trong Scaffold để có FloatingActionButton
      body: cabinetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Lỗi: $e")),
        data: (cabinets) => ListView.builder(
          itemCount: cabinets.length,
          itemBuilder: (context, index) {
            final cabinet = cabinets[index];
            return ListTile(
              title: Text(cabinet.name),
              subtitle: Text(cabinet.location ?? "Chưa có vị trí"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  /* TODO: Mở form sửa tủ điện */
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /* TODO: Mở form thêm tủ điện mới */
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

final electricalCabinetsProvider = FutureProvider<List<ElectricalCabinet>>((
  ref,
) async {
  final supabase = ref.read(supabaseProvider);
  final response = await supabase
      .from('electrical_cabinets')
      .select()
      .eq('is_active', true)
      .order('name');

  return response.map((json) => ElectricalCabinet.fromJson(json)).toList();
});

// 2. Provider lấy số liệu điện trong 1 tháng (để vẽ biểu đồ)
final monthlyElectricityProvider =
    FutureProvider.family<List<ElectricityReading>, DateTime>((
      ref,
      month,
    ) async {
      final supabase = ref.read(supabaseProvider);

      // Lấy ngày đầu tháng và ngày cuối tháng
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final response = await supabase
          .from('electricity_readings')
          .select()
          .gte('recorded_at', startOfMonth.toIso8601String())
          .lte('recorded_at', endOfMonth.toIso8601String())
          .order('recorded_at');

      return response.map((json) => ElectricityReading.fromJson(json)).toList();
    });

// 3. Provider xử lý các thao tác Thêm/Sửa/Xóa (Action)
final productionReportActionProvider = Provider(
  (ref) => ProductionReportActionController(ref),
);

class ProductionReportActionController {
  final Ref ref;
  ProductionReportActionController(this.ref);

  // Hàm lưu số liệu điện hàng ngày
  Future<bool> upsertElectricityReading(
    String cabinetId,
    double value,
    DateTime date,
  ) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser!.id;
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      // Upsert: Nếu tủ đó trong ngày đó đã nhập rồi thì nó sẽ update, chưa có thì insert
      await supabase.from('electricity_readings').upsert({
        'cabinet_id': cabinetId,
        'recorded_at': dateStr,
        'reading_value': value,
        'recorded_by': userId,
      }, onConflict: 'cabinet_id, recorded_at');

      // Làm mới lại biểu đồ
      ref.invalidate(monthlyElectricityProvider);
      return true;
    } catch (e) {
      print("Lỗi nhập số điện: $e");
      return false;
    }
  }

  // Hàm thêm Tủ điện mới (dùng cho Tab Cấu hình)
  Future<bool> addCabinet(String name, String? location) async {
    try {
      await ref.read(supabaseProvider).from('electrical_cabinets').insert({
        'name': name,
        'location': location,
        'is_active': true,
      });
      ref.invalidate(electricalCabinetsProvider);
      return true;
    } catch (e) {
      print("Lỗi thêm tủ điện: $e");
      return false;
    }
  }
}
