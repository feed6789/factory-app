import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/attendance_row_model.dart';
import '../../controllers/attendance_controller.dart';

// Các hằng số danh sách như code cũ của bạn
const List<String> dsTrangThai = [
  'Có mặt',
  'Nghỉ phép',
  'Nghỉ ốm',
  'Nghỉ không phép',
  'Ngày nghỉ',
];
const List<String> dsCaLam = [
  'Ca Ngày',
  'Sáng',
  'Chiều',
  'Đêm',
  'Sáng Đêm',
  'Sáng Chiều',
  'Ngày Đêm',
  'Ngày Chiều',
  'Nửa Ngày',
  'Không chấm',
];

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
  // Thay vì gọi setState thủ công, ta báo cho Riverpod Controller biết
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
      elevation: 0, // Bỏ bóng đổ để nhìn phẳng và công nghiệp hơn
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
          child: Row(
            children: [
              // DROPDOWN CA LÀM
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
                      value: dsCaLam.contains(timesheet.shiftType)
                          ? timesheet.shiftType
                          : 'Ca Ngày',
                      isExpanded: true,
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                      items: dsCaLam
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          // Logic: Chọn ca (khác Không chấm) -> Tự động set trạng thái 'Có mặt'
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

              // DROPDOWN TRẠNG THÁI
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
                      value: dsTrangThai.contains(timesheet.status)
                          ? timesheet.status
                          : 'Có mặt',
                      isExpanded: true,
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                      items: dsTrangThai
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          // Logic: Nếu nghỉ thì Ca là 'Không chấm'
                          String newShift = (val != 'Có mặt')
                              ? 'Không chấm'
                              : (timesheet.shiftType == 'Không chấm'
                                    ? 'Ca Ngày'
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
