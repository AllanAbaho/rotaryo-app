import 'package:flutter/material.dart';
import 'package:tumiapesa/theme.dart';
import 'package:tumiapesa/views/splash/splash.dart';

import 'views/transactions/transaction_success.dart';
 
void main() {
  runApp(TumiaPesa());
}

class TumiaPesa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tumia Pesa',
      theme: AppTheme.defaultTheme,
      home: SplashPage(),
      routes: {
        'TransactionSuccessPage' : (context)=> TransactionSuccessPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
