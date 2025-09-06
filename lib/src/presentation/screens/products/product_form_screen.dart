import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_test_app/src/presentation/screens/products/widgets/product_add.dart';


import '../../../data/models/product_input.dart';
import '../../../data/repositories/product_input_repository.dart';
import '../../blocs/product_form/product_form_bloc.dart';
import '../../blocs/product_form/product_form_event.dart';
import '../../blocs/product_form/product_form_state.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});
  @override
  State<ProductAddPage> createState() => ProductAddPageState();
}












