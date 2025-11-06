import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: .9),
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
              Text(
                'ServelQ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                  children: [_buildAgentLogin(context), _buildTVLogin(context)],
                ),
              ),
            ],
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
        _buildTextField(
          controller: _agentEmail,
          label: 'Email Address',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _agentPassword,
          label: 'Password',
          icon: Icons.lock_outline,
          obscureText: _agentObscure,
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
          onPressed: () => context.go('/agent'),
        ),
      ],
    );
  }

  // TV Display Login Form
  Widget _buildTVLogin(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTextField(
            controller: _tvEmail,
            label: 'Email Address',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _tvPassword,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: _tvObscure,
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
            onPressed: () => context.go('/display'),
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
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
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
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
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
