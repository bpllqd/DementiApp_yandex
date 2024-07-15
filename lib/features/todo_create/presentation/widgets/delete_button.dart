import 'package:demetiapp/core/extensions/context_extensions.dart';
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
                Icon(
                  Icons.delete,
                  color: context.colors.colorRed,
                ),
                const SizedBox(width: 12.0),
                Text(
                  S.of(context).createScreenDeleteButtonDelete,
                  style: context.textStyles.body
                      .copyWith(color: context.colors.colorRed),
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
            Icon(
              Icons.delete,
              color: context.colors.labelDisable,
            ),
            const SizedBox(width: 12.0),
            Text(
              S.of(context).createScreenDeleteButtonDelete,
              style: context.textStyles.body
                  .copyWith(color: context.colors.labelDisable),
            ),
          ],
        ),
      );
    }
  }
}
