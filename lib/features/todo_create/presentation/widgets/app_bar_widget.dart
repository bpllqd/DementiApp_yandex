import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/text_constants.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class BarWidget extends StatelessWidget implements PreferredSizeWidget {
  const BarWidget({
    super.key,
    required this.bloc,
    required this.task,
    required this.textController,
    required this.isSwitchEnabled,
    required this.pickedDate,
    required this.importance,
  });

  final Uuid uuid = const Uuid();
  final ToDoListBloc bloc;
  final TaskEntity? task;
  final TextEditingController textController;
  final bool isSwitchEnabled;
  final DateTime? pickedDate;
  final String? importance;

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
                      id: task?.id ?? uuid.v1(),
                      text: textController.text.isNotEmpty
                          ? textController.text
                          : TextConstants.chtoTo(),
                      importance: TextConstants.importanceBasicValue(),
                      deadline: pickedDate,
                    ),
                  ),
                );
                Navigator.pop(context);
                DementiappLogger.infoLog('Navigating to ToDo List');
              },
              child: Text(
                TextConstants.createSave(),
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
