import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/text_constants.dart';
import 'package:demetiapp/features/todo_list/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddNewButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ToDoListBloc>();
    return BlocBuilder<ToDoListBloc, ToDoListState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is TodoListSuccessState) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(
                bottom: 8.0,
                top: state.filteredTasks.isEmpty ? 8.0 : 0,
              ),
              height: 48.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: AppColors.lightBackSecondary,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 63.0),
                  child: Row(
                    children: [
                      Text(
                        TextConstants.novoe(),
                        style: const TextStyle(
                          fontSize: AppFontSize.bodyFontSize,
                          color: AppColors.lightLabelTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Placeholder();
        }
      },
    );
  }
}
