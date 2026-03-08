import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/portfolio_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _currentPin;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _currentPin = box.get('app_pin') as String?;
    });
  }

  void _showPinDialog(BuildContext context, {bool isRemove = false}) {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardDark,
        title: Text(isRemove ? 'PIN\'i Kaldır' : 'Yeni PIN Belirle', style: const TextStyle(color: AppConstants.textLight)),
        content: TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          style: const TextStyle(color: AppConstants.textLight, fontSize: 24, letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: '****',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: AppConstants.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              final val = _pinController.text;
              if (val.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN 4 haneli olmalıdır.'), backgroundColor: Colors.red));
                return;
              }
              final box = await Hive.openBox('settings');
              if (isRemove) {
                if (val == _currentPin) {
                  await box.delete('app_pin');
                  if (context.mounted) Navigator.pop(context);
                  _loadSettings();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN kaldırıldı.'), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mevcut PIN hatalı.'), backgroundColor: Colors.red));
                }
              } else {
                await box.put('app_pin', val);
                if (context.mounted) Navigator.pop(context);
                _loadSettings();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN güncellendi.'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Kaydet', style: TextStyle(color: AppConstants.primaryGold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('GÜVENLİK', style: TextStyle(color: AppConstants.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: AppConstants.primaryGold),
            title: const Text('Uygulama Şifresi (PIN)'),
            subtitle: Text(_currentPin == null ? 'Şu an şifre kapalı' : '4 Haneli Şifre Aktif'),
            onTap: () => _showPinDialog(context),
            trailing: _currentPin != null
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showPinDialog(context, isRemove: true),
                  )
                : null,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('VERİ KAYNAĞI', style: TextStyle(color: AppConstants.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Consumer<PortfolioProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  RadioListTile<bool>(
                    value: false,
                    groupValue: provider.isSerbestPiyasa,
                    onChanged: (val) => provider.setDataSource(val!),
                    title: const Text('Kapalı Çarşı'),
                    subtitle: const Text('Daha yüksek makas aralığı (Haftasonu Kapalı)', style: TextStyle(fontSize: 12)),
                    activeColor: AppConstants.primaryGold,
                  ),
                  RadioListTile<bool>(
                    value: true,
                    groupValue: provider.isSerbestPiyasa,
                    onChanged: (val) => provider.setDataSource(val!),
                    title: const Text('Serbest Piyasa'),
                    subtitle: const Text('Anlık küresel veriler (7/24 Canlı)', style: TextStyle(fontSize: 12)),
                    activeColor: AppConstants.primaryGold,
                  ),
                  if (!provider.isSerbestPiyasa && (DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday))
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Dikkat: Kapalı Çarşı haftasonu kapalıdır. Canlı fiyatlar için Serbest Piyasa\'yı seçebilirsiniz.',
                              style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
