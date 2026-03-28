import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_nm/features/admin/controllers/employee_controller.dart';
import 'package:ung_dung_nm/features/attendance/controllers/leave_controller.dart';
import 'package:ung_dung_nm/features/auth/controllers/auth_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../../admin/controllers/department_controller.dart';

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
      appBar: AppBar(
        title: const Text(
          "Bảng Công Cá Nhân",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Tháng ${DateTime.now().month}/${DateTime.now().year}",
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
          // Lấy profile của người dùng HIỆN TẠI trước khi mở dialog
          final currentUserProfile = await ref.read(
            currentProfileProvider.future,
          );
          if (!context.mounted) return;

          // Mở Dialog để điền đơn
          showDialog(
            context: context,
            barrierDismissible: false,
            // Sử dụng một Dialog Widget riêng để quản lý state tốt hơn
            builder: (c) => XinNghiPhepDialog(
              currentUserId: currentUserId,
              // Truyền managerId mặc định vào dialog
              defaultManagerId: currentUserProfile?.managerId,
            ),
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

// ======================================================================
// WIDGET DIALOG XIN NGHỈ PHÉP (PHIÊN BẢN HOÀN CHỈNH - ĐÃ BỔ SUNG HÀM)
// ======================================================================
class XinNghiPhepDialog extends ConsumerStatefulWidget {
  final String currentUserId;
  final String? defaultManagerId;

  const XinNghiPhepDialog({
    super.key,
    required this.currentUserId,
    this.defaultManagerId,
  });

  @override
  ConsumerState<XinNghiPhepDialog> createState() => _XinNghiPhepDialogState();
}

class _XinNghiPhepDialogState extends ConsumerState<XinNghiPhepDialog> {
  final _reasonCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _startHour = '07';
  String _startMin = '00';
  String _endHour = '16';
  String _endMin = '00';
  String? _selectedApproverId;

  final _hours = List.generate(24, (i) => i.toString().padLeft(2, '0'));
  final _minutes = ['00', '15', '30', '45'];

  @override
  void initState() {
    super.initState();
    _selectedApproverId = widget.defaultManagerId;
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _placeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeeListProvider);

    return AlertDialog(
      title: const Text(
        "Đơn Xin Nghỉ Phép",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDatePicker(
                      context,
                      "Ngày bắt đầu",
                      _startDate,
                      (d) => setState(() => _startDate = d),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      "Giờ",
                      _startHour,
                      _hours,
                      (v) => setState(() => _startHour = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      "Phút",
                      _startMin,
                      _minutes,
                      (v) => setState(() => _startMin = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDatePicker(
                      context,
                      "Ngày kết thúc",
                      _endDate,
                      (d) => setState(() => _endDate = d),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      "Giờ",
                      _endHour,
                      _hours,
                      (v) => setState(() => _endHour = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      "Phút",
                      _endMin,
                      _minutes,
                      (v) => setState(() => _endMin = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Lý do nghỉ", _reasonCtrl, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField("Nơi nghỉ", _placeCtrl),
              const SizedBox(height: 16),
              const Text(
                "Quản lý trực tiếp:",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              employeesAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, s) => const Text(
                  "Lỗi tải danh sách",
                  style: TextStyle(color: Colors.red),
                ),
                data: (employees) {
                  // ĐỌC CẤP BẬC TỪ DATABASE ĐỂ LỌC
                  return Consumer(
                    builder: (context, ref, child) {
                      final workflowsAsync = ref.watch(
                        approvalWorkflowsProvider,
                      );
                      final currentUserAsync = ref.watch(
                        currentProfileProvider,
                      );

                      return workflowsAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => const Text(
                          "Lỗi tải quy trình duyệt",
                          style: TextStyle(color: Colors.red),
                        ),
                        data: (workflows) {
                          final currentUserRole =
                              currentUserAsync.valueOrNull?.role ?? 'worker';
                          final currentUserDept =
                              currentUserAsync.valueOrNull?.departmentId;

                          // 1. Tìm các quy trình duyệt dành cho chức vụ của người này
                          final myWorkflows = workflows
                              .where(
                                (w) =>
                                    w['role_code'] == currentUserRole &&
                                    w['module_type'] ==
                                        'leave_request', // <--- LỌC ĐÚNG QUY TRÌNH NGHỈ PHÉP
                              )
                              .toList();

                          // 2. Trích xuất ra danh sách "Người duyệt bước 1" (Phần tử đầu tiên trong mảng steps)
                          final List<String> allowedManagerRoles = [];
                          for (var wf in myWorkflows) {
                            final steps = wf['steps'] as List<dynamic>? ?? [];
                            if (steps.isNotEmpty) {
                              allowedManagerRoles.add(steps.first.toString());
                            }
                          }

                          // 3. Lọc danh sách nhân sự thực tế trong công ty khớp với Role duyệt bước 1
                          final managers = employees.where((e) {
                            bool isAllowedRole = allowedManagerRoles.contains(
                              e.role,
                            );
                            bool isSameDept =
                                e.departmentId == currentUserDept ||
                                e.role == 'director' ||
                                e.role == 'admin';
                            return isAllowedRole && isSameDept;
                          }).toList();

                          // Reset dropdown nếu dữ liệu không khớp
                          if (_selectedApproverId != null &&
                              !managers.any(
                                (m) => m.id == _selectedApproverId,
                              )) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _selectedApproverId = null),
                            );
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedApproverId,
                                hint: const Text(
                                  "-- Chọn người nhận đơn (Bước 1) --",
                                ),
                                items: managers
                                    .map(
                                      (m) => DropdownMenuItem(
                                        value: m.id,
                                        child: Text(
                                          "${m.fullName} (${m.role})",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedApproverId = v),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            if (_reasonCtrl.text.isEmpty || _selectedApproverId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Vui lòng nhập lý do và chọn người quản lý."),
                ),
              );
              return;
            }
            final startDateTime = DateTime(
              _startDate.year,
              _startDate.month,
              _startDate.day,
              int.parse(_startHour),
              int.parse(_startMin),
            );
            final endDateTime = DateTime(
              _endDate.year,
              _endDate.month,
              _endDate.day,
              int.parse(_endHour),
              int.parse(_endMin),
            );
            final success = await ref
                .read(leaveActionProvider)
                .submitLeaveRequest(
                  userId: widget.currentUserId,
                  startTime: startDateTime,
                  endTime: endDateTime,
                  reason: _reasonCtrl.text,
                  placeOfLeave: _placeCtrl.text,
                  approverId: _selectedApproverId!,
                  leaveType: 'Nghỉ phép',
                );
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? "Đã gửi đơn!" : "Gửi đơn thất bại."),
                ),
              );
            }
          },
          child: const Text("GỬI ĐƠN"),
        ),
      ],
    );
  }

  // ========================================================
  // CÁC HÀM PHỤ TRỢ BỊ THIẾU (ĐÃ BỔ SUNG VÀO ĐÂY)
  // ========================================================

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
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                ), // Sửa định dạng ngày cho thân thiện
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

  // Widget phụ trợ
  
