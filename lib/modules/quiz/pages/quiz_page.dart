import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/modules/home/pages/components/error_screen.dart';
import 'package:servelq_agent/modules/home/pages/components/header.dart';
import 'package:servelq_agent/modules/home/pages/components/loading_screen.dart';
import 'package:servelq_agent/modules/quiz/components/filter_bar.dart';
import 'package:servelq_agent/modules/quiz/components/quiz_card.dart';
import 'package:servelq_agent/modules/quiz/cubit/quiz_cubit.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<QuizCubit>().getQuizzes();
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
            const Header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: FilterBar(searchController: searchController),
            ),
            Expanded(
              child: BlocBuilder<QuizCubit, QuizState>(
                builder: (context, state) {
                  if (state is QuizLoading) {
                    return const LoadingScreen(title: "Loading Quizzes");
                  }

                  if (state is QuizError) {
                    return ErrorScreen(
                      message: "An error occurred",
                      onRetry: () => context.read<QuizCubit>().getQuizzes(),
                    );
                  }

                  if (state is QuizLoaded) {
                    if (state.filtered.isEmpty) {
                      return _NoResultsView();
                    }

                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: GridView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 48),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 1.35,
                              ),
                          itemCount: state.filtered.length,
                          itemBuilder: (context, index) {
                            return QuizSurveryCard(quiz: state.filtered[index]);
                          },
                        ),
                      ),
                    );
                  }

                  return const LoadingScreen(title: "Loading Quizzes");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
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
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
