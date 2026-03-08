import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/portfolio_item.dart';

class ApiService {
  static const Map<String, String> headers = {
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
    'Referer': 'https://www.haremaltin.com/canli-piyasalar/',
    'Origin': 'https://www.haremaltin.com',
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
  };

  static final Map<String, PriceData> _cachedPrices = {};
  static DateTime _lastCryptoFetch = DateTime.fromMillisecondsSinceEpoch(0);

  Future<Map<String, PriceData>> fetchAllPrices({bool isSerbestPiyasa = false}) async {
    Map<String, PriceData> prices = {};
    try {
      if (isSerbestPiyasa) {
        prices = await fetchSerbestPiyasa();
        print('SerbestPiyasa success');
      } else {
        prices = await fetchAnlikAltin();
        print('AnlikAltin success');
      }
    } catch (e) {
      print('Primary source failed: $e');
      try {
        prices = await fetchHaremAltin();
      } catch (e2) {
        print('Haremaltin failed, using Truncgil: $e2');
        prices = await fetchTruncgil();
      }
    }

    _cachedPrices.addAll(prices);

    try {
      final now = DateTime.now();
      if (now.difference(_lastCryptoFetch).inSeconds > 30) {
        final crypto = await fetchCryptoPrices();
        _cachedPrices.addAll(crypto);
        _lastCryptoFetch = now;
      }
    } catch (e) {
      print('Crypto failed: $e');
    }

    // copy _cachedPrices to a new map so we don't pollute cache with derived calculations
    Map<String, PriceData> combined = Map.from(_cachedPrices);
    _applyCrossCalculations(combined);
    return combined;
  }

