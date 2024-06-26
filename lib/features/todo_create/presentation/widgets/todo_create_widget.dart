import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/features/todo_create/presentation/bloc/todo_create_bloc.dart';
import 'package:demetiapp/features/todo_list/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app_bar_widget.dart';
import 'delete_button.dart';
import 'textfield_widget.dart';

class ToDoCreateWidget extends StatelessWidget {
  final TaskEntity? task;

  const ToDoCreateWidget({
    super.key,
    this.task,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ToDoCreateBloc>();

    final TextEditingController textController = TextEditingController();

    textController.text = task?.title ?? '';
    Priority? priority = task?.priority;
    DateTime? pickedDate = task?.date;
    bool isSwitchEnabled = task?.date != null;

    return BlocListener<ToDoCreateBloc, ToDoCreateState>(
      listener: (context, state) {
        if (state is ToDoCreateSuccessState) {
          context.pop();
          DementiappLogger.infoLog('Navigating back');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: BarWidget(
          bloc: bloc,
          task: task,
          textController: textController,
          priority: priority,
          isSwitchEnabled: isSwitchEnabled,
          pickedDate: pickedDate,
        ),
        body: BlocBuilder<ToDoCreateBloc, ToDoCreateState>(
          builder: (context, state) {
            if (state is ToDoCreateLoadingState) {
              return const CircularProgressIndicator();
            } else {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: MaterialTextfield(textController: textController),
                    ),
                    const SizedBox(height: 12.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 100),
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                            value: priority,
                            onChanged: (newPriority) {
                              if (newPriority != Priority.no) {
                                priority = newPriority as Priority;
                              } else {
                                priority = null;
                              }
                            },
                            style: const TextStyle(
                              fontSize: AppFontSize.buttonFontSize,
                              height: 18.0 / AppFontSize.bodyFontSize,
                              color: AppColors.lightLabelTertiary,
                            ),
                            decoration: const InputDecoration(
                              enabled: false,
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.lightSupportSeparator,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              contentPadding:
                                  EdgeInsets.only(bottom: 16.0, top: 16.0),
                              labelText: 'Важность',
                              labelStyle: TextStyle(
                                fontSize: 22.0,
                                color: AppColors.lightLabelPrimary,
                              ),
                            ),
                            iconSize: 0,
                            hint: Text(
                              'Нет',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            items: <DropdownMenuItem<Priority>>[
                              DropdownMenuItem(
                                value: Priority.no,
                                child: Text(
                                  'Нет',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              DropdownMenuItem(
                                value: Priority.low,
                                child: Text(
                                  'Низкий',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const DropdownMenuItem(
                                value: Priority.high,
                                child: Text(
                                  '!! Высокий',
                                  style: TextStyle(
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
                                'Сделать до',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Visibility(
                                visible: isSwitchEnabled != false,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    pickedDate != null
                                        ? FormatDate.toDmmmmyyyy(pickedDate!)
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
                            value: isSwitchEnabled != false,
                            onChanged: (bool value) async {
                              isSwitchEnabled != false
                                  ? null
                                  : pickedDate = await pickDate(context);
                              if (pickedDate != null) {
                                isSwitchEnabled = !isSwitchEnabled;
                                bloc.add(ToDoCreateSwitchDateEvent(task));
                              }
                            },
                          )
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
                      child: task != null
                          ? DeleteButton(
                              onTap: () {
                                bloc.add(ToDoCreateDeleteEvent(task!));
                                Navigator.pop(context);
                                DementiappLogger.infoLog(
                                    'Delet button has been pressed');
                              },
                            )
                          : DeleteButton(
                              onTap: () {},
                            ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

Future<DateTime?> pickDate(BuildContext context) {
  return showDatePicker(
    helpText: DateTime.now().year.toString(),
    confirmText: 'ГОТОВО',
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
