import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/training_model.dart';
import 'package:servelq_agent/modules/home/pages/components/header.dart';
import 'package:servelq_agent/modules/training/components/filter_chip.dart';
import 'package:servelq_agent/modules/training/components/material_card.dart';
import 'package:servelq_agent/modules/training/cubit/training_cubit.dart';

class Training extends StatefulWidget {
  const Training({super.key, required this.contentId});

  final String contentId;

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  String selectedTrainingType = "all";

  @override
  void initState() {
    super.initState();
    context.read<TrainingCubit>().loadTrainings();
  }

  void _handleTrainingTypeChange(String type) {
    setState(() => selectedTrainingType = type);
    context.read<TrainingCubit>().filterByType(type);
  }

  Future<void> _handleViewMaterial(
    TrainingAssignment material,
    BuildContext context,
  ) async {
    // Navigation logic here
    if (context.mounted) context.read<TrainingCubit>().loadTrainings();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 1200;
    final isMediumScreen = size.width > 800 && size.width <= 1200;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.bg01Png),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Professional Header
            Header(),
            // Filter Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 28 : (isMediumScreen ? 32 : 16),
                vertical: 16,
              ),
              child: Row(
                children: [
                  Text(
                    'Filter by type:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brownVeryDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilterChipWidget(
                    label: 'All',
                    isSelected: selectedTrainingType == "all",
                    onTap: () => _handleTrainingTypeChange("all"),
                  ),
                  const SizedBox(width: 12),
                  FilterChipWidget(
                    label: 'Video',
                    isSelected: selectedTrainingType == "video",
                    onTap: () => _handleTrainingTypeChange("video"),
                  ),
                  const SizedBox(width: 12),
                  FilterChipWidget(
                    label: 'Document',
                    isSelected: selectedTrainingType == "document",
                    onTap: () => _handleTrainingTypeChange("document"),
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<TrainingCubit, TrainingState>(
                builder: (context, state) {
                  if (state is TrainingLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is TrainingLoaded) {
                    if (state.trainings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No training materials found',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isWideScreen ? 1400 : double.infinity,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen
                              ? 48
                              : (isMediumScreen ? 32 : 16),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 1;
                            if (isWideScreen) {
                              crossAxisCount = 3;
                            } else if (isMediumScreen) {
                              crossAxisCount = 2;
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.only(
                                bottom: 48,
                                top: 16,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: isWideScreen ? 1.1 : 1.0,
                                  ),
                              itemCount: state.trainings.length,
                              itemBuilder: (context, index) {
                                final material = state.trainings[index];
                                return MaterialCardWidget(
                                  material: material,
                                  onViewMaterial: () =>
                                      _handleViewMaterial(material, context),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }

                  if (state is TrainingError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 64,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Something went wrong',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
