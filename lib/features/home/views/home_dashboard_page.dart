// File: lib/features/home/views/home_dashboard_page.dart

import 'package:flutter/material.dart';

class FeatureMenuItem {
  final String title;
  final IconData icon;
  final Widget? destination;
  final bool isComingSoon;
  final Color iconColor;

  const FeatureMenuItem({
    required this.title,
    required this.icon,
    this.destination,
    this.isComingSoon = false,
    this.iconColor = Colors.blue, // Màu mặc định
  });
}

class HomeDashboardPage extends StatelessWidget {
  final String userName;
  final List<FeatureMenuItem> menuItems;
  final VoidCallback onLogout;

  const HomeDashboardPage({
    super.key,
    required this.userName,
    required this.menuItems,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Xin chào, $userName",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: onLogout,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1000,
          ), // Giới hạn độ rộng trên Web
          child: GridView.builder(
            padding: const EdgeInsets.all(20.0),
            // Sử dụng MaxCrossAxisExtent để các ô tự động co giãn vuông vức
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220, // Rộng tối đa 220px mỗi ô
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0, // Ép tỷ lệ 1:1 (Hình vuông hoàn hảo)
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              return _buildMenuItemCard(context, menuItems[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, FeatureMenuItem item) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      clipBehavior: Clip
          .antiAlias, // Quan trọng: Cắt các phần tử tràn ra ngoài góc bo tròn
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (item.isComingSoon || item.destination == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tính năng này sẽ được phát triển sớm!'),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item.destination!),
            );
          }
        },
        child: Stack(
          // Sử dụng Stack để đặt cái nhãn "Sắp có" vào góc
          children: [
            // Nội dung chính của thẻ
            Container(
              decoration: BoxDecoration(
                gradient: LinearFromTopToBottom(
                  item.iconColor,
                ), // Tự tạo màu nền nhẹ
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 54,
                        color: item.iconColor.withOpacity(0.8),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Nhãn "Sắp có" gọn gàng ở góc trên cùng bên phải
            if (item.isComingSoon)
              Positioned(
                top: 12,
                right: -25,
                child: Transform.rotate(
                  angle: 0.785398, // Xoay 45 độ
                  child: Container(
                    color: Colors.orange.shade400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 4,
                    ),
                    child: const Text(
                      'Sắp có',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Hàm phụ tạo màu gradient nhẹ
  LinearGradient LinearFromTopToBottom(Color baseColor) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, baseColor.withOpacity(0.05)],
    );
  }
}
