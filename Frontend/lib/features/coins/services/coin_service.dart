import '../../../shared/models/coin_package.dart';

class CoinService {
  static const int _callCost = 10;
  static const int _chatCost = 5;
  static const int _adReward = 5;
  static const int initialCoins = 50000; // Added initial coins

  static int get callCost => _callCost;
  static int get chatCost => _chatCost;
  static int get adReward => _adReward;

  static List<CoinPackage> get coinPackages => [
    CoinPackage(name: '50 Coins', coins: 50, price: 4.99),
    CoinPackage(name: '100 Coins', coins: 100, price: 8.99),
    CoinPackage(name: '200 Coins', coins: 200, price: 15.99),
  ];

  static bool hasEnoughCoins(int availableCoins, String action) {
    switch (action.toLowerCase()) {
      case 'call':
        return availableCoins >= _callCost;
      case 'chat':
        return availableCoins >= _chatCost;
      default:
        return false;
    }
  }

  static int getCostForAction(String action) {
    switch (action.toLowerCase()) {
      case 'call':
        return _callCost;
      case 'chat':
        return _chatCost;
      default:
        return 0;
    }
  }
}
