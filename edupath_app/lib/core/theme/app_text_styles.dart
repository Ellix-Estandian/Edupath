import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const heading1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static const caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.35,
  );
}
