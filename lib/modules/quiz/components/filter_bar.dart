import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/modules/quiz/components/search_card.dart';
import 'package:servelq_agent/modules/quiz/cubit/quiz_cubit.dart';

class FilterBar extends StatelessWidget {
  final TextEditingController searchController;

  const FilterBar({super.key, required this.searchController});

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state is! QuizLoaded) return const SizedBox();

        final hasActiveFilters =
            state.selectedStatus != "All Status" ||
            state.selectedType != "All Types" ||
            state.selectedParticipation != "All" ||
            state.selectedSort != "Sort by" ||
            state.selectedDate != null ||
            searchController.text.isNotEmpty;

        return SizedBox(
          height: 70,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            scrollDirection: Axis.horizontal,
            children: [
              /// 🧹 Clear filters
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: hasActiveFilters
                        ? () => context.read<QuizCubit>().resetFilters()
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: _height,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: hasActiveFilters
                            ? LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.8),
                                ],
                              )
                            : null,
                        color: hasActiveFilters ? null : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasActiveFilters
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear_all_rounded,
                            size: 18,
                            color: hasActiveFilters
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Clear",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: hasActiveFilters
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// 🔍 Search
              SizedBox(
                width: 260,
                height: _height,
                child: SearchCard(
                  controller: searchController,
                  hintText: "Search by title...",
                ),
              ),
              const SizedBox(width: 12),

              _dropdown(
                context,
                value: state.selectedStatus ?? "All Status",
                items: const ["All Status", "Active", "Closed"],
                onChanged: (v) =>
                    context.read<QuizCubit>().setFilter(status: v),
              ),
              const SizedBox(width: 12),

              _dropdown(
                context,
                value: state.selectedType ?? "All Types",
                items: const ["All Types", "Survey", "Quiz"],
                onChanged: (v) => context.read<QuizCubit>().setFilter(type: v),
              ),
              const SizedBox(width: 12),

              _dropdown(
                context,
                value: state.selectedSort ?? "Sort by",
                items: const ["Sort by", "Latest", "Oldest"],
                onChanged: (v) => context.read<QuizCubit>().setFilter(sort: v),
              ),
              const SizedBox(width: 12),

              _dropdown(
                context,
                value: state.selectedParticipation ?? "All",
                items: const ["All", "Participated", "Not Participated"],
                onChanged: (v) =>
                    context.read<QuizCubit>().setFilter(participation: v),
              ),
              const SizedBox(width: 12),

              _datePicker(context, state),
            ],
          ),
        );
      },
    );
  }

  // ---------- Dropdown ----------
  Widget _dropdown(
    BuildContext context, {
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBeige),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.offWhite,
          borderRadius: BorderRadius.circular(10),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.brownDeep,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------- Date Picker ----------
  Widget _datePicker(BuildContext context, QuizLoaded state) {
    final hasDate = state.selectedDate != null;

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: state.selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && context.mounted) {
          context.read<QuizCubit>().setFilter(date: picked);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasDate ? AppColors.primary : AppColors.lightBeige,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: hasDate ? AppColors.primary : AppColors.brownDark,
            ),
            const SizedBox(width: 8),
            Text(
              hasDate
                  ? "${state.selectedDate!.day}/${state.selectedDate!.month}/${state.selectedDate!.year}"
                  : "dd/mm/yyyy",
              style: TextStyle(
                fontSize: 14,
                color: hasDate ? AppColors.primary : AppColors.brownDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
