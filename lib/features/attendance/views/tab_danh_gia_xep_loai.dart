import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/attendance_controller.dart';
import '../controllers/evaluation_controller.dart';
import '../models/evaluation_model.dart';
import '../../auth/controllers/auth_controller.dart';

const List<String> RATING_OPTIONS = ['Tốt', 'Khá', 'Trung bình', 'Yếu'];
const List<String> GRADE_OPTIONS = ['A+', 'A', 'B', 'C', 'D'];

class TabDanhGiaXepLoai extends ConsumerWidget {
  const TabDanhGiaXepLoai({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(evaluationMonthProvider);
    final employeesAsync = ref.watch(departmentEmployeesProvider);
    final evaluationsAsync = ref.watch(monthlyEvaluationsProvider);

    return Column(
      children: [
        // Header: Chọn tháng & Nút Gửi HR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: currentMonth,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    ref.read(evaluationMonthProvider.notifier).state = picked;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        "Tháng ${DateFormat('MM/yyyy').format(currentMonth)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                label: const Text(
                  "Hoàn tất & Gửi HR",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
                onPressed: () => _confirmSubmit(context, ref),
              ),
            ],
          ),
        ),

        // Body: Danh sách nhân viên
        Expanded(
          child: employeesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Lỗi: $e")),
            data: (employees) {
              if (employees.isEmpty)
                return const Center(child: Text("Không có nhân viên."));

              return evaluationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Lỗi: $e")),
                data: (evaluations) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final emp = employees[index];
                      // Tìm xem đã có đánh giá chưa
                      final eval = evaluations
                          .where((e) => e.userId == emp.id)
                          .firstOrNull;

                      bool isDraft = eval?.status == 'draft';
                      bool isSubmitted = eval?.status == 'submitted';

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSubmitted
                                ? Colors.green.shade100
                                : isDraft
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            child: Icon(
                              isSubmitted
                                  ? Icons.check_circle
                                  : (isDraft ? Icons.save : Icons.person),
                              color: isSubmitted
                                  ? Colors.green
                                  : (isDraft ? Colors.blue : Colors.grey),
                            ),
                          ),
                          title: Text(
                            emp.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Mã NV: ${emp.employeeCode}"),
                          trailing: Chip(
                            label: Text(
                              isSubmitted
                                  ? "Đã gửi"
                                  : (isDraft ? "Đã lưu" : "Chưa đánh giá"),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSubmitted
                                    ? Colors.white
                                    : (isDraft ? Colors.white : Colors.black87),
                              ),
                            ),
                            backgroundColor: isSubmitted
                                ? Colors.green
                                : isDraft
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                          onTap: isSubmitted
                              ? () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Đã gửi HR, không thể sửa.",
                                        ),
                                      ),
                                    )
                              : () => _showEvaluationForm(
                                  context,
                                  ref,
                                  emp.id,
                                  emp.fullName,
                                  eval,
                                ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEvaluationForm(
    BuildContext context,
    WidgetRef ref,
    String userId,
    String empName,
    EvaluationModel? existingEval,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => EvaluationDialogForm(
        userId: userId,
        empName: empName,
        existingEval: existingEval,
      ),
    );
  }

  Future<void> _confirmSubmit(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Xác nhận Gửi"),
        content: const Text(
          "Bạn có chắc muốn gửi tất cả đánh giá đã lưu lên HR? Sau khi gửi sẽ không thể chỉnh sửa.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: const Text("Đồng ý gửi"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(evaluationActionProvider)
          .submitAllEvaluations();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? "Đã gửi thành công!" : "Lỗi khi gửi đánh giá.",
            ),
          ),
        );
      }
    }
  }
}

// Dialog Form Đánh giá
class EvaluationDialogForm extends ConsumerStatefulWidget {
  final String userId;
  final String empName;
  final EvaluationModel? existingEval;

  const EvaluationDialogForm({
    super.key,
    required this.userId,
    required this.empName,
    this.existingEval,
  });

