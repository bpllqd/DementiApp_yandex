import 'package:demetiapp/core/constants/constants.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/features/todo_list/presentation/bloc/todo_list_bloc.dart';
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
        if (state is TodoListSuccessState) {
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
                    state.filteredTasks[index].taskID,
                  ),
                  confirmDismiss: (direction) =>
                      confirmDismissing(direction, bloc, index, state),
                  onDismissed: (_) => bloc.add(
                    DeleteTaskEvent(
                      state.filteredTasks[index].taskID,
                    ),
                  ),
                  background: Container(
                    color: Color(
                      (state.filteredTasks[index].done)
                          ? lightColorGrayLight
                          : lightColorGreen,
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
                    color: const Color(lightColorRed),
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
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<bool> confirmDismissing(
    DismissDirection direction,
    ToDoListBloc bloc,
    int index,
    TodoListSuccessState state,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      bloc.add(
        CompleteTaskEvent(
          state.filteredTasks[index],
        ),
      );
    }
    DementiappLogger.infoLog('Dissmising has been confirmed');
    return direction == DismissDirection.endToStart;
  }
}
