import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';

class InputField extends StatelessWidget {
  final String text, hintText;
  final TextEditingController controller;
  final Widget? prefixIcon, suffixIcon;
  final bool? autofocus, obscureText;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  const InputField({
    super.key,
    required this.text,
    required this.hintText,
    required this.controller,
    required this.textInputAction,
    required this.textInputType,
    this.validator,
    this.onSubmitted,
    this.autofocus = false,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          SizedBox(height: 6.0),
          TextFormField(
            keyboardType: textInputType,
            textInputAction: textInputAction,
            autofocus: autofocus!,
            controller: controller,
            validator: validator,
            obscureText: obscureText!,
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              fillColor: AppColors.greyColor,
              filled: true,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
