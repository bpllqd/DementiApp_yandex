import 'package:demetiapp/core/constants/constants.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final String icon;
  final int textColor;
  final VoidCallback onTap;

  const DeleteButton({
    super.key,
    required this.icon,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 5.0),
        child: InkWell(
          onTap: () {
            DementiappLogger.infoLog('Delet button has been pressed');
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete,
                color: Color(lightColorRed),
              ),
              SizedBox(width: 12.0),
              Text(
                'Удалить',
                style: TextStyle(
                  fontSize: bodyFontSize,
                  height: bodyFontHeight,
                  color: Color(lightColorRed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
