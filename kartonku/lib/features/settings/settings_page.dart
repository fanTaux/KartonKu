import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _supabase = Supabase.instance.client;

  String get _email => _supabase.auth.currentUser?.email ?? '-';

  // Inisial dari email: ambil huruf pertama sebelum @
  String get _initials {
    final name = _email.split('@').first;
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ─── Ambang Batas Global ───────────────────────────────────────────────────

  void _openGlobalThresholdDialog() async {
    // Ambil nilai threshold saat ini dari salah satu produk (semua harusnya sama kalau sudah di-set global)
    int? currentThreshold;
    try {
      final result = await _supabase
          .from('products')
          .select('low_stock_threshold_ctn')
          .limit(1)
          .single();
      currentThreshold = result['low_stock_threshold_ctn'] as int?;
    } catch (_) {
      currentThreshold = 5; // default fallback
    }

    final controller = TextEditingController(text: currentThreshold?.toString() ?? '5');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ambang Batas Global'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stok di bawah angka ini akan ditandai "MENIPIS".\nSatuan: Karton.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Karton',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () async {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan angka yang valid')),
                );
                return;
              }
              Navigator.pop(context);
              await _applyGlobalThreshold(value);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _applyGlobalThreshold(int value) async {
    try {
      // Update semua produk sekaligus — tidak ada filter WHERE, jadi berlaku untuk semua
      await _supabase
          .from('products')
          .update({'low_stock_threshold_ctn': value})
          .neq('id', '00000000-0000-0000-0000-000000000000'); // trick: neq UUID dummy = match semua row

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ambang batas global diperbarui: $value karton'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ─── Ganti Kata Sandi ──────────────────────────────────────────────────────

  void _openChangePasswordDialog() {
    final newPassController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ganti Kata Sandi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPassController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Baru',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: () async {
                final newPass = newPassController.text.trim();
                final confirm = confirmController.text.trim();

                if (newPass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kata sandi minimal 6 karakter')),
                  );
                  return;
                }
                if (newPass != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kata sandi tidak cocok')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _changePassword(newPass);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi berhasil diperbarui'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    }
  }

  // ─── Keluar Sesi ───────────────────────────────────────────────────────────

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Sesi'),
        content: const Text('Anda yakin ingin keluar? Anda perlu login kembali untuk mengakses aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _supabase.auth.signOut();
              // Navigasi ke LoginPage otomatis via StreamBuilder di main.dart
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Profil Card ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryGreen,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _email,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text('Admin', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    // TODO: edit profil (nama, foto) — belum diimplementasikan
                    _showComingSoon('Edit Profil');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Profil', style: TextStyle(color: AppColors.primaryGreen)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Notifikasi (non-fungsional, scope skip) ──────────────────────
          _SectionLabel(label: 'NOTIFIKASI'),
          _SettingsCard(children: [
            _SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Stok Rendah',
              subtitle: 'Kirim peringatan jika stok menipis',
              trailing: Opacity(
                opacity: 0.4,
                child: Switch(
                  value: false,
                  onChanged: null, // disabled — scope skip
                  activeColor: AppColors.primaryGreen,
                ),
              ),
              onTap: () => _showComingSoon('Notifikasi Stok Rendah'),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Inventaris ───────────────────────────────────────────────────
          _SectionLabel(label: 'INVENTARIS'),
          _SettingsCard(children: [
            _SettingsTile(
              icon: Icons.tune_outlined,
              title: 'Ambang Batas Global',
              subtitle: 'Atur batas stok standar semua barang',
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _openGlobalThresholdDialog,
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.category_outlined,
              title: 'Ambang Batas Kategori',
              subtitle: 'Sesuaikan batas tiap kategori barang',
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showComingSoon('Ambang Batas Kategori'),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Keamanan ────────────────────────────────────────────────────
          _SectionLabel(label: 'KEAMANAN'),
          _SettingsCard(children: [
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Ganti Kata Sandi',
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _openChangePasswordDialog,
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.logout,
              title: 'Keluar Sesi',
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: _confirmSignOut,
            ),
          ]),

          const SizedBox(height: 24),

          // ── Bantuan ─────────────────────────────────────────────────────
          _SectionLabel(label: 'BANTUAN'),
          _SettingsCard(children: [
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Pusat Bantuan',
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showComingSoon('Pusat Bantuan'),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.shield_outlined,
              title: 'Kebijakan Privasi',
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showComingSoon('Kebijakan Privasi'),
            ),
          ]),

          const SizedBox(height: 32),

          // ── Versi ────────────────────────────────────────────────────────
          const Center(
            child: Text(
              'Versi 1.0.0 (Development)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — segera hadir'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Reusable sub-widgets ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.black87),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}