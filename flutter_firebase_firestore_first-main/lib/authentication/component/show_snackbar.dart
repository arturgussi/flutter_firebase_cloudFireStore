import 'package:flutter/material.dart';

showSnackBar({
  required BuildContext context,
  required String text,
  required bool isErro,
}) {
  SnackBar snackBar = SnackBar(
    content: Text(text),
    backgroundColor: isErro ? Colors.green : Colors.red,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
