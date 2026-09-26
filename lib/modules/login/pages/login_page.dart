import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/common/utils/app_screen_util.dart';
import 'package:servelq_agent/common/widgets/flutter_toast.dart';
import 'package:servelq_agent/common/widgets/primary_button.dart';
import 'package:servelq_agent/configs/assets/app_images.dart';
import 'package:servelq_agent/configs/theme/app_colors.dart';
import 'package:servelq_agent/configs/theme/app_theme.dart';
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
    _emailController.text = 'farzan@serveiq.com';
    _passwordController.text = '12345678';
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
      flutterToast(message: 'Please fill all fields');
      return;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.logo, height: 60.heightMultiplier),
                      10.horizontalSpace,
                      Text(
                        "MSSPF",
                        style: context.semiBold.copyWith(
                          color: AppColors.almostBlack,
                          fontSize: 30.textMultiplier,
                        ),
                      ),
                    ],
                  ),
                  50.verticalSpace,
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
                              'No counters — tap to retry',
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
                        style: TextStyle(
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
                          labelText: 'Counter',
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
                                alignment: Alignment.centerLeft,
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
                          return DropdownMenuItem(
                            value: c,
                            enabled: !blocked,
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
                                            'In use by ${c.occupiedByName ?? 'another agent'}',
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
                          'Select a counter',
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
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          enabled: !state.submitting,
                        ),
                        24.verticalSpace,
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
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
                          label: 'Login',
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
