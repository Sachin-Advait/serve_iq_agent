import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/token_model.dart';

/// What the agent can do with a token from the Hold list (recall, transfer,
/// no-show) or the No-Show list (recall, transfer: [onNoShow] is null).
/// Same look as the transfer dialog: brown header, light body.
class QueuedTokenActionsDialog extends StatelessWidget {
  const QueuedTokenActionsDialog({
    super.key,
    required this.token,
    required this.headerIcon,
    required this.onRecall,
    required this.onTransfer,
    this.onNoShow,
  });

  final TokenModel token;

  /// The list's own icon (hold or no-show).
  final String headerIcon;

  /// Null when the counter is busy: recall is shown disabled with the reason.
  final VoidCallback? onRecall;
  final VoidCallback onTransfer;
  final VoidCallback? onNoShow;

  @override
  Widget build(BuildContext context) {
    final lang = context.currentLocale.languageCode;
    return Dialog(
      backgroundColor: AppColors.offWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context, lang),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                children: [
                  _ActionTile(
                    icon: AppImages.recall,
                    color: AppColors.green,
                    label: context.tr(AppStrings.actionRecall),
                    hint: context.tr(
                      onRecall != null
                          ? AppStrings.queuedRecallHint
                          : AppStrings.queuedRecallBusy,
                    ),
                    onTap: _close(context, onRecall),
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: AppImages.transferred,
                    color: AppColors.red,
                    label: context.tr(AppStrings.actionTransfer),
                    hint: context.tr(AppStrings.queuedTransferHint),
                    onTap: _close(context, onTransfer),
                  ),
                  if (onNoShow != null) ...[
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: AppImages.noShow,
                      color: AppColors.brownVeryDark,
                      label: context.tr(AppStrings.actionNoShow),
                      hint: context.tr(AppStrings.queuedNoShowHint),
                      onTap: _close(context, onNoShow),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brownDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.lightBeige),
                    ),
                  ),
                  child: Text(
                    context.tr(AppStrings.transferCancel),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _close(BuildContext context, VoidCallback? action) =>
      action == null
      ? null
      : () {
          Navigator.of(context).pop();
          action();
        };

  Widget _header(BuildContext context, String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.primary,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              headerIcon,
              height: 28,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token.tokenIn(lang),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  token.serviceNameIn(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

/// One action: colored icon, name and a short line on what it does.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final String icon;
  final Color color;
  final String label;
  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final tint = enabled ? color : AppColors.beige;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? color.withValues(alpha: 0.35)
                  : AppColors.lightBeige,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  icon,
                  height: 26,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? AppColors.brownVeryDark
                            : AppColors.warmGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: TextStyle(
                        fontSize: 13,
                        color: enabled ? AppColors.taupe : AppColors.warmGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.chevron_right_rounded : Icons.lock_outline,
                color: tint,
                size: enabled ? 28 : 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
