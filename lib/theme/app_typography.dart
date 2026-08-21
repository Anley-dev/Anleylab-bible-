import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  // Ensure "NotoSansEthiopic" is bundled in pubspec.yaml
  static const String fontFamily = 'NotoSansEthiopic';

  static TextStyle appTitle(BuildContext context, {bool isDark = false}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    height: 1.3,
  );

  static TextStyle sectionTitle(BuildContext context, {bool isDark = false}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    height: 1.3,
  );

  static TextStyle bookTitle(BuildContext context, {bool isDark = false}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    height: 1.4,
  );

  static TextStyle verseText(BuildContext context, {double fontSize = 17, bool isDark = false}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: FontWeight.normal,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    height: 1.65, // Crucial for Amharic script readability
  );

  static TextStyle verseNumber({bool isDark = false}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.liturgicalGold,
    height: 1.0,
  );

  static TextStyle secondaryText({bool isDark = false}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    height: 1.4,
  );

  static TextStyle buttonText({bool isDark = false}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.liturgicalBlue,
  );
}
