import 'package:demetiapp/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppDefaultTextStyles extends AppTextStyles {
  AppDefaultTextStyles({
    required AppColors colors,
  }) : super(
          largeTitle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 45.0,
            color: colors.labelPrimary,
          ),
          title: TextStyle(
            fontSize: 23.0,
            color: colors.labelTertiary,
          ),
          button: TextStyle(
            fontSize: 14.0,
            color: colors.labelSecondary,
          ),
          body: TextStyle(
            fontSize: 16.0,
            color: colors.labelPrimary,
          ),
          subhead: TextStyle(
            fontSize: 14.0,
            color: colors.labelPrimary,
          ),
        );
}

class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle largeTitle;
  final TextStyle title;
  final TextStyle button;
  final TextStyle body;
  final TextStyle subhead;

  const AppTextStyles({
    required this.largeTitle,
    required this.title,
    required this.button,
    required this.body,
    required this.subhead,
  });

  @override
  ThemeExtension<AppTextStyles> copyWith({
    TextStyle? largeTitle,
    TextStyle? title,
    TextStyle? button,
    TextStyle? body,
    TextStyle? subhead,
  }) {
    return AppTextStyles(
      largeTitle: largeTitle ?? this.largeTitle,
      title: title ?? this.title,
      button: button ?? this.button,
      body: body ?? this.body,
      subhead: subhead ?? this.subhead,
    );
  }

  @override
  ThemeExtension<AppTextStyles> lerp(
    covariant ThemeExtension<AppTextStyles>? other,
    double t,
  ) {
    if (other == null || other.runtimeType != AppTextStyles) {
      return this;
    }

    final AppTextStyles typedOther = other as AppTextStyles;

    return AppTextStyles(
      largeTitle: TextStyle.lerp(largeTitle, typedOther.largeTitle, t)!,
      title: TextStyle.lerp(title, typedOther.title, t)!,
      button: TextStyle.lerp(button, typedOther.button, t)!,
      body: TextStyle.lerp(body, typedOther.body, t)!,
      subhead: TextStyle.lerp(subhead, typedOther.subhead, t)!,
    );
  }
}
