import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/modules/quiz/cubit/quiz_cubit.dart';

class SearchCard extends StatelessWidget {
  final void Function()? onCancellingSearch;
  final bool readOnly;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const SearchCard({
    super.key,
    this.readOnly = false,
    this.hintText,
    this.onCancellingSearch,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      style: const TextStyle(
        height: 1.1,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      readOnly: readOnly,
      cursorColor: AppColors.primary,
      onChanged: (query) {
        // if (query.isNotEmpty && query.length > 1) {
        //   context.read<SearchCubit>().searchProducts(query);
        // } else if (query.isEmpty) {
        //   context.read<SearchCubit>().searchProducts('');
        // }
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 7),
        hintText: hintText ?? 'Search...',
        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        prefixIcon: SizedBox(
          width: 53,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  Image.asset(
                    AppImages.search,
                    width: 22,
                    color: AppColors.brownDark,
                  ),
                ],
              ),
            ),
          ),
        ),
        suffixIcon: SizedBox(
          width: 80,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
            child: BlocBuilder<QuizCubit, QuizState>(
              builder: (context, state) {
                if (controller.text.isNotEmpty) {
                  return Container(
                    alignment: Alignment.centerRight,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      constraints: BoxConstraints(minHeight: 24, minWidth: 24),
                    ),
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          controller.clear();
                          // context.read<SearchCubit>().searchProducts('');
                          FocusManager.instance.primaryFocus!.unfocus();
                          if (onCancellingSearch != null) {
                            onCancellingSearch!();
                          }
                        },
                        child: const Icon(Icons.close, size: 20),
                      ),
                    const SizedBox(width: 5),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
