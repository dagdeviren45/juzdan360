import 'package:hive/hive.dart';

part 'portfolio_item.g.dart';

@HiveType(typeId: 0)
enum PortfolioCategory {
  @HiveField(0)
  gold,
  @HiveField(1)
  silver,
  @HiveField(2)
  crypto,
  @HiveField(3)
  forex,
  @HiveField(4)
  debt,
  @HiveField(5)
  cash
}

@HiveType(typeId: 1)
class PortfolioItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String symbol; // e.g., 'gram', 'BTC', 'USD'
  @HiveField(3)
  final double amount;
  @HiveField(4)
  final PortfolioCategory category;
  @HiveField(5)
  final String? note;
  @HiveField(6)
  final DateTime dateAdded;
  @HiveField(7)
  final bool isPhysical; // True if physical gold/cash

  PortfolioItem({
    required this.id,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.category,
    this.note,
    required this.dateAdded,
    this.isPhysical = true,
  });
}

class PriceData {
  final String name;
  final String symbol;
  final double buy;
  final double sell;
  final double change;

  PriceData({
    required this.name,
    required this.symbol,
    required this.buy,
    required this.sell,
    required this.change,
  });
}
