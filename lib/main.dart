import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_test_app/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:sales_test_app/src/data/repositories/auth_firebase_repository.dart';
import 'package:sales_test_app/src/presentation/screens/auth_gate.dart';
import 'package:sales_test_app/src/presentation/screens/customers/customer_add_screen.dart';
import 'package:sales_test_app/src/presentation/screens/customers/customer_list_screen.dart';
import 'package:sales_test_app/src/presentation/screens/dashboard_screen.dart';
import 'package:sales_test_app/src/presentation/screens/Invoice/invoice_form_screen.dart';
import 'package:sales_test_app/src/presentation/screens/login_screen.dart';
import 'package:sales_test_app/src/presentation/screens/products/product_form_screen.dart';
import 'package:sales_test_app/src/presentation/screens/products/product_list_screen.dart';
import 'package:sales_test_app/src/presentation/screens/salesreport/sales_report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    RepositoryProvider(
      create: (_) => FirebaseAuthRepository(),
      child: BlocProvider(
        create: (ctx) => AuthBloc(ctx.read<FirebaseAuthRepository>()),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sales Test App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const AuthGate(),                 // ← start here
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/customers': (_) => const CustomerAddPage(),
        '/customer_list': (_) => const CustomerListPage(),
        '/product_add': (_) => const ProductAddPage(),
        '/sales_report': (_) => const SalesReportGroupedPage(),
        '/invoice_create': (_) => const InvoiceCreatePage(),
      },
      onGenerateRoute: (settings) {
        // handle dynamic paths if you add later, otherwise return null
        return null;
      },
    );
  }
}