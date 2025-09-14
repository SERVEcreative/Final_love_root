class CoinPackage {
  final String name;
  final int coins;
  final double price;
  final String currency;

  CoinPackage({
    required this.name,
    required this.coins,
    required this.price,
    this.currency = '\$',
  });

  String get formattedPrice => '$currency${price.toStringAsFixed(2)}';
  String get formattedName => '$coins Coins';
}
