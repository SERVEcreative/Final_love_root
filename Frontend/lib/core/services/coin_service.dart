import 'api_service.dart';
import '../models/coin_models.dart';

class CoinService {
  // API Endpoints
  static const String _balanceEndpoint = '/coins/balance';
  static const String _purchaseEndpoint = '/coins/purchase';
  static const String _historyEndpoint = '/coins/history';
  static const String _packagesEndpoint = '/coins/packages';
  static const String _earnCoinsEndpoint = '/coins/earn';
  static const String _transferEndpoint = '/coins/transfer';

  /// Get user's coin balance
  static Future<CoinBalance> getBalance() async {
    try {
      final response = await ApiService.get(_balanceEndpoint);
      return CoinBalance.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Purchase coins
  static Future<CoinPurchaseResponse> purchaseCoins(
    String packageId,
    String paymentMethod,
  ) async {
    try {
      final response = await ApiService.post(
        _purchaseEndpoint,
        body: {
          'packageId': packageId,
          'paymentMethod': paymentMethod,
        },
      );
      return CoinPurchaseResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get coin transaction history
  static Future<List<CoinTransaction>> getHistory({
    int page = 1,
    int limit = 20,
    String? type, // 'purchase', 'spend', 'earn', 'transfer'
  }) async {
    try {
      final response = await ApiService.get(
        _historyEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null) 'type': type,
        },
      );
      
      final List<dynamic> transactionsData = response['transactions'] ?? [];
      return transactionsData.map((tx) => CoinTransaction.fromJson(tx)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get available coin packages
  static Future<List<CoinPackage>> getPackages() async {
    try {
      final response = await ApiService.get(_packagesEndpoint);
      final List<dynamic> packagesData = response['packages'] ?? [];
      return packagesData.map((pkg) => CoinPackage.fromJson(pkg)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Earn coins through activities
  static Future<CoinEarnResponse> earnCoins(String activityType) async {
    try {
      final response = await ApiService.post(
        _earnCoinsEndpoint,
        body: {
          'activityType': activityType,
        },
      );
      return CoinEarnResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Transfer coins to another user
  static Future<CoinTransferResponse> transferCoins(
    String recipientId,
    int amount,
  ) async {
    try {
      final response = await ApiService.post(
        _transferEndpoint,
        body: {
          'recipientId': recipientId,
          'amount': amount,
        },
      );
      return CoinTransferResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
