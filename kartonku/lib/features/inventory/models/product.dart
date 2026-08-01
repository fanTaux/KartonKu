enum StockStatus { aman, tipis, habis }

class Product {
  final String id;
  final String name;
  final String? labelCode;
  final int packsPerCarton;
  final int lowStockThresholdCtn;
  final int totalStockPacks;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.labelCode,
    required this.packsPerCarton,
    required this.lowStockThresholdCtn,
    required this.totalStockPacks,
    this.imageUrl,
  });

  int get cartons => totalStockPacks ~/ packsPerCarton;
  int get remainingPacks => totalStockPacks % packsPerCarton;

  StockStatus get status {
    if (totalStockPacks <= 0) return StockStatus.habis;
    if (cartons < lowStockThresholdCtn) return StockStatus.tipis;
    return StockStatus.aman;
  }

  // Factory dari row product_stock view (dipakai nanti saat wiring data asli)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      labelCode: map['label_code'],
      packsPerCarton: map['packs_per_carton'],
      lowStockThresholdCtn: map['low_stock_threshold_ctn'],
      totalStockPacks: map['total_stock_packs'] ?? 0,
      imageUrl: map['image_url'],
    );
  }
}