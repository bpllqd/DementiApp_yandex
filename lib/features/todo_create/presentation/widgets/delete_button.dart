import 'package:demetiapp/core/theme/theme.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {

  final VoidCallback onTap;

  const DeleteButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 5.0),
        child: InkWell(
          onTap: onTap,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete,
                color: AppColors.lightColorRed,
              ),
              SizedBox(width: 12.0),
              Text(
                'Удалить',
                style: TextStyle(
                  fontSize: AppFontSize.bodyFontSize,
                  color: AppColors.lightColorRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
