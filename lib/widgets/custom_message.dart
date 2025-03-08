import 'package:flutter/material.dart';
import 'package:tracker_v2/constants/app_colors.dart';

class CustomMessage {
  static void show(BuildContext context, String message,
      {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor ?? AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
