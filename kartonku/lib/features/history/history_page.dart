import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/theme/app_colors.dart';
import 'models/stock_transaction.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _supabase = Supabase.instance.client;
  final List<StockTransaction> _transactions = [];
  final _searchController = TextEditingController();

  static const _pageSize = 20;
  int _offset = 0;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    try {
      final query = _supabase
          .from('stock_transactions')
          .select('id, change_qty, reason, created_at, products(name, image_url, packs_per_carton)')
          .order('created_at', ascending: false)
          .range(_offset, _offset + _pageSize - 1);

      final result = await query;
      final newItems = (result as List).map((e) => StockTransaction.fromMap(e)).toList();

      setState(() {
        _transactions.addAll(newItems);
        _offset += newItems.length;
        _hasMore = newItems.length == _pageSize;
      });
    } catch (e) {
      // TODO: tampilkan error state yang lebih baik ke user
      debugPrint('Gagal load transaksi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Grouping "Hari Ini" / "Kemarin" / tanggal biasa
  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'HARI INI';
    if (target == yesterday) return 'KEMARIN';
    return '${date.day}/${date.month}/${date.year}'.toUpperCase();
  }

  Map<String, List<StockTransaction>> _groupByDate(List<StockTransaction> items) {
    final Map<String, List<StockTransaction>> grouped = {};
    for (final tx in items) {
      final label = _dateLabel(tx.createdAt);
      grouped.putIfAbsent(label, () => []).add(tx);
    }
    return grouped;
  }

  void _openAddTransactionSheet() {
    // TODO: buat form pilih produk + jumlah karton + tipe (masuk/keluar)
    // lalu insert ke stock_transactions dengan change_qty = jumlahCarton * packsPerCarton
    showModalBottomSheet(
      context: context,
      builder: (context) => const SizedBox(
        height: 300,
        child: Center(child: Text('Form tambah transaksi manual — belum diimplementasikan')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(_transactions);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Riwayat',
          style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              // TODO: fitur notifikasi belum dibahas — konfirmasi dulu scope-nya
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari transaksi...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onSubmitted: (_) {
                      // TODO: implementasikan filter/search — lihat catatan di bawah
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      // TODO: filter by tipe (masuk/keluar) atau rentang tanggal
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < entry.value.length; i++) ...[
                          _TransactionTile(tx: entry.value[i]),
                          if (i != entry.value.length - 1) const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (_hasMore)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: OutlinedButton(
                      onPressed: _loading ? null : _loadMore,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Muat Lebih Banyak', style: TextStyle(color: AppColors.primaryGreen)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: _openAddTransactionSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final StockTransaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final sign = tx.isIncoming ? '+' : '-';
    final color = tx.isIncoming ? Colors.green.shade700 : Colors.red.shade700;
    final badgeBg = tx.isIncoming ? Colors.green.shade50 : Colors.red.shade50;
    final badgeLabel = tx.isIncoming ? 'MASUK' : 'KELUAR';
    final hour = tx.createdAt.hour.toString().padLeft(2, '0');
    final minute = tx.createdAt.minute.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: tx.productImageUrl != null
                ? Image.network(tx.productImageUrl!, width: 48, height: 48, fit: BoxFit.cover)
                : Container(
              width: 48, height: 48,
              color: AppColors.background,
              child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  'Admin: ${Supabase.instance.client.auth.currentUser?.email ?? '-'} • $hour:$minute WIB',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sign${tx.changeQtyCartons} Ctn',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                child: Text(badgeLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}