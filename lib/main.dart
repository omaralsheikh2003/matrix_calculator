import 'package:flutter/material.dart';
import 'home.dart';

void main() => runApp(MatrixApp());

class MatrixApp extends StatelessWidget {
  const MatrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Matrix Calculator",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: Home(),
    );
  }
}