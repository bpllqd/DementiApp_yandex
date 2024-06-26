import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/features/todo_create/presentation/widgets/todo_create_widget.dart';
import 'package:flutter/material.dart';

class ToDoCreateScreen extends StatelessWidget {
  const ToDoCreateScreen({super.key, required this.task});

  final TaskEntity? task;

  @override
  Widget build(BuildContext context) {
    return const ToDoCreateWidget();
  }
}
