import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';

class InputTextStyle {
  static TextStyle inputStyle(BuildContext context) {
    return context.medium.copyWith(
      fontSize: 15,
      height: 1.1,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
    );
  }
}

mixin CustomDecorationMixin {
  InputDecoration customDecoration({
    required BuildContext context,
    String? hintText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    BorderRadius? borderRadius,
  }) {
    return InputDecoration(
      errorMaxLines: 2,
      errorStyle: context.medium.copyWith(color: AppColors.red, fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.brownDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.brownVeryDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.brownVeryDark),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.darkRed),
      ),
      hintText: hintText,
      filled: true,
      fillColor: AppColors.white,
      hintStyle: context.medium.copyWith(color: AppColors.beige),
      contentPadding: const EdgeInsets.fromLTRB(12, 15, 10, 15),
      suffixIcon: suffixIcon,
      prefixIconConstraints: const BoxConstraints(),
      prefixIcon: prefixIcon,
    );
  }
}

class UniversalTextField extends StatelessWidget with CustomDecorationMixin {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final int maxLines;
  final String? Function(String?)? validator;

  const UniversalTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      cursorColor: AppColors.primary,
      decoration: customDecoration(
        context: context,
        borderRadius: BorderRadius.circular(7),
        suffixIcon: suffixIcon,
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
      inputFormatters: inputFormatters,
      style: InputTextStyle.inputStyle(context),
      maxLines: maxLines,
    );
  }
}
