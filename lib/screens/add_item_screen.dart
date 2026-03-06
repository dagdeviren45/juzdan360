import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/portfolio_item.dart';
import '../providers/portfolio_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  PortfolioCategory _category = PortfolioCategory.gold;
  String? _selectedSymbol;

  @override
  void initState() {
    super.initState();
    _selectedSymbol = 'gram';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Yatırım Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              if (_category != PortfolioCategory.debt && _category != PortfolioCategory.cash) ...[
                _buildItemDropdown(provider),
                const SizedBox(height: 20),
              ],
              _buildTextField(
                controller: _amountController,
                label: _category == PortfolioCategory.debt ? 'Borç Miktarı (₺)' : (_category == PortfolioCategory.cash ? 'TL Tutarı (₺)' : 'Miktar (Adet/Gram)'),
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _noteController,
                label: 'Not (Opsiyonel)',
                icon: Icons.notes,
                isOptional: true,
              ),
              const SizedBox(height: 40),
              _buildSubmitButton(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<PortfolioCategory>(
      value: _category,
      decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
      items: const [
        DropdownMenuItem(value: PortfolioCategory.gold, child: Text('Altın')),
        DropdownMenuItem(value: PortfolioCategory.crypto, child: Text('KRİPTO')),
        DropdownMenuItem(value: PortfolioCategory.forex, child: Text('Döviz')),
        DropdownMenuItem(value: PortfolioCategory.cash, child: Text('Nakit / TL')),
        DropdownMenuItem(value: PortfolioCategory.debt, child: Text('Borçlarım')),
      ],
      onChanged: (val) {
        setState(() {
          _category = val!;
          if (_category == PortfolioCategory.gold) _selectedSymbol = 'gram';
          if (_category == PortfolioCategory.crypto) _selectedSymbol = 'BTC';
          if (_category == PortfolioCategory.forex) _selectedSymbol = 'usd';
          if (_category == PortfolioCategory.cash) _selectedSymbol = 'try';
          if (_category == PortfolioCategory.debt) _selectedSymbol = 'tr';
        });
      },
    );
  }

  Widget _buildItemDropdown(PortfolioProvider provider) {
    List<String> options = [];
    if (_category == PortfolioCategory.gold) options = ['gram', '22ayar', '14ayar', 'ceyrek', 'ceyrek_eski', 'yarim', 'tam', 'gram_has', 'ata', 'ata5', 'gremse', 'gumus', 'gumus_ons', 'altin_gumus', 'ons'];
    if (_category == PortfolioCategory.crypto) options = ['BTC', 'ETH', 'LTC', 'XRP', 'SOL', 'ADA', 'DOGE', 'BNB', 'AVAX'];
    if (_category == PortfolioCategory.forex) options = ['usd', 'eur', 'gbp', 'chf', 'sar', 'aud', 'cad', 'sek', 'dkk', 'nok', 'jpy'];

    return DropdownButtonFormField<String>(
      value: _selectedSymbol,
      decoration: const InputDecoration(labelText: 'Yatırım Türü', prefixIcon: Icon(Icons.list)),
      items: options.map((s) => DropdownMenuItem(value: s, child: Text(provider.prices[s]?.name ?? s))).toList(),
      onChanged: (val) => setState(() => _selectedSymbol = val),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      keyboardType: keyboardType,
      validator: (val) {
        if (isOptional) return null;
        if (val == null || val.trim().isEmpty) return 'Lütfen bir değer girin';
        return null;
      },
    );
  }


  Widget _buildSubmitButton(BuildContext context, PortfolioProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
              final parsedAmount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
              if (parsedAmount <= 0) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen geçerli bir miktar girin'), backgroundColor: Colors.red));
                 return;
              }
              final item = PortfolioItem(
                id: const Uuid().v4(),
                name: _category == PortfolioCategory.cash ? 'Nakit TL' : (provider.prices[_selectedSymbol]?.name ?? _selectedSymbol!),
                symbol: _category == PortfolioCategory.cash ? 'try' : _selectedSymbol!,
                amount: parsedAmount,
                category: _category,
                note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                dateAdded: DateTime.now(),
              );
            await provider.addItem(item);
            if (context.mounted) Navigator.pop(context);
          }
        },
        child: const Text('Portföye Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
