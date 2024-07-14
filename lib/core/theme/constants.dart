part of 'theme.dart';

abstract class AppColors {
  /// ==========[LIGHT COLORS]=================
  static const lightSupportSeparator = Color(0x33000000);
  static const lightSupportOverlay = Color(0x0F000000);
  static const lightLabelPrimary = Color(0xFF000000);
  static const lightLabelDecondary = Color(0x99000000);
  static const lightLabelTertiary = Color(0x4D000000);
  static const lightLabelDisable = Color(0x26000000);
  static const lightColorRed = Color(0xFFFF3B30);
  static const lightColorGreen = Color(0xFF34C759);
  static const lightColorBlue = Color(0xFF007AFF);
  static const lightColorGray = Color(0xFF8E8E93);
  static const lightColorGrayLight = Color(0xFFD1D1D6);
  static const lightColorWhite = Color(0xFFFFFFFF);
  static const lightBackPrimary = Color(0xFFF7F6F2);
  static const lightBackSecondary = Color(0xFFFFFFFF);
  static const lightBackElevated = Color(0xFFFFFFFF);
  /// ==========[DARK COLORS]=================
  static const darkSupportSeparator = Color(0x33FFFFFF);
  static const darkSupportOverlay = Color(0x52000000);
  static const darkLabelPrimary = Color(0xFFFFFFFF);
  static const darkLabelDecondary = Color(0x99FFFFFF);
  static const darkLabelTertiary = Color(0x66FFFFFF);
  static const darkLabelDisable = Color(0x26FFFFFF);
  static const darkColorRed = Color(0xFFFF453A);
  static const darkColorGreen = Color(0xFF32D74B);
  static const darkColorBlue = Color(0xFF0A84FF);
  static const darkColorGray = Color(0xFF8E8E93);
  static const darkColorGrayLight = Color(0xFF48484A);
  static const darkColorWhite = Color(0xFFFFFFFF);
  static const darkBackPrimary = Color(0xFF161618);
  static const darkBackSecondary = Color(0xFF252528);
  static const darkBackElevated = Color(0xFF3C3C3F);
}

/// ==========[IMAGE PATHS]=================
const String priorityHigh = 'assets/images/priority_high.svg';
const String priorityLow = 'assets/images/priority_low.svg';

abstract class AppFontSize {
  /// ==========[FONT SIZES]=================
  static const largeTitleFontSize = 32.0;
  static const titleFontSize = 20.0;
  static const buttonFontSize = 14.0;
  static const bodyFontSize = 16.0;
  static const subheadFontSize = 14.0;
}

// const double largeTitleFontHeight = 38 / largeTitleFontSize;
// const double titleFontHeight = 32 / titleFontSize;
// const double buttonFontHeight = 24 / buttonFontSize;
// const double bodyFontHeight = 20 / bodyFontSize;
// const double subheadFontHeight = 20 / subheadFontSize;
