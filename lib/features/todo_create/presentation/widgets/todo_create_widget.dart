import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:demetiapp/generated/l10n.dart';
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
  bool isSwitchDisabled = true;
  String? importance;
  bool isCreatingTask = true;
  TaskEntity? taskToDelete;
  bool isInitialized = false;

  void switchChange(bool value) async {
    if (value) {
      DateTime? deadlineFromPicker = await showDatePicker(
        context: context,
        initialDate: deadline ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
      );
      setState(() {
        deadline = deadlineFromPicker;
      });
    }
  }

  Text? subtitle(DateTime? date) {
    if (date != null) {
      return Text(
        convertDateTimeToString(date, Localizations.localeOf(context)),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      );
    }
    return null;
  }

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
                            labelText: S.of(context).createScreenDropDownLabel,
                            labelStyle: const TextStyle(
                              fontSize: 22.0,
                              color: AppColors.lightLabelPrimary,
                            ),
                          ),
                          iconSize: 0,
                          hint: Text(
                            S.of(context).createScreenDropdownMenuHint,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: 'basic',
                              child: Text(
                                S.of(context).createScreenDropdownMenuBasic,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'low',
                              child: Text(
                                S.of(context).createScreenDropdownMenuLow,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'important',
                              child: Text(
                                S.of(context).createScreenDropdownMenuImportant,
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
                    child: SwitchListTile(
                      title: Text(S.of(context).createScreenSwitchTileTitle),
                      subtitle: subtitle(deadline),
                      value: deadline != null,
                      onChanged: switchChange,
                      contentPadding: const EdgeInsets.only(left: 16, right: 0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
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
