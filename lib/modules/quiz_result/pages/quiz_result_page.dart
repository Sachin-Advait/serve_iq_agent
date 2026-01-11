import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/quiz_result_model.dart';
import 'package:servelq_agent/models/top_scorers_model.dart';
import 'package:servelq_agent/modules/quiz_result/bloc/quiz_result_bloc.dart';
import 'package:servelq_agent/services/session_manager.dart';

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key, required this.quizId, required this.title});

  final String quizId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 1200;
    final isMediumScreen = size.width > 800 && size.width <= 1200;

    return BlocProvider(
      create: (_) => QuizResultBloc()
        ..add(
          LoadQuizResults(quizId: quizId, userId: SessionManager.getUserId()),
        ),
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.brownVeryDark,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.beige.withValues(alpha: 0.3),
            ),
          ),
        ),
        body: BlocBuilder<QuizResultBloc, QuizResultState>(
          builder: (context, state) {
            if (state is QuizResultsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is QuizResultsLoaded) {
              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isWideScreen ? 1400 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isWideScreen ? 48 : (isMediumScreen ? 32 : 20),
                    ),
                    child: Column(
                      children: [
                        // Two Column Layout for Wide Screens
                        if (isWideScreen || isMediumScreen)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column - Leaderboard
                              Expanded(
                                flex: 2,
                                child: _buildLeaderboardSection(
                                  state.leaderboard,
                                  isWideScreen,
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Right Column - User Result
                              Expanded(
                                flex: 1,
                                child: _buildUserResultCard(
                                  state.result,
                                  isWideScreen,
                                ),
                              ),
                            ],
                          )
                        else
                          // Mobile Layout - Stacked
                          Column(
                            children: [
                              _buildUserResultCard(state.result, false),
                              const SizedBox(height: 24),
                              _buildLeaderboardSection(
                                state.leaderboard,
                                false,
                              ),
                            ],
                          ),
                        const SizedBox(height: 32),
                        // Questions Section
                        _buildQuestionsSection(state.result, isWideScreen),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (state is QuizResultsError) {
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
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(
    TopScorersDetails leaderboard,
    bool isWideScreen,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Top Scorers',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownVeryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(
            leaderboard.topScorers!.length,
            (index) => _LeaderboardCard(
              entry: leaderboard.topScorers![index],
              rank: index + 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserResultCard(QuizResultDetails result, bool isWideScreen) {
    final percentage = (result.score / result.maxScore * 100).toStringAsFixed(
      1,
    );

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.05), AppColors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Avatar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),

          // Username
          const Text(
            'Your Result',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.taupe,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            result.username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.brownVeryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Score Stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.quiz_outlined,
                  label: 'Score',
                  value: '${result.score}/${result.maxScore}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.percent_outlined,
                  label: 'Percentage',
                  value: '$percentage%',
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownVeryDark,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: result.score / result.maxScore,
                  minHeight: 12,
                  backgroundColor: AppColors.beige.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Timestamp
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: AppColors.taupe,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Submitted: ${_formatDateTime(result.submittedAt)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brownDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection(QuizResultDetails result, bool isWideScreen) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.format_list_numbered_rounded,
                  color: AppColors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Detailed Answers',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownVeryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...result.answers.entries.map(
            (entry) => _QuestionCard(
              question: entry.key,
              answer: entry.value,
              result: result,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Custom Widgets
class _LeaderboardCard extends StatefulWidget {
  final TopScorer entry;
  final int rank;

  const _LeaderboardCard({required this.entry, required this.rank});

  @override
  State<_LeaderboardCard> createState() => _LeaderboardCardState();
}

class _LeaderboardCardState extends State<_LeaderboardCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    IconData medalIcon;

    switch (widget.rank) {
      case 1:
        rankColor = const Color(0xFFFFD700); // Gold
        medalIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = const Color(0xFFC0C0C0); // Silver
        medalIcon = Icons.emoji_events_outlined;
        break;
      case 3:
        rankColor = const Color(0xFFCD7F32); // Bronze
        medalIcon = Icons.emoji_events_outlined;
        break;
      default:
        rankColor = AppColors.taupe;
        medalIcon = Icons.military_tech_outlined;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isHovered
              ? AppColors.primary.withValues(alpha: 0.03)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.rank <= 3
                ? rankColor.withValues(alpha: 0.3)
                : AppColors.beige,
            width: 2,
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rankColor, rankColor.withValues(alpha: 0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(medalIcon, color: AppColors.white, size: 32),
                  Positioned(
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.rank}',
                        style: TextStyle(
                          color: rankColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.username!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownVeryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.quiz,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Score: ${widget.entry.score} / ${widget.entry.maxScore}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.taupe,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final QuizAnswer answer;
  final QuizResultDetails result;

  const _QuestionCard({
    required this.question,
    required this.answer,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final questionNumber = result.answers.keys.toList().indexOf(question) + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.beige.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'Q$questionNumber',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownVeryDark,
                          height: 1.4,
                        ),
                      ),
                      if (answer.arabicTitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          answer.arabicTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brownDark,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Choices
          if (answer.choices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: answer.choices.asMap().entries.map((entry) {
                  return _ChoiceItem(
                    choice: entry.value,
                    answer: answer,
                    index: entry.key,
                  );
                }).toList(),
              ),
            ),

          // Answer Summary
          _AnswerSummary(answer: answer),
        ],
      ),
    );
  }
}

class _ChoiceItem extends StatelessWidget {
  final QuizChoice choice;
  final QuizAnswer answer;
  final int index;

  const _ChoiceItem({
    required this.choice,
    required this.answer,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> selectedList = _normalizeSelectedOptions(
      answer.selectedOptions,
    );

    final isSelected = selectedList.contains(choice.text);
    final isCorrect = choice.isSelect;

    Color backgroundColor;
    Color borderColor;
    Widget icon;

    if (isSelected && isCorrect) {
      backgroundColor = AppColors.green.withValues(alpha: 0.1);
      borderColor = AppColors.green;
      icon = const Icon(Icons.check_circle, color: AppColors.green, size: 24);
    } else if (isSelected && !isCorrect) {
      backgroundColor = AppColors.red.withValues(alpha: 0.1);
      borderColor = AppColors.red;
      icon = const Icon(Icons.cancel, color: AppColors.red, size: 24);
    } else if (!isSelected && isCorrect) {
      backgroundColor = AppColors.green.withValues(alpha: 0.05);
      borderColor = AppColors.green.withValues(alpha: 0.5);
      icon = const Icon(
        Icons.check_circle_outline,
        color: AppColors.green,
        size: 24,
      );
    } else {
      backgroundColor = AppColors.white;
      borderColor = AppColors.beige;
      icon = const SizedBox.shrink();
    }

    String optionLabel = String.fromCharCode(97 + index);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              optionLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: borderColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              choice.text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.brownVeryDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          icon,
        ],
      ),
    );
  }

  List<String> _normalizeSelectedOptions(dynamic selectedOptions) {
    if (selectedOptions == null) return [];
    if (selectedOptions is List) {
      return List<String>.from(selectedOptions.map((e) => e.toString()));
    }
    return [selectedOptions.toString()];
  }
}

class _AnswerSummary extends StatelessWidget {
  final QuizAnswer answer;

  const _AnswerSummary({required this.answer});

  @override
  Widget build(BuildContext context) {
    final List<String> selectedAnswers = _normalizeSelectedOptions(
      answer.selectedOptions,
    );

    final List<String> correctAnswers = answer.type == 'text'
        ? [answer.correctAnswer ?? '']
        : answer.choices
              .where((choice) => choice.isSelect)
              .map((c) => c.text)
              .toList();

    final bool isCorrect =
        selectedAnswers.toSet().containsAll(correctAnswers) &&
        correctAnswers.toSet().containsAll(selectedAnswers);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isCorrect
                ? AppColors.green.withValues(alpha: 0.08)
                : AppColors.red.withValues(alpha: 0.08),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? AppColors.green : AppColors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? 'Correct!' : 'Incorrect',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isCorrect ? AppColors.green : AppColors.red,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.green.withValues(alpha: 0.15)
                      : AppColors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Score: ${isCorrect ? 1 : 0} / 1',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCorrect ? AppColors.green : AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            icon: Icons.person_outline,
            label: 'Your Answer',
            value: selectedAnswers.isEmpty
                ? 'No answer'
                : selectedAnswers.join(', '),
            color: AppColors.blue,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.check_circle_outline,
            label: 'Correct Answer',
            value: correctAnswers.join(', '),
            color: AppColors.green,
          ),
        ],
      ),
    );
  }

  List<String> _normalizeSelectedOptions(dynamic selectedOptions) {
    if (selectedOptions == null) return [];
    if (selectedOptions is List) {
      return List<String>.from(selectedOptions.map((e) => e.toString()));
    }
    return [selectedOptions.toString()];
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 18),
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.taupe,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownVeryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
