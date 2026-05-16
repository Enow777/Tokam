import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _style(String family, double size, Color color) =>
      TextStyle(fontFamily: family, fontSize: size, color: color);

  // Bold
  static TextStyle bold(double size, {Color color = Colors.black}) =>
      _style('PoppinsBold', size, color);

  // Medium
  static TextStyle medium(double size, {Color color = Colors.black}) =>
      _style('PoppinsMedium', size, color);

  // Regular
  static TextStyle regular(double size, {Color color = Colors.black}) =>
      _style('PoppinsRegular', size, color);
}