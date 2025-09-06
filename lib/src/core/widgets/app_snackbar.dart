import 'package:flutter/material.dart';


void showAppSnack(BuildContext ctx, String msg) =>
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));