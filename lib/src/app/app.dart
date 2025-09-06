import 'package:flutter/material.dart';
import 'app.router.dart';



class SalesApp extends StatelessWidget {
  const SalesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sales Test App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      routerConfig: router,
    );
  }
}