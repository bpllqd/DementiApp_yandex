import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/extensions/context_extensions.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:demetiapp/generated/l10n.dart';
import 'package:uuid/uuid.dart';

class BarWidget extends StatelessWidget implements PreferredSizeWidget {
  const BarWidget({
    super.key,
    required this.bloc,
    required this.textController,
    required this.deadline,
    required this.importance,
  });

  final ToDoListBloc bloc;
  final Uuid uuid = const Uuid();
  final TextEditingController textController;
  final DateTime? deadline;
  final String? importance;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.backPrimary,
      elevation: 0,
      scrolledUnderElevation: 5.0,
      leading: IconButton(
        splashRadius: 24.0,
        onPressed: () {
          bloc.add(GetTasksEvent());
          context.pop(context);
        },
        icon: Icon(
          Icons.close,
          color: context.colors.labelPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(
            child: BlocBuilder<ToDoListBloc, ToDoListState>(
              builder: (context, state) {
                if (state is CreateInProgressState) {
                  return TextButton(
                    key: const ValueKey('SaveCreated'),
                    onPressed: () {
                      bloc.add(
                        TaskCreatedSaveEvent(
                          task: TaskEntity(
                            id: uuid.v1(),
                            text: textController.text,
                            importance: importance ?? 'basic',
                            deadline: deadline,
                            createdAt: DateTime.now(),
                            changedAt: DateTime.now(),
                          ),
                        ),
                      );
                      context.pop();
                    },
                    child: Text(
                      S.of(context).createScreenAppBarSave,
                      style: context.textStyles.body,
                    ),
                  );
                } else if (state is EditInProgressState) {
                  return TextButton(
                    key: const ValueKey('SaveEdited'),
                    onPressed: () {
                      bloc.add(
                        TaskEditedSaveEvent(
                          oldTask: state.task,
                          newTask: TaskEntity(
                            id: state.task.id,
                            text: textController.text,
                            importance: importance ?? 'basic',
                            deadline: deadline,
                            createdAt: state.task.createdAt,
                            changedAt: DateTime.now(),
                          ),
                        ),
                      );
                      context.pop();
                    },
                    child: Text(
                      S.of(context).createScreenAppBarSave,
                      style: context.textStyles.body,
                    ),
                  );
                } else {
                  return TextButton(
                    onPressed: () {},
                    child: Text(
                      S.of(context).createScreenAppBarSave,
                      style: context.textStyles.body,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
