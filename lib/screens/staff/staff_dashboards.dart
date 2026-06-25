import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/lead_model.dart';
import '../../models/staff_model.dart';
import '../../models/user_model.dart';
import '../../widgets/glass_card.dart';

class StaffDashboardFactory {
  static Widget buildDashboardForRole(StaffRole role, bool isDark) {
    switch (role) {
      case StaffRole.creditCardTL:
        return _TlLeadsDashboard(title: 'Credit Card TL Dashboard', serviceType: 'Credit Card', isDark: isDark);
      case StaffRole.loanTL:
        return _TlLeadsDashboard(title: 'Loan TL Dashboard', serviceType: 'Loan', isDark: isDark);
      case StaffRole.insuranceTL:
        return _TlLeadsDashboard(title: 'Insurance TL Dashboard', serviceType: 'Insurance', isDark: isDark);
      case StaffRole.itProjectManager:
        return _GenericDashboard(title: 'IT Project Manager Dashboard', icon: Icons.developer_board, isDark: isDark);
      case StaffRole.hr:
        return _HrDashboard(isDark: isDark);
      case StaffRole.itSupport:
        return _GenericDashboard(title: 'IT Support Dashboard', icon: Icons.computer, isDark: isDark);
      case StaffRole.kycDepartment:
        return _KycDashboard(isDark: isDark);
      case StaffRole.accountTeam:
        return _GenericDashboard(title: 'Account Team Dashboard', icon: Icons.account_balance_wallet, isDark: isDark);
      case StaffRole.ficHelpDesk:
        return _GenericDashboard(title: 'FIC Help Desk', icon: Icons.help_center, isDark: isDark);
      case StaffRole.other:
      default:
        return _GenericDashboard(title: 'Staff Dashboard', icon: Icons.work, isDark: isDark);
    }
  }
}

class _GenericDashboard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _GenericDashboard({Key? key, required this.title, required this.icon, required this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 32, color: const Color(0xFFFFC107)),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Tasks Pending', '12', Icons.pending_actions),
              _buildStatCard('Tasks Completed', '45', Icons.task_alt),
              _buildStatCard('Messages', '3', Icons.message),
              _buildStatCard('Alerts', '0', Icons.notifications_active),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(0),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1A3B6E).withOpacity(0.1),
                    child: const Icon(Icons.history, color: Color(0xFFFFC107), size: 16),
                  ),
                  title: Text('System Activity ${index + 1}', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text('2 hours ago', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData statIcon) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statIcon, color: const Color(0xFFFFC107), size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E))),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _HrDashboard extends StatefulWidget {
  final bool isDark;
  const _HrDashboard({Key? key, required this.isDark}) : super(key: key);

  @override
  State<_HrDashboard> createState() => _HrDashboardState();
}

