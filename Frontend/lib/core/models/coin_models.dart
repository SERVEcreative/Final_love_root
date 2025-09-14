class CoinBalance {
  final int balance;
  final int totalEarned;
  final int totalSpent;
  final DateTime lastUpdated;

  CoinBalance({
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.lastUpdated,
  });

  factory CoinBalance.fromJson(Map<String, dynamic> json) {
    return CoinBalance(
      balance: json['balance'] ?? 0,
      totalEarned: json['totalEarned'] ?? 0,
      totalSpent: json['totalSpent'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class CoinPackage {
  final String id;
  final String name;
  final int coins;
  final double price;
  final String currency;
  final bool isPopular;
  final int? bonusCoins;

  CoinPackage({
    required this.id,
    required this.name,
    required this.coins,
    required this.price,
    required this.currency,
    required this.isPopular,
    this.bonusCoins,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      coins: json['coins'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      isPopular: json['isPopular'] ?? false,
      bonusCoins: json['bonusCoins'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coins': coins,
      'price': price,
      'currency': currency,
      'isPopular': isPopular,
      'bonusCoins': bonusCoins,
    };
  }
}

class CoinTransaction {
  final String id;
  final String type; // 'purchase', 'spend', 'earn', 'transfer'
  final int amount;
  final String description;
  final DateTime timestamp;
  final String? relatedUserId;

  CoinTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    this.relatedUserId,
  });

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: json['amount'] ?? 0,
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      relatedUserId: json['relatedUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'relatedUserId': relatedUserId,
    };
  }
}

class CoinPurchaseResponse {
  final bool success;
  final String message;
  final String? paymentUrl;
  final String? transactionId;

  CoinPurchaseResponse({
    required this.success,
    required this.message,
    this.paymentUrl,
    this.transactionId,
  });

  factory CoinPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return CoinPurchaseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      paymentUrl: json['paymentUrl'],
      transactionId: json['transactionId'],
    );
  }
}

class CoinEarnResponse {
  final bool success;
  final String message;
  final int earnedCoins;
  final int newBalance;

  CoinEarnResponse({
    required this.success,
    required this.message,
    required this.earnedCoins,
    required this.newBalance,
  });

  factory CoinEarnResponse.fromJson(Map<String, dynamic> json) {
    return CoinEarnResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      earnedCoins: json['earnedCoins'] ?? 0,
      newBalance: json['newBalance'] ?? 0,
    );
  }
}

class CoinTransferResponse {
  final bool success;
  final String message;
  final int transferredAmount;
  final int newBalance;
  final String recipientName;

  CoinTransferResponse({
    required this.success,
    required this.message,
    required this.transferredAmount,
    required this.newBalance,
    required this.recipientName,
  });

  factory CoinTransferResponse.fromJson(Map<String, dynamic> json) {
    return CoinTransferResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transferredAmount: json['transferredAmount'] ?? 0,
      newBalance: json['newBalance'] ?? 0,
      recipientName: json['recipientName'] ?? '',
    );
  }
}
