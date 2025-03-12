import 'package:flutter/material.dart';

class Myhome extends StatelessWidget {
  const Myhome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text('Welcome'),centerTitle: true,
      backgroundColor: Colors.yellow,),
    );
  }
}