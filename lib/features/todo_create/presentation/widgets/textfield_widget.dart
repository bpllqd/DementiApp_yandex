import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/utils/text_constants.dart';
import 'package:demetiapp/features/todo_create/presentation/bloc/todo_create_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaterialTextfield extends StatelessWidget {
  final TextEditingController textController;
  const MaterialTextfield({
    super.key,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToDoCreateBloc, ToDoCreateState>(
      builder: (context, state) {
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          elevation: 2,
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              contentPadding: const EdgeInsets.all(16.0),
              labelText: TextConstants.chtoTo(),
              alignLabelWithHint: true,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              filled: true,
              fillColor: AppColors.lightBackSecondary,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: null,
            minLines: 5,
          ),
        );
      },
    );
  }
}
