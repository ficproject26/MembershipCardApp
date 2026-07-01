import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/glass_card.dart';
import '../../models/user_model.dart';
import '../../models/lead_model.dart';
import 'service_details_screen.dart';
import 'services_tab.dart';
import 'all_leads_screen.dart';
import '../../widgets/hover_scale_card.dart';

class AgentDashboardTab extends StatefulWidget {
  final Function(int)? onNavigate;
  
  const AgentDashboardTab({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<AgentDashboardTab> createState() => _AgentDashboardTabState();
}

class _AgentDashboardTabState extends State<AgentDashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late PageController _pageController;
  int _currentCardIndex = 0;
  bool _pageControllerInitialized = false;
  int _promoIndex = 0;

  final List<Map<String, dynamic>> _promos = [
    {
      'tag': '🔥 HOT OFFER',
      'title': 'Earn 2x Commission on BPO Leads!',
      'subtitle': 'Submit direct outsourcing center leads by June 30.',
      'icon': Icons.campaign,
      'color': Color(0xFFFF6B35),
    },
    {
      'tag': '⭐ NEW',
      'title': 'IT Projects Referral Bonus Unlocked!',
      'subtitle': 'Platinum agents get ₹5,000 per IT project closure.',
      'icon': Icons.computer,
      'color': Color(0xFF00C48C),
    },
    {
      'tag': '💎 PREMIUM',
      'title': 'Insurance Leads Pay 15% Commission!',
      'subtitle': 'Refer health & life insurance. Higher payouts this month.',
      'icon': Icons.shield,
      'color': Color(0xFF7B61FF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Auto-cycle promos
    Future.delayed(const Duration(seconds: 3), _cyclePromo);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_pageControllerInitialized) {
      _pageControllerInitialized = true;
      final state = Provider.of<AppStateProvider>(context, listen: false);
      final agent = state.currentAgent;
      if (agent != null) {
        _pageController = PageController(viewportFraction: 0.9);
      }
      // Start auto-cycling cards every 2 seconds
      Future.delayed(const Duration(seconds: 2), _cycleCards);
    }
  }

  void _cycleCards() {
    if (!mounted) return;
    final nextPage = (_currentCardIndex + 1) % 4;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      _currentCardIndex = nextPage;
    });
    Future.delayed(const Duration(seconds: 2), _cycleCards);
  }

