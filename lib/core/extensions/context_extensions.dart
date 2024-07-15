import 'package:demetiapp/core/theme/app_colors.dart';
import 'package:demetiapp/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

extension CoreContextExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  AppTextStyles get textStyles => Theme.of(this).extension<AppTextStyles>()!;
}
