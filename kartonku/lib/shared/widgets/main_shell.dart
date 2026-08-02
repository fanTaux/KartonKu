import 'package:flutter/material.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/history/history_page.dart';
import '../../features/settings/settings_page.dart';
import '../theme/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;

  static const _pages = [
    DashboardPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  void _openCameraScan() {
    // TODO: buka flow OCR/scan karton — belum diimplementasikan
    // Fungsi ini dipanggil dari FAB yang sama baik di tab Dashboard maupun Riwayat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      floatingActionButton: _navIndex == 2 // sembunyikan FAB di tab Settings
          ? null
          : FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: _openCameraScan,
        child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}