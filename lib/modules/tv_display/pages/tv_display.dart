import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:servelq_agent/configs/lang/cubit/localization_cubit.dart';
import 'package:servelq_agent/models/display_token.dart';
import 'package:servelq_agent/modules/tv_display/cubit/tv_display_cubit.dart';
import 'package:servelq_agent/services/session_manager.dart';

class TVDisplayScreen extends StatefulWidget {
  const TVDisplayScreen({super.key});

  @override
  State<TVDisplayScreen> createState() => _TVDisplayScreenState();
}

class _TVDisplayScreenState extends State<TVDisplayScreen> {
  late Timer _timer;
  late Timer _dataRefreshTimer;
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

    // Initialize data refresh timer (every 10 seconds)
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _refreshData();
    });

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalizationCubit>().initialize();
      _refreshData();
    });
  }

  void _refreshData() {
    final branchId = SessionManager.getBranch();
    context.read<TVDisplayCubit>().loadDisplayData(branchId);
  }

  @override
  void dispose() {
    _timer.cancel();
    _dataRefreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TVDisplayCubit, TVDisplayState>(
      listener: (context, state) {
        // Handle errors silently or show subtle notification
      },
      child: BlocBuilder<TVDisplayCubit, TVDisplayState>(
        builder: (context, tvState) {
          return BlocBuilder<LocalizationCubit, LocalizationState>(
            builder: (context, localizationState) {
              return _buildScreen(context, tvState, localizationState);
            },
          );
        },
      ),
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
              _buildTopBar(context, tvState, isRTL),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      if (tvState is TVDisplayLoaded &&
                          tvState.latestCalls.isNotEmpty)
                        _buildLatestCalls(tvState.latestCalls, isRTL),
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

  Widget _buildTopBar(
    BuildContext context,
    TVDisplayState tvState,
    bool isRTL,
  ) {
    String branchName = 'Branch Muscat';

    if (tvState is TVDisplayLoaded && tvState.branchName != null) {
      branchName = tvState.branchName!;
    }

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
                branchName,
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
      children: calls.take(4).map((call) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(16), // Reduced from 20
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                16,
              ), // Slightly smaller radius
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
                    fontSize: 16, // Reduced from 20
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8), // Reduced from 12
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          context.tr('token'),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12, // Reduced from 14
                          ),
                        ),
                        Text(
                          call.token,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 32, // Reduced from 42
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20), // Reduced from 30
                    Icon(
                      isRTL ? Icons.arrow_back : Icons.arrow_forward,
                      color: Colors.teal,
                      size: 28, // Reduced from 36
                    ),
                    const SizedBox(width: 20), // Reduced from 30
                    Column(
                      children: [
                        Text(
                          context.tr('counter'),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12, // Reduced from 14
                          ),
                        ),
                        Text(
                          call.counter,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 32, // Reduced from 42
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced from 8
                Text(
                  call.service,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14, // Reduced from 16
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // Reduced from 8
                Text(
                  _formatCalledAt(call.calledAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11, // Reduced from 12
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatCalledAt(DateTime calledAt) {
    final now = DateTime.now();
    final difference = now.difference(calledAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else {
      return intl.DateFormat('HH:mm').format(calledAt);
    }
  }

  Widget _buildNowServingTable(TVDisplayState tvState, bool isRTL) {
    List<DisplayToken> nowServing = [];

    if (tvState is TVDisplayLoaded) {
      nowServing = tvState.nowServing;
    }

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
          if (nowServing.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                context.tr('no_active_services'),
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          else
            Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1.5,
                borderRadius: BorderRadius.circular(10),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
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
                ...nowServing.asMap().entries.map((entry) {
                  final index = entry.key;
                  final token = entry.value;
                  return TableRow(
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.grey.shade50 : Colors.white,
                    ),
                    children: [
                      _buildTableCell(
                        token.counter,
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

  Widget _buildQueueSummary(TVDisplayState tvState, bool isRTL) {
    List<String> upcomingTokens = [];

    if (tvState is TVDisplayLoaded) {
      upcomingTokens = tvState.upcomingTokens;
    }

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
          if (upcomingTokens.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                context.tr('no_upcoming_tokens'),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            ...upcomingTokens.take(5).map((token) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  token,
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
