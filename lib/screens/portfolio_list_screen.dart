import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/portfolio_item.dart';
import '../providers/portfolio_provider.dart';
import 'add_item_screen.dart';

class PortfolioListScreen extends StatelessWidget {
  const PortfolioListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Scaffold(
      body: provider.holdings.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (provider.holdings.any((h) => h.category != PortfolioCategory.debt)) ...[
                  Text('Varlıklarım', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...provider.holdings
                      .where((h) => h.category != PortfolioCategory.debt)
                      .map((item) => _buildPortfolioCard(context, item, provider, currencyFormat)),
                  const SizedBox(height: 24),
                ],
                if (provider.holdings.any((h) => h.category == PortfolioCategory.debt)) ...[
                  Text('Borçlarım / Alacaklarım', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...provider.holdings
                      .where((h) => h.category == PortfolioCategory.debt)
                      .map((item) => _buildPortfolioCard(context, item, provider, currencyFormat)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConstants.primaryGold,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen())),
        label: const Text('Yeni Ekle', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wallet_outlined, size: 60, color: AppConstants.textGrey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Henüz bir yatırım eklemediniz.', style: TextStyle(color: AppConstants.textGrey)),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(BuildContext context, PortfolioItem item, PortfolioProvider provider, NumberFormat format) {
    final price = provider.prices[item.symbol]?.sell ?? 0.0;
    final value = (item.category == PortfolioCategory.debt || item.category == PortfolioCategory.cash) ? item.amount : (item.amount * price);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteItem(item),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${item.amount.toStringAsFixed(2)} ${item.symbol.toUpperCase()} ${item.note != null ? "• ${item.note}" : ""}'),
          trailing: Text(format.format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.textLight)),
        ),
      ),
    );
  }
}
