import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

export '../constants/app_colors.dart';

/// Design tokens extracted from Figma design & Bagisto BEENZO storefront theme

class AppTextStyles {
  /// Text-2: Roboto 500, 20px (auth heading)
  static TextStyle text2(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
      fontSize: 20,
      height: 1.17,
      color: isDark ? AppColors.neutral200 : AppColors.neutral800,
    );
  }

  /// Text-3: Roboto 600, 18px (section headers)
  static TextStyle text3(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.17,
      color: isDark ? AppColors.neutral200 : AppColors.neutral900,
    );
  }

  /// Text-5: Roboto 400, 14px (body text)
  static TextStyle text5(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.17,
      color: isDark ? AppColors.neutral200 : AppColors.neutral800,
    );
  }

  /// Text-5 for dark mode category labels (semibold in dark)
  static TextStyle text5Category(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: isDark ? FontWeight.w600 : FontWeight.w400,
      fontSize: 14,
      height: 1.17,
      color: isDark ? AppColors.neutral200 : AppColors.neutral800,
    );
  }

  /// Text-6: Roboto 400, 12px (small text)
  static TextStyle text6(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 1.17,
      color: isDark ? AppColors.neutral300 : AppColors.neutral800,
    );
  }

  /// Price text: bold 18px
  static TextStyle priceText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.17,
      color: isDark ? AppColors.white : AppColors.neutral900,
    );
  }

  /// Strikethrough price
  static TextStyle originalPriceText(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.17,
      color: AppColors.neutral500,
      decoration: TextDecoration.lineThrough,
    );
  }

  /// Discount text
  static TextStyle discountText(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.17,
      color: AppColors.primary500,
    );
  }

  /// Text-1: Roboto 600, 24px (large price)
  static TextStyle text1(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: 24,
      height: 1.17,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  /// Text-4: Roboto 600, 16px (section headers in product detail)
  static TextStyle text4(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.17,
      color: isDark ? AppColors.neutral100 : AppColors.black,
    );
  }

  /// Body text with 1.5x line height for descriptions
  static TextStyle bodyText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.5,
      color: isDark ? AppColors.neutral300 : AppColors.neutral800,
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.primary600,
        surface: AppColors.white,
        onSurface: AppColors.neutral900,
        outline: AppColors.neutral200,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary500,
        selectionColor: AppColors.textSelection,
        selectionHandleColor: AppColors.primary500,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.neutral50,
        selectedItemColor: AppColors.primary500,
        unselectedItemColor: AppColors.neutral800,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: AppColors.neutral100,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.neutral900,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary500,
        secondary: AppColors.primary600,
        surface: AppColors.neutral900,
        onSurface: AppColors.neutral200,
        outline: AppColors.neutral800,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary500,
        selectionColor: AppColors.textSelection,
        selectionHandleColor: AppColors.primary500,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral900,
        foregroundColor: AppColors.neutral200,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.neutral800,
        selectedItemColor: AppColors.primary500,
        unselectedItemColor: AppColors.neutral300,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutral800,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: AppColors.neutral800,
    );
  }
}
