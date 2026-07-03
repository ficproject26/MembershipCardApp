import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'admin/admin_shell.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;

  final Color bgColor = const Color(0xFF0C1017);
  final Color inputColor = const Color(0xFF131A22);
  final Color borderColor = const Color(0xFF1F2937);
  final Color goldColor = const Color(0xFFFACC15);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _doDemoLogin(AppStateProvider state) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Missing Fields', 'Please enter your email and password.');
      return;
    }

    if (email == 'admin@fic.com' && password == 'admin123') {
      state.loginAsAdmin();
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShell()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome back, Admin!'), backgroundColor: Colors.green),
      );
      return;
    } else {
      _showErrorDialog('Login Failed', 'Invalid admin credentials.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white24, size: 20),
                  tooltip: 'Demo Simulator Controls',
                  onPressed: () => _showDemoBypassSheet(context, state),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.all_inclusive, color: goldColor, size: 40),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FIC MEMBERSHIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'CLUB',
                        style: TextStyle(
                          color: goldColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Admin ',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    children: [
                      TextSpan(
                        text: 'Portal',
                        style: TextStyle(color: goldColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Login to your administrative control account',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),

              const SizedBox(height: 40),

              const Text('Email Address', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your admin email address',
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
                  filled: true,
                  fillColor: inputColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: goldColor)),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white54, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: inputColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: goldColor)),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                          activeColor: goldColor,
                          checkColor: Colors.black,
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Remember me', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Text('Forgot Password?', style: TextStyle(color: goldColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),

              const SizedBox(height: 32),

              Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFF57F17)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => _doDemoLogin(state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Login', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.black87, size: 20),
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

  void _showDemoBypassSheet(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: inputColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Developer Simulator Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: goldColor))),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3B6E), padding: const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () {
                    state.loginAsAdmin();
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShell()));
                  },
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  label: const Text('System Admin Portal', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
