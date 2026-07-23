import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'training_detail_screen.dart';
import '../agent_login_screen.dart';

class AgentProfileTab extends StatefulWidget {
  final Function(int)? onNavigate;

  const AgentProfileTab({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<AgentProfileTab> createState() => _AgentProfileTabState();
}

class _AgentProfileTabState extends State<AgentProfileTab> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final agent = state.currentAgent;
    final isDark = state.isDarkMode;

    if (agent == null) return const SizedBox.shrink();

    final courses = [
      _CourseItem(
        title: 'Platform Onboarding 101',
        category: 'Getting Started',
        duration: '12 mins',
        progress: 1.0,
        icon: Icons.play_circle_fill,
      ),
      _CourseItem(
        title: 'Mastering IT & BPO Referrals',
        category: 'Advanced Sales',
        duration: '45 mins',
        progress: 0.45,
        icon: Icons.video_library,
      ),
      _CourseItem(
        title: 'KYC & Banking Compliance Policies',
        category: 'Legal',
        duration: '18 mins',
        progress: 0.9,
        icon: Icons.policy,
      ),
      _CourseItem(
        title: 'Growing Your Level-2 Indirect Network',
        category: 'Referral Marketing',
        duration: '30 mins',
        progress: 0.0,
        icon: Icons.group_work,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HERO PROFILE HEADER CARD ───────────────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: const Color(0xFFFACC15).withOpacity(0.3),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFFFACC15).withOpacity(0.2),
                          child: Text(
                            agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFACC15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agent.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                agent.email,
                                style: const TextStyle(fontSize: 12, color: Colors.white54),
                              ),
                              Text(
                                agent.phoneNumber,
                                style: const TextStyle(fontSize: 12, color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Membership Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: agent.membership == MembershipTier.Platinum
                                  ? [const Color(0xFFC084FC), const Color(0xFF7C3AED)]
                                  : agent.membership == MembershipTier.Diamond
                                      ? [const Color(0xFF60A5FA), const Color(0xFF2563EB)]
                                      : agent.membership == MembershipTier.Gold
                                          ? [const Color(0xFFFBBF24), const Color(0xFFD97706)]
                                          : [const Color(0xFF9CA3AF), const Color(0xFF4B5563)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFACC15).withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.workspace_premium, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${agent.membership.name.toUpperCase()} TIER',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // KYC Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: agent.kycStatus == KycStatus.Approved
                                ? Colors.green.withOpacity(0.15)
                                : agent.kycStatus == KycStatus.Pending
                                    ? Colors.amber.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: agent.kycStatus == KycStatus.Approved
                                  ? Colors.green
                                  : agent.kycStatus == KycStatus.Pending
                                      ? Colors.amber
                                      : Colors.red,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                agent.kycStatus == KycStatus.Approved
                                    ? Icons.verified
                                    : Icons.warning_amber_rounded,
                                size: 14,
                                color: agent.kycStatus == KycStatus.Approved
                                    ? Colors.green
                                    : agent.kycStatus == KycStatus.Pending
                                        ? Colors.amber
                                        : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'KYC: ${agent.kycStatus.name}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: agent.kycStatus == KycStatus.Approved
                                      ? Colors.green
                                      : agent.kycStatus == KycStatus.Pending
                                          ? Colors.amber
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── DIGITAL BUSINESS CARD & QR BUTTON ──────────────────────────
              GestureDetector(
                onTap: () => _showDigitalCardModal(context, agent),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFACC15).withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.qr_code_2, color: Color(0xFFFACC15), size: 32),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Digital Agent ID & Business Card',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Show QR Code & Share Business Pass with Clients',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── 🎓 ACADEMY & TRAINING SECTION ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.school, color: Color(0xFFFACC15), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'FIC Academy & Training Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFACC15).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '4 Modules',
                      style: TextStyle(
                        color: Color(0xFFFACC15),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...courses.map((course) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrainingDetailScreen(
                            title: course.title,
                            category: course.category,
                            duration: course.duration,
                            progress: course.progress,
                            icon: course.icon,
                          ),
                        ),
                      );
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3B6E).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(course.icon, color: const Color(0xFFFACC15), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFACC15),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: course.progress,
                                          minHeight: 4,
                                          backgroundColor: Colors.white10,
                                          color: const Color(0xFFFACC15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${(course.progress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFFACC15)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // ── ACCOUNT & BANK DETAILS ─────────────────────────────────────
              const Text(
                'ACCOUNT & BANK DETAILS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.badge_outlined, 'Agent Code', agent.agentCode),
                    const Divider(color: Colors.white10),
                    _buildDetailRow(Icons.credit_card, 'Aadhaar Verified', agent.aadhaarNumber ?? 'Verified'),
                    const Divider(color: Colors.white10),
                    _buildDetailRow(Icons.account_balance, 'Bank Account', agent.bankAccountNumber ?? 'Not Configured'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── APP PREFERENCES & SUPPORT ──────────────────────────────────
              const Text(
                'SETTINGS & SUPPORT',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined, color: Color(0xFFFACC15)),
                      title: const Text('Dark Mode Aesthetics', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      trailing: Switch(
                        value: state.isDarkMode,
                        activeColor: const Color(0xFFFACC15),
                        onChanged: (val) => state.toggleDarkMode(),
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      leading: const Icon(Icons.support_agent_outlined, color: Color(0xFFFACC15)),
                      title: const Text('24/7 Customer Support', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Reach FIC Desk via Chat or Call', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF0F172A),
                            title: const Row(
                              children: [
                                Icon(Icons.support_agent, color: Color(0xFFFACC15)),
                                SizedBox(width: 10),
                                Text('FIC Support Desk', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            content: const Text(
                              'Email: support@ficmembership.com\nPhone: +91 98765 43210\nLive Hours: 24/7 Support Active',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK', style: TextStyle(color: Color(0xFFFACC15))),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text('Logout Account', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Row(
                              children: [
                                Icon(Icons.logout, color: Colors.redAccent),
                                SizedBox(width: 10),
                                Text('Logout Confirmation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: const Text(
                              'Are you sure you want to log out of your FIC Membership account?',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  state.logout();
                                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const AgentLoginScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFACC15)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  void _showDigitalCardModal(BuildContext context, AgentModel agent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFACC15), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.all_inclusive, color: Color(0xFFFACC15), size: 40),
                    const SizedBox(height: 8),
                    const Text('FIC MEMBERSHIP CLUB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Text(agent.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('AGENT CODE: ${agent.agentCode}', style: const TextStyle(color: Color(0xFFFACC15), fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.qr_code_2, size: 100, color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    const Text('Scan to verify Agent Credentials', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACC15),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.share, color: Colors.black),
                label: const Text('Share Digital Pass', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseItem {
  final String title;
  final String category;
  final String duration;
  final double progress;
  final IconData icon;

  _CourseItem({
    required this.title,
    required this.category,
    required this.duration,
    required this.progress,
    required this.icon,
  });
}
