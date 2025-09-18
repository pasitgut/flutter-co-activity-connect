import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final bool autoFocus;
  final String labelText, hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  const InputField({
    super.key,
    this.autoFocus = false,
    this.maxLines = 1,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
