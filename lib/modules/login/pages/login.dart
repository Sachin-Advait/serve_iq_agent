import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:servelq_agent/configs/flutter_toast.dart';
import 'package:servelq_agent/modules/login/bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _agentEmail = TextEditingController();
  final _agentPassword = TextEditingController();
  final _tvEmail = TextEditingController();
  final _tvPassword = TextEditingController();
  bool _agentObscure = true;
  bool _tvObscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _agentEmail.dispose();
    _agentPassword.dispose();
    _tvEmail.dispose();
    _tvPassword.dispose();
    super.dispose();
  }

  void _handleLoginSuccess() {
    setState(() => _isLoading = false);
    // Navigation will be handled by the BLoC listener
  }

  void _handleLoginError(String message) {
    setState(() => _isLoading = false);
    flutterToast(message: message);
  }

  void _performAgentLogin() {
    if (_agentEmail.text.isEmpty || _agentPassword.text.isEmpty) {
      flutterToast(message: 'Please fill all fields');
      return;
    }
    setState(() => _isLoading = true);
    context.read<LoginBloc>().add(
      AgentLogin(email: _agentEmail.text.trim(), password: _agentPassword.text),
    );
  }

  void _performTVLogin() {
    if (_tvEmail.text.isEmpty || _tvPassword.text.isEmpty) {
      flutterToast(message: 'Please fill all fields');
      return;
    }
    setState(() => _isLoading = true);
    context.read<LoginBloc>().add(
      TVDisplayLogin(email: _tvEmail.text.trim(), password: _tvPassword.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          _handleLoginSuccess();
          // Navigate based on user type
          if (state.user.isAgent) {
            context.go('/agent');
          } else if (state.user.isDisplay) {
            context.go('/display');
          }
        } else if (state is LoginError) {
          _handleLoginError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 500),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Section
                Image.asset("assets/images/logo.png", height: 100),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    dividerHeight: 0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: const Color(0xFF4B5563),
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    padding: const EdgeInsets.all(4),
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Agent Login'),
                      Tab(text: 'TV Display Login'),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAgentLogin(context),
                      _buildTVLogin(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Agent Login Form
  Widget _buildAgentLogin(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        _buildTextField(
          controller: _agentEmail,
          label: 'Email Address',
          icon: Icons.email_outlined,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _agentPassword,
          label: 'Password',
          icon: Icons.lock_outline,
          obscureText: _agentObscure,
          enabled: !_isLoading,
          suffixIcon: IconButton(
            icon: Icon(
              _agentObscure ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF9CA3AF),
            ),
            onPressed: () => setState(() {
              _agentObscure = !_agentObscure;
            }),
          ),
        ),
        const SizedBox(height: 30),
        _buildLoginButton(
          label: 'Login as Agent',
          color: const Color(0xFF2563EB),
          isLoading: _isLoading,
          onPressed: _performAgentLogin,
        ),
      ],
    );
  }

  // TV Display Login Form
  Widget _buildTVLogin(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildTextField(
            controller: _tvEmail,
            label: 'Email Address',
            icon: Icons.email_outlined,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _tvPassword,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: _tvObscure,
            enabled: !_isLoading,
            suffixIcon: IconButton(
              icon: Icon(
                _tvObscure ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9CA3AF),
              ),
              onPressed: () => setState(() {
                _tvObscure = !_tvObscure;
              }),
            ),
          ),
          const SizedBox(height: 30),
          _buildLoginButton(
            label: 'Login as Display',
            color: const Color(0xFF0D9488),
            isLoading: _isLoading,
            onPressed: _performTVLogin,
          ),
        ],
      ),
    );
  }

  // Common Input Field
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
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: enabled ? const Color(0xFFF9FAFB) : Colors.grey[200],
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Common Button
  Widget _buildLoginButton({
    required String label,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          disabledBackgroundColor: color.withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
