class StockTransaction {
  final String id;
  final String productName;
  final String? productImageUrl;
  final int changeQtyPacks; // disimpan dalam pack, dikonversi saat ditampilkan
  final int packsPerCarton;
  final String? reason;
  final DateTime createdAt;
  final String? createdByEmail;

  StockTransaction({
    required this.id,
    required this.productName,
    this.productImageUrl,
    required this.changeQtyPacks,
    required this.packsPerCarton,
    this.reason,
    required this.createdAt,
    this.createdByEmail,
  });

  bool get isIncoming => changeQtyPacks > 0;

  int get changeQtyCartons => (changeQtyPacks.abs()) ~/ packsPerCarton;

  factory StockTransaction.fromMap(Map<String, dynamic> map) {
    final product = map['products'] as Map<String, dynamic>?;
    return StockTransaction(
      id: map['id'],
      productName: product?['name'] ?? 'Produk tidak ditemukan',
      productImageUrl: product?['image_url'],
      changeQtyPacks: map['change_qty'],
      packsPerCarton: product?['packs_per_carton'] ?? 1,
      reason: map['reason'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      createdByEmail: map['created_by_email'], // lihat catatan di bawah soal ini
    );
  }
}