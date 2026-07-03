import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class KycTeamDocumentsTab extends StatefulWidget {
  const KycTeamDocumentsTab({super.key});

  @override
  State<KycTeamDocumentsTab> createState() => _KycTeamDocumentsTabState();
}

class _KycTeamDocumentsTabState extends State<KycTeamDocumentsTab> {
  String _selectedTab = 'Pending';
  LeadModel? _selectedDoc;
  List<Map<String, dynamic>> _uploadedDocs = [];
  bool _isLoadingDocs = false;

  void _fetchDocumentsForLead(String leadId) async {
    setState(() {
      _isLoadingDocs = true;
      _uploadedDocs = [];
    });
    try {
      final docs = await Provider.of<AppStateProvider>(context, listen: false).getKycDocuments(leadId);
      setState(() {
        _uploadedDocs = docs;
        _isLoadingDocs = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingDocs = false;
      });
    }
  }

  Future<String?> _showRejectionReasonDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject KYC'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    final primaryColor = const Color(0xFF9C27B0);

    final kycLeads = state.leads.where((l) => l.status == LeadStatus.KYC_Pending || l.status == LeadStatus.KYC_Verified).toList();
    final pendingDocs = kycLeads.where((l) => l.status == LeadStatus.KYC_Pending).toList();
    final verifiedDocs = kycLeads.where((l) => l.status == LeadStatus.KYC_Verified).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '4. Documents',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              CircleAvatar(
                backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
                child: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildTab('Pending Documents (${pendingDocs.length})', 'Pending', isDark),
              const SizedBox(width: 24),
              _buildTab('Verified Documents (${verifiedDocs.length})', 'Verified', isDark),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: GlassCard(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 250,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black26 : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black54),
                                    hintText: 'Search by Name / Ref ID',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                  ),
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.filter_list),
                                label: const Text('Filters'),
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                showCheckboxColumn: false,
                                headingRowColor: WidgetStateProperty.all(primaryColor.withValues(alpha: 0.05)),
                                columns: const [
                                  DataColumn(label: Text('Ref ID')),
                                  DataColumn(label: Text('Applicant')),
                                  DataColumn(label: Text('Document Type')),
                                  DataColumn(label: Text('Uploaded Date')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: kycLeads.where((l) {
                                  if (_selectedTab == 'Pending') return l.status == LeadStatus.KYC_Pending;
                                  if (_selectedTab == 'Verified') return l.status == LeadStatus.KYC_Verified;
                                  return false;
                                }).map((doc) {
                                  final isPending = doc.status == LeadStatus.KYC_Pending;
                                  return DataRow(
                                    onSelectChanged: (selected) {
                                      if (selected == true) {
                                        setState(() => _selectedDoc = doc);
                                        _fetchDocumentsForLead(doc.id);
                                      }
                                    },
                                    cells: [
                                      DataCell(Text(doc.id.substring(0, 8), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                      DataCell(Text(doc.customerName ?? 'N/A', style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                                      DataCell(Text('KYC Documents', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                      DataCell(Text('${doc.dateCreated.day}/${doc.dateCreated.month}/${doc.dateCreated.year}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.circle, size: 8, color: isPending ? Colors.orange : Colors.green),
                                            const SizedBox(width: 4),
                                            Text(doc.status.name, style: TextStyle(color: isPending ? Colors.orange : Colors.green)),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        OutlinedButton(
                                          onPressed: () {
                                            setState(() => _selectedDoc = doc);
                                            _fetchDocumentsForLead(doc.id);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: isDark ? Colors.white : Colors.black,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                          ),
                                          child: const Text('View'),
                                        )
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width > 900) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildDocumentPreview(isDark, primaryColor),
                  ),
                ]
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width <= 900) ...[
            const SizedBox(height: 16),
            _buildDocumentPreview(isDark, primaryColor),
          ]
        ],
      ),
    );
  }

  Widget _buildTab(String title, String tabId, bool isDark) {
    final isSelected = _selectedTab == tabId;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabId),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF9C27B0) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF9C27B0) : (isDark ? Colors.white54 : Colors.black54),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(bool isDark, Color primaryColor) {
    if (_selectedDoc == null) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Select a document to view', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
      );
    }

    final state = Provider.of<AppStateProvider>(context, listen: false);

    Map<String, dynamic>? getDoc(String docType) {
      try {
        return _uploadedDocs.firstWhere((d) => d['docType'] == docType);
      } catch (_) {
        return null;
      }
    }

    Widget buildDocItem(String label, String docType) {
      final doc = getDoc(docType);
      if (doc == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
              const SizedBox(height: 4),
              Text('No document uploaded', style: TextStyle(color: Colors.red[300], fontSize: 13)),
            ],
          ),
        );
      }

      final baseUrl = ApiClient.instance.options.baseUrl;
      final fileUrl = '$baseUrl${doc['filePath']}';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fileUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: isDark ? Colors.white10 : Colors.black12,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: isDark ? Colors.white10 : Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    final aadhaarFrontDoc = getDoc('aadhaar_front');
    final panDoc = getDoc('pan_card');
    
    final aadhaarNumber = aadhaarFrontDoc?['aadhaarNumber'] ?? 'N/A';
    final panNumber = panDoc?['panNumber'] ?? 'N/A';

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 24),
            _buildDetailRow('Applicant', _selectedDoc!.customerName ?? 'N/A', isDark),
            const SizedBox(height: 16),
            _buildDetailRow('Uploaded Date', '${_selectedDoc!.dateCreated.day}/${_selectedDoc!.dateCreated.month}/${_selectedDoc!.dateCreated.year}', isDark),
            const SizedBox(height: 16),
            _buildDetailRow('Aadhaar No.', aadhaarNumber, isDark),
            const SizedBox(height: 16),
            _buildDetailRow('PAN Card No.', panNumber, isDark),
            const SizedBox(height: 24),
            
            if (_isLoadingDocs)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_uploadedDocs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No documents uploaded yet by customer.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else ...[
              buildDocItem('Aadhaar Front', 'aadhaar_front'),
              buildDocItem('Aadhaar Back', 'aadhaar_back'),
              buildDocItem('PAN Card', 'pan_card'),
              buildDocItem('Live Photo', 'live_photo'),
              buildDocItem('Passport Photo', 'passport_photo'),
            ],
            
            const SizedBox(height: 24),
            
            if (_selectedDoc!.status == LeadStatus.KYC_Pending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await state.verifyLead(_selectedDoc!.id, LeadStatus.KYC_Verified);
                        setState(() {
                          _selectedDoc = null;
                          _uploadedDocs = [];
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('KYC Verified successfully!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Verify KYC', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final reason = await _showRejectionReasonDialog(context);
                        if (reason != null && reason.isNotEmpty) {
                          await state.verifyLead(_selectedDoc!.id, LeadStatus.KYC_Rejected, reason: reason);
                          setState(() {
                            _selectedDoc = null;
                            _uploadedDocs = [];
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('KYC Rejected.')),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Reject KYC', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
