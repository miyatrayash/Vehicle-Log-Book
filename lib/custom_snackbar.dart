import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSnackBar(String content,BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1000),
        shape: const RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(20.0))),
        content: SizedBox(
            height: 20,
            width: MediaQuery.of(context).size.width- 20,
            child: Center(child: Text(content)))));
  }
}
