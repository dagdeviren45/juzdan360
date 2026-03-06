import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/portfolio_provider.dart';

class RatesScreen extends StatelessWidget {
  const RatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppConstants.primaryGold,
            labelColor: AppConstants.primaryGold,
            unselectedLabelColor: AppConstants.textGrey,
            tabs: const [
              Tab(text: 'ALTIN'),
              Tab(text: 'DÖVİZ'),
              Tab(text: 'KRİPTO'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPriceList(context, ['gram', '22ayar', '14ayar', 'ceyrek', 'ceyrek_eski', 'yarim', 'tam', 'gram_has', 'ata', 'ata5', 'gremse', 'gumus', 'gumus_ons', 'altin_gumus', 'ons']),
                _buildPriceList(context, ['usd', 'eur', 'gbp', 'chf', 'sar', 'aud', 'cad', 'sek', 'dkk', 'nok', 'jpy']),
                _buildPriceList(context, ['BTC', 'ETH', 'LTC', 'XRP', 'SOL', 'ADA', 'DOGE', 'BNB', 'AVAX']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceList(BuildContext context, List<String> symbols) {
    final provider = context.watch<PortfolioProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemCount: symbols.length + 1,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }

        final symbol = symbols[index - 1];
        final data = provider.prices[symbol];
        if (data == null) return const SizedBox();

        final isUp = data.change >= 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(data.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: isUp ? AppConstants.priceUp : AppConstants.priceDown, size: 20),
                        Text(
                          symbol == 'ons' || symbol.toUpperCase() == symbol ? data.buy.toStringAsFixed(2) : currencyFormat.format(data.buy).replaceAll('₺', '').trim(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppConstants.textLight.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  symbol == 'ons' || symbol.toUpperCase() == symbol ? data.sell.toStringAsFixed(2) : currencyFormat.format(data.sell).replaceAll('₺', '').trim(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppConstants.textLight.withOpacity(0.9)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${isUp ? '+' : ''}${data.change.toStringAsFixed(2)}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: isUp ? AppConstants.priceUp : AppConstants.priceDown, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppConstants.cardDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Emtiya', style: TextStyle(color: AppConstants.textGrey, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Alış', textAlign: TextAlign.center, style: TextStyle(color: AppConstants.textGrey, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Satış', textAlign: TextAlign.center, style: TextStyle(color: AppConstants.textGrey, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Değişim', textAlign: TextAlign.end, style: TextStyle(color: AppConstants.textGrey, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
