import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';

class DropDownButton<T> extends StatelessWidget {
  final String text, hintText;
  final List<T> items;
  final void Function(T?)? onChanged;
  final T? value;
  final String? Function(T?)? validator;
  const DropDownButton({
    super.key,
    required this.text,
    required this.hintText,
    required this.items,
    required this.onChanged,
    required this.value,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          const SizedBox(height: 6.0),
          DropdownButtonFormField(
            validator:
                validator ??
                (v) {
                  return null;
                },
            initialValue: value,
            hint: Text(hintText),
            decoration: InputDecoration(
              fillColor: AppColors.greyColor,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(value: e, child: Text(e.toString())),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
