
import 'package:bustrack/const/color_pallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  TextInputType textInputType;
  bool isPass = true;
  CustomTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.textInputType,
      required this.isPass});

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return TextFormField(
        controller: controller,
        keyboardType: textInputType,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.secondaryColor),
          border: inputBorder,
          filled: true,
          fillColor: AppColors.mobileSearchColor,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
        ));
  }
}