  void _cyclePromo() {
    if (!mounted) return;
    setState(() => _promoIndex = (_promoIndex + 1) % _promos.length);
    Future.delayed(const Duration(seconds: 4), _cyclePromo);
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final agent = state.currentAgent!;
    final isDark = true; // Force dark theme aesthetic for this tab

    final myLeads = state.leads.where((l) => l.agentCode == agent.agentCode).toList();
    final approvedLeads = myLeads.where((l) => l.status == LeadStatus.Approved).length;
    final pendingLeads = myLeads.where((l) => l.status == LeadStatus.Pending).length;
    final rejectedLeads = myLeads.where((l) => l.status == LeadStatus.Rejected).length;

    double tierProgress = 0.0;
    String nextTier = 'Max Level';
    double nextTarget = 0;
    if (agent.membership == MembershipTier.Silver) {
      tierProgress = (agent.totalEarnings / 15000).clamp(0.0, 1.0);
      nextTier = 'Gold';
      nextTarget = 15000;
    } else if (agent.membership == MembershipTier.Gold) {
      tierProgress = (agent.totalEarnings / 40000).clamp(0.0, 1.0);
      nextTier = 'Diamond';
      nextTarget = 40000;
    } else if (agent.membership == MembershipTier.Diamond) {
      tierProgress = (agent.totalEarnings / 80000).clamp(0.0, 1.0);
      nextTier = 'Platinum';
      nextTarget = 80000;
    } else {
      tierProgress = 1.0;
      nextTier = 'Platinum Master';
    }



    final tierConfig = _getTierConfig(agent.membership);
    final promo = _promos[_promoIndex];

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HERO WALLET CARD ──────────────────────────────────────
              _buildHeroCard(agent, tierConfig, tierProgress, nextTier, nextTarget, approvedLeads, myLeads.length, isDark),

              const SizedBox(height: 16),

              // ── MEMBERSHIP CARDS ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _sectionHeader('Membership Cards', isDark),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 210,
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentCardIndex = index;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: _buildMembershipCard(
                        tier: 'SILVER',
                        price: '₹999/yr',
                        features: ['Credit Card', 'Loan'],
                        gradient: [const Color(0xFF6B7280), const Color(0xFF4B5563)],
                        icon: '🥈',
                        isActive: agent.membership == MembershipTier.Silver,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: _buildMembershipCard(
                        tier: 'GOLD',
                        price: '₹2,499/yr',
                        features: ['Credit Card', 'Loan', 'Jobs'],
                        gradient: [const Color(0xFFD97706), const Color(0xFFB45309)],
                        icon: '🥇',
                        isActive: agent.membership == MembershipTier.Gold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: _buildMembershipCard(
                        tier: 'DIAMOND',
                        price: '₹4,999/yr',
                        features: ['Credit Card', 'Loan', 'Jobs', 'Insurance'],
                        gradient: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                        icon: '💎',
                        isActive: agent.membership == MembershipTier.Diamond,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: _buildMembershipCard(
                        tier: 'PLATINUM',
                        price: '₹9,999/yr',
                        features: ['All Services', 'IT Projects', 'BPO'],
                        gradient: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
                        icon: '👑',
                        isActive: agent.membership == MembershipTier.Platinum,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Dot indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentCardIndex == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentCardIndex == index ? const Color(0xFFFFC107) : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // ── STATS ROW ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildStatPill('Approved', approvedLeads.toString(), Icons.check_box, const Color(0xFF10B981), isDark),
                    const SizedBox(width: 8),
                    _buildStatPill('Pending', pendingLeads.toString(), Icons.hourglass_top, const Color(0xFFF59E0B), isDark),
                    const SizedBox(width: 8),
                    _buildStatPill('Rejected', rejectedLeads.toString(), Icons.close, const Color(0xFFEF4444), isDark),
                    const SizedBox(width: 8),
                    _buildStatPill('Total', myLeads.length.toString(), Icons.list_alt, const Color(0xFF3B82F6), isDark),
                  ],
                ),
              ),

              // ── PROMO BANNER ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPromoBanner(promo, isDark),
              ),
              const SizedBox(height: 16),

              // ── QUICK ACTIONS ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Quick Actions', isDark),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildActionCard(
                          icon: Icons.add_circle_outline,
                          label: 'Submit\nLead',
                          iconColor: const Color(0xFF10B981),
                          isDark: isDark,
                          onTap: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(1); // Navigate to Services tab
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildActionCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Request\nPayout',
                          iconColor: const Color(0xFF8B5CF6),
                          isDark: isDark,
                          onTap: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(2); // Navigate to Wallet tab
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildActionCard(
                          icon: Icons.qr_code_2,
                          label: 'Share\nReferral',
                          iconColor: const Color(0xFFFACC15),
                          isDark: isDark,
                          onTap: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(3); // Navigate to Share tab
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildActionCard(
                          icon: Icons.school_outlined,
                          label: 'Training\nCenter',
                          iconColor: const Color(0xFFF97316),
                          isDark: isDark,
                          onTap: () {
                            if (widget.onNavigate != null) {
                              widget.onNavigate!(5); // Navigate to Training tab
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── EARNINGS BREAKDOWN ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Earnings Breakdown', isDark),
                    const SizedBox(height: 10),
                    _buildEarningsBreakdown(agent, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── SERVICES AVAILABLE ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Your Active Services', isDark),
                    const SizedBox(height: 10),
                    _buildServicesGrid(agent, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── KYC NOTICE ────────────────────────────────────────────
              if (agent.kycStatus != KycStatus.Approved)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildKycBanner(agent, isDark),
                ),
              if (agent.kycStatus != KycStatus.Approved) const SizedBox(height: 20),

              // ── RECENT LEADS ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionHeader('Recent Leads', isDark),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3B6E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${myLeads.length} Total',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A3B6E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (myLeads.isEmpty)
                      _buildEmptyLeads(isDark)
                    else
                      ...myLeads.take(3).map((lead) => _buildLeadCard(lead, isDark)).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── NOTIFICATIONS ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Broadcasts & Alerts', isDark),
                    const SizedBox(height: 10),
                    _buildNotifications(state, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── HERO CARD ──────────────────────────────────────────────────────────────
  Widget _buildHeroCard(
    AgentModel agent,
    Map<String, dynamic> tierConfig,
    double tierProgress,
    String nextTier,
    double nextTarget,
    int approvedLeads,
    int totalLeads,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Base background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)], // Slate to Deep Violet
                ),
              ),
            ),
            // Glowing Orbs
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (tierConfig['gradient'][0] as Color).withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x663B82F6), // Blue glow
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Glass effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.01),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_greeting()} 👋',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                agent.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          _buildTierBadge(agent.membership, tierConfig),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Balance Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL BALANCE',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${_formatAmount(agent.walletBalance)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.5,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                          // Agent Code Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.qr_code, color: Colors.white70, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  agent.agentCode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Stats Row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.03)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHeroStat('Earned', '₹${_formatAmount(agent.totalEarnings)}', Icons.payments_outlined, const Color(0xFF10B981)),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                            _buildHeroStat('Leads', '$approvedLeads/$totalLeads', Icons.people_outline, const Color(0xFF3B82F6)),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                            _buildHeroStat('Target', nextTarget > 0 ? '₹${_formatAmount(nextTarget)}' : 'MAX', Icons.flag_outlined, const Color(0xFFF59E0B)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Progress Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress to $nextTier',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(tierProgress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: tierProgress,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(tierConfig['gradient'][0]),
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
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon, Color iconColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTierBadge(MembershipTier tier, Map<String, dynamic> config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: config['gradient'] as List<Color>),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (config['gradient'] as List<Color>).first.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(config['emoji'] as String, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            tier.name.toUpperCase(),
            style: TextStyle(
              color: config['textColor'] as Color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── STAT PILLS ─────────────────────────────────────────────────────────────
  Widget _buildStatPill(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllLeadsScreen(initialFilter: label),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF131A22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color.withOpacity(0.8), size: 8),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  // ── PROMO BANNER ───────────────────────────────────────────────────────────
  Widget _buildPromoBanner(Map<String, dynamic> promo, bool isDark) {
    final color = promo['color'] as Color;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_promoIndex),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(promo['icon'] as IconData, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      promo['tag'] as String,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    promo['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    promo['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: List.generate(
                _promos.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  width: 4,
                  height: i == _promoIndex ? 14 : 4,
                  decoration: BoxDecoration(
                    color: i == _promoIndex ? color : color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── QUICK ACTION CARDS ─────────────────────────────────────────────────────
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: HoverScaleCard(
        onTap: onTap,
        builder: (context, isHovered) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF131A22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon, 
                  color: iconColor, 
                  size: 24,
                  shadows: isHovered ? [Shadow(color: iconColor, blurRadius: 12)] : [],
                ),
                const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),
          );
        },
      ),
    );
  }

  // ── EARNINGS BREAKDOWN ─────────────────────────────────────────────────────
  Widget _buildEarningsBreakdown(AgentModel agent, bool isDark) {
    final bg = const Color(0xFF131A22);
    final borderColor = const Color(0xFF1F2937);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _earningRow('💰 Wallet Balance', '₹${_formatAmount(agent.walletBalance)}', const Color(0xFF1A3B6E), isDark),
          _earningDivider(isDark),
          _earningRow('📈 Total Lifetime Earnings', '₹${_formatAmount(agent.totalEarnings)}', Colors.green, isDark),
          _earningDivider(isDark),
          _earningRow('🔗 Direct Commissions', '₹${_formatAmount(agent.totalEarnings * 0.75)}', Colors.orange, isDark),
          _earningDivider(isDark),
          _earningRow('🌐 Network Commissions', '₹${_formatAmount(agent.totalEarnings * 0.25)}', const Color(0xFF7B61FF), isDark),
        ],
      ),
    );
  }

  Widget _earningRow(String label, String value, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningDivider(bool isDark) {
    return Container(height: 1, color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05));
  }

  // ── SERVICES GRID ──────────────────────────────────────────────────────────
  Widget _buildServicesGrid(AgentModel agent, bool isDark) {
    final allServices = [
      {'name': 'Credit Card', 'icon': Icons.credit_card, 'tiers': [MembershipTier.Silver, MembershipTier.Gold, MembershipTier.Diamond, MembershipTier.Platinum], 'desc': 'Submit client credit card applications', 'color': const Color(0xFF1A3B6E), 'detailsKeys': ['Bank Preferred', 'Client Monthly Income']},
      {'name': 'Loan', 'icon': Icons.account_balance, 'tiers': [MembershipTier.Silver, MembershipTier.Gold, MembershipTier.Diamond, MembershipTier.Platinum], 'desc': 'Submit Home, Personal, and Business Loan leads', 'color': Colors.green, 'detailsKeys': ['Loan Amount Needed', 'Type of Loan']},
      {'name': 'Jobs', 'icon': Icons.work, 'tiers': [MembershipTier.Gold, MembershipTier.Diamond, MembershipTier.Platinum], 'desc': 'Refer applicants for various roles', 'color': Colors.amber, 'detailsKeys': ['Desired Role', 'Years of Experience']},
      {'name': 'Insurance', 'icon': Icons.shield, 'tiers': [MembershipTier.Diamond, MembershipTier.Platinum], 'desc': 'Submit Insurance inquiries', 'color': Colors.teal, 'detailsKeys': ['Insurance Category', 'Annual Premium Budget']},
      {'name': 'IT Projects', 'icon': Icons.computer, 'tiers': [MembershipTier.Platinum], 'desc': 'Refer software and cloud projects', 'color': const Color(0xFFFFC107), 'detailsKeys': ['Project Details', 'Approximate Budget']},
      {'name': 'BPO Services', 'icon': Icons.headset_mic, 'tiers': [MembershipTier.Platinum], 'desc': 'Submit outsourcing center leads', 'color': Colors.pinkAccent, 'detailsKeys': ['Agents Required', 'Duration of Contract']},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: allServices.length,
      itemBuilder: (ctx, i) {
        final svc = allServices[i];
        final unlocked = (svc['tiers'] as List).contains(agent.membership);
        final icon = svc['icon'] as IconData;
        final name = svc['name'] as String;

        return HoverScaleCard(
          onTap: () {
            if (unlocked) {
              final service = ServiceItem(
                title: svc['name'] as String,
                desc: svc['desc'] as String,
                minTier: (svc['tiers'] as List<MembershipTier>).first,
                icon: svc['icon'] as IconData,
                color: svc['color'] as Color,
                detailsKeys: svc['detailsKeys'] as List<String>,
              );
              Navigator.push(
                ctx,
                MaterialPageRoute(builder: (_) => ServiceDetailsScreen(service: service)),
              );
            } else {
              showDialog(
                context: ctx,
                builder: (BuildContext dialogCtx) {
                  return AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF1E212D) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        const Icon(Icons.workspace_premium, color: Color(0xFFFFC107), size: 28),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Upgrade Required', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18))),
                      ],
                    ),
                    content: Text(
                      'Upgrade your membership to access $name and boost your earnings.',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text('Later', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          // Placeholder for actual upgrade flow.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            }
          },
          builder: (context, isHovered) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: unlocked
                    ? const LinearGradient(
                        colors: [Color(0xFF1A3B6E), Color(0xFF2A5298)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: unlocked ? null : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: unlocked
                      ? const Color(0xFFFFC107).withOpacity(0.4)
                      : (isDark ? Colors.white12 : Colors.black12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Icon(
                        icon,
                        color: unlocked ? const Color(0xFFFFC107) : (isDark ? Colors.white24 : Colors.black26),
                        size: 26,
                        shadows: isHovered && unlocked ? [const Shadow(color: Color(0xFFFFC107), blurRadius: 12)] : [],
                      ),
                    if (!unlocked)
                      const Icon(Icons.lock, color: Colors.red, size: 11),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: unlocked
                        ? Colors.white
                        : (isDark ? Colors.white30 : Colors.black38),
                  ),
                ),
                if (unlocked)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(color: Colors.green, fontSize: 7, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

  // ── RECENT LEADS ───────────────────────────────────────────────────────────
  Widget _buildLeadCard(LeadModel lead, bool isDark) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.hourglass_top;
    if (lead.status == LeadStatus.Approved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (lead.status == LeadStatus.Rejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.customerName ?? 'Customer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 10, color: isDark ? Colors.white38 : Colors.black38),
                    const SizedBox(width: 3),
                    Text(
                      lead.serviceType,
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Builder(
                  builder: (context) {
                    String badgeText = lead.status.name;
                    if (lead.serviceType == 'Loan') {
                      if (lead.status == LeadStatus.Stage1Approved) badgeText = 'Doc Verification';
                      else if (lead.status == LeadStatus.Stage2Approved) badgeText = 'Bank Processing';
                    } else if (lead.serviceType == 'Insurance') {
                      if (lead.status == LeadStatus.Stage1Approved) badgeText = 'KYC Verification';
                      else if (lead.status == LeadStatus.Stage2Approved) badgeText = 'Underwriting';
                      else if (lead.status == LeadStatus.Approved) badgeText = 'Active';
                    } else if (lead.serviceType == 'IT Projects') {
                      if (lead.status == LeadStatus.Stage1Approved) badgeText = 'Requirements';
                      else if (lead.status == LeadStatus.Stage2Approved) badgeText = 'In Development';
                      else if (lead.status == LeadStatus.Stage3Approved) badgeText = 'Testing';
                      else if (lead.status == LeadStatus.Approved) badgeText = 'Delivered';
                    }
                    if (badgeText == lead.status.name) {
                      badgeText = badgeText.replaceAll('Stage1', 'Stage 1 ').replaceAll('Stage2', 'Stage 2 ').replaceAll('Stage3', 'Stage 3 ');
                    }
                    return Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              if (lead.status == LeadStatus.Approved)
                Text(
                  '+₹${_commissionForService(lead.serviceType)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLeads(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          const Text('📭', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            'No leads yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Go to Services tab and submit your first lead to start earning!',
            style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── KYC BANNER ─────────────────────────────────────────────────────────────
  Widget _buildKycBanner(AgentModel agent, bool isDark) {
    final isPending = agent.kycStatus == KycStatus.Pending;
    final color = isPending ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPending ? Icons.hourglass_top : Icons.warning_amber_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPending ? '⏳ KYC Under Review' : '⚠️ KYC Verification Required',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  isPending
                      ? 'Your documents are being verified by the admin team.'
                      : 'Complete KYC in Wallet tab to unlock withdrawals.',
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── NOTIFICATIONS ──────────────────────────────────────────────────────────
  Widget _buildNotifications(AppStateProvider state, bool isDark) {
    final notifications = state.notifications.take(3).toList();
    return Column(
      children: notifications.asMap().entries.map((entry) {
        final icons = [Icons.notifications_active, Icons.info_outline, Icons.stars];
        final colors = [const Color(0xFFFFC107), const Color(0xFF1A3B6E), Colors.green];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors[entry.key % colors.length].withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icons[entry.key % icons.length],
                  color: colors[entry.key % colors.length],
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFFACC15),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  Map<String, dynamic> _getTierConfig(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.Platinum:
        return {
          'gradient': [const Color(0xFF8E8E8E), const Color(0xFFD4D4D4)],
          'emoji': '💎',
          'textColor': const Color(0xFF1A1A1A),
        };
      case MembershipTier.Diamond:
        return {
          'gradient': [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
          'emoji': '🔷',
          'textColor': Colors.white,
        };
      case MembershipTier.Gold:
        return {
          'gradient': [const Color(0xFFFFB300), const Color(0xFFFF8F00)],
          'emoji': '🥇',
          'textColor': Colors.white,
        };
      case MembershipTier.Silver:
      default:
        return {
          'gradient': [const Color(0xFF9E9E9E), const Color(0xFF757575)],
          'emoji': '🥈',
          'textColor': Colors.white,
        };
    }
  }

  String _commissionForService(String serviceType) {
    const commissions = {
      'Credit Card': '1,200',
      'Loan': '2,500',
      'Jobs': '800',
      'Insurance': '3,500',
      'IT Projects': '8,000',
      'BPO Services': '5,000',
    };
    return commissions[serviceType] ?? '500';
  }

  // ── MEMBERSHIP CARD ─────────────────────────────────────────────────────
  Widget _buildMembershipCard({
    required String tier,
    required String price,
    required List<String> features,
    required List<Color> gradient,
    required String icon,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: isActive
            ? Border.all(color: const Color(0xFFFFC107), width: 2.5)
            : Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: gradient.last.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Shimmer accent line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Chip icon + Tier badge + Active
                  Row(
                    children: [
                      // Card chip
                      Container(
                        width: 32,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.9),
                              const Color(0xFFDAA520).withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: const Color(0xFFB8860B).withOpacity(0.5), width: 0.5),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) => Container(
                              width: 1,
                              height: 14,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              color: const Color(0xFFB8860B).withOpacity(0.4),
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(icon, style: const TextStyle(fontSize: 20)),
                      const Spacer(),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFC107).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tier name - large
                  Text(
                    tier,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Price
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  // Features row - horizontal chips
                  SizedBox(
                    height: 22,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      children: features.take(4).map((f) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bottom: FIC branding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FIC MEMBERSHIP CLUB',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      // Card network icon
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tier[0],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
