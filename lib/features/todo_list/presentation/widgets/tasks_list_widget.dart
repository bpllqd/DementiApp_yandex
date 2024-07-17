import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/extensions/context_extensions.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:demetiapp/generated/l10n.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'current_task_widget.dart';

class TasksList extends StatefulWidget {
  const TasksList({super.key});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ToDoListBloc>();

    return BlocBuilder<ToDoListBloc, ToDoListState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is SuccessState) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            child: AnimatedList(
              padding: EdgeInsets.zero,
              key: _listKey,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              initialItemCount: state.filteredTasks.length,
              itemBuilder: (
                BuildContext context,
                int index,
                Animation<double> animation,
              ) {
                return _buildTaskItem(
                  bloc,
                  index,
                  animation,
                  state,
                );
              },
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: context.colors.backPrimary,
            body: Center(
              child: Text(
                S.of(context).listTaskListError,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildTaskItem(
    ToDoListBloc bloc,
    int index,
    Animation<double> animation,
    SuccessState state,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Dismissible(
        key: Key(
          state.filteredTasks[index].id,
        ),
        confirmDismiss: (direction) =>
            confirmDismissing(direction, bloc, index, state),
        onDismissed: (_) {
          FirebaseAnalytics.instance.logEvent(
            name: 'delete_from_swipe',
          );
          _removeTaskFromList(index);
          bloc.add(
            TaskDeleteEvent(
              task: state.filteredTasks[index],
            ),
          );
        },
        background: Container(
          color: Color(
            (state.filteredTasks[index].done) ? 0xFF8E8E93 : 0xFF34C759,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.check,
                color: context.colors.colorWhite,
              ),
            ),
          ),
        ),
        secondaryBackground: Container(
          color: context.colors.colorRed,
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.delete_forever_outlined,
                color: context.colors.colorWhite,
              ),
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: index == 0 ? 20.0 : 12.0,
            right: 16.0,
            bottom: 12.0,
          ),
          child: CurrentTask(task: state.filteredTasks[index]),
        ),
      ),
    );
  }

  void _removeTaskFromList(int index) {
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => const SizedBox.shrink(),
      duration: const Duration(milliseconds: 300),
    );
  }

  Future<bool> confirmDismissing(
    DismissDirection direction,
    ToDoListBloc bloc,
    int index,
    SuccessState state,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      FirebaseAnalytics.instance.logEvent(
        name: 'complete_from_swipe',
      );
      bloc.add(TaskCompleteEvent(task: state.filteredTasks[index]));
    }
    return direction == DismissDirection.endToStart;
  }
}
