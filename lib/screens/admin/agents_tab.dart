import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/glass_card.dart';
import '../../models/user_model.dart';

class AdminAgentsTab extends StatelessWidget {
  const AdminAgentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: const Color(0xFFFFC107),
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            indicatorColor: const Color(0xFFFFC107),
            tabs: const [
              Tab(text: 'Registry'),
              Tab(text: 'KYC Queue'),
              Tab(text: 'Referral Trees'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRegistryTab(context, state, isDark),
                _buildKycTab(context, state, isDark),
                _buildReferralTab(context, state, isDark),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRegistryTab(BuildContext context, AppStateProvider state, bool isDark) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.agents.length,
      itemBuilder: (context, idx) {
        final agent = state.agents[idx];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF1A3B6E).withOpacity(0.1),
                        child: Text(
                          agent.name.substring(0, 1),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFFFFC107)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                            ),
                          ),
                          Text(
                            'Code: ${agent.agentCode} | Tier: ${agent.membership.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: agent.kycStatus == KycStatus.Approved
                          ? Colors.green.withOpacity(0.15)
                          : agent.kycStatus == KycStatus.Pending
                              ? Colors.amber.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'KYC: ${agent.kycStatus.name}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: agent.kycStatus == KycStatus.Approved
                            ? Colors.green
                            : agent.kycStatus == KycStatus.Pending
                                ? Colors.amber
                                : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniInfo('Earnings', '₹${agent.totalEarnings.toStringAsFixed(0)}', isDark),
                  _buildMiniInfo('Wallet Bal', '₹${agent.walletBalance.toStringAsFixed(0)}', isDark),
                  _buildMiniInfo('Referred By', agent.referredBy ?? 'None', isDark),
                ],
              ),
            ],
          ),
        ).marginOnly(bottom: 12);
      },
    );
  }

  Widget _buildMiniInfo(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Add Staff form moved to staff_tab.dart


  Widget _buildKycTab(BuildContext context, AppStateProvider state, bool isDark) {
    final pendingKyc = state.agents.where((a) => a.kycStatus == KycStatus.Pending).toList();

    if (pendingKyc.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
            const SizedBox(height: 12),
            Text(
              'No pending KYC requests',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: pendingKyc.length,
      itemBuilder: (context, idx) {
        final agent = pendingKyc[idx];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agent: ${agent.name} (${agent.agentCode})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDocCard('Aadhaar Card', agent.aadhaarNumber ?? 'N/A', isDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDocCard('PAN Card', agent.panNumber ?? 'N/A', isDark),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDocCard('Bank Name', agent.bankAccountName ?? 'N/A', isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDocCard('Account #', agent.bankAccountNumber ?? 'N/A', isDark),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDocCard('IFSC', agent.bankIfscCode ?? 'N/A', isDark),
                  ),
                ],
              ),
              if (agent.photoUrl != null && agent.photoUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(agent.photoUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ID Photo Attached',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.verified, color: Colors.green, size: 16),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    onPressed: () {
                      state.verifyKyc(agent.id, KycStatus.Rejected);
                    },
                    child: const Text('Reject KYC'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      state.verifyKyc(agent.id, KycStatus.Approved);
                    },
                    child: const Text('Approve KYC', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ).marginOnly(bottom: 12);
      },
    );
  }

  Widget _buildDocCard(String title, String docNum, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        border: Border.all(color: Colors.blue.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1A3B6E)),
          ),
          const SizedBox(height: 4),
          Text(
            docNum,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.attachment, size: 12, color: const Color(0xFF1A3B6E)),
              SizedBox(width: 4),
              Text(
                'doc_scanned.jpg',
                style: TextStyle(fontSize: 9, color: const Color(0xFF1A3B6E), decoration: TextDecoration.underline),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReferralTab(BuildContext context, AppStateProvider state, bool isDark) {
    // We build a simplified tree view.
    // Level 1: Find root level agents (referredBy is null or not matching any other agent)
    // Level 2: Show child nodes referred by level 1.
    final rootAgents = state.agents.where((a) => a.referredBy == null || a.referredBy!.isEmpty).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rootAgents.map((root) {
          final children = state.agents.where((a) => a.referredBy == root.agentCode).toList();

          return Card(
            color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_tree, color: const Color(0xFFFFC107)),
                      const SizedBox(width: 8),
                      Text(
                        'Lineage: ${root.name} (${root.agentCode})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A3B6E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (children.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(
                        'No referrals under this agent.',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    )
                  else
                    ...children.map((child) {
                      // Sub-child referred by child (Level 2)
                      final subChildren = state.agents.where((a) => a.referredBy == child.agentCode).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              const Text('├── ', style: TextStyle(color: const Color(0xFFFFC107), fontWeight: FontWeight.bold)),
                              Icon(Icons.person, size: 16, color: const Color(0xFFFFC107)),
                              const SizedBox(width: 6),
                              Text(
                                '${child.name} (${child.agentCode}) - L1 Direct',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          if (subChildren.isNotEmpty)
                            ...subChildren.map((sub) {
                              return Row(
                                children: [
                                  const SizedBox(width: 44),
                                  const Text('└── ', style: TextStyle(color: const Color(0xFF1A3B6E), fontWeight: FontWeight.bold)),
                                  Icon(Icons.person_outline, size: 14, color: Colors.amber[400]),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${sub.name} (${sub.agentCode}) - L2 Indirect',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ],
                              );
                            })
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
