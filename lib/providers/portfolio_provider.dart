import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/portfolio_item.dart';
import '../services/api_service.dart';

class PortfolioProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, PriceData> _prices = {};
  List<PortfolioItem> _holdings = [];
  bool _isLoading = false;
  String? _error;
  DateTime _lastUpdate = DateTime.now();
  
  Map<String, PriceData> get prices => _prices;
  List<PortfolioItem> get holdings => _holdings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get lastUpdate => _lastUpdate;

  Box<PortfolioItem>? _box;
  bool _isPolling = false;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PortfolioCategoryAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PortfolioItemAdapter());
      
      _box = await Hive.openBox<PortfolioItem>('portfolio');
      _holdings = _box!.values.toList();
      
      await refreshPrices();
      _startPolling();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isPolling) return false;
      await refreshPrices();
      return true;
    });
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  Future<void> refreshPrices() async {
    try {
      _prices = await _apiService.fetchAllPrices();
      _lastUpdate = DateTime.now();
      _error = null;
    } catch (e) {
      _error = 'Fiyatlar güncellenemedi: $e';
    }
    notifyListeners();
  }

  double get totalGoldValue {
    return _holdings.where((h) => h.category == PortfolioCategory.gold).fold(0.0, (sum, item) {
      final price = _prices[item.symbol]?.sell ?? 0.0;
      return sum + (item.amount * price);
    });
  }

  double get totalCryptoValue {
    return _holdings.where((h) => h.category == PortfolioCategory.crypto).fold(0.0, (sum, item) {
      final price = _prices[item.symbol]?.sell ?? 0.0;
      return sum + (item.amount * price);
    });
  }

  double get totalForexValue {
    return _holdings.where((h) => h.category == PortfolioCategory.forex).fold(0.0, (sum, item) {
      final price = _prices[item.symbol]?.sell ?? 0.0;
      return sum + (item.amount * price);
    });
  }

  double get totalDebtValue {
    return _holdings.where((h) => h.category == PortfolioCategory.debt).fold(0.0, (sum, item) {
      return sum + item.amount;
    });
  }

  double get totalCashValue {
    return _holdings.where((h) => h.category == PortfolioCategory.cash).fold(0.0, (sum, item) {
      return sum + item.amount;
    });
  }

  double get netWorth => totalGoldValue + totalCryptoValue + totalForexValue + totalCashValue - totalDebtValue;

  Future<void> addItem(PortfolioItem item) async {
    await _box?.add(item);
    _holdings = _box!.values.toList();
    notifyListeners();
  }

  Future<void> deleteItem(PortfolioItem item) async {
    await item.delete();
    _holdings = _box!.values.toList();
    notifyListeners();
  }
}