  @override
  ConsumerState<EvaluationDialogForm> createState() =>
      _EvaluationDialogFormState();
}

class _EvaluationDialogFormState extends ConsumerState<EvaluationDialogForm> {
  final _formKey = GlobalKey<FormState>();

  String _skill = 'Khá';
  String _attitude = 'Khá';
  String _grade = 'B';

  final _violationsCtrl = TextEditingController();
  final _actionCtrl = TextEditingController();
  final _workingDaysCtrl = TextEditingController(text: '0');
  final _leaveDaysCtrl = TextEditingController(text: '0');
  final _unpaidLeaveCtrl = TextEditingController(text: '0');
  final _unexcusedCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    if (widget.existingEval != null) {
      _skill = widget.existingEval!.skillRating;
      _attitude = widget.existingEval!.attitudeRating;
      _grade = widget.existingEval!.monthlyGrade;
      _violationsCtrl.text = widget.existingEval!.violations;
      _actionCtrl.text = widget.existingEval!.proposedAction;
      _workingDaysCtrl.text = widget.existingEval!.workingDays.toString();
      _leaveDaysCtrl.text = widget.existingEval!.leaveDays.toString();
      _unpaidLeaveCtrl.text = widget.existingEval!.unpaidLeaveDays.toString();
      _unexcusedCtrl.text = widget.existingEval!.unexcusedDays.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Đánh giá: ${widget.empName}",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        "Nhận xét tay nghề (*)",
                        _skill,
                        RATING_OPTIONS,
                        (v) => setState(() => _skill = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        "Ý thức kỷ luật (*)",
                        _attitude,
                        RATING_OPTIONS,
                        (v) => setState(() => _attitude = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Text(
                  "Thống kê công (Ngày)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField("Ngày công", _workingDaysCtrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNumberField("Công phép", _leaveDaysCtrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNumberField("Nghỉ KL", _unpaidLeaveCtrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildNumberField("Vô lý do", _unexcusedCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _violationsCtrl,
                  decoration: const InputDecoration(
                    labelText: "Các lỗi vi phạm trong tháng (*)",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        "Xếp loại tháng",
                        _grade,
                        GRADE_OPTIONS,
                        (v) => setState(() => _grade = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _actionCtrl,
                        decoration: const InputDecoration(
                          labelText: "Loại xét đề nghị (*)",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (v) => v!.isEmpty ? 'Vui lòng nhập' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Giả lập chữ ký người quản lý
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Ký tên: (Đã xác thực điện tử bởi Quản lý)",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
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
            if (_formKey.currentState!.validate()) {
              final currentProfile = await ref.read(
                currentProfileProvider.future,
              );
              final currentMonth = ref.read(evaluationMonthProvider);
              final monthYearStr = DateFormat('yyyy-MM').format(currentMonth);

              final newEval = EvaluationModel(
                userId: widget.userId,
                managerId: currentProfile!.id,
                monthYear: monthYearStr,
                skillRating: _skill,
                attitudeRating: _attitude,
                workingDays: double.tryParse(_workingDaysCtrl.text) ?? 0,
                leaveDays: double.tryParse(_leaveDaysCtrl.text) ?? 0,
                unpaidLeaveDays: double.tryParse(_unpaidLeaveCtrl.text) ?? 0,
                unexcusedDays: double.tryParse(_unexcusedCtrl.text) ?? 0,
                violations: _violationsCtrl.text,
                monthlyGrade: _grade,
                proposedAction: _actionCtrl.text,
                status: 'draft',
              );

              final success = await ref
                  .read(evaluationActionProvider)
                  .saveEvaluation(newEval);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? "Đã lưu bản nháp!" : "Lỗi khi lưu.",
                    ),
                  ),
                );
              }
            }
          },
          child: const Text("LƯU ĐÁNH GIÁ"),
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
            border: Border.all(color: Colors.grey),
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

  Widget _buildNumberField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        labelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
