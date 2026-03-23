import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _phoneCtrl = TextEditingController();
  bool _isEditingPhone = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  // DIALOG ĐỔI MẬT KHẨU
  void _showChangePasswordDialog(BuildContext context) {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscurePass = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              "Đổi Mật Khẩu",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passCtrl,
                  obscureText: obscurePass,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu mới (ít nhất 6 ký tự)",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePass ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscurePass = !obscurePass),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: "Xác nhận mật khẩu mới",
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
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
                  if (passCtrl.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mật khẩu phải từ 6 ký tự!"),
                      ),
                    );
                    return;
                  }
                  if (passCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mật khẩu xác nhận không khớp!"),
                      ),
                    );
                    return;
                  }

                  // Gọi hàm đổi mật khẩu
                  final result = await ref
                      .read(profileActionProvider)
                      .changePassword(passCtrl.text);
                  if (context.mounted) {
                    Navigator.pop(c);
                    if (result == "OK") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ Đổi mật khẩu thành công!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("❌ $result"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text("CẬP NHẬT"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Thông Tin Người Dùng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Lỗi: $e")),
        data: (profile) {
          if (profile == null)
            return const Center(child: Text("Không tải được dữ liệu"));

          if (!_isEditingPhone && _phoneCtrl.text.isEmpty) {
            _phoneCtrl.text = profile.phoneNumber ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. Avatar và Tên
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade200,
                        child: Text(
                          profile.fullName.isNotEmpty
                              ? profile.fullName[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Mã NV: ${profile.employeeCode}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          profile.role.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Thẻ hiển thị thông tin không được sửa
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thông tin hệ thống (Chỉ HR được sửa)",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.email, color: Colors.blue),
                          title: const Text("Email đăng nhập"),
                          subtitle: Text(profile.email ?? "Chưa cập nhật"),
                        ),
                        // Nếu có nhu cầu hiển thị thêm Bộ phận, Phòng ban thì gọi ở đây...
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Thẻ thông tin cá nhân CÓ THỂ sửa (Số điện thoại)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Thông tin liên hệ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextButton.icon(
                              icon: Icon(
                                _isEditingPhone ? Icons.save : Icons.edit,
                                color: Colors.green,
                              ),
                              label: Text(_isEditingPhone ? "Lưu" : "Sửa"),
                              onPressed: () async {
                                if (_isEditingPhone) {
                                  // Lưu vào DB
                                  final success = await ref
                                      .read(profileActionProvider)
                                      .updatePhone(
                                        profile.id,
                                        _phoneCtrl.text.trim(),
                                      );
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Đã lưu số điện thoại!"),
                                      ),
                                    );
                                  }
                                }
                                setState(
                                  () => _isEditingPhone = !_isEditingPhone,
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        TextField(
                          controller: _phoneCtrl,
                          enabled: _isEditingPhone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Số điện thoại",
                            prefixIcon: const Icon(Icons.phone),
                            border: _isEditingPhone
                                ? const OutlineInputBorder()
                                : InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 4. Nút đổi mật khẩu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.lock_reset),
                    label: const Text(
                      "THAY ĐỔI MẬT KHẨU",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => _showChangePasswordDialog(context),
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
