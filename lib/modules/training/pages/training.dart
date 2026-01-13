import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/training_model.dart';
import 'package:servelq_agent/modules/home/pages/components/header.dart';
import 'package:servelq_agent/modules/training/components/document_learning.dart';
import 'package:servelq_agent/modules/training/components/filter_chip.dart';
import 'package:servelq_agent/modules/training/components/material_card.dart';
import 'package:servelq_agent/modules/training/components/video_learning.dart';
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
    if (material.type!.toLowerCase() == "video") {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => BlocProvider.value(
          value: context.read<TrainingCubit>(),
          child: VideoLearningDialog(material: material),
        ),
      );
    } else if (material.type!.toLowerCase() == "document") {
      context.read<TrainingCubit>().updateTrainingProgess(
        material.trainingId!,
        100,
      );
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DocumentLearning(material: material)),
      );
    }

    if (context.mounted) {
      context.read<TrainingCubit>().loadTrainings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.bg01Png),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            /// 🔝 Header
            const Header(),

            /// 🎛 Filter section (web fixed layout)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
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

            /// 📦 Content
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
                      return _NoTrainingView();
                    }

                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: GridView.builder(
                          padding: const EdgeInsets.only(top: 16, bottom: 48),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 1.54,
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
                        ),
                      ),
                    );
                  }

                  if (state is TrainingError) {
                    return _TrainingErrorView(message: state.message);
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

class _NoTrainingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _TrainingErrorView extends StatelessWidget {
  final String message;

  const _TrainingErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
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
            message,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
