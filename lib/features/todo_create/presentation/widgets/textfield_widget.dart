import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/generated/l10n.dart';
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
    return BlocBuilder<ToDoListBloc, ToDoListState>(
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
              labelText: S.of(context).createScreenTextfieldLabel,
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
