import 'package:flutter/material.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Widget tile(String title, String path) => Card(
      child: ListTile(title: Text(title), trailing: const Icon(Icons.arrow_forward_ios), onTap: (){

        Navigator.of(context).pushNamed(path);
// TODO: use RouterDelegate to go(path)
      }),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          tile('Customers', '/customer_list'),
          tile('Products', '/product_add'),
          tile('Sales Invoice', '/invoice_create'),
          tile('Sales Report', '/sales_report'),
        ],
      ),
    );
  }
}