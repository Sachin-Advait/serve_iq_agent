import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/modules/quiz/components/filter_bar.dart';
import 'package:servelq_agent/modules/quiz/components/quiz_card.dart';
import 'package:servelq_agent/modules/quiz/cubit/quiz_cubit.dart';
import 'package:servelq_agent/modules/home/pages/components/error_screen.dart';
import 'package:servelq_agent/modules/home/pages/components/header.dart';
import 'package:servelq_agent/modules/home/pages/components/loading_screen.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    context.read<QuizCubit>().getQuizzes();
    super.initState();
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
            Header(),

            // Filter Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 48 : (isMediumScreen ? 32 : 16),
                vertical: 16,
              ),
              child: FilterBar(searchController: searchController),
            ),

            // Content Area
            Expanded(
              child: BlocBuilder<QuizCubit, QuizState>(
                builder: (context, state) {
                  if (state is QuizLoading) {
                    return LoadingScreen(title: "Loading Quizzes");
                  }
                  if (state is QuizError) {
                    return ErrorScreen(
                      message: 'An error occurred',
                      onRetry: () => context.read<QuizCubit>().getQuizzes(),
                    );
                  }
                  if (state is QuizLoaded) {
                    if (state.filtered.isEmpty) {
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
                                Icons.search_off_rounded,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No results found",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Try adjusting your filters or search terms",
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
                                top: 8,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: isWideScreen ? 1.3 : 1.2,
                                  ),
                              itemCount: state.filtered.length,
                              itemBuilder: (context, index) {
                                final quiz = state.filtered[index];
                                return QuizSurveryCard(quiz: quiz);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return LoadingScreen(title: "Loading Quizzes");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
