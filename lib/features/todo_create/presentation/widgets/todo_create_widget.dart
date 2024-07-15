import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/extensions/context_extensions.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/network_status.dart';
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

  late NetworkStatus networkStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    networkStatus = context.read<NetworkStatus>();
    networkStatus.addListener(_handleNetworkNotifications);
  }

  void _handleNetworkNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: networkStatus.isOnline
            ? context.colors.colorGreen
            : context.colors.colorRed,
        content: Row(
          children: [
            Icon(
              networkStatus.isOnline ? Icons.wifi : Icons.wifi_off,
              color: context.colors.colorWhite,
            ),
            const SizedBox(width: 8),
            Text(
              networkStatus.isOnline
                  ? S.of(context).createToDoCreateConnected
                  : S.of(context).createToDoCreateDisconnected,
              style: context.textStyles.subhead
                  .copyWith(color: context.colors.colorWhite),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(10.0),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
        style: context.textStyles.body,
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
            backgroundColor: context.colors.backPrimary,
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
                          style: context.textStyles.body,
                          decoration: InputDecoration(
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.colors.supportSeparator,
                                width: 0.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(
                              bottom: 16.0,
                              top: 16.0,
                            ),
                            labelStyle: context.textStyles.body,
                          ),
                          iconSize: 0,
                          hint: Text(
                            S.of(context).createScreenDropdownMenuHint,
                            style: context.textStyles.body,
                          ),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: 'basic',
                              child: Text(
                                S.of(context).createScreenDropdownMenuBasic,
                                style: context.textStyles.body,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'low',
                              child: Text(
                                S.of(context).createScreenDropdownMenuLow,
                                style: context.textStyles.body,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'important',
                              child: Text(
                                S.of(context).createScreenDropdownMenuImportant,
                                style: context.textStyles.body
                                    .copyWith(color: context.colors.colorRed),
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
                      color: context.colors.supportSeparator,
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
                    color: context.colors.supportSeparator,
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
                              context.pop();
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
