import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/counter_model.dart';
import 'package:servelq_agent/models/transfer_reason_model.dart';
import 'package:servelq_agent/modules/home/cubit/home_cubit.dart';

class TransferDialog extends StatefulWidget {
  final HomeState state;

  const TransferDialog({super.key, required this.state});

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  String? selectedCounterId;
  String? selectedReason;
  // 0: pick the counter, 1: pick the reason
  int step = 0;
  bool isTransferring = false;
  String searchQuery = '';
  late List<CounterModel> counters = widget.state.allCounter;
  late List<TransferReasonModel> reasons = widget.state.transferReasons;

  @override
  void initState() {
    super.initState();
    // The list loaded with the home screen goes stale as agents log in and
    // out, so fetch who holds which counter right now.
    context.read<HomeCubit>().refreshAllCounters().then((fresh) {
      if (mounted && fresh != null) setState(() => counters = fresh);
    });
    // The admin may have changed the reasons since the home screen loaded.
    context.read<HomeCubit>().refreshTransferReasons().then((fresh) {
      if (mounted && fresh != null) setState(() => reasons = fresh);
    });
  }

  // Only counters an agent is logged into can take a transfer; also exclude
  // the current counter and apply the search.
  List<CounterModel> get filteredCounters {
    return counters
        .where(
          (counter) =>
              counter.id != widget.state.counter?.id &&
              (counter.userId?.isNotEmpty ?? false) &&
              (counter.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  counter.code.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  )),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.offWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            // _buildSearchBar(),
            _buildStepTitle(),
            Flexible(
              child: step == 0 ? _buildCounterList() : _buildReasonList(),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(AppStrings.transferTitle),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.tr(AppStrings.transferTokenLabel)}: '
                  '${widget.state.currentToken?.token ?? context.tr(AppStrings.notAvailable)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          context.tr(
            step == 0
                ? AppStrings.transferSelectCounter
                : AppStrings.transferSelectReason,
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.brownDeep,
          ),
        ),
      ),
    );
  }

  // The admin's list, or the original codes if it couldn't be loaded.
  List<String> get reasonCodes => reasons.isNotEmpty
      ? reasons.map((reason) => reason.code).toList()
      : AppStrings.transferReasons;

  Widget _buildReasonList() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: reasonCodes.map((code) {
        final isSelected = selectedReason == code;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.beige,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.brownDeep : AppColors.beige,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            value: code,
            groupValue: selectedReason,
            onChanged: (value) => setState(() => selectedReason = value),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              transferReasonTitle(context, code, reasons),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.almostBlack,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCounterList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredCounters.length,
      itemBuilder: (context, index) {
        final counter = filteredCounters[index];
        final isSelected = selectedCounterId == counter.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCounterId = counter.id;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10, top: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.brownDeep : AppColors.beige,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      counter.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                        '${counterDisplayName(context, counter.name)} - ${counter.username ?? context.tr('no_agent_on_counter')}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: counter.username == null
                              ? AppColors.almostBlack.withValues(alpha: .6)
                              : AppColors.almostBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.brownDark, width: 2),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isTransferring
                  ? null
                  : step == 0
                  ? () => Navigator.of(context).pop()
                  : () => setState(() => step = 0),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: const BorderSide(color: AppColors.warmGray),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                context.tr(
                  step == 0
                      ? AppStrings.transferCancel
                      : AppStrings.transferBack,
                ),
                style: TextStyle(
                  color: AppColors.brownDeep,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isTransferring
                  ? null
                  : step == 0
                  ? (selectedCounterId != null
                        ? () => setState(() => step = 1)
                        : null)
                  : (selectedReason != null
                        ? () => _handleTransfer(context)
                        : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brownDark,
                disabledBackgroundColor: AppColors.beige,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: isTransferring
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : step == 0
                  ? Text(
                      context.tr(AppStrings.transferNext),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppImages.transferred,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          context.tr(AppStrings.transferConfirm),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTransfer(BuildContext context) async {
    if (selectedCounterId == null || selectedReason == null) return;

    setState(() {
      isTransferring = true;
    });

    try {
      // Call your transfer method from the cubit
      await context.read<HomeCubit>().transferToken(
        selectedCounterId!,
        selectedReason!,
      );

      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          isTransferring = false;
        });
        if (context.mounted) {
          flutterToast(message: '${context.tr(AppStrings.transferFailed)}: $e');
        }
      }
    }
  }
}
