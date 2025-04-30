import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

class CurrencyConverterPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  CurrencyConverterPage({required this.isDark, required this.toggleTheme});

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  String fromCurrency = 'USD';
  String toCurrency = 'INR';
  double amount = 1.0;
  String result = '';
  bool isLoading = false;
  bool showResult = false;

  List<String> currencies = ['USD', 'INR', 'EUR', 'GBP', 'JPY', 'AUD'];

  String getFlag(String code) {
    String country = code.substring(0, 2);
    return String.fromCharCodes(country.codeUnits.map((c) => 0x1F1E6 + c - 65));
  }

  Future<void> convertCurrency() async {
    setState(() {
      isLoading = true;
      showResult = false;
    });

    final url = Uri.parse(
        'https://v6.exchangerate-api.com/v6/2be3fe8befb816a76143d578/latest/USD');

    final response = await http.get(url);

    await Future.delayed(Duration(milliseconds: 500));

    if (response.statusCode == 200) {
      final rates = json.decode(response.body)['conversion_rates'];
      double rate = rates[toCurrency];
      double converted = rate * amount;

      setState(() {
        result =
        '$amount $fromCurrency = ${converted.toStringAsFixed(2)} $toCurrency';
        isLoading = false;
        showResult = true;
      });
    } else {
      setState(() {
        result = 'Failed to fetch exchange rate.';
        isLoading = false;
        showResult = true;
      });
    }
  }

  Widget currencySelector(String label, String selected, ValueChanged<String?> onChanged) {
    return DropdownSearch<String>(
      items: currencies,
      selectedItem: selected,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isSelected) {
          return ListTile(
            leading: Text(getFlag(item)),
            title: Text(item),
          );
        },
      ),
      onChanged: onChanged,
      dropdownBuilder: (context, selectedItem) {
        return Row(
          children: [
            Text(getFlag(selectedItem ?? '')),
            SizedBox(width: 8),
            Text(selectedItem ?? ''),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = double.tryParse(value) ?? 0.0,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: currencySelector("From", fromCurrency,
                          (val) => setState(() => fromCurrency = val!)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: currencySelector("To", toCurrency,
                          (val) => setState(() => toCurrency = val!)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: convertCurrency,
              child: AnimatedScale(
                scale: isLoading ? 0.9 : 1.0,
                duration: Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.blueAccent.withOpacity(0.4),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    isLoading ? 'Converting...' : 'Convert',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (isLoading) CircularProgressIndicator(),
            AnimatedOpacity(
              opacity: showResult ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Text(
                result,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}