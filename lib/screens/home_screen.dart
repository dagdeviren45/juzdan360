import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/portfolio_provider.dart';
import 'rates_screen.dart';
import 'portfolio_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isBalanceVisible = false;
  final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();

    final List<Widget> screens = [
      _buildDashboard(provider),
      const RatesScreen(),
      const PortfolioListScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset('assets/icon.png', width: 32, height: 32, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('JUZDAN360', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('LIVE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                Text(
                  'Son Güncelleme: ${DateFormat('HH:mm:ss').format(provider.lastUpdate)}',
                  style: const TextStyle(fontSize: 10, color: AppConstants.textGrey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: provider.isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.primaryGold))
                : const Icon(Icons.refresh),
            onPressed: provider.refreshPrices,
          ),
        ],
      ),
      body: (provider.isLoading && provider.prices.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Panel'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Piyasalar'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), label: 'Portföyüm'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
        selectedItemColor: AppConstants.primaryGold,
        unselectedItemColor: AppConstants.textGrey,
        backgroundColor: AppConstants.cardDark,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildDashboard(PortfolioProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalBalanceCard(provider),
          const SizedBox(height: 24),
          Text('Varlıklarım', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildCategoryTile('Altın', provider.totalGoldValue, Icons.view_agenda_rounded, AppConstants.primaryGold),
              _buildCategoryTile('Kripto', provider.totalCryptoValue, Icons.currency_bitcoin, Colors.orange),
              _buildCategoryTile('Döviz', provider.totalForexValue, Icons.euro, Colors.blue),
              _buildCategoryTile('Nakit / TL', provider.totalCashValue, Icons.account_balance_wallet_outlined, Colors.green),
              _buildCategoryTile('Borçlar', provider.totalDebtValue, Icons.money_off, Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          _buildMarketTicker(provider),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard(PortfolioProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.cardDark, Color(0xFF222222)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primaryGold.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppConstants.primaryGold.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Text('NET PORTFÖY DEĞERİ', style: TextStyle(color: AppConstants.textLight.withOpacity(0.8), letterSpacing: 1.5, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _isBalanceVisible ? 0 : 8,
                    sigmaY: _isBalanceVisible ? 0 : 8,
                  ),
                  child: Text(
                    currencyFormat.format(provider.netWorth),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppConstants.primaryGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -10,
            bottom: -5,
            child: IconButton(
              icon: Icon(
                _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                color: AppConstants.textGrey,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isBalanceVisible = !_isBalanceVisible;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String title, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Text(currencyFormat.format(value), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMarketTicker(PortfolioProvider provider) {
    final tickerPrices = ['gram', 'ons', 'usd', 'eur', 'BTC'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Piyasa Özeti', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tickerPrices.length,
            itemBuilder: (context, index) {
              final symbol = tickerPrices[index];
              final data = provider.prices[symbol];
              if (data == null) return const SizedBox();
              
              final isPositive = data.change >= 0;

              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppConstants.cardDark, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: const TextStyle(fontSize: 12, color: AppConstants.textGrey)),
                    const Spacer(),
                    Text(
                      symbol == 'ons' ? '\$${data.sell.toStringAsFixed(0)}' : currencyFormat.format(data.sell), 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${data.change.toStringAsFixed(2)}%',
                      style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
