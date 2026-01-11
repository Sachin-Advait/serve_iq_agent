import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/modules/quiz/cubit/quiz_cubit.dart';

class FilterBar extends StatelessWidget {
  final TextEditingController searchController;

  const FilterBar({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state is! QuizLoaded) return const SizedBox();

        final hasActiveFilters =
            state.selectedStatus != "All Status" ||
            state.selectedType != "All Types" ||
            state.selectedParticipation != "All" ||
            state.selectedDate != null;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Clear filters button with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.read<QuizCubit>().resetFilters(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
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
                const SizedBox(width: 10),

                // Status dropdown
                _buildChipDropdown(
                  context,
                  icon: Icons.circle,
                  hint: "Status",
                  items: const ["All Status", "Active", "Closed"],
                  selected: state.selectedStatus ?? "All Status",
                  onChanged: (val) =>
                      context.read<QuizCubit>().setFilter(status: val),
                ),
                const SizedBox(width: 10),

                // Type dropdown
                _buildChipDropdown(
                  context,
                  icon: Icons.category_rounded,
                  hint: "Type",
                  items: const ["All Types", "Survey", "Quiz"],
                  selected: state.selectedType ?? "All Types",
                  onChanged: (val) =>
                      context.read<QuizCubit>().setFilter(type: val),
                ),
                const SizedBox(width: 10),

                // Sort dropdown
                _buildChipDropdown(
                  context,
                  icon: Icons.sort_rounded,
                  hint: "Sort",
                  items: const ["Sort by", "Latest", "Oldest"],
                  selected: state.selectedSort ?? "Latest",
                  onChanged: (val) =>
                      context.read<QuizCubit>().setFilter(sort: val),
                ),
                const SizedBox(width: 10),

                // Participation dropdown
                _buildChipDropdown(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  hint: "Participation",
                  items: const ["All", "Participated", "Not Participated"],
                  selected: state.selectedParticipation ?? "All",
                  onChanged: (val) =>
                      context.read<QuizCubit>().setFilter(participation: val),
                ),
                const SizedBox(width: 10),

                // Date picker
                _buildDatePicker(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChipDropdown(
    BuildContext context, {
    required IconData icon,
    required String hint,
    required List<String> items,
    required String selected,
    required Function(String?) onChanged,
  }) {
    final isFiltered = !selected.startsWith("All") && selected != "Sort by";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isFiltered
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.white,
        border: Border.all(
          color: isFiltered ? AppColors.primary : Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          padding: const EdgeInsets.symmetric(vertical: 6),
          isDense: true,
          value: selected,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: isFiltered ? AppColors.primary : Colors.grey.shade600,
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isFiltered ? AppColors.primary : Colors.grey.shade700,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (items.indexOf(e) == 0)
                        Icon(icon, size: 16, color: Colors.grey.shade600),
                      if (items.indexOf(e) == 0) const SizedBox(width: 6),
                      Text(
                        e,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, QuizLoaded state) {
    final hasDate = state.selectedDate != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: state.selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.grey.shade800,
                  ),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: hasDate
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            border: Border.all(
              color: hasDate ? AppColors.primary : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: hasDate ? AppColors.primary : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                state.selectedDate != null
                    ? "${state.selectedDate!.day}/${state.selectedDate!.month}/${state.selectedDate!.year}"
                    : "Date",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: hasDate ? AppColors.primary : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
