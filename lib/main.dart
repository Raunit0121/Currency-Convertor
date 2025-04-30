import 'package:currency_converter/splashScreen.dart';
import 'package:flutter/material.dart';
import 'currency_converter.dart';


void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatefulWidget {
  @override
  State<CurrencyConverterApp> createState() => _CurrencyConverterAppState();
}

class _CurrencyConverterAppState extends State<CurrencyConverterApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: SplashScreen(
        isDark: isDark,
        toggleTheme: () => setState(() => isDark = !isDark),
      ),
    );
  }
}
