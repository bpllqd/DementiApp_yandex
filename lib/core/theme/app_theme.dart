import 'package:demetiapp/core/theme/app_colors.dart';
import 'package:demetiapp/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppThemes {
  final _appLightColors = AppLightColors();
  final _appDarkColors = AppDarkColors();
  late final _appLightTextStyles =
      AppDefaultTextStyles(colors: _appLightColors);
  late final _appDarkTextStyles = AppDefaultTextStyles(colors: _appDarkColors);

  ThemeData get lightThemeData => ThemeData(
        brightness: Brightness.light,
        extensions: [
          _appLightColors,
          _appLightTextStyles,
        ],
      );

  ThemeData get darkThemeData => ThemeData(
        brightness: Brightness.dark,
        extensions: [
          _appDarkColors,
          _appDarkTextStyles,
        ],
      );
}
