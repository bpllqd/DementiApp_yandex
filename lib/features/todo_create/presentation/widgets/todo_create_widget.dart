import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/text_constants.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app_bar_widget.dart';
import 'delete_button.dart';
import 'textfield_widget.dart';

class ToDoCreateWidget extends StatefulWidget {
  const ToDoCreateWidget({
    super.key,
  });

  @override
  State<ToDoCreateWidget> createState() => _ToDoCreateWidgetState();
}

class _ToDoCreateWidgetState extends State<ToDoCreateWidget> {
  final TextEditingController textController = TextEditingController();

  DateTime? deadline;
  bool isSwitchDisabled = false;
  String? importance;
  bool isCreatingTask = true;
  TaskEntity? taskToDelete;
  bool isInitialized = false;
  

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ToDoListBloc>();

    return BlocListener<ToDoListBloc, ToDoListState>(
      listener: (context, state) {
        if (state is CreatingSuccessState || state is EditingSuccessState) {
          bloc.add(GetTasksEvent());
          context.pop();
        }
      },
      child: BlocBuilder<ToDoListBloc, ToDoListState>(
        builder: (context, state) {
          if (state is EditInProgressState && !isInitialized) {
            textController.text = state.task.text;
            deadline = state.task.deadline;
            importance = state.task.importance;
            isSwitchDisabled = state.task.deadline != null ? true : false;
            isCreatingTask = false;
            taskToDelete = state.task;
            isInitialized = true;
          }
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: BarWidget(
              bloc: bloc,
              textController: textController,
              deadline: deadline,
              importance: importance,
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: MaterialTextfield(
                      textController: textController,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 100),
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField(
                          value: importance,
                          onChanged: (newPriority) {
                            setState(() {
                              importance = newPriority;
                            });
                          },
                          style: const TextStyle(
                            fontSize: AppFontSize.buttonFontSize,
                            height: 18.0 / AppFontSize.bodyFontSize,
                            color: AppColors.lightLabelTertiary,
                          ),
                          decoration: InputDecoration(
                            enabled: false,
                            disabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.lightSupportSeparator,
                                width: 0.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(
                              bottom: 16.0,
                              top: 16.0,
                            ),
                            labelText: TextConstants.importance(),
                            labelStyle: const TextStyle(
                              fontSize: 22.0,
                              color: AppColors.lightLabelPrimary,
                            ),
                          ),
                          iconSize: 0,
                          hint: Text(
                            TextConstants.importanceBasicValue(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: TextConstants.importanceBasicValue(),
                              child: Text(
                                TextConstants.importanceBasicValue(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            DropdownMenuItem(
                              value: TextConstants.importanceLow(),
                              child: Text(
                                TextConstants.importanceLow(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            DropdownMenuItem(
                              value: TextConstants.importanceImportant(),
                              child: Text(
                                TextConstants.importanceImportant(),
                                style: const TextStyle(
                                  fontSize: AppFontSize.bodyFontSize,
                                  color: AppColors.lightColorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      height: 0,
                      thickness: 0.5,
                      color: Theme.of(context).dividerTheme.color,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TextConstants.sdelatD0(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Visibility(
                              visible: isSwitchDisabled != true,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  deadline != null
                                      ? FormatDate.toDmmmmyyyy(deadline!)
                                      : '',
                                  style: const TextStyle(
                                    fontSize: AppFontSize.buttonFontSize,
                                    color: AppColors.lightColorRed,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isSwitchDisabled != true,
                          onChanged: (bool value) async {
                            isSwitchDisabled != false
                                ? null
                                : deadline = await pickDate(context);
                            if (deadline != null) {
                              isSwitchDisabled = !isSwitchDisabled;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Theme.of(context).dividerTheme.color,
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: DeleteButton(
                      isActive: !isCreatingTask,
                      onTap: isCreatingTask
                          ? null
                          : () {
                              bloc.add(TaskDeleteEvent(task: taskToDelete!));
                              Navigator.pop(context);
                              DementiappLogger.infoLog(
                                'Delete button has been pressed',
                              );
                            },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<DateTime?> pickDate(BuildContext context) {
  return showDatePicker(
    helpText: DateTime.now().year.toString(),
    confirmText: TextConstants.ready(),
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2024),
    lastDate: DateTime(2080),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.lightColorRed,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.lightColorRed,
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
