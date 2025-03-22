import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Time extends StatelessWidget {
  int index;
  Time({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Text(index.toString());
  }
}
