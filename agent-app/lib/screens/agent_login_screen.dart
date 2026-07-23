import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'agent/agent_shell.dart';

class AgentLoginScreen extends StatefulWidget {
  const AgentLoginScreen({Key? key}) : super(key: key);

  @override
  State<AgentLoginScreen> createState() => _AgentLoginScreenState();
}

class _AgentLoginScreenState extends State<AgentLoginScreen> {
  bool _isLoginTab = true;
  bool _rememberMe = true;
  bool _obscurePassword = true;

  // Sign In controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Registration controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regPhoneController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regReferralController = TextEditingController();
  MembershipTier _selectedTier = MembershipTier.Basic;

  final Color bgColor = const Color(0xFF0C1017);
  final Color inputColor = const Color(0xFF131A22);
  final Color borderColor = const Color(0xFF1F2937);
  final Color goldColor = const Color(0xFFFACC15);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppStateProvider>(context, listen: false);
      state.fetchPricing();
      state.fetchCommissions();
    });
    // Auto-populate referral code if present in the URL query parameters
    final ref = Uri.base.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      _regReferralController.text = ref;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regReferralController.dispose();
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

  void _showForgotPasswordDialog(BuildContext context, AppStateProvider state) {
    final emailController = TextEditingController();
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: bgColor,
              title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter your registered email address and we will send you a password reset link.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
                      filled: true,
                      fillColor: inputColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: goldColor),
                      ),
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: goldColor, strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Please enter a valid email address.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                            return;
                          }

                          setDialogState(() => isLoading = true);
                          final success = await state.forgotPassword(email);
                          setDialogState(() => isLoading = false);

                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                            if (success) {
                              showDialog(
                                context: context,
                                builder: (successCtx) => AlertDialog(
                                  backgroundColor: bgColor,
                                  title: const Text('Email Sent', style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                    'If an account with that email exists, a password reset link has been sent to it.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(successCtx).pop(),
                                      child: Text('OK', style: TextStyle(color: goldColor)),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              _showErrorDialog('Error', state.error ?? 'Failed to request password reset link.');
                            }
                          }
                        },
                        child: Text('Send Link', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold)),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  void _doDemoLogin(AppStateProvider state) async {
    final emailOrPhone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrPhone.isEmpty || password.isEmpty) {
      _showErrorDialog('Missing Fields', 'Please enter your email and password.');
      return;
    }

    if (emailOrPhone.contains('@')) {
      final agent = await state.agentLogin(emailOrPhone, password);
      if (agent != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentShell()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), content: Text('Welcome back, ${agent.name}!'), backgroundColor: Colors.green),
        );
        return;
      } else {
        _showErrorDialog('Login Failed', state.error ?? 'Invalid email or password.');
        return;
      }
    } else {
      _showErrorDialog('Invalid Input', 'Please login with your registered Email ID.');
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
              // Developer / Demo bypass icon at the very top right (hidden in plain sight)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white24, size: 20),
                  tooltip: 'Demo Simulator Controls',
                  onPressed: () => _showDemoBypassSheet(context, state),
                ),
              ),

              const SizedBox(height: 20),

              // Custom Logo
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

              // Title
              if (_isLoginTab) ...[
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Welcome ',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Back',
                          style: TextStyle(color: goldColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Login to your FIC Membership Club account',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ),
              ] else ...[
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Join ',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Membership',
                          style: TextStyle(color: goldColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Create your FIC Membership Club agent account',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              _isLoginTab ? _buildSignInForm(context, state) : _buildRegisterForm(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context, AppStateProvider state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Email or Mobile Number', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your email or mobile number',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
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
            GestureDetector(
              onTap: () => _showForgotPasswordDialog(context, state),
              child: Text('Forgot Password?', style: TextStyle(color: goldColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Golden Login Button
        Container(
          height: 55,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFF57F17)], // Golden gradient
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

        const SizedBox(height: 32),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: borderColor, thickness: 1)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('or continue with', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
            Expanded(child: Divider(color: borderColor, thickness: 1)),
          ],
        ),

        const SizedBox(height: 32),

        // Social Buttons
        Row(
          children: [
            Expanded(
              child: _buildSocialButton('Google', Icons.g_mobiledata),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton('WhatsApp', Icons.chat),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSocialButton('Apple', Icons.apple),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: borderColor, thickness: 1)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('or', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
            Expanded(child: Divider(color: borderColor, thickness: 1)),
          ],
        ),

        const SizedBox(height: 32),

        // Login with OTP Button
        OutlinedButton.icon(
          onPressed: () => _doDemoLogin(state),
          icon: const Icon(Icons.security, color: Colors.white70, size: 20),
          label: const Text('Login with OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: borderColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 32),

        // Join Membership
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have a membership? ", style: TextStyle(color: Colors.white54, fontSize: 13)),
            GestureDetector(
              onTap: () => setState(() => _isLoginTab = false),
              child: Row(
                children: [
                  Text('Join Membership ', style: TextStyle(color: goldColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward, color: goldColor, size: 14),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, IconData icon) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: inputColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: text == 'Google' ? Colors.redAccent : (text == 'WhatsApp' ? Colors.green : Colors.white), size: 18),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context, AppStateProvider state) {
    final pricing = state.pricings.firstWhere((p) => p.tier == _selectedTier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDarkTextField(controller: _regNameController, label: 'Full Name', icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildDarkTextField(
          controller: _regPhoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
        const SizedBox(height: 16),
        _buildDarkTextField(controller: _regEmailController, label: 'Email Address', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _regPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your Password',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                filled: true,
                fillColor: inputColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: goldColor)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDarkTextField(controller: _regReferralController, label: 'Referral Agent Code (Optional)', icon: Icons.group_add_outlined),
        const SizedBox(height: 24),

        const SizedBox(height: 32),

        Container(
          height: 55,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFF57F17)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: () {
              final phone = _regPhoneController.text.trim();
              final email = _regEmailController.text.trim();
              
              if (_regNameController.text.trim().isEmpty ||
                  phone.isEmpty ||
                  email.isEmpty ||
                  _regPasswordController.text.trim().isEmpty) {
                showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: const Text('Please fill in Name, Phone, Email, and Password.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                return;
              }
              
              if (phone.length != 10) {
                showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: const Text('Phone number must be exactly 10 digits.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                return;
              }
              
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(email)) {
                showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: const Text('Please enter a valid email address.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                return;
              }
              
              _simulateRegisterCheckout(context, state);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sign Up', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.person_add, color: Colors.black87, size: 20),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),

        // Back to Login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account? ", style: TextStyle(color: Colors.white54, fontSize: 13)),
            GestureDetector(
              onTap: () => setState(() => _isLoginTab = true),
              child: Text('Login Instead', style: TextStyle(color: goldColor, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDarkTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.white54),
            filled: true,
            fillColor: inputColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: goldColor)),
          ),
        ),
      ],
    );
  }

  void _simulateRegisterCheckout(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: bgColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40, width: 40, child: CircularProgressIndicator(color: goldColor)),
              const SizedBox(height: 16),
              const Text('Creating your account...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Please wait while we set up your dashboard.', style: TextStyle(fontSize: 10, color: Colors.white54), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
    
    // Run checkout and registration outside the builder to prevent multiple calls
    _performRegistration(context, state);
  }

  Future<void> _performRegistration(BuildContext context, AppStateProvider state) async {
    // Simulate Razorpay Delay
    await Future.delayed(const Duration(seconds: 2));

    final newAgent = await state.registerAgent(
      name: _regNameController.text.trim(),
      email: _regEmailController.text.trim(),
      phoneNumber: _regPhoneController.text.trim(),
      password: _regPasswordController.text.trim(),
      membership: _selectedTier,
      referredBy: _regReferralController.text.trim(),
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
    
    if (newAgent != null) {
      state.loginAsAgent(newAgent.id);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentShell()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
        content: Text('Registered successfully! Your new code is ${newAgent.agentCode}'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
        content: Text('Registration failed: ${state.error ?? "Unknown error"}'),
        backgroundColor: Colors.red,
      ));
    }
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
                const Text('Quickly login as Agent:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.agents.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (c, idx) {
                      final ag = state.agents[idx];
                      return GestureDetector(
                        onTap: () {
                          state.loginAsAgent(ag.id);
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentShell()));
                        },
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: goldColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(ag.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                              Text(ag.membership.name, style: TextStyle(fontSize: 10, color: goldColor, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(ag.agentCode, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
