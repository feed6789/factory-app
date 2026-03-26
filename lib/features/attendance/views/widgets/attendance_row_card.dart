import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_nm/features/admin/controllers/department_controller.dart';
import '../../models/attendance_row_model.dart';
import '../../controllers/attendance_controller.dart';

class AttendanceRowCard extends ConsumerStatefulWidget {
  final AttendanceRowModel rowData;

  const AttendanceRowCard({super.key, required this.rowData});

  @override
  ConsumerState<AttendanceRowCard> createState() => _AttendanceRowCardState();
}

class _AttendanceRowCardState extends ConsumerState<AttendanceRowCard> {
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;

  @override
  void initState() {
    super.initState();
    // Khởi tạo TextController từ dữ liệu Supabase trả về
    _startCtrl = TextEditingController(
      text: widget.rowData.timesheet.overtimeStart ?? '',
    );
    _endCtrl = TextEditingController(
      text: widget.rowData.timesheet.overtimeEnd ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant AttendanceRowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Đồng bộ lại TextController nếu Riverpod cập nhật state từ bên ngoài
    if (oldWidget.rowData.timesheet.overtimeStart !=
        widget.rowData.timesheet.overtimeStart) {
      _startCtrl.text = widget.rowData.timesheet.overtimeStart ?? '';
    }
    if (oldWidget.rowData.timesheet.overtimeEnd !=
        widget.rowData.timesheet.overtimeEnd) {
      _endCtrl.text = widget.rowData.timesheet.overtimeEnd ?? '';
    }
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  // --- HÀM CẬP NHẬT LÊN RIVERPOD NGAY LẬP TỨC ---
  void _updateStateLocal({
    String? caLamMoi,
    String? trangThaiMoi,
    String? gioBatDau,
    String? gioKetThuc,
    String? ghiChu,
  }) {
    final currentTimesheet = widget.rowData.timesheet;

    // Tạo bản sao mới (copy) với dữ liệu vừa thay đổi
    final updatedTimesheet = currentTimesheet.copyWith(
      shiftType: caLamMoi ?? currentTimesheet.shiftType,
      status: trangThaiMoi ?? currentTimesheet.status,
      overtimeStart: gioBatDau ?? currentTimesheet.overtimeStart,
      overtimeEnd: gioKetThuc ?? currentTimesheet.overtimeEnd,
      notes: ghiChu ?? currentTimesheet.notes,
    );

    // Gọi Controller để cập nhật UI ngay lập tức
    ref
        .read(attendanceControllerProvider.notifier)
        .updateLocalRow(widget.rowData.profile.id, updatedTimesheet);
  }

  Future<void> _chonGio(TextEditingController ctrl, bool isStart) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t != null) {
      final dt = DateTime(2024, 1, 1, t.hour, t.minute);
      final timeString = DateFormat('HH:mm').format(dt);

      if (isStart) {
        _updateStateLocal(gioBatDau: timeString);
      } else {
        _updateStateLocal(gioKetThuc: timeString);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.rowData.profile;
    final timesheet = widget.rowData.timesheet;

    // Giao diện phong cách Industrial: Gọn gàng, viền nét cứng cáp
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 0,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        collapsedBackgroundColor: timesheet.status == 'Có mặt'
            ? Colors.white
            : Colors.red.shade50,
        leading: CircleAvatar(
          backgroundColor: timesheet.status == 'Có mặt'
              ? Colors.blue.shade100
              : Colors.red.shade100,
          child: Text(
            profile.fullName.isNotEmpty
                ? profile.fullName[0].toUpperCase()
                : "?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        title: Text(
          profile.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Consumer(
            // Dùng Consumer để watch được Config Provider an toàn
            builder: (context, ref, child) {
              // 1. Lấy danh sách cấu hình động, ép kiểu về <Map<String, dynamic>>[] để tránh lỗi Type
              final shiftConfigs =
                  ref.watch(shiftConfigsProvider).valueOrNull ??
                  <Map<String, dynamic>>[];
              final statusConfigs =
                  ref.watch(attendanceStatusConfigsProvider).valueOrNull ??
                  <Map<String, dynamic>>[];

              // 2. Chuyển thành List<String> lấy trường 'name'
              List<String> listCaLam = shiftConfigs
                  .map((e) => e['name'].toString())
                  .toList();
              List<String> listTrangThai = statusConfigs
                  .map((e) => e['name'].toString())
                  .toList();

              // Nếu db trống, dự phòng mảng mặc định để App không crash
              if (listCaLam.isEmpty) listCaLam = ['Ca Ngày', 'Không chấm'];
              if (listTrangThai.isEmpty)
                listTrangThai = ['Có mặt', 'Nghỉ phép'];

              // 3. Đảm bảo giá trị hiện tại có tồn tại trong danh sách
              final currentShift = listCaLam.contains(timesheet.shiftType)
                  ? timesheet.shiftType
                  : listCaLam.first;
              final currentStatus = listTrangThai.contains(timesheet.status)
                  ? timesheet.status
                  : listTrangThai.first;

              return Row(
                children: [
                  // DROPDOWN CA LÀM VIỆC ĐỘNG
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentShift,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          items: listCaLam
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              // Logic phụ: Nếu chọn Không chấm thì đổi trạng thái
                              String newStatus = (val != 'Không chấm')
                                  ? 'Có mặt'
                                  : timesheet.status;
                              _updateStateLocal(
                                caLamMoi: val,
                                trangThaiMoi: newStatus,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // DROPDOWN TRẠNG THÁI CÔNG ĐỘNG
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentStatus,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          items: listTrangThai
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              // Logic phụ: Nếu chọn trạng thái Nghỉ, tự chuyển Ca về Không chấm
                              String newShift = (val != 'Có mặt')
                                  ? 'Không chấm'
                                  : (timesheet.shiftType == 'Không chấm'
                                        ? listCaLam.first
                                        : timesheet.shiftType);
                              _updateStateLocal(
                                trangThaiMoi: val,
                                caLamMoi: newShift,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        children: [
          // PHẦN MỞ RỘNG: TĂNG CA VÀ GHI CHÚ
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chi tiết Tăng ca & Ghi chú",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startCtrl,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Bắt đầu TC",
                          border: OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: Icon(Icons.access_time, size: 18),
                        ),
                        onTap: () => _chonGio(_startCtrl, true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _endCtrl,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Kết thúc TC",
                          border: OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: Icon(Icons.access_time, size: 18),
                        ),
                        onTap: () => _chonGio(_endCtrl, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: timesheet.notes,
                  decoration: const InputDecoration(
                    labelText: "Ghi chú công việc",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) => _updateStateLocal(ghiChu: val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