class _HrDashboardState extends State<_HrDashboard> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final allJobsLeads = state.leads.where((l) => l.serviceType == 'Jobs').toList();
    
    // Stats
    final total = allJobsLeads.length;
    final pending = allJobsLeads.where((l) => l.status == LeadStatus.Pending).length;
    final converted = allJobsLeads.where((l) => l.status == LeadStatus.Converted || l.status == LeadStatus.Selected).length;
    final process = allJobsLeads.where((l) => l.status == LeadStatus.Process || l.status == LeadStatus.Followup).length;

    // Filter
    final jobsLeads = allJobsLeads.where((l) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return (l.customerName?.toLowerCase().contains(query) ?? false) || 
             (l.agentCode.toLowerCase().contains(query));
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_alt, size: 28, color: Color(0xFFFFC107)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HR Recruitment Center',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF1A3B6E)),
                    ),
                    Text(
                      'Manage and track job referrals',
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Colors.white54 : Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // KPIs
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Referrals', total.toString(), Icons.group, Colors.blue, widget.isDark),
              _buildStatCard('Pending', pending.toString(), Icons.pending_actions, Colors.orange, widget.isDark),
              _buildStatCard('In Process', process.toString(), Icons.sync, Colors.amber, widget.isDark),
              _buildStatCard('Selected', converted.toString(), Icons.verified, Colors.green, widget.isDark),
            ],
          ),
          const SizedBox(height: 32),
          // Search Bar
          TextField(
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Search by applicant name or agent ID...',
              hintStyle: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black54),
              prefixIcon: Icon(Icons.search, color: widget.isDark ? Colors.white54 : Colors.black54),
              filled: true,
              fillColor: widget.isDark ? const Color(0xFF1E212D) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Applications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF1A3B6E)),
          ),
          const SizedBox(height: 16),
          if (jobsLeads.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 64, color: widget.isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 16),
                    Text('No applications found.', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87, fontSize: 16)),
                  ],
                ),
              )
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jobsLeads.length,
              itemBuilder: (context, index) {
                final lead = jobsLeads[index];
                return Card(
                  color: widget.isDark ? const Color(0xFF1E212D) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFFFC107).withOpacity(0.2),
                                    radius: 20,
                                    child: Text(
                                      (lead.customerName ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(lead.customerName ?? 'Unknown', style: TextStyle(color: widget.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.badge, size: 14, color: widget.isDark ? Colors.white54 : Colors.black54),
                                            const SizedBox(width: 4),
                                            Text(lead.details['Desired Role'] ?? 'Not specified', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              decoration: BoxDecoration(
                                color: _getStatusColor(lead.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getStatusColor(lead.status).withOpacity(0.5)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<LeadStatus>(
                                  value: [LeadStatus.Pending, LeadStatus.Process, LeadStatus.Followup, LeadStatus.Converted, LeadStatus.Selected].contains(lead.status) ? lead.status : LeadStatus.Pending,
                                  dropdownColor: widget.isDark ? const Color(0xFF2C3140) : Colors.white,
                                  icon: Icon(Icons.arrow_drop_down, color: _getStatusColor(lead.status), size: 20),
                                  isDense: true,
                                  style: TextStyle(color: _getStatusColor(lead.status), fontWeight: FontWeight.bold, fontSize: 12),
                                  items: [
                                    LeadStatus.Pending,
                                    LeadStatus.Process,
                                    LeadStatus.Followup,
                                    LeadStatus.Converted,
                                    LeadStatus.Selected
                                  ].map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.name),
                                  )).toList(),
                                  onChanged: (newStatus) {
                                    if (newStatus != null) {
                                      state.verifyLead(lead.id, newStatus);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Status updated to ${newStatus.name}')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            Icon(Icons.event, size: 14, color: widget.isDark ? Colors.white54 : Colors.black54),
                            const SizedBox(width: 4),
                            Text('Applied: ${lead.dateCreated.toString().split(' ')[0]}', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                            const Spacer(),
                            Icon(Icons.storefront, size: 14, color: widget.isDark ? Colors.white54 : Colors.black54),
                            const SizedBox(width: 4),
                            Text('Agent: ${lead.agentName ?? lead.agentCode}', style: TextStyle(color: widget.isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E), fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E))),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.Pending: return Colors.orange;
      case LeadStatus.Process: return Colors.blue;
      case LeadStatus.Followup: return Colors.purple;
      case LeadStatus.Converted: return Colors.teal;
      case LeadStatus.Selected: return Colors.green;
      default: return Colors.grey;
    }
  }
}

class _KycDashboard extends StatefulWidget {
  final bool isDark;
  const _KycDashboard({Key? key, required this.isDark}) : super(key: key);

  @override
  State<_KycDashboard> createState() => _KycDashboardState();
}

class _KycDashboardState extends State<_KycDashboard> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final allAgents = state.agents;

    final pendingKyc = allAgents.where((a) => a.kycStatus == KycStatus.Pending).toList();
    final approvedKyc = allAgents.where((a) => a.kycStatus == KycStatus.Approved).toList();
    final rejectedKyc = allAgents.where((a) => a.kycStatus == KycStatus.Rejected).toList();

    // Search filter
    final displayedQueue = pendingKyc.where((a) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return a.name.toLowerCase().contains(query) || a.agentCode.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.verified_user, size: 28, color: Color(0xFFFFC107)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KYC Team Dashboard',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF1A3B6E)),
                    ),
                    Text(
                      'Review and process agent KYC submissions',
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Colors.white54 : Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // KPIs
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : (MediaQuery.of(context).size.width > 600 ? 3 : 1),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.0,
            children: [
              _buildStatCard('Pending Reviews', pendingKyc.length.toString(), Icons.pending_actions, Colors.orange, widget.isDark),
              _buildStatCard('Approved', approvedKyc.length.toString(), Icons.check_circle, Colors.green, widget.isDark),
              _buildStatCard('Rejected', rejectedKyc.length.toString(), Icons.cancel, Colors.red, widget.isDark),
            ],
          ),
          const SizedBox(height: 32),
          // Search Bar
          TextField(
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Search pending queue by name or agent ID...',
              hintStyle: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black54),
              prefixIcon: Icon(Icons.search, color: widget.isDark ? Colors.white54 : Colors.black54),
              filled: true,
              fillColor: widget.isDark ? const Color(0xFF1E212D) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 24),
          Text(
            'Action Required (${displayedQueue.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF1A3B6E)),
          ),
          const SizedBox(height: 16),
          if (displayedQueue.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('Queue is empty! Great job.', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedQueue.length,
              itemBuilder: (context, index) {
                final agent = displayedQueue[index];
                return Card(
                  color: widget.isDark ? const Color(0xFF1E212D) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF1A3B6E).withOpacity(0.1),
                              child: Text(
                                agent.name.substring(0, 1),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFC107)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Agent: ${agent.name}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF1A3B6E)),
                                  ),
                                  Text(
                                    'Code: ${agent.agentCode}',
                                    style: TextStyle(fontSize: 13, color: widget.isDark ? Colors.white54 : Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildDocCard('Aadhaar Card', agent.aadhaarNumber ?? 'N/A', widget.isDark)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDocCard('PAN Card', agent.panNumber ?? 'N/A', widget.isDark)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildDocCard('Bank Name', agent.bankAccountName ?? 'N/A', widget.isDark)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildDocCard('Account #', agent.bankAccountNumber ?? 'N/A', widget.isDark)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildDocCard('IFSC', agent.bankIfscCode ?? 'N/A', widget.isDark)),
                          ],
                        ),
                        if (agent.photoUrl != null && agent.photoUrl!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID Photo Attached',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: const [
                                      Icon(Icons.verified, color: Colors.green, size: 14),
                                      SizedBox(width: 4),
                                      Text('Verified Format', style: TextStyle(color: Colors.green, fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject KYC'),
                              onPressed: () {
                                state.verifyKyc(agent.id, KycStatus.Rejected);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('KYC for ${agent.name} rejected.')),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Approve KYC'),
                              onPressed: () {
                                state.verifyKyc(agent.id, KycStatus.Approved);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('KYC for ${agent.name} approved!')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3B6E))),
                Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(String title, String docNum, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3140) : Colors.blue.withOpacity(0.05),
        border: Border.all(color: isDark ? Colors.transparent : Colors.blue.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E)),
          ),
          const SizedBox(height: 6),
          Text(
            docNum,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _TlLeadsDashboard extends StatefulWidget {
  final String title;
  final String serviceType;
  final bool isDark;

  const _TlLeadsDashboard({
    Key? key,
    required this.title,
    required this.serviceType,
    required this.isDark,
  }) : super(key: key);

  @override
  State<_TlLeadsDashboard> createState() => _TlLeadsDashboardState();
}

class _TlLeadsDashboardState extends State<_TlLeadsDashboard> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final allLeads = state.leads;

    // TL sees leads that match their serviceType and are in the workflow pipeline
    final pendingLeads = allLeads.where((l) => 
      l.serviceType == widget.serviceType &&
      (l.status == LeadStatus.Pending || 
       l.status == LeadStatus.Stage1Approved || 
       l.status == LeadStatus.Stage2Approved || 
       l.status == LeadStatus.Stage3Approved ||
       (l.serviceType == 'Loan' && l.status == LeadStatus.Approved))
    ).toList();

    // Search filter
    final displayedQueue = pendingLeads.where((l) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final cName = (l.customerName ?? '').toLowerCase();
      final aCode = l.agentCode.toLowerCase();
      final leadId = l.id.toLowerCase();
      return cName.contains(query) || aCode.contains(query) || leadId.contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.leaderboard, size: 28, color: Colors.blueAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF1A3B6E)),
                    ),
                    Text(
                      'Review and process ${widget.serviceType} applications',
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Colors.white54 : Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Search Bar
          TextField(
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Search by Customer Name, Agent ID, or Lead ID...',
              hintStyle: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black54),
              prefixIcon: Icon(Icons.search, color: widget.isDark ? Colors.white54 : Colors.black54),
              filled: true,
              fillColor: widget.isDark ? const Color(0xFF1E212D) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 24),
          Text(
            'Action Required (${displayedQueue.length})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF1A3B6E)),
          ),
          const SizedBox(height: 16),
          if (displayedQueue.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('No pending ${widget.serviceType} leads! Great job.', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedQueue.length,
              itemBuilder: (context, index) {
                final lead = displayedQueue[index];
                return Card(
                  color: widget.isDark ? const Color(0xFF1E212D) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Lead ID: ${lead.id}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Builder(
                                builder: (context) {
                                  String badgeText = 'Pending';
                                  if (lead.serviceType == 'Loan') {
                                    if (lead.status == LeadStatus.Stage1Approved) badgeText = 'Doc Verification';
                                    else if (lead.status == LeadStatus.Stage2Approved) badgeText = 'Bank Processing';
                                    else if (lead.status == LeadStatus.Approved) badgeText = 'Approved';
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
                                  else if (lead.status.name.contains('Pending')) badgeText = lead.status.name.replaceAll('Stage1', 'Stage 1 ').replaceAll('Stage2', 'Stage 2 ').replaceAll('Stage3', 'Stage 3 ');
                                  else badgeText = lead.status.name;

                                  return Text(
                                    badgeText,
                                    style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Submitted by Agent: ${lead.agentCode}', style: TextStyle(fontSize: 12, color: widget.isDark ? Colors.white70 : Colors.black87)),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Customer Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDark ? Colors.white : Colors.black)),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
                              onPressed: () {
                                final buffer = StringBuffer();
                                buffer.writeln('Lead ID: ${lead.id}');
                                buffer.writeln('Agent Code: ${lead.agentCode}');
                                if (lead.customerName != null && lead.customerName!.isNotEmpty) {
                                  buffer.writeln('Customer: ${lead.customerName} (${lead.customerPhone})');
                                }
                                for (var e in lead.details.entries) {
                                  buffer.writeln('${e.key}: ${e.value}');
                                }
                                Clipboard.setData(ClipboardData(text: buffer.toString()));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Lead details copied to clipboard!')),
                                );
                              },
                              tooltip: 'Copy Details',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (lead.customerName != null && lead.customerName!.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('${lead.customerName} (${lead.customerPhone})', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        // Dynamically render all submitted details (PAN, Type of Loan, etc)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: lead.details.entries.map((e) {
                            return Container(
                              width: MediaQuery.of(context).size.width > 600 ? 250 : double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.isDark ? const Color(0xFF2C3140) : Colors.blue.withOpacity(0.05),
                                border: Border.all(color: widget.isDark ? Colors.transparent : Colors.blue.withOpacity(0.15)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.key,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.isDark ? const Color(0xFFFFC107) : const Color(0xFF1A3B6E)),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    e.value.isEmpty ? 'N/A' : e.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                state.verifyLead(lead.id, LeadStatus.Rejected, reason: 'Rejected by TL');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lead ${lead.id} rejected.')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Reject'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                LeadStatus nextStatus = LeadStatus.Stage1Approved;
                                String msg = 'Verified Documents';
                                
                                if (lead.serviceType == 'Insurance') {
                                  msg = 'KYC Verified';
                                  if (lead.status == LeadStatus.Stage1Approved) { nextStatus = LeadStatus.Stage2Approved; msg = 'Sent to Underwriting'; }
                                  else if (lead.status == LeadStatus.Stage2Approved) { nextStatus = LeadStatus.Approved; msg = 'Policy Activated'; }
                                } else if (lead.serviceType == 'IT Projects') {
                                  msg = 'Requirements Gathered';
                                  if (lead.status == LeadStatus.Stage1Approved) { nextStatus = LeadStatus.Stage2Approved; msg = 'Moved to Development'; }
                                  else if (lead.status == LeadStatus.Stage2Approved) { nextStatus = LeadStatus.Stage3Approved; msg = 'Sent to Testing'; }
                                  else if (lead.status == LeadStatus.Stage3Approved) { nextStatus = LeadStatus.Approved; msg = 'Project Delivered'; }
                                } else {
                                  if (lead.status == LeadStatus.Stage1Approved) { nextStatus = LeadStatus.Stage2Approved; msg = 'Sent to Bank'; }
                                  else if (lead.status == LeadStatus.Stage2Approved) { nextStatus = LeadStatus.Approved; msg = 'Final Approval'; }
                                  else if (lead.status == LeadStatus.Approved) { nextStatus = LeadStatus.Dispatched; msg = 'Marked as Disbursed'; }
                                }
                                
                                state.verifyLead(lead.id, nextStatus);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lead ${lead.id}: $msg!')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(
                                lead.serviceType == 'Insurance' ? 
                                  (lead.status == LeadStatus.Pending ? 'Verify KYC' : 
                                  (lead.status == LeadStatus.Stage1Approved ? 'Send to Underwriting' : 'Activate Policy')) 
                                : lead.serviceType == 'IT Projects' ? 
                                  (lead.status == LeadStatus.Pending ? 'Start Requirements' : 
                                  (lead.status == LeadStatus.Stage1Approved ? 'Start Development' : 
                                  (lead.status == LeadStatus.Stage2Approved ? 'Send to Testing' : 'Deliver Project')))
                                :
                                  (lead.status == LeadStatus.Pending ? 'Verify Documents' : 
                                  (lead.status == LeadStatus.Stage1Approved ? 'Send to Bank' : 
                                  (lead.status == LeadStatus.Stage2Approved ? 'Final Approval' : 'Mark Disbursed')))
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