  Future<Map<String, PriceData>> fetchSerbestPiyasa() async {
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final String url = 'https://anlikaltinfiyatlari.com/socket/total.php?_=$cacheBuster';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('SerbestPiyasa Error: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final Map<String, PriceData> prices = {};

    final usd = double.tryParse(data['USDTRY']?.toString() ?? '0') ?? 0.0;
    final eur = double.tryParse(data['EURTRY']?.toString() ?? '0') ?? 0.0;
    final gbp = double.tryParse(data['GBPTRY']?.toString() ?? '0') ?? 0.0;
    final ons = double.tryParse(data['XAUUSD']?.toString() ?? '0') ?? 0.0;
    final gumusOns = double.tryParse(data['XAGUSD']?.toString() ?? '0') ?? 0.0;

    // Calculation: (ONS * USDTRY) / 31.1
    final gramHas = (ons * usd) / 31.1;

    prices['usd'] = PriceData(name: 'DOLAR', symbol: 'usd', buy: usd, sell: usd, change: 0);
    prices['eur'] = PriceData(name: 'EURO', symbol: 'eur', buy: eur, sell: eur, change: 0);
    prices['gbp'] = PriceData(name: 'POUND', symbol: 'gbp', buy: gbp, sell: gbp, change: 0);
    prices['ons'] = PriceData(name: 'ALTIN ONS \$', symbol: 'ons', buy: ons, sell: ons, change: 0);
    prices['gram_has'] = PriceData(name: 'HAS ALTIN', symbol: 'gram_has', buy: gramHas, sell: gramHas, change: 0);
    prices['gram'] = PriceData(name: 'GRAM ALTIN', symbol: 'gram', buy: gramHas, sell: gramHas, change: 0);
    prices['gumus'] = PriceData(name: 'GÜMÜŞ GRAM', symbol: 'gumus', buy: (gumusOns * usd) / 31.1, sell: (gumusOns * usd) / 31.1, change: 0);

    return prices;
  }

  Future<Map<String, PriceData>> fetchAnlikAltin() async {
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final String url = 'https://anlikaltinfiyatlari.com/js/fetch/kapalicarsi.php?_=$cacheBuster';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('AnlikAltin Error: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final Map<String, PriceData> prices = {};

    final mapping = {
      'HAS': 'gram_has', // HAS ALTIN
      'GRAM': 'gram', // GRAM ALTIN
      'ONS': 'ons', // ALTIN ONS $
      'USDTRY': 'usd', // DOLAR
      'EURTRY': 'eur', // EURO
      'GBPTRY': 'gbp', // POUND
      'CHFTRY': 'chf', // FRANK
      'SARTRY': 'sar', // RIYAL
      'AUDTRY': 'aud', // AVUSTRALYA DOLARI
      'CADTRY': 'cad', // KANADA DOLARI
      'SEKTRY': 'sek', // İSVEÇ KRONU
      'DKKTRY': 'dkk', // DANİMARKA KRONU
      'NOKTRY': 'nok', // NORVEÇ KRONU
      'JPYTRY': 'jpy', // JAPON YENİ
      'GUMUSTRY': 'gumus', // GÜMÜŞ GRAM
      'XAGUSD': 'gumus_ons', // GÜMÜŞ ONS
      'XAUXAG': 'altin_gumus', // ALTIN/GÜMÜŞ
      'CEYREK': 'ceyrek', // ÇEYREK ALTIN
      'CEYREK_ESKI': 'ceyrek_eski', // ÇEYREK ESKİ
      'YARIM': 'yarim', // YARIM ALTIN
      'TEK': 'tam', // TAM ALTIN
      'ATA': 'ata', // ATA ALTIN
      'ATA5': 'ata5', // ATA 5'Lİ
      'GREMSE': 'gremse', // GREMSE (2.5)
      'AYAR22': '22ayar', // 22 AYAR ALTIN
      'AYAR14': '14ayar', // 14 AYAR ALTIN
    };

    final Map<String, String> names = {
      'gram_has': 'HAS ALTIN',
      'gram': 'GRAM ALTIN',
      'ons': 'ALTIN ONS \$',
      'usd': 'DOLAR',
      'eur': 'EURO',
      'gbp': 'POUND',
      'chf': 'FRANK',
      'sar': 'RİYAL',
      'aud': 'AVUSTRALYA DOLARI',
      'cad': 'KANADA DOLARI',
      'sek': 'İSVEÇ KRONU',
      'dkk': 'DANİMARKA KRONU',
      'nok': 'NORVEÇ KRONU',
      'jpy': 'JAPON YENİ',
      'gumus': 'GÜMÜŞ GRAM',
      'gumus_ons': 'GÜMÜŞ ONS',
      'altin_gumus': 'ALTIN/GÜMÜŞ',
      'ceyrek': 'ÇEYREK ALTIN',
      'ceyrek_eski': 'ÇEYREK ESKİ',
      'yarim': 'YARIM ALTIN',
      'tam': 'TAM ALTIN',
      'ata': 'ATA ALTIN',
      'ata5': 'ATA 5\'Lİ',
      'gremse': 'GREMSE (2.5)',
      '22ayar': '22 AYAR ALTIN',
      '14ayar': '14 AYAR ALTIN',
    };

    mapping.forEach((key, symbol) {
      if (data.containsKey(key)) {
        final item = data[key];
        try {
          prices[symbol] = PriceData(
            name: names[symbol] ?? symbol.toUpperCase(),
            symbol: symbol,
            buy: double.parse(item['alis'].toString().replaceAll(',', '')),
            sell: double.parse(item['satis'].toString().replaceAll(',', '')),
            change: double.parse(item['percent']?.toString().replaceAll('%', '') ?? '0'),
          );
        } catch (e) {
          print('Error parsing $key: $e');
        }
      }
    });

    if (prices.isEmpty) {
      throw Exception('AnlikAltin returned no valid prices');
    }
    return prices;
  }

  void _applyCrossCalculations(Map<String, PriceData> prices) {
    if (!prices.containsKey('gram_has')) return;

    final hasAlis = prices['gram_has']!.buy;
    final hasSatis = prices['gram_has']!.sell;
    final change = prices['gram_has']!.change;

    // Helper to add derived prices
    void addDerived(String symbol, String name, double buyFactor, double sellFactor) {
      if (prices.containsKey(symbol)) return;
      prices[symbol] = PriceData(
        name: name,
        symbol: symbol,
        buy: hasAlis * buyFactor,
        sell: hasSatis * sellFactor,
        change: change,
      );
    }

    // Derived types from HAS ALTIN
    addDerived('ceyrek', 'ÇEYREK ALTIN', 1.63, 1.67);
    addDerived('ceyrek_eski', 'ESKİ ÇEYREK', 1.63, 1.65);
    addDerived('yarim', 'YARIM ALTIN', 3.26, 3.34);
    addDerived('tam', 'TAM ALTIN', 6.52, 6.68);
    addDerived('ata', 'ATA ALTIN', 6.72, 7.00);
    addDerived('resat', 'REŞAT ALTIN', 6.62, 6.75);
    addDerived('hamit', 'HAMİT ALTIN', 6.62, 6.75);
    addDerived('22ayar', '22 AYAR ALTIN', 0.912, 0.960);
    addDerived('14ayar', '14 AYAR ALTIN', 0.58, 0.82);
    addDerived('gram_has', 'HAS ALTIN', 1.0, 1.0);
  }

  Future<Map<String, PriceData>> fetchHaremAltin() async {
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final response = await http.post(
      Uri.parse('https://www.haremaltin.com/dashboard/ajax/doviz?_=$cacheBuster'),
      headers: {...headers, 'Cache-Control': 'no-cache'},
      body: 'dil_kodu=tr',
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) throw Exception('Status ${response.statusCode}');

    final data = json.decode(response.body);
    final items = data['data'];
    if (items == null) throw Exception('No data key');

    final Map<String, PriceData> prices = {};
    final mapping = {
      'ALTIN': 'gram',
      'ONS': 'ons',
      'USDTRY': 'usd',
      'EURTRY': 'eur',
      'GBPTRY': 'gbp',
      'GUMUSTRY': 'gumus',
    };

    mapping.forEach((key, symbol) {
      if (items.containsKey(key)) {
        final item = items[key];
        prices[symbol] = PriceData(
          name: item['name'] ?? symbol.toUpperCase(),
          symbol: symbol,
          buy: double.parse(item['alis'].toString()),
          sell: double.parse(item['satis'].toString()),
          change: double.parse(item['degisim'].toString().replaceAll('%', '')),
        );
      }
    });

    return prices;
  }

  Future<Map<String, PriceData>> fetchTruncgil() async {
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('https://finans.truncgil.com/today.json?_=$cacheBuster'),
      headers: {'Cache-Control': 'no-cache'},
    ).timeout(const Duration(seconds: 10));
    final data = json.decode(response.body);
    
    final Map<String, PriceData> prices = {};
    double parseTR(dynamic val) {
      if (val == null) return 0.0;
      final str = val.toString().replaceAll('.', '').replaceAll(',', '.').replaceAll('\$', '');
      return double.tryParse(str) ?? 0.0;
    }

    final mapping = {'gram-altin': 'gram', 'ons': 'ons', 'USD': 'usd', 'EUR': 'eur', 'gumus': 'gumus'};
    mapping.forEach((key, symbol) {
      if (data.containsKey(key)) {
        final item = data[key];
        prices[symbol] = PriceData(
          name: symbol.toUpperCase(),
          symbol: symbol,
          buy: parseTR(item['Alış']),
          sell: parseTR(item['Satış']),
          change: double.tryParse(item['Değişim']?.toString().replaceAll('%', '').replaceAll(',', '.') ?? '0') ?? 0.0,
        );
      }
    });
    return prices;
  }

  Future<Map<String, PriceData>> fetchCryptoPrices() async {
    const ids = 'bitcoin,ethereum,litecoin,ripple,solana';
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('https://api.coingecko.com/api/v3/coins/markets?vs_currency=try&ids=$ids&order=market_cap_desc&sparkline=false&price_change_percentage=24h&_=$cacheBuster'),
      headers: {'Cache-Control': 'no-cache'},
    );
    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Crypto API returned unexpected format: $decoded');
    }
    
    final List data = decoded;
    final Map<String, PriceData> prices = {};

    for (var item in data) {
      final symbol = item['symbol'].toUpperCase();
      prices[symbol] = PriceData(
        name: item['name'],
        symbol: symbol,
        buy: double.parse(item['current_price'].toString()),
        sell: double.parse(item['current_price'].toString()),
        change: double.parse(item['price_change_percentage_24h']?.toString() ?? '0'),
      );
    }
    return prices;
  }
}
