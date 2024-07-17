import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/extensions/context_extensions.dart';
import 'package:demetiapp/core/theme/constants.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
                FirebaseAnalytics.instance.logEvent(
                  name: 'complete_task_from_checkbox',
                );
                bloc.add(TaskCompleteEvent(task: task));
              },
              fillColor: WidgetStatePropertyAll(
                task.done ? context.colors.colorGreen : null,
              ),
              checkColor: context.colors.colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              side: BorderSide(
                color: task.importance == 'important'
                    ? context.colors.colorRed
                    : context.colors.labelSecondary,
                width: 2,
              ),
            ),
            title: Text.rich(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: task.done
                    ? context.colors.labelTertiary
                    : context.colors.labelPrimary,
                decoration: task.done ? TextDecoration.lineThrough : null,
                decorationColor: Theme.of(context).dividerColor,
              ),
              textWithImportance(
                context: context,
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
  const TaskDeadline({
    super.key,
    required this.deadline,
    required this.isCompleted,
  });

  final DateTime deadline;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Text(
      convertDateTimeToString(deadline, Localizations.localeOf(context)),
      style: isCompleted
          ? context.textStyles.subhead
              .copyWith(decoration: TextDecoration.lineThrough)
          : context.textStyles.subhead,
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
        color: context.colors.labelTertiary,
        size: 24,
      ),
    );
  }
}

TextSpan textWithImportance({
  required String importance,
  required String text,
  required BuildContext context,
}) {
  return TextSpan(
    children: [
      if (importance == 'important')
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SVG(
            imagePath: priorityHigh,
            color: context.colors.colorRed,
          ),
        ),
      if (importance == 'low')
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SVG(
            imagePath: priorityLow,
            color: context.colors.colorGrayLight,
          ),
        ),
      TextSpan(
        text: text,
      ),
    ],
  );
}
