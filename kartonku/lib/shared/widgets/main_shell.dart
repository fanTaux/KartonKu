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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      floatingActionButton: _navIndex == 2
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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}