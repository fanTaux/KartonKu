import 'package:flutter/material.dart';
import '../../shared/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text('Halaman Settings — belum dirancang', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}