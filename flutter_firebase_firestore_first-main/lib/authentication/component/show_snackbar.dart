import 'package:flutter/material.dart';

showSnackBar({
  required BuildContext context,
  required String text,
  bool isErro = false,
}) {
  SnackBar snackBar = SnackBar(
    content: Text(text),
    backgroundColor: isErro ? Colors.green : Colors.red,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
