import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/generated/l10n.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActive;

  const DeleteButton({
    super.key,
    this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 5.0),
          child: InkWell(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete,
                  color: AppColors.lightColorRed,
                ),
                const SizedBox(width: 12.0),
                Text(
                  S.of(context).createScreenDeleteButtonDelete,
                  style: const TextStyle(
                    fontSize: AppFontSize.bodyFontSize,
                    color: AppColors.lightColorRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete,
              color: AppColors.lightColorGray,
            ),
            const SizedBox(width: 12.0),
            Text(
              S.of(context).createScreenDeleteButtonDelete,
              style: const TextStyle(
                fontSize: AppFontSize.bodyFontSize,
                color: AppColors.lightColorGray,
              ),
            ),
          ],
        ),
      );
    }
  }
}
