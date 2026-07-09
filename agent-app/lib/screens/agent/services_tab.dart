import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'service_details_screen.dart';

class AgentServicesTab extends StatelessWidget {
  const AgentServicesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final agent = state.currentAgent!;
    final isDark = state.isDarkMode;

    final servicesList = [
      ServiceItem(
        title: 'Credit Card',
        desc: 'Submit client credit card applications (HDFC, SBI, ICICI, etc.)',
        minTier: MembershipTier.Silver,
        icon: Icons.credit_card,
        color: const Color(0xFF1A3B6E),
        detailsKeys: ['Bank Preferred', 'Client Monthly Income'],
      ),
      ServiceItem(
        title: 'Loan',
        desc: 'Submit Home, Personal, and Business Loan leads.',
        minTier: MembershipTier.Silver,
        icon: Icons.monetization_on,
        color: Colors.green,
        detailsKeys: ['Loan Amount Needed', 'Type of Loan'],
      ),
      ServiceItem(
        title: 'Jobs',
        desc: 'Refer applicants for various domestic/international roles.',
        minTier: MembershipTier.Gold,
        icon: Icons.work,
        color: Colors.amber,
        detailsKeys: ['Desired Role', 'Years of Experience'],
      ),
      ServiceItem(
        title: 'Insurance',
        desc: 'Submit Life, Health, and Motor Insurance inquiries.',
        minTier: MembershipTier.Diamond,
        icon: Icons.health_and_safety,
        color: Colors.teal,
        detailsKeys: ['Insurance Category', 'Annual Premium Budget'],
      ),
      ServiceItem(
        title: 'IT Projects',
        desc: 'Refer offshore software design, development, and cloud projects.',
        minTier: MembershipTier.Platinum,
        icon: Icons.code,
        color: const Color(0xFFFFC107),
        detailsKeys: ['Project Details', 'Approximate Budget'],
      ),
      ServiceItem(
        title: 'BPO Services',
        desc: 'Submit outsourcing center support, voice, and chat leads.',
        minTier: MembershipTier.Platinum,
        icon: Icons.headset_mic,
        color: Colors.pinkAccent,
        detailsKeys: ['Agents Required', 'Duration of Contract'],
      ),
    ];

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: servicesList.length,
      itemBuilder: (context, idx) {
        final service = servicesList[idx];
        final isUnlocked = _checkAccess(agent.membership, service.minTier);

        return GestureDetector(
          onTap: () {
            if (isUnlocked) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ServiceDetailsScreen(service: service)),
              );
            } else {
              _showUpgradePromo(context, state, service.minTier);
            }
          },
          child: GlassCard(
            borderColor: isUnlocked ? service.color : Colors.grey[700],
            borderOpacity: isUnlocked ? 0.3 : 0.1,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isUnlocked ? service.color : Colors.grey).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(service.icon, color: isUnlocked ? service.color : Colors.grey, size: 24),
                    ),
                    if (!isUnlocked)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, color: Colors.amber, size: 14),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? (isUnlocked ? Colors.white : Colors.white30)
                            : (isUnlocked ? Colors.black87 : Colors.black38),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? (isUnlocked ? Colors.white60 : Colors.white24)
                            : (isUnlocked ? Colors.black54 : Colors.black26),
                      ),
                    ),
                  ],
                ),
                if (!isUnlocked)
                  Text(
                    'Requires ${service.minTier.name}+',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber),
                  )
                else
                  const Text(
                    'Access Unlocked',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  bool _checkAccess(MembershipTier agentTier, MembershipTier requiredTier) {
    return agentTier.index >= requiredTier.index;
  }

  void _showUpgradePromo(BuildContext context, AppStateProvider state, MembershipTier needed) {
    final pricing = state.pricings.firstWhere((p) => p.tier == needed);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.lock_open, color: Colors.amber),
              const SizedBox(width: 8),
              Text('Unlock ${needed.name} Plan'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This service requires a ${needed.name} membership or higher.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3B6E).withOpacity(0.05),
                  border: Border.all(color: const Color(0xFF1A3B6E).withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upgrade Cost:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₹${pricing.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Includes Benefits:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ...pricing.benefits.map((b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 12, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(child: Text(b, style: const TextStyle(fontSize: 11))),
                      ],
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
              onPressed: () {
                Navigator.pop(ctx);
                // Trigger Simulated Razorpay Upgrade
                _simulateRazorpayUpgrade(context, state, needed);
              },
              child: const Text('Upgrade via Razorpay', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _simulateRazorpayUpgrade(BuildContext context, AppStateProvider state, MembershipTier needed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!ctx.mounted) return;
          state.upgradeAgentMembership(needed);
          Navigator.pop(ctx);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
              content: Text('Payment Successful! You are now a ${needed.name} Member!'),
              backgroundColor: Colors.green,
            ),
          );
        });

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(color: const Color(0xFF1A3B6E)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Razorpay Gateway Loading...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Completing secure transaction with FIC Membership Club',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ServiceItem {
  final String title;
  final String desc;
  final MembershipTier minTier;
  final IconData icon;
  final Color color;
  final List<String> detailsKeys;

  ServiceItem({
    required this.title,
    required this.desc,
    required this.minTier,
    required this.icon,
    required this.color,
    required this.detailsKeys,
  });
}
