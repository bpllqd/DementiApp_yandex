import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'current_task_widget.dart';

class TasksList extends StatelessWidget {
  const TasksList({super.key});

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
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: state.filteredTasks.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(
                    state.filteredTasks[index].id,
                  ),
                  confirmDismiss: (direction) =>
                      confirmDismissing(direction, bloc, index, state),
                  onDismissed: (_) => bloc.add(
                    TaskDeleteEvent(
                      task: state.filteredTasks[index],
                    ),
                  ),
                  background: Container(
                    color: Color(
                      (state.filteredTasks[index].done)
                          ? 0xFF8E8E93
                          : 0xFF34C759,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  secondaryBackground: Container(
                    color: AppColors.lightColorRed,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 24.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.white,
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
                );
              },
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Error occured'),
            ),
          );
        }
      },
    );
  }

  Future<bool> confirmDismissing(
    DismissDirection direction,
    ToDoListBloc bloc,
    int index,
    SuccessState state,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      bloc.add(TaskCompleteEvent(task: state.filteredTasks[index]));
    }
    return direction == DismissDirection.endToStart;
  }
}
