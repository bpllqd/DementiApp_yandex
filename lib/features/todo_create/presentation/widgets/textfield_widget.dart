import 'package:demetiapp/core/constants/constants.dart';
import 'package:flutter/material.dart';

class MaterialTextfield extends StatelessWidget {
  final TextEditingController textController;

  const MaterialTextfield({
    super.key,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      elevation: 2,
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.all(16.0),
          labelText: 'Что надо сделать…',
          alignLabelWithHint: true,
          labelStyle: const TextStyle(
            fontSize: bodyFontSize,
            height: 18.0 / bodyFontSize,
            color: Color(lightLabelTertiary),
          ),
          filled: true,
          fillColor: const Color(lightBackSecondary),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        style: const TextStyle(
          fontSize: bodyFontSize,
          height: 18.0 / bodyFontSize,
          color: Color(lightLabelPrimary),
        ),
        maxLines: null,
        minLines: 5,
      ),
    );
  }
}
