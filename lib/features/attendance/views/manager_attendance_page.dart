// File: lib/features/attendance/views/manager_attendance_page.dart

import 'package:flutter/material.dart';
import 'package:ung_dung_nm/features/attendance/views/tab_cham_cong_ngay.dart';
import 'package:ung_dung_nm/features/attendance/views/tab_bang_cong_thang.dart';
import 'package:ung_dung_nm/features/attendance/views/tab_danh_gia_xep_loai.dart';

class ManagerAttendancePage extends StatelessWidget {
  final String profileId;
  const ManagerAttendancePage({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý Chấm Công"),
          backgroundColor: Colors.blue.shade800,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.playlist_add_check), text: "Chấm Công Ngày"),
              Tab(icon: Icon(Icons.grid_on), text: "Bảng Tháng"),
              Tab(icon: Icon(Icons.star_rate), text: "Đánh Giá Xếp Loại"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TabChamCongNgay(currentUserId: profileId),
            const TabBangCongThang(),
            const TabDanhGiaXepLoai(),
          ],
        ),
      ),
    );
  }
}
