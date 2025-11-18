import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:servelq_agent/configs/app_colors.dart';
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
          image: DecorationImage(
            image: AssetImage('assets/images/Monitor_BG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              _buildTopBar(context, tvState, isRTL),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(35, 25, 35, 35),
                  child: Column(
                    children: [
                      if (tvState is TVDisplayLoaded &&
                          tvState.latestCalls.isNotEmpty)
                        _buildLatestCalls(tvState.latestCalls, isRTL),
                      const SizedBox(height: 30),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _buildNowServingTable(tvState, isRTL),
                            ),
                            const SizedBox(width: 40),
                            SizedBox(
                              width: 320,
                              child: _buildQueueSummary(tvState, isRTL),
                            ),
                          ],
                        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            "assets/images/logo.png",
            height: 80,
            color: AppColors.white,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                intl.DateFormat('HH:mm').format(_currentTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getFormattedDate(_currentTime, isRTL),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date, bool isRTL) {
    if (isRTL) {
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
    return SizedBox(
      height: 200,
      child: Row(
        children: calls.take(4).map((call) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      context.tr('now_calling'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              call.token,
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              call.counter,
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNowServingTable(TVDisplayState tvState, bool isRTL) {
    List<DisplayToken> nowServing = [];

    if (tvState is TVDisplayLoaded) {
      nowServing = tvState.nowServing;
    }

    // Split into two columns
    final leftColumn = nowServing.take((nowServing.length / 2).ceil()).toList();
    final rightColumn = nowServing.skip(leftColumn.length).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              context.tr('now_serving'),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: _buildServingColumn(leftColumn)),
                  Container(
                    width: 1.2,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  Expanded(child: _buildServingColumn(rightColumn)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingColumn(List<DisplayToken> tokens) {
    return ListView.builder(
      itemCount: tokens.length,
      itemBuilder: (context, index) {
        final token = tokens[index];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
              child: Row(
                children: [
                  Text(
                    token.token,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    token.counter,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (index != tokens.length - 1)
              Divider(
                thickness: 1.2,
                color: AppColors.primary.withOpacity(0.3),
                indent: 30,
                endIndent: 30,
              ),
          ],
        );
      },
    );
  }

  Widget _buildQueueSummary(TVDisplayState tvState, bool isRTL) {
    List<String> upcomingTokens = [];

    if (tvState is TVDisplayLoaded) {
      upcomingTokens = tvState.upcomingTokens;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              context.tr('upcoming_tokens'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (upcomingTokens.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  context.tr('no_upcoming_tokens'),
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: upcomingTokens.length,
                itemBuilder: (context, index) {
                  final token = upcomingTokens[index];

                  return Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          token,
                          style: TextStyle(
                            fontSize: 26,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (index != upcomingTokens.length - 1)
                        Divider(
                          thickness: 1.2,
                          endIndent: 30,
                          indent: 30,
                          color: AppColors.secondary.withOpacity(0.6),
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
