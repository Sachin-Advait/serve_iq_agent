import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:servelq_agent/cubit/localization_cubit.dart';
import 'package:servelq_agent/models/display_token.dart';
import 'package:servelq_agent/modules/tv_display/cubit/tv_display_cubit.dart';

class TVDisplayScreen extends StatefulWidget {
  const TVDisplayScreen({super.key});

  @override
  State<TVDisplayScreen> createState() => _TVDisplayScreenState();
}

class _TVDisplayScreenState extends State<TVDisplayScreen> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize time update timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    // Initialize localization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalizationCubit>().initialize();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TVDisplayCubit, TVDisplayState>(
      builder: (context, tvState) {
        return BlocBuilder<LocalizationCubit, LocalizationState>(
          builder: (context, localizationState) {
            return _buildScreen(context, tvState, localizationState);
          },
        );
      },
    );
  }

  Widget _buildScreen(
    BuildContext context,
    TVDisplayState tvState,
    LocalizationState localizationState,
  ) {
    final isRTL = context.currentLocale.languageCode == 'ar';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.teal.shade50],
          ),
        ),
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              _buildTopBar(context, isRTL),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      if (tvState.latestCall.isNotEmpty)
                        _buildLatestCalls(tvState.latestCall, isRTL),
                      const SizedBox(height: 32),
                      // Row with table on left, upcoming on right
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildNowServingTable(tvState, isRTL),
                          ),
                          const SizedBox(width: 32),
                          _buildQueueSummary(tvState, isRTL),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isRTL) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(width: 16),
              Text(
                context.tr('branch_muscat'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: isRTL
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(
                intl.DateFormat('HH:mm').format(_currentTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getFormattedDate(_currentTime, isRTL),
                style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date, bool isRTL) {
    if (isRTL) {
      // Arabic date format
      final arabicMonths = {
        'January': 'يناير',
        'February': 'فبراير',
        'March': 'مارس',
        'April': 'أبريل',
        'May': 'مايو',
        'June': 'يونيو',
        'July': 'يوليو',
        'August': 'أغسطس',
        'September': 'سبتمبر',
        'October': 'أكتوبر',
        'November': 'نوفمبر',
        'December': 'ديسمبر',
      };

      final arabicDays = {
        'Monday': 'الاثنين',
        'Tuesday': 'الثلاثاء',
        'Wednesday': 'الأربعاء',
        'Thursday': 'الخميس',
        'Friday': 'الجمعة',
        'Saturday': 'السبت',
        'Sunday': 'الأحد',
      };

      final englishDay = intl.DateFormat('EEEE').format(date);
      final englishMonth = intl.DateFormat('MMMM').format(date);

      return '${arabicDays[englishDay] ?? englishDay}، ${date.day} ${arabicMonths[englishMonth] ?? englishMonth}، ${date.year}';
    } else {
      return intl.DateFormat('EEEE, MMMM d, y').format(date);
    }
  }

  Widget _buildLatestCalls(List<DisplayToken> calls, bool isRTL) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: calls.take(2).map((call) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr('now_calling'),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          context.tr('token'),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          call.token,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 30),
                    Icon(
                      isRTL ? Icons.arrow_back : Icons.arrow_forward,
                      color: Colors.teal,
                      size: 36,
                    ),
                    const SizedBox(width: 30),
                    Column(
                      children: [
                        Text(
                          context.tr('counter'),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          call.counter,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  call.service,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNowServingTable(TVDisplayState appState, bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          Text(
            context.tr('now_serving'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1.5,
              borderRadius: BorderRadius.circular(10),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(2),
            },
            children: [
              // Header row
              TableRow(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                  ),
                ),
                children: [
                  _buildTableHeader(context.tr('counter'), isRTL),
                  _buildTableHeader(context.tr('token'), isRTL),
                  _buildTableHeader(context.tr('service'), isRTL),
                ],
              ),
              ...appState.displayedTokens.asMap().entries.map((entry) {
                final index = entry.key;
                final token = entry.value;
                return TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.grey.shade50 : Colors.white,
                  ),
                  children: [
                    _buildTableCell(
                      '#${token.counter}',
                      isCounter: true,
                      isRTL: isRTL,
                    ),
                    _buildTableCell(token.token, isBold: true, isRTL: isRTL),
                    _buildTableCell(token.service, isRTL: isRTL),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, bool isRTL) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        textAlign: isRTL ? TextAlign.right : TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isCounter = false,
    bool isBold = false,
    required bool isRTL,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        text,
        textAlign: isRTL ? TextAlign.right : TextAlign.center,
        style: TextStyle(
          fontSize: isCounter || isBold ? 25 : 20,
          fontWeight: isCounter || isBold ? FontWeight.bold : FontWeight.w600,
          color: isCounter ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildQueueSummary(TVDisplayState appState, bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 12),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('upcoming_tokens'),
                textAlign: isRTL ? TextAlign.right : TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...appState.queue.take(5).map((t) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                t.id,
                textAlign: isRTL ? TextAlign.right : TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
