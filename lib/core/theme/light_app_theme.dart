part of 'theme.dart';

ThemeData lightTheme() {
  return ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackPrimary,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackPrimary,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: AppFontSize.largeTitleFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.lightLabelPrimary,
      ),
      titleMedium: TextStyle(
          fontSize: AppFontSize.titleFontSize,
          fontWeight: FontWeight.normal,
          color: AppColors.lightLabelTertiary,),
      bodyMedium: TextStyle(
          fontSize: AppFontSize.bodyFontSize,
          color: AppColors.lightLabelPrimary,
          height: 20.0 / AppFontSize.bodyFontSize,),
      bodySmall: TextStyle(
        fontSize: AppFontSize.subheadFontSize,
        color: AppColors.lightLabelTertiary,
      ),
      labelMedium: TextStyle(
        color: AppColors.lightColorBlue,
        fontSize: AppFontSize.buttonFontSize,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lightColorRed,
      foregroundColor: AppColors.lightBackPrimary,
    ),
    cardColor: AppColors.lightBackSecondary,
    dividerColor: AppColors.lightSupportSeparator,
    datePickerTheme: const DatePickerThemeData(
      headerBackgroundColor: AppColors.lightColorRed,
      headerForegroundColor: AppColors.lightColorWhite,
      surfaceTintColor: AppColors.lightColorWhite,
      todayForegroundColor: WidgetStatePropertyAll(AppColors.lightColorWhite),
      rangePickerBackgroundColor: AppColors.lightColorRed,
      rangeSelectionOverlayColor:
          WidgetStatePropertyAll(AppColors.lightColorRed),
      rangePickerHeaderBackgroundColor: AppColors.lightColorRed,
      todayBackgroundColor: WidgetStatePropertyAll(AppColors.lightColorRed),
      rangeSelectionBackgroundColor: AppColors.lightColorRed,
      dayOverlayColor: WidgetStatePropertyAll(AppColors.lightColorRed),
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(
        fontSize: AppFontSize.bodyFontSize,
        color: AppColors.lightLabelPrimary,
        height: 20.0 / AppFontSize.bodyFontSize,
      ),
    ),
  );
}

// ДОДЕЛАТЬ ТЕМЫ ДЛЯ ВСЯКИХ ЛИНИЙ, ИКОНОК, ЭКСТЕНШЕНЫ И ПРОЧЕЕ

