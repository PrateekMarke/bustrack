import 'package:flutter/material.dart';

class Time extends StatelessWidget {
  int index;
  Time({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Text(index.toString());
  }
}
