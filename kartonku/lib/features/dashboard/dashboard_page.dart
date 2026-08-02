import 'package:flutter/material.dart';
import '../inventory/models/product.dart';
import '../inventory/widgets/product_list_item.dart';
import 'widgets/stat_card.dart';
import '../../shared/theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // MOCK DATA — ganti dengan fetch dari Supabase view `product_stock` di Fase 3
  final List<Product> _products = [
    Product(id: '1', name: 'Laras Facial 250s', packsPerCarton: 12, lowStockThresholdCtn: 5, totalStockPacks: 25 * 12 + 10),
    Product(id: '2', name: 'Laras Toilet Roll', packsPerCarton: 6, lowStockThresholdCtn: 5, totalStockPacks: 2 * 6 + 4),
    Product(id: '3', name: 'Laras Napkin 18x20', packsPerCarton: 10, lowStockThresholdCtn: 5, totalStockPacks: 0),
  ];

  void _handleIncrement(Product p) {
    // TODO Fase 3: insert ke stock_transactions (product_id: p.id, change_qty: +1 atau +packsPerCarton)
  }

  void _handleDecrement(Product p) {
    // TODO Fase 3: insert ke stock_transactions (product_id: p.id, change_qty: -1 atau -packsPerCarton)
  }

  @override
  Widget build(BuildContext context) {
    final aman = _products.where((p) => p.status == StockStatus.aman).length;
    final tipis = _products.where((p) => p.status == StockStatus.tipis).length;
    final habis = _products.where((p) => p.status == StockStatus.habis).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'KartonKu',
              style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // TODO: belum ada fungsi — konfirmasi dulu ini search produk atau apa
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  StatCard(label: 'AMAN', value: aman, valueColor: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  StatCard(label: 'TIPIS', value: tipis, valueColor: AppColors.statusTipisText),
                  const SizedBox(width: 12),
                  StatCard(label: 'HABIS', value: habis, valueColor: AppColors.statusHabisText),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return ProductListItem(
                      product: p,
                      onIncrement: () => _handleIncrement(p),
                      onDecrement: () => _handleDecrement(p),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar & floatingActionButton DIHAPUS — sekarang dikelola MainShell
    );
  }
}