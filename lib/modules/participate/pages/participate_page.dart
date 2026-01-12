import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:servelq_agent/common/utils/app_screen_util.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/quiz_details_model.dart';
import 'package:servelq_agent/modules/home/pages/components/header.dart';
import 'package:servelq_agent/modules/participate/components/custom_text_field.dart';
import 'package:servelq_agent/modules/participate/components/submitted_view.dart';
import 'package:servelq_agent/modules/participate/cubit/participate_cubit.dart';

class ParticipatePage extends StatefulWidget {
  const ParticipatePage({
    super.key,
    required this.quizId,
    required this.isMandatory,
  });

  final String quizId;
  final bool isMandatory;

  @override
  State<ParticipatePage> createState() => _ParticipatePageState();
}

class _ParticipatePageState extends State<ParticipatePage> {
  // Map to store text controllers for each text/comment question
  final Map<String, TextEditingController> _textControllers = {};

  // Map to store all answers indexed by question name/id
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    context.read<ParticipateCubit>().getQuizSurveyDetails(widget.quizId);
    super.initState();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String questionName) {
    if (!_textControllers.containsKey(questionName)) {
      _textControllers[questionName] = TextEditingController();
    }
    return _textControllers[questionName]!;
  }

  void _updateAnswer(String questionName, dynamic value) {
    setState(() {
      _answers[questionName] = value;
    });
  }

  bool _isQuestionAnswered(String questionName) {
    return _answers.containsKey(questionName) && _answers[questionName] != null;
  }

  int _getAnsweredCount(List<QuestionElement> questions) {
    return questions.where((q) => _isQuestionAnswered(q.name)).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.bg01Png),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Header(),
            Expanded(
              child: BlocConsumer<ParticipateCubit, ParticipateState>(
                listener: (context, state) {
                  if (state is ParticipateValidationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ParticipateInProgress) {
                    return _buildQuizListView(state);
                  }
                  if (state is ParticipateSubmitted) {
                    return SubmittedView(
                      submitQuizDetails: state.submitQuizDetails,
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizListView(ParticipateInProgress state) {
    final questions = state.quizDetails!.definitionJson.pages[0].elements;
    final total = questions.length;
    final answeredCount = _getAnsweredCount(questions);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  50.verticalSpace,
                  // Quiz Header
                  _buildQuizHeader(state, total, answeredCount),
                  const SizedBox(height: 32),

                  // Questions List
                  ...List.generate(questions.length, (index) {
                    final question = questions[index];
                    return _buildQuestionCard(question, index + 1, state);
                  }),

                  const SizedBox(height: 32),

                  // Complete Button
                  _buildCompleteButton(state, questions),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 320,
          margin: EdgeInsets.only(top: 50.heightMultiplier),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: _buildProgressSidebar(state, questions, answeredCount),
        ),
        40.horizontalSpace,
      ],
    );
  }

  Widget _buildQuizHeader(
    ParticipateInProgress state,
    int total,
    int answeredCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.quizDetails!.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownVeryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${state.quizDetails!.type} • $total Questions",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.taupe,
                      ),
                    ),
                  ],
                ),
              ),
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: AppColors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${(state.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(state.timeLeft % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: AppColors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: answeredCount / total,
              color: AppColors.primary,
              backgroundColor: AppColors.beige.withOpacity(0.3),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$answeredCount of $total questions answered",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.taupe,
                ),
              ),
              Text(
                "${((answeredCount / total) * 100).toStringAsFixed(0)}% Complete",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    QuestionElement question,
    int questionNumber,
    ParticipateInProgress state,
  ) {
    final isAnswered = _isQuestionAnswered(question.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAnswered
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.beige.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Q$questionNumber",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question.title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownVeryDark,
                    height: 1.5,
                  ),
                ),
              ),
              if (isAnswered)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.green,
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Answer Widget
          _buildAnswerWidget(question, state),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(
    QuestionElement question,
    ParticipateInProgress state,
  ) {
    final qType = question.type;

    if ((qType == "radiogroup" || qType == "dropdown") &&
        question.choices != null) {
      return Column(
        children: List.generate(question.choices!.length, (i) {
          final choice = question.choices![i];
          final isSelected = _answers[question.name] == choice;

          return _WebRadioOption(
            index: i,
            choice: choice,
            isSelected: isSelected,
            onTap: () => _updateAnswer(question.name, choice),
          );
        }),
      );
    }

    if (qType == "checkbox" && question.choices != null) {
      return Column(
        children: List.generate(question.choices!.length, (i) {
          final choice = question.choices![i];
          final selectedList = _answers[question.name] as List<String>? ?? [];
          final isSelected = selectedList.contains(choice);

          return _WebCheckboxOption(
            choice: choice,
            isSelected: isSelected,
            onChanged: (val) {
              final currentList = List<String>.from(
                _answers[question.name] as List<String>? ?? [],
              );
              if (val == true) {
                currentList.add(choice);
              } else {
                currentList.remove(choice);
              }
              _updateAnswer(question.name, currentList);
            },
          );
        }),
      );
    }

    if (qType == "text" || qType == "comment") {
      final controller = _getController(question.name);
      controller.addListener(() {
        _updateAnswer(question.name, controller.text);
      });

      return Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.beige.withOpacity(0.5), width: 1),
        ),
        child: UniversalTextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          hintText: 'Type your answer here...',
          maxLines: qType == "comment" ? 6 : 1,
        ),
      );
    }

    if (qType == "rating") {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              'Rate your experience',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.brownVeryDark,
              ),
            ),
            const SizedBox(height: 20),
            RatingBar(
              initialRating: (_answers[question.name] as double?) ?? 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 48,
              itemPadding: const EdgeInsets.symmetric(horizontal: 6),
              ratingWidget: RatingWidget(
                full: const Icon(Icons.star_rounded, color: Colors.amber),
                half: const Icon(Icons.star_half_rounded, color: Colors.amber),
                empty: Icon(
                  Icons.star_outline_rounded,
                  color: Colors.amber.shade200,
                ),
              ),
              onRatingUpdate: (rating) {
                _updateAnswer(question.name, rating);
              },
            ),
          ],
        ),
      );
    }

    if (qType == "boolean") {
      return Row(
        children: ["Yes", "No"].map<Widget>((choice) {
          final bool isSurvey =
              state.quizDetails?.type.toLowerCase() == "survey";

          bool isSelected;
          if (isSurvey) {
            isSelected =
                (_answers[question.name] == true && choice == "Yes") ||
                (_answers[question.name] == false && choice == "No");
          } else {
            isSelected = _answers[question.name] == choice;
          }

          return Expanded(
            child: _WebBooleanOption(
              label: choice,
              isSelected: isSelected,
              onTap: () {
                if (isSurvey) {
                  _updateAnswer(question.name, choice == "Yes");
                } else {
                  _updateAnswer(question.name, choice);
                }
              },
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProgressSidebar(
    ParticipateInProgress state,
    List<QuestionElement> questions,
    int answeredCount,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Progress Overview",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.brownVeryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          _buildStatCard(
            icon: Icons.quiz_outlined,
            label: "Total Questions",
            value: "${questions.length}",
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.check_circle_outline,
            label: "Answered",
            value: "$answeredCount",
            color: AppColors.green,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.pending_outlined,
            label: "Remaining",
            value: "${questions.length - answeredCount}",
            color: AppColors.blue,
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // Question List
          const Text(
            "Questions",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.brownVeryDark,
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(questions.length, (index) {
            final question = questions[index];
            final isAnswered = _isQuestionAnswered(question.name);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isAnswered
                    ? AppColors.green.withOpacity(0.1)
                    : AppColors.offWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAnswered
                      ? AppColors.green.withOpacity(0.3)
                      : AppColors.beige.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isAnswered ? AppColors.green : AppColors.taupe,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brownVeryDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAnswered)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.green,
                      size: 18,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.taupe,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(
    ParticipateInProgress state,
    List<QuestionElement> questions,
  ) {
    final answeredCount = _getAnsweredCount(questions);
    final allAnswered = answeredCount == questions.length;
    final isSurvey = state.quizDetails!.type.toLowerCase() == "survey";

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Validate if survey requires all answers
          if (isSurvey && !allAnswered) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Please answer all questions before completing",
                ),
                backgroundColor: AppColors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            return;
          }

          context.read<ParticipateCubit>().submitAllAnswers(
            state.quizDetails!.id,
            _answers,
            _textControllers,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.green, AppColors.green.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isSurvey
                    ? "Complete Survey"
                    : "Complete Quiz ($answeredCount/${questions.length})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Components
class _WebRadioOption extends StatefulWidget {
  final int index;
  final String choice;
  final bool isSelected;
  final VoidCallback onTap;

  const _WebRadioOption({
    required this.index,
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_WebRadioOption> createState() => _WebRadioOptionState();
}

class _WebRadioOptionState extends State<_WebRadioOption> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.08)
                : (isHovered ? AppColors.offWhite : AppColors.white),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : (isHovered
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.beige.withOpacity(0.5)),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.taupe,
                ),
                child: Text(
                  String.fromCharCode(97 + widget.index).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.choice,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: AppColors.brownVeryDark,
                  ),
                ),
              ),
              if (widget.isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebCheckboxOption extends StatefulWidget {
  final String choice;
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;

  const _WebCheckboxOption({
    required this.choice,
    required this.isSelected,
    this.onChanged,
  });

  @override
  State<_WebCheckboxOption> createState() => _WebCheckboxOptionState();
}

class _WebCheckboxOptionState extends State<_WebCheckboxOption> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isHovered ? AppColors.offWhite : Colors.transparent,
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : AppColors.beige.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(
            widget.choice,
            style: TextStyle(
              fontSize: 16,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.brownVeryDark,
            ),
          ),
          value: widget.isSelected,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

class _WebBooleanOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WebBooleanOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_WebBooleanOption> createState() => _WebBooleanOptionState();
}

class _WebBooleanOptionState extends State<_WebBooleanOption> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  )
                : null,
            color: widget.isSelected
                ? null
                : (isHovered ? AppColors.offWhite : Colors.transparent),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : (isHovered
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.beige),
              width: 2,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: widget.isSelected
                  ? AppColors.white
                  : AppColors.brownVeryDark,
            ),
          ),
        ),
      ),
    );
  }
}
