import 'package:demetiapp/core/constants/constants.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/features/todo_list/domain/entities/task_entity.dart';
import 'package:demetiapp/features/todo_list/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'check_box_button_widget.dart';

class CurrentTask extends StatelessWidget {
  final TaskEntity task;

  const CurrentTask({
    super.key,
    required this.task,
  });

  void _showTaskInfo(
    BuildContext context,
  ) async {
    await context.push('/add_new');
    DementiappLogger.infoLog('Navigating to /add_new');
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ToDoListBloc>();
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (task.done) ...[
              CheckBoxButton(
                imagePath: checkboxChecked,
                onTap: () {
                  bloc.add(CompleteTaskEvent(task));
                  DementiappLogger.infoLog('Added CompleteTaskEvent 1');
                },
              ),
            ] else ...[
              if (task.priority == Priority.high) ...[
                CheckBoxButton(
                  imagePath: checkboxHigh,
                  onTap: () {
                    bloc.add(CompleteTaskEvent(task));
                    DementiappLogger.infoLog('Added CompleteTaskEvent 2');
                  },
                ),
              ] else ...[
                CheckBoxButton(
                  imagePath: checkboxNo,
                  onTap: () {
                    bloc.add(CompleteTaskEvent(task));
                    DementiappLogger.infoLog('Added CompleteTaskEvent 3');
                  },
                ),
              ]
            ],
            Visibility(
              visible: !(task.done) &&
                  (task.priority == Priority.high ||
                      task.priority == Priority.low),
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: task.priority == Priority.high
                    ? const SVG(
                        imagePath: priorityHigh,
                        color: lightColorRed,
                      )
                    : const SVG(
                        imagePath: priorityLow,
                        color: lightColorGray,
                      ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.done) ...[
                    Text(
                      task.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(lightLabelTertiary),
                        decoration: TextDecoration.lineThrough,
                        fontSize: bodyFontSize,
                      ),
                    ),
                  ] else ...[
                    Text(
                      task.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(lightLabelPrimary),
                        decoration: TextDecoration.none,
                        fontSize: bodyFontSize,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push('/add_new'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const SVG(
                imagePath: info,
                color: lightLabelTertiary,
              ),
            )
          ],
        ),
        if (task.date != null && task.done == false)
          Padding(
            padding: const EdgeInsets.only(left: 62),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FormatDate.toDmmmmyyyy(task.date!),
                  style: const TextStyle(
                      color: Color(lightLabelTertiary),
                      fontSize: subheadFontSize),
                ),
              ],
            ),
          )
      ],
    );
  }
}
