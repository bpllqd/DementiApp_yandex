import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/features/todo_create/presentation/bloc/todo_create_bloc.dart';
import 'package:demetiapp/features/todo_list/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BarWidget extends StatelessWidget implements PreferredSizeWidget {
  const BarWidget({
    super.key,
    required this.bloc,
    required this.task,
    required this.textController,
    required this.priority,
    required this.isSwitchEnabled,
    required this.pickedDate,
  });

  final ToDoCreateBloc bloc;
  final TaskEntity? task;
  final TextEditingController textController;
  final Priority? priority;
  final bool isSwitchEnabled;
  final DateTime? pickedDate;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 5.0,
      leading: IconButton(
        splashRadius: 24.0,
        onPressed: () {
          context.pop(context);
          DementiappLogger.infoLog('Navigate back');
        },
        icon: const Icon(
          Icons.close,
          color: AppColors.lightLabelPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(
            child: TextButton(
              onPressed: () {
                bloc.add(
                  ToDoCreateNewEvent(
                    TaskEntity(
                      taskID: task?.taskID ?? '',
                      title: textController.text.isNotEmpty
                          ? textController.text
                          : 'Что надо сделать...',
                      done: false,
                      priority: priority,
                      date: isSwitchEnabled ? pickedDate : null,
                    ),
                  ),
                );
                Navigator.pop(context, true);
                DementiappLogger.infoLog('Navigating to ToDo List');
              },
              child: Text(
                'СОХРАНИТЬ',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
