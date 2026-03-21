import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_nm/features/admin/controllers/employee_controller.dart';
import 'package:ung_dung_nm/features/attendance/controllers/leave_controller.dart';
import 'package:ung_dung_nm/features/auth/controllers/auth_controller.dart';
import '../../controllers/worker_controller.dart';

class TabCongCaNhan extends ConsumerWidget {
  final String currentUserId;
  const TabCongCaNhan({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gọi provider lấy dữ liệu tháng của User này
    final monthlyDataAsync = ref.watch(
      workerMonthlyTimesheetProvider(currentUserId),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Tiêu đề tháng
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Bảng công Tháng ${DateTime.now().month}/${DateTime.now().year}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Danh sách chấm công
          Expanded(
            child: monthlyDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Text(
                  "Lỗi tải dữ liệu: $e",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (timesheets) {
                if (timesheets.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tháng này bạn chưa có dữ liệu chấm công.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: timesheets.length,
                  itemBuilder: (context, index) {
                    final item = timesheets[index];
                    final dateStr = DateFormat('dd/MM/yyyy').format(item.date);

                    bool isPresent = item.status == 'Có mặt';

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPresent
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            isPresent ? Icons.check : Icons.close,
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          "Ngày: $dateStr",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Ca làm: ${item.shiftType}"
                          "${item.overtimeStart != null && item.overtimeStart!.isNotEmpty ? '\nTăng ca: ${item.overtimeStart} - ${item.overtimeEnd}' : ''}",
                        ),
                        trailing: Text(
                          item.status,
                          style: TextStyle(
                            color: isPresent ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Thêm nút này vào phần Scaffold của TabCongCaNhan:
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Lấy thông tin user hiện tại để gán mặc định "Quản lý trực tiếp"
          final currentUserProfile = await ref.read(
            currentProfileProvider.future,
          );

          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (c) {
              final reasonCtrl = TextEditingController();
              final placeCtrl = TextEditingController(); // Controller nơi nghỉ

              DateTime startDate = DateTime.now();
              DateTime endDate = DateTime.now();
              String startHour = '07';
              String startMin = '00';
              String endHour = '16';
              String endMin = '00';
              String? selectedApproverId = currentUserProfile?.managerId;

              // Các list để dropdown giờ phút
              final hours = List.generate(
                24,
                (index) => index.toString().padLeft(2, '0'),
              );
              final minutes = ['00', '15', '30', '45'];

              return StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  title: const Text(
                    "Đơn Xin Nghỉ Phép",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 500, // Căn rộng ra cho giống web
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HÀNG 1: NGÀY BẮT ĐẦU + GIỜ + PHÚT
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildDatePicker(
                                  context,
                                  "Ngày bắt đầu",
                                  startDate,
                                  (d) => setState(() => startDate = d),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: _buildDropdown(
                                  "Giờ",
                                  startHour,
                                  hours,
                                  (v) => setState(() => startHour = v!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: _buildDropdown(
                                  "Phút",
                                  startMin,
                                  minutes,
                                  (v) => setState(() => startMin = v!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // HÀNG 2: NGÀY KẾT THÚC + GIỜ + PHÚT
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildDatePicker(
                                  context,
                                  "Ngày kết thúc",
                                  endDate,
                                  (d) => setState(() => endDate = d),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: _buildDropdown(
                                  "Giờ",
                                  endHour,
                                  hours,
                                  (v) => setState(() => endHour = v!),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: _buildDropdown(
                                  "Phút",
                                  endMin,
                                  minutes,
                                  (v) => setState(() => endMin = v!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // LÝ DO NGHỈ
                          const Text(
                            "Lý do nghỉ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: reasonCtrl,
                            maxLines: 3, // Giống text area trong hình
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // NƠI NGHỈ
                          const Text(
                            "Nơi nghỉ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: placeCtrl,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // QUẢN LÝ TRỰC TIẾP
                          const Text(
                            "Quản lý trực tiếp:",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ref
                              .watch(employeeListProvider)
                              .when(
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (e, s) => const Text("Lỗi"),
                                data: (employees) {
                                  // Lấy danh sách quản lý
                                  final managers = employees
                                      .where(
                                        (e) => [
                                          'team_leader',
                                          'section_head',
                                          'director',
                                          'admin',
                                        ].contains(e.role),
                                      )
                                      .toList();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedApproverId,
                                        hint: const Text(
                                          "-- Chọn người quản lý --",
                                        ),
                                        items: managers
                                            .map(
                                              (m) => DropdownMenuItem(
                                                value: m.id,
                                                child: Text(
                                                  "${m.fullName} (${m.role})",
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) => setState(
                                          () => selectedApproverId = v,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
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
                        if (reasonCtrl.text.isEmpty ||
                            selectedApproverId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Vui lòng nhập lý do và chọn người quản lý.",
                              ),
                            ),
                          );
                          return;
                        }

                        // Ghép chuỗi ngày giờ
                        final startDateTime = DateTime(
                          startDate.year,
                          startDate.month,
                          startDate.day,
                          int.parse(startHour),
                          int.parse(startMin),
                        );
                        final endDateTime = DateTime(
                          endDate.year,
                          endDate.month,
                          endDate.day,
                          int.parse(endHour),
                          int.parse(endMin),
                        );

                        final success = await ref
                            .read(leaveActionProvider)
                            .submitLeaveRequest(
                              userId: currentUserId,
                              startTime: startDateTime,
                              endTime: endDateTime,
                              reason: reasonCtrl.text,
                              placeOfLeave: placeCtrl.text, // Nơi nghỉ
                              approverId: selectedApproverId!, // Quản lý
                              leaveType: 'Nghỉ phép',
                            );

                        if (context.mounted) {
                          Navigator.pop(c);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success ? "Đã gửi đơn!" : "Gửi đơn thất bại.",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("GỬI ĐƠN"),
                    ),
                  ],
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.edit_document),
        label: const Text("Xin Nghỉ"),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onPicked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('MM/dd/yyyy').format(date)),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
