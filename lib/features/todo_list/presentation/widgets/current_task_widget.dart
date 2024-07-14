import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          return ListTile(
            minTileHeight: 40,
            leading: Checkbox(
              value: task.done,
              onChanged: (bool? value) {
                bloc.add(TaskCompleteEvent(task: task));
              },
              fillColor: WidgetStatePropertyAll(
                task.done ? AppColors.lightColorGreen : null,
              ),
              checkColor: AppColors.lightColorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              side: BorderSide(
                color: task.importance == 'important'
                    ? AppColors.lightColorRed
                    : AppColors.lightColorGrayLight,
                width: 2,
              ),
            ),
            title: Text.rich(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: task.done
                    ? Theme.of(context).dividerColor
                    : Theme.of(context).colorScheme.onSurface,
                decoration: task.done ? TextDecoration.lineThrough : null,
                decorationColor: Theme.of(context).dividerColor,
              ),
              textWithImportance(
                importance: task.importance,
                text: task.text,
              ),
            ),
            subtitle: task.deadline != null
                ? TaskDeadline(
                    deadline: task.deadline!,
                    isCompleted: task.done,
                  )
                : null,
            contentPadding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            trailing: TaskInfo(
              task: task,
              bloc: bloc,
            ),
          );
        } else {
          return const Placeholder();
        }
      },
    );
  }
}

class TaskDeadline extends StatelessWidget {
  const TaskDeadline(
      {super.key, required this.deadline, required this.isCompleted,});

  final DateTime deadline;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Text(
      convertDateTimeToString(deadline, Localizations.localeOf(context)),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).dividerColor,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: Theme.of(context).dividerColor,
          ),
    );
  }
}

class TaskInfo extends StatelessWidget {
  const TaskInfo({super.key, required this.task, required this.bloc});

  final TaskEntity task;
  final ToDoListBloc bloc;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        bloc.add(TaskEditEvent(task: task));
      },
      icon: Icon(
        Icons.info_outline,
        color: Theme.of(context).colorScheme.tertiary,
        size: 24,
      ),
    );
  }
}

TextSpan textWithImportance({
  required String importance,
  required String text,
}) {
  return TextSpan(
    children: [
      if (importance == 'important')
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SVG(
            imagePath: priorityHigh,
            color: AppColors.lightColorRed,
          ),
        ),
      if (importance == 'low')
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SVG(
            imagePath: priorityLow,
            color: AppColors.lightColorGray,
          ),
        ),
      TextSpan(text: text),
    ],
  );
}
