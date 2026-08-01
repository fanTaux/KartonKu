import 'package:flutter/material.dart';
import '../models/product.dart';
import '../../../shared/theme/app_colors.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ProductListItem({
    super.key,
    required this.product,
    required this.onIncrement,
    required this.onDecrement,
  });

  (Color, Color, String) _statusStyle() {
    switch (product.status) {
      case StockStatus.aman:
        return (AppColors.statusAmanBg, AppColors.statusAmanText, 'AMAN');
      case StockStatus.tipis:
        return (AppColors.statusTipisBg, AppColors.statusTipisText, 'MENIPIS');
      case StockStatus.habis:
        return (AppColors.statusHabisBg, AppColors.statusHabisText, 'HABIS');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = _statusStyle();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: product.imageUrl != null
                ? Image.network(
              product.imageUrl!,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            )
                : Container(
              width: 64,
              height: 64,
              color: AppColors.background,
              child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stock: ${product.cartons.toString().padLeft(2, '0')} Ctn / ${product.remainingPacks.toString().padLeft(2, '0')} Pk',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _RoundIconButton(icon: Icons.add, color: AppColors.primaryGreen, onTap: onIncrement),
              const SizedBox(height: 8),
              _RoundIconButton(icon: Icons.remove, color: Colors.grey.shade700, onTap: onDecrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}