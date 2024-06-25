part of 'theme.dart';

ThemeData darkTheme(){
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackPrimary,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: AppFontSize.largeTitleFontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.darkLabelPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: AppFontSize.titleFontSize,
        fontWeight: FontWeight.normal,
        color: AppColors.darkLabelTertiary
      ),
      bodyMedium: TextStyle(
        fontSize: AppFontSize.bodyFontSize,
        color: AppColors.darkLabelPrimary,
        height: 20.0 / AppFontSize.bodyFontSize
      ),
      bodySmall: TextStyle(
        fontSize: AppFontSize.subheadFontSize,
        color: AppColors.darkLabelTertiary
      ),
      labelMedium: TextStyle(
        color: AppColors.darkColorBlue,
        fontSize: AppFontSize.buttonFontSize,
      )
    ),
  );
}

// ДОДЕЛАТЬ ТЕМЫ ДЛЯ ВСЯКИХ ЛИНИЙ, ИКОНОК, ЭКСТЕНШЕНЫ И ПРОЧЕЕ