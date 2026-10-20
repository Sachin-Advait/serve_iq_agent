import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/common/constants/app_strings.dart';
import 'package:servelq_agent/common/utils/app_screen_util.dart';
import 'package:servelq_agent/common/widgets/app_logo.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/common/widgets/primary_button.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/lang/localization_cubit.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/models/counter_option.dart';
import 'package:servelq_agent/modules/login/bloc/login_bloc.dart';
import 'package:servelq_agent/routes/pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    context.read<LoginBloc>().add(const LoadCounters());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return flutterToast(
        message: context.trNoListen(AppStrings.emailPasswordRequired),
      );
    }
    context.read<LoginBloc>().add(
      AgentLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage || prev.user != curr.user,
      listener: (context, state) {
        if (state.errorMessage != null) {
          flutterToast(message: state.errorMessage!);
        }
        if (state.user != null) context.goNamed(Routes.home);
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.bg),
              fit: BoxFit.cover,
              matchTextDirection: true,
            ),
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 600.widthMultiplier,
                maxHeight: 650.heightMultiplier,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 40.widthMultiplier,
                vertical: 40.heightMultiplier,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24.radiusMultipier),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 25,
                    offset: Offset(0, 10.heightMultiplier),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _LanguagePicker(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [AppLogo(height: 60.heightMultiplier)],
                  ),
                  40.verticalSpace,
                  BlocBuilder<LoginBloc, LoginState>(
                    buildWhen: (prev, curr) =>
                        prev.counters != curr.counters ||
                        prev.loadingCounters != curr.loadingCounters ||
                        prev.selectedCounterId != curr.selectedCounterId ||
                        prev.submitting != curr.submitting,
                    builder: (context, state) {
                      if (state.loadingCounters) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.heightMultiplier,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      if (state.counters.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.widthMultiplier,
                            vertical: 18.heightMultiplier,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(
                              14.radiusMultipier,
                            ),
                            border: Border.all(color: AppColors.lightBeige),
                          ),
                          child: TextButton.icon(
                            onPressed: () => context.read<LoginBloc>().add(
                              const LoadCounters(),
                            ),
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              context.tr(AppStrings.noCountersRetry),
                              style: TextStyle(
                                color: AppColors.brownDarker,
                                fontSize: 16.textMultiplier,
                              ),
                            ),
                          ),
                        );
                      }

                      return DropdownButtonFormField<CounterOption>(
                        initialValue: state.selectedCounter,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.taupe,
                        ),
                        dropdownColor: AppColors.white,
                        // This style replaces the theme's for the menu items,
                        // so name the font or they fall back to Roboto.
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.almostBlack,
                          fontSize: 18.textMultiplier,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.widthMultiplier,
                            ),
                            child: Icon(
                              Icons.desktop_windows_outlined,
                              color: AppColors.primary,
                              size: 28.widthMultiplier,
                            ),
                          ),
                          labelText: context.tr(AppStrings.counter),
                          labelStyle: TextStyle(
                            color: AppColors.brownDarker,
                            fontSize: 18.textMultiplier,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.widthMultiplier,
                            vertical: 24.heightMultiplier,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(
                              14.radiusMultipier,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.offWhite,
                            ),
                            borderRadius: BorderRadius.circular(
                              14.radiusMultipier,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.offWhite,
                            ),
                            borderRadius: BorderRadius.circular(
                              14.radiusMultipier,
                            ),
                          ),
                        ),
                        selectedItemBuilder: (context) => state.counters
                            .map(
                              (c) => Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  c.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.almostBlack,
                                    fontSize: 18.textMultiplier,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        items: state.counters.map((c) {
                          final blocked = c.occupied;
                          // Still selectable: the agent holding it can log
                          // back in (e.g. after a failed logout); the backend
                          // rejects anyone else with who holds it.
                          return DropdownMenuItem(
                            value: c,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 6.heightMultiplier,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    blocked
                                        ? Icons.lock_outline
                                        : Icons.check_circle_outline,
                                    size: 18.widthMultiplier,
                                    color: blocked
                                        ? AppColors.warmGray
                                        : AppColors.green,
                                  ),
                                  8.horizontalSpace,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          c.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: blocked
                                                ? AppColors.warmGray
                                                : AppColors.almostBlack,
                                            fontSize: 16.textMultiplier,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (blocked)
                                          Text(
                                            '${context.tr(AppStrings.inUseBy)} ${c.occupiedByName ?? context.tr(AppStrings.anotherAgent)}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppColors.beige,
                                              fontSize: 12.textMultiplier,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: state.submitting
                            ? null
                            : (c) => c != null
                                  ? context.read<LoginBloc>().add(
                                      SelectCounter(c.id),
                                    )
                                  : null,
                        hint: Text(
                          context.tr(AppStrings.selectCounter),
                          style: TextStyle(
                            color: AppColors.warmGray,
                            fontSize: 18.textMultiplier,
                          ),
                        ),
                      );
                    },
                  ),
                  24.verticalSpace,
                  BlocBuilder<LoginBloc, LoginState>(
                    buildWhen: (prev, curr) =>
                        prev.submitting != curr.submitting,
                    builder: (context, state) => Column(
                      children: [
                        _buildTextField(
                          controller: _emailController,
                          label: context.tr(AppStrings.emailAddress),
                          icon: Icons.email_outlined,
                          enabled: !state.submitting,
                        ),
                        24.verticalSpace,
                        _buildTextField(
                          controller: _passwordController,
                          label: context.tr(AppStrings.password),
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          enabled: !state.submitting,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.warmGray,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        40.verticalSpace,
                        PrimaryButton(
                          label: context.tr(AppStrings.login),
                          color: AppColors.primary,
                          isLoading: state.submitting,
                          onPressed: _performLogin,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.widthMultiplier),
          child: Icon(icon, color: AppColors.primary, size: 28.widthMultiplier),
        ),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.brownDarker,
          fontSize: 18.textMultiplier,
        ),
        filled: true,
        fillColor: enabled ? AppColors.white : AppColors.offWhite,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.widthMultiplier,
          vertical: 24.heightMultiplier,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(14.radiusMultipier),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.offWhite),
          borderRadius: BorderRadius.circular(14.radiusMultipier),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.offWhite),
          borderRadius: BorderRadius.circular(14.radiusMultipier),
        ),
      ),
      style: TextStyle(fontSize: 18.textMultiplier),
    );
  }
}

/// English / Arabic switch on the login card; the choice is remembered.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final current = context.currentLocale.languageCode;
    return Container(
      padding: EdgeInsets.all(4.widthMultiplier),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(20.radiusMultipier),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _option(context, LocalizationCubit.arabic, 'العربية', current),
          _option(context, LocalizationCubit.english, 'English', current),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    Locale locale,
    String label,
    String current,
  ) {
    final selected = locale.languageCode == current;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.read<LocalizationCubit>().setLocale(locale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: 14.widthMultiplier,
            vertical: 6.heightMultiplier,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16.radiusMultipier),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.brownDarker,
              fontSize: 14.textMultiplier,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
