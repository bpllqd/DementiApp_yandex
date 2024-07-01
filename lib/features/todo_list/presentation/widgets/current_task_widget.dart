import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/text_constants.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'check_box_button_widget.dart';

class CurrentTask extends StatelessWidget {
  final TaskEntity task;

  const CurrentTask({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ToDoListBloc>();
    return BlocBuilder<ToDoListBloc, ToDoListState>(
      builder: (context, state) {
        if (state is SuccessState) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (task.done) ...[
                    CheckBoxButton(
                      imagePath: checkboxChecked,
                      onTap: () {
                        bloc.add(TaskCompleteEvent(task: task));
                        DementiappLogger.infoLog('Added CompleteTaskEvent 1');
                      },
                    ),
                  ] else ...[
                    if (task.importance ==
                        TextConstants.importanceImportant()) ...[
                      CheckBoxButton(
                        imagePath: checkboxHigh,
                        onTap: () {
                          bloc.add(TaskCompleteEvent(task: task));
                          DementiappLogger.infoLog('Added CompleteTaskEvent 2');
                        },
                      ),
                    ] else ...[
                      CheckBoxButton(
                        imagePath: checkboxNo,
                        onTap: () {
                          bloc.add(TaskCompleteEvent(task: task));
                          DementiappLogger.infoLog('Added CompleteTaskEvent 3');
                        },
                      ),
                    ],
                  ],
                  Visibility(
                    visible: !(task.done) &&
                        (task.importance ==
                                TextConstants.importanceImportant() ||
                            task.importance == TextConstants.importanceLow()),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 3.0),
                      child:
                          task.importance == TextConstants.importanceImportant()
                              ? const SVG(
                                  imagePath: priorityHigh,
                                  color: 0xFFFF3B30,
                                )
                              : const SVG(
                                  imagePath: priorityLow,
                                  color: 0xFF8E8E93,
                                ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.done) ...[
                          Text(
                            task.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.lightLabelTertiary,
                              decoration: TextDecoration.lineThrough,
                              fontSize: AppFontSize.bodyFontSize,
                            ),
                          ),
                        ] else ...[
                          Text(
                            task.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.lightLabelPrimary,
                              decoration: TextDecoration.none,
                              fontSize: AppFontSize.bodyFontSize,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => bloc.add(TaskEditEvent(task: task)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.lightLabelTertiary,
                    ),
                  ),
                ],
              ),
              if (task.deadline != null && task.done == false)
                Visibility(
                  visible: task.deadline != null,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 62),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FormatDate.toDmmmmyyyy(task.deadline!),
                          style: const TextStyle(
                            color: AppColors.lightLabelTertiary,
                            fontSize: AppFontSize.subheadFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        } else {
          return const Placeholder();
        }
      },
    );
  }
}
