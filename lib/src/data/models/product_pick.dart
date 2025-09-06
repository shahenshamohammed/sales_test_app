class ProductPick {
  final String id;
  final String name;
  final double rate;
  final String? coverUrl;

  const ProductPick({
    required this.id,
    required this.name,
    required this.rate,
    this.coverUrl,
  });
}
