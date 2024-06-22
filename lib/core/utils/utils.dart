import 'package:demetiapp/features/todo_list/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class FormatDate {
  static String toDmmmmyyyy(DateTime date) {
    return '${DateFormat.d().format(date)} ${DateFormat.MMMM('ru').format(date)} ${DateFormat.y().format(date)}';
  }
}

class SVG extends StatelessWidget {
  final String imagePath;
  final int? color;

  const SVG({
    super.key,
    required this.imagePath,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return color != null
        ? SvgPicture.asset(
            imagePath,
            fit: BoxFit.scaleDown,
            colorFilter: ColorFilter.mode(
              Color(color!),
              BlendMode.srcIn,
            ),
          )
        : SvgPicture.asset(
            imagePath,
            fit: BoxFit.scaleDown,
          );
  }
}

enum TaskFilter { showAll, showOnly }

extension TasksFilterExtension on TaskFilter {
  bool filterMode(TaskEntity task) {
    switch (this) {
      case TaskFilter.showAll:
        return true;
      case TaskFilter.showOnly:
        return !task.done;
    }
  }

  List<TaskEntity> applyFilter(List<TaskEntity> tasks) {
    return tasks.where(filterMode).toList();
  }
}
