import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/quiz_details_model.dart';
import 'package:servelq_agent/models/submit_quiz_model.dart';
import 'package:servelq_agent/modules/participate/components/custom_text_field.dart';
import 'package:servelq_agent/modules/participate/cubit/participate_cubit.dart';

class ParticipatePage extends StatefulWidget {
  const ParticipatePage({
    super.key,
    required this.quizSurveyId,
    required this.isMandatory,
  });

  final String quizSurveyId;
  final bool isMandatory;

  @override
  State<ParticipatePage> createState() => _ParticipatePageState();
}

class _ParticipatePageState extends State<ParticipatePage> {
  final answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 1200;
    final isMediumScreen = size.width > 800 && size.width <= 1200;

    return BlocProvider(
      create: (_) =>
          ParticipateCubit()..getQuizSurveyDetails(widget.quizSurveyId),
      child: PopScope(
        canPop: !widget.isMandatory,
        child: Scaffold(
          backgroundColor: AppColors.offWhite,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: BlocBuilder<ParticipateCubit, ParticipateState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () {
                    if (widget.isMandatory) return;
                    if (state is ParticipateSubmitted) {
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
            title: BlocBuilder<ParticipateCubit, ParticipateState>(
              builder: (context, state) {
                return Text(
                  state is ParticipateInProgress
                      ? state.quizDetails!.title
                      : '',
                  style: const TextStyle(
                    color: AppColors.brownVeryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                );
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: AppColors.beige.withOpacity(0.3),
              ),
            ),
          ),
          body: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isWideScreen
                    ? 1000
                    : (isMediumScreen ? 800 : double.infinity),
              ),
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
                    return _buildQuestionView(
                      state,
                      isWideScreen,
                      isMediumScreen,
                    );
                  }
                  if (state is ParticipateSubmitted) {
                    return _buildSubmittedView(
                      state.submitQuizDetails,
                      context,
                      isWideScreen,
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView(
    ParticipateInProgress state,
    bool isWideScreen,
    bool isMediumScreen,
  ) {
    final questions = state.quizDetails!.definitionJson.pages[0].elements;
    final currentQ = questions[state.currentIndex];
    final total = questions.length;
    final qType = currentQ.type;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWideScreen ? 48 : (isMediumScreen ? 32 : 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Progress
          Container(
            padding: const EdgeInsets.all(28),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Question Counter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Question Progress",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.taupe,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "${state.currentIndex + 1}",
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  height: 1,
                                ),
                              ),
                              Text(
                                " / $total",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.taupe,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
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
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${(state.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(state.timeLeft % 60).toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
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
                    value: (state.currentIndex + 1) / total,
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
                      "Question ${state.currentIndex + 1} of $total",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.taupe,
                      ),
                    ),
                    Text(
                      "${((state.currentIndex + 1) / total * 100).toStringAsFixed(0)}% Complete",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.12),
                  AppColors.primary.withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Text(
              currentQ.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.brownVeryDark,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Answer Options
          _buildAnswerWidget(qType, currentQ, state),

          const SizedBox(height: 40),

          // Navigation Buttons
          _buildNavigationButtons(state, questions, total),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(
    String qType,
    dynamic currentQ,
    ParticipateInProgress state,
  ) {
    if ((qType == "radiogroup" || qType == "dropdown") &&
        currentQ.choices != null) {
      return Column(
        children: List.generate(currentQ.choices!.length, (i) {
          final choice = currentQ.choices![i];
          final isSelected = state.selectedAnswer == choice;

          return _WebRadioOption(
            index: i,
            choice: choice,
            isSelected: isSelected,
            onTap: () => context.read<ParticipateCubit>().selectAnswer(choice),
          );
        }),
      );
    }

    if (qType == "checkbox" && currentQ.choices != null) {
      return Column(
        children: List.generate(currentQ.choices!.length, (i) {
          final choice = currentQ.choices![i];
          final isSelected =
              (state.selectedAnswer is List<String>) &&
              (state.selectedAnswer as List<String>).contains(choice);

          return _WebCheckboxOption(
            choice: choice,
            isSelected: isSelected,
            onChanged: (val) =>
                context.read<ParticipateCubit>().toggleAnswer(choice),
          );
        }),
      );
    }

    if (qType == "text" || qType == "comment") {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: UniversalTextField(
          controller: answerController,
          keyboardType: TextInputType.multiline,
          hintText: 'Type your answer here...',
          maxLines: 6,
        ),
      );
    }

    if (qType == "rating") {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Rate your experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.brownVeryDark,
              ),
            ),
            const SizedBox(height: 24),
            RatingBar(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 52,
              itemPadding: const EdgeInsets.symmetric(horizontal: 8),
              ratingWidget: RatingWidget(
                full: const Icon(Icons.star_rounded, color: Colors.amber),
                half: const Icon(Icons.star_half_rounded, color: Colors.amber),
                empty: Icon(
                  Icons.star_outline_rounded,
                  color: Colors.amber.shade200,
                ),
              ),
              onRatingUpdate: (rating) {
                context.read<ParticipateCubit>().selectAnswer(rating);
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
          final bool isSelected = isSurvey
              ? ((state.selectedAnswer == true && choice == "Yes") ||
                    (state.selectedAnswer == false && choice == "No"))
              : state.selectedAnswer == choice;

          return Expanded(
            child: _WebBooleanOption(
              label: choice,
              isSelected: isSelected,
              onTap: () {
                if (isSurvey) {
                  context.read<ParticipateCubit>().selectAnswer(
                    choice == "Yes",
                  );
                } else {
                  context.read<ParticipateCubit>().selectAnswer(choice);
                }
              },
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNavigationButtons(
    ParticipateInProgress state,
    List<QuestionElement> questions,
    int total,
  ) {
    return Row(
      children: [
        Expanded(
          child: _WebNavigationButton(
            label: "← Previous",
            onTap: () => context.read<ParticipateCubit>().prevQuestion(),
            isPrimary: false,
            isEnabled: state.currentIndex > 0,
          ),
        ),
        const SizedBox(width: 16),
        if (state.quizDetails!.type != "Survey")
          Expanded(
            child: _WebNavigationButton(
              label: "Skip",
              onTap: () => context.read<ParticipateCubit>().skipQuestion(
                total,
                state.quizDetails!.id,
              ),
              isPrimary: false,
              color: AppColors.blue,
            ),
          ),
        if (state.quizDetails!.type != "Survey") const SizedBox(width: 16),
        Expanded(
          child: _WebNavigationButton(
            label: "Next →",
            onTap: () {
              context.read<ParticipateCubit>().nextQuestion(
                questions,
                state.quizDetails!.id,
                textAnswer: answerController.text,
              );
              answerController.clear();
            },
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittedView(
    SubmitQuizDetails submitQuizDetails,
    BuildContext context,
    bool isWideScreen,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          padding: EdgeInsets.all(isWideScreen ? 56 : 40),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.green.withOpacity(0.2),
                      AppColors.green.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 100,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 40),

              // Score Display
              if (submitQuizDetails.maxScore != 0) ...[
                const Text(
                  "Your Final Score",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.taupe,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    "${submitQuizDetails.score} / ${submitQuizDetails.maxScore}",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Congratulation Message
              const Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownVeryDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Great job, ${submitQuizDetails.username}!",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "You have successfully completed the Quiz",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.taupe,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Back Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Web Components
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
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.08)
                : (isHovered ? AppColors.offWhite : AppColors.white),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : (isHovered
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.beige),
              width: 2,
            ),
            boxShadow: widget.isSelected || isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: widget.isSelected ? null : AppColors.brownDark,
                ),
                child: Text(
                  String.fromCharCode(97 + widget.index).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  widget.choice,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: AppColors.brownVeryDark,
                    height: 1.4,
                  ),
                ),
              ),
              if (widget.isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 28,
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isHovered ? AppColors.offWhite : AppColors.white,
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : (isHovered
                      ? AppColors.beige
                      : AppColors.beige.withOpacity(0.5)),
            width: 2,
          ),
        ),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            widget.choice,
            style: TextStyle(
              fontSize: 17,
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
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
                : (isHovered ? AppColors.offWhite : AppColors.white),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : (isHovered
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.beige),
              width: 2,
            ),
            boxShadow: widget.isSelected || isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: widget.isSelected
                  ? AppColors.white
                  : AppColors.brownVeryDark,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _WebNavigationButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isEnabled;
  final Color? color;

  const _WebNavigationButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isEnabled = true,
    this.color,
  });

  @override
  State<_WebNavigationButton> createState() => _WebNavigationButtonState();
}

class _WebNavigationButtonState extends State<_WebNavigationButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        widget.color ??
        (widget.isPrimary ? AppColors.primary : AppColors.brownDark);

    return MouseRegion(
      cursor: widget.isEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.isEnabled && (widget.isPrimary || isHovered)
                ? LinearGradient(
                    colors: [buttonColor, buttonColor.withOpacity(0.85)],
                  )
                : null,
            color: widget.isEnabled
                ? (widget.isPrimary || isHovered ? null : buttonColor)
                : AppColors.taupe.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isEnabled && (isHovered || widget.isPrimary)
                ? [
                    BoxShadow(
                      color: buttonColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isEnabled ? AppColors.white : AppColors.taupe,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
