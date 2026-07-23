import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'hr_application_details.dart';

class HrDashboardMain extends StatefulWidget {
  const HrDashboardMain({super.key});

  @override
  State<HrDashboardMain> createState() => _HrDashboardMainState();
}

class _HrDashboardMainState extends State<HrDashboardMain> {
  final Color primaryDark = const Color(0xFF0B132B);
  final Color cardDark = const Color(0xFF1C2541);
  final Color accentYellow = const Color(0xFFFFC107);

  late Future<HrDashboardStats> _dashboardStatsFuture;

  @override
  void initState() {
    super.initState();
    _dashboardStatsFuture = StaffService().getHrDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    
    // For now we force dark theme styling in the cards, or use isDark to adapt
    final bgColor = isDark ? primaryDark : const Color(0xFFF4F7FE);
    final cardColor = isDark ? cardDark : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2B3674);
    final textMuted = isDark ? Colors.white54 : Colors.black54;

    return FutureBuilder<HrDashboardStats>(
      future: _dashboardStatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
        }

        final stats = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(textColor, textMuted),
              const SizedBox(height: 32),
              
              // Top KPI Cards
              _buildKpiGrid(cardColor, textColor, textMuted, stats.kpi),
              const SizedBox(height: 32),
              
              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 32),
              
              // Recruitment Pipeline
              Text('Recruitment Pipeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 16),
              _buildPipeline(cardColor, textColor, stats.pipeline),
              const SizedBox(height: 32),

              // Two column layout for larger screens, column for mobile
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildRecentApplications(cardColor, textColor, textMuted, stats.recentApplications)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: Column(
                          children: [
                            _buildAgentPerformance(cardColor, textColor, textMuted, stats.topAgents),
                            const SizedBox(height: 24),
                            _buildTasksAndFollowups(cardColor, textColor, textMuted),
                          ],
                        )),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildAgentPerformance(cardColor, textColor, textMuted, stats.topAgents),
                        const SizedBox(height: 24),
                        _buildTasksAndFollowups(cardColor, textColor, textMuted),
                        const SizedBox(height: 24),
                        _buildRecentApplications(cardColor, textColor, textMuted, stats.recentApplications),
                      ],
                    );
                  }
                }
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeader(Color textColor, Color textMuted) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: accentYellow.withValues(alpha: 0.2),
          child: Icon(Icons.person, color: accentYellow, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HR Recruitment Center',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Today is ${DateTime.now().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 14, color: textMuted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildKpiGrid(Color cardColor, Color textColor, Color textMuted, HrKpi stats) {
    final width = MediaQuery.of(context).size.width;
    double aspectRatio = 1.8;
    if (width < 600) {
      aspectRatio = 1.0; // Square cards for mobile to guarantee no overflow
    } else if (width < 900) {
      aspectRatio = 1.3;
    }

    return GridView.count(
      crossAxisCount: width > 1200 ? 4 : (width > 800 ? 3 : 2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: [
        _kpiCard('Total Referrals', '${stats.totalReferrals}', Icons.group_add, Colors.blue, cardColor, textColor, textMuted, '0%'),
        _kpiCard('Pending Applications', '${stats.pendingApplications}', Icons.pending_actions, Colors.orange, cardColor, textColor, textMuted, '0%'),
        _kpiCard('In Process', '${stats.inProcess}', Icons.sync, Colors.purple, cardColor, textColor, textMuted, '0%'),
        _kpiCard('Selected Candidates', '${stats.selectedCandidates}', Icons.verified, Colors.green, cardColor, textColor, textMuted, '0%'),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color iconColor, Color cardColor, Color textColor, Color textMuted, String trend) {
    final isPositive = trend.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: isPositive ? Colors.green : Colors.red),
                    const SizedBox(width: 4),
                    Text(trend, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
          ),
          Text(title, style: TextStyle(fontSize: 13, color: textMuted, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.person_add, 'label': 'Add Candidate', 'key': 'add_candidate'},
      {'icon': Icons.support_agent, 'label': 'Onboard Agent', 'key': 'onboard'},
      {'icon': Icons.call, 'label': 'Follow Up', 'key': 'follow_up'},
      {'icon': Icons.analytics, 'label': 'Agent Reports', 'key': 'reports'},
      {'icon': Icons.work, 'label': 'Job Openings', 'key': 'jobs'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map((action) {
        return InkWell(
          onTap: () {
            final key = action['key'] as String;
            if (key == 'add_candidate') {
              _showAddCandidateSheet(context);
            } else if (key == 'onboard') {
              _showOnboardAgentSheet(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${action['label']} — coming soon!'),
                  backgroundColor: accentYellow,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: accentYellow,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: accentYellow.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action['icon'] as IconData, size: 18, color: primaryDark),
                const SizedBox(width: 8),
                Text(action['label'] as String, style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showAddCandidateSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final referralCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: accentYellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.person_add, color: accentYellow, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text('Add New Candidate', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Fill in the details to register a new agent candidate.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sheetField('Full Name', nameCtrl, Icons.person_outline, 'e.g. Rajesh Kumar',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
                          const SizedBox(height: 16),
                          _sheetField('Email Address', emailCtrl, Icons.email_outlined, 'e.g. rajesh@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            }),
                          const SizedBox(height: 16),
                          _sheetField('Phone Number', phoneCtrl, Icons.phone_outlined, 'e.g. 9876543210',
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Phone is required' : null),
                          const SizedBox(height: 16),
                          _sheetField('Referral Code (optional)', referralCtrl, Icons.card_giftcard_outlined, 'Referrer\'s agent code'),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentYellow,
                                foregroundColor: primaryDark,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              icon: isSubmitting
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                  : const Icon(Icons.check_circle_outline),
                              label: Text(isSubmitting ? 'Submitting…' : 'Add Candidate', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              onPressed: isSubmitting ? null : () async {
                                if (!formKey.currentState!.validate()) return;
                                setSheetState(() => isSubmitting = true);
                                try {
                                  await AgentService().createAgent({
                                    'name': nameCtrl.text.trim(),
                                    'email': emailCtrl.text.trim(),
                                    'phoneNumber': phoneCtrl.text.trim(),
                                    'password': 'Welcome@123',
                                    if (referralCtrl.text.trim().isNotEmpty) 'referredBy': referralCtrl.text.trim(),
                                  });
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    setState(() => _dashboardStatsFuture = StaffService().getHrDashboardStats());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Candidate added successfully ✅'), backgroundColor: Colors.green),
                                    );
                                  }
                                } catch (e) {
                                  setSheetState(() => isSubmitting = false);
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(content: Text('Failed to add candidate: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
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
        ),
      ),
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl, IconData icon, String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true,
            fillColor: primaryDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentYellow, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
            errorStyle: const TextStyle(color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showOnboardAgentSheet(BuildContext context) {
    final steps = [
      {'icon': Icons.person_add_alt_1, 'title': 'Register Candidate', 'desc': 'Tap "Add Candidate" to create their profile in the system.', 'done': true},
      {'icon': Icons.verified_user_outlined, 'title': 'KYC Verification', 'desc': 'Ensure Aadhaar, PAN, and bank details are submitted and approved by the KYC team.', 'done': false},
      {'icon': Icons.school_outlined, 'title': 'Training & Orientation', 'desc': 'Schedule product training and onboarding orientation session.', 'done': false},
      {'icon': Icons.assignment_turned_in_outlined, 'title': 'Agreement Signing', 'desc': 'Get the agent agreement signed digitally or physically.', 'done': false},
      {'icon': Icons.phone_android_outlined, 'title': 'App Access & Activation', 'desc': 'Share app login credentials. Confirm the agent can log in successfully.', 'done': false},
      {'icon': Icons.leaderboard_outlined, 'title': 'First Lead Assignment', 'desc': 'Assign initial leads to get the agent started on the field.', 'done': false},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.80,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: accentYellow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.support_agent, color: accentYellow, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text('Onboard Agent', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Follow these steps to onboard a new field agent.', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  itemCount: steps.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Container(width: 2, height: 16, color: Colors.white10),
                  ),
                  itemBuilder: (_, i) {
                    final step = steps[i];
                    final isDone = step['done'] as bool;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDone ? accentYellow.withValues(alpha: 0.15) : primaryDark,
                                shape: BoxShape.circle,
                                border: Border.all(color: isDone ? accentYellow : Colors.white12, width: 1.5),
                              ),
                              child: Icon(step['icon'] as IconData, color: isDone ? accentYellow : Colors.white38, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Step ${i + 1}: ${step['title']}',
                                        style: TextStyle(
                                          color: isDone ? accentYellow : Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isDone)
                                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(step['desc'] as String, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPipeline(Color cardColor, Color textColor, HrPipeline stats) {
    final steps = [
      {'label': 'Applied', 'count': '${stats.applied}'},
      {'label': 'Screening', 'count': '${stats.screening}'},
      {'label': 'Interview', 'count': '${stats.interview}'},
      {'label': 'Selected', 'count': '${stats.selected}'},
      {'label': 'Joined', 'count': '${stats.joined}'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return isMobile 
            ? Column(
                children: steps.map((s) => _buildPipelineStepMobile(s['label']!, s['count']!, textColor, s == steps.last)).toList(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: steps.map((s) => _buildPipelineStep(s['label']!, s['count']!, textColor, s == steps.last)).toList(),
              );
        }
      ),
    );
  }

  Widget _buildPipelineStep(String label, String count, Color textColor, bool isLast) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accentYellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: accentYellow, width: 2),
              ),
              child: Center(child: Text(count, style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold, fontSize: 18))),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.arrow_forward_ios, color: textColor.withValues(alpha: 0.2), size: 16),
          )
      ],
    );
  }

  Widget _buildPipelineStepMobile(String label, String count, Color textColor, bool isLast) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentYellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: accentYellow, width: 2),
              ),
              child: Center(child: Text(count, style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold, fontSize: 14))),
            ),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(Icons.arrow_downward, color: textColor.withValues(alpha: 0.2), size: 16),
          )
      ],
    );
  }

  Widget _buildAgentPerformance(Color cardColor, Color textColor, Color textMuted, List<HrTopAgent> topAgents) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard, color: accentYellow),
              const SizedBox(width: 8),
              Text('Top Performing Agents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 24),
          if (topAgents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text('No performance data available yet.', style: TextStyle(color: textMuted)),
              ),
            )
          else
            ...topAgents.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildAgentStat(a.name, '${a.referrals}', Colors.blue, textColor, textMuted),
            )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: accentYellow,
                side: BorderSide(color: accentYellow),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View Full Leaderboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAgentStat(String name, String referrals, Color color, Color textColor, Color textMuted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
          ],
        ),
        Text('$referrals Referrals', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTasksAndFollowups(Color cardColor, Color textColor, Color textMuted) {
    final List<Map<String, dynamic>> tasks = [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today\'s Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              Text('See All', style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text('No tasks scheduled for today.', style: TextStyle(color: textMuted))),
            )
          else
            ...tasks.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t['color'] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['title'] as String, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                        Text(t['subtitle'] as String, style: TextStyle(color: textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(t['time'] as String, style: TextStyle(color: textMuted, fontWeight: FontWeight.w600)),
                ],
              ),
            ))
        ],
      ),
    );
  }

  Widget _buildRecentApplications(Color cardColor, Color textColor, Color textMuted, List<HrRecentApplication> apps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: textMuted),
                  const SizedBox(width: 4),
                  Text('Filter', style: TextStyle(color: textMuted)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        if (apps.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text('No recent applications found.', style: TextStyle(color: textMuted))),
          )
        else
          ...apps.map((app) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HrApplicationDetails(leadId: app.id),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF1A3B6E),
                      child: Text(app.name.isNotEmpty ? app.name.substring(0, 1) : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 4),
                          Text(app.role, style: TextStyle(fontSize: 13, color: textMuted)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone, size: 14, color: textMuted),
                                  const SizedBox(width: 4),
                                  Flexible(child: Text(app.mobile, style: TextStyle(fontSize: 12, color: textMuted), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.storefront, size: 14, color: textMuted),
                                  const SizedBox(width: 4),
                                  Flexible(child: Text(app.agent, style: TextStyle(fontSize: 12, color: textMuted), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    _buildStatusBadge(app.status),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: Colors.white10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Applied on: ${app.date}', style: TextStyle(fontSize: 12, color: textMuted)),
                    OutlinedButton(
                      onPressed: () => _showStatusUpdateDialog(context, app),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentYellow,
                        side: BorderSide(color: accentYellow.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      ),
                      child: const Text('Follow Up'),
                    )
                  ],
                )
              ],
            ),
          ))),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Selected': color = Colors.green; break;
      case 'Converted': color = Colors.teal; break;
      case 'Process': color = Colors.amber; break;
      case 'In Process': color = Colors.amber; break;
      case 'Followup': color = Colors.purple; break;
      case 'Interview': color = Colors.purple; break;
      case 'Pending': color = Colors.orange; break;
      case 'Rejected': color = Colors.red; break;
      default: color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, HrRecentApplication app) {
    String selectedStatus = app.status;
    if (selectedStatus == 'In Process') selectedStatus = 'Process';
    if (selectedStatus == 'Interview') selectedStatus = 'Followup';
    final statuses = ['Pending', 'Process', 'Followup', 'Converted', 'Selected', 'Rejected'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardDark,
              title: const Text('Update Status', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Application: ${app.name}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: primaryDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: primaryDark,
                        value: statuses.contains(selectedStatus) ? selectedStatus : 'Pending',
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                        items: statuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              selectedStatus = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final appState = Provider.of<AppStateProvider>(context, listen: false);
                      LeadStatus statusEnum = LeadStatus.values.firstWhere(
                        (e) => e.name.toLowerCase() == selectedStatus.toLowerCase(),
                        orElse: () => LeadStatus.Pending,
                      );
                      await appState.verifyLead(app.id, statusEnum);
                      setState(() {
                        _dashboardStatsFuture = StaffService().getHrDashboardStats();
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status updated successfully'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: Text('Update', style: TextStyle(color: accentYellow, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
