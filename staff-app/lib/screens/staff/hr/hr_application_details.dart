import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class HrApplicationDetails extends StatefulWidget {
  final String leadId;

  const HrApplicationDetails({super.key, required this.leadId});

  @override
  State<HrApplicationDetails> createState() => _HrApplicationDetailsState();
}

class _HrApplicationDetailsState extends State<HrApplicationDetails> {
  final Color primaryDark = const Color(0xFF0B132B);
  final Color cardDark = const Color(0xFF1C2541);
  final Color accentYellow = const Color(0xFFFFC107);
  
  late Future<LeadModel> _leadFuture;
  late Future<List<KycDocument>> _docsFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _leadFuture = LeadService().getLeadById(widget.leadId);
    _docsFuture = LeadService().getKycDocuments(widget.leadId);
  }

  Future<void> _updateStatus(AppStateProvider state, LeadStatus status) async {
    try {
      await state.verifyLead(widget.leadId, status);
      if (mounted) {
        showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Application marked as ${status.name}'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
        setState(() {
          _fetchData();
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Failed to update: $e'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    
    final bgColor = isDark ? primaryDark : const Color(0xFFF4F7FE);
    final cardColor = isDark ? cardDark : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2B3674);
    final textMuted = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text('Application Details', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder(
        future: Future.wait([_leadFuture, _docsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
          }

          final lead = snapshot.data![0] as LeadModel;
          final docs = snapshot.data![1] as List<KycDocument>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(lead, cardColor, textColor, textMuted),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('KYC Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    if (docs.isEmpty)
                      Text('No documents uploaded', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (docs.isNotEmpty)
                  _buildDocumentsGrid(docs, cardColor, textColor, textMuted),
                
                const SizedBox(height: 32),
                
                if (lead.status != LeadStatus.Approved && lead.status != LeadStatus.Rejected)
                  _buildActionButtons(state),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildProfileCard(LeadModel lead, Color cardColor, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: accentYellow.withValues(alpha: 0.2),
                child: Text(
                  lead.customerName != null && lead.customerName!.isNotEmpty ? lead.customerName![0].toUpperCase() : '?',
                  style: TextStyle(color: accentYellow, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lead.customerName ?? 'Unknown', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    Text(lead.serviceType, style: TextStyle(fontSize: 16, color: textMuted)),
                  ],
                ),
              ),
              _buildStatusBadge(lead.status.name),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(child: _buildInfoItem('Phone', lead.customerPhone ?? 'N/A', Icons.phone, textColor, textMuted)),
              Expanded(child: _buildInfoItem('Email', lead.customerEmail ?? 'N/A', Icons.email, textColor, textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoItem('Date Applied', lead.dateCreated.toString().split(' ')[0], Icons.calendar_today, textColor, textMuted)),
              Expanded(child: _buildInfoItem('Agent Code', lead.agentCode ?? 'Direct', Icons.person_pin, textColor, textMuted)),
            ],
          ),
          if (lead.details.containsKey('Resume') || lead.details.containsKey('ResumeUrl')) ...[
            const Divider(height: 32),
            Row(
              children: [
                Icon(Icons.description, size: 24, color: accentYellow),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resume / CV', style: TextStyle(fontSize: 12, color: textMuted)),
                      Text(
                        lead.details['Resume'] ?? 'Resume File',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (lead.details['ResumeUrl'] != null && lead.details['ResumeUrl']!.toString().isNotEmpty)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final rawUrl = lead.details['ResumeUrl']!;
                      final fullUrl = rawUrl.startsWith('http')
                          ? rawUrl
                          : '${ApiClient.baseUrl}$rawUrl';
                      final uri = Uri.parse(fullUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Could not open resume link.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color textColor, Color textMuted) {
    return Row(
      children: [
        Icon(icon, size: 20, color: textMuted),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: textMuted)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    if (status == 'Approved' || status == 'KYC_Verified') color = Colors.green;
    else if (status == 'Rejected') color = Colors.red;
    else color = Colors.orange;

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

  Widget _buildDocumentsGrid(List<KycDocument> docs, Color cardColor, Color textColor, Color textMuted) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return _buildDocumentCard(doc, cardColor, textColor, textMuted);
      },
    );
  }

  Widget _buildDocumentCard(KycDocument doc, Color cardColor, Color textColor, Color textMuted) {
    return InkWell(
      onTap: () {
        if (doc.url != null) {
          _showDocumentPreview(doc.url!, doc.docType);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.black12,
                ),
                child: doc.url != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          doc.url!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      )
                    : const Icon(Icons.insert_drive_file, size: 48, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.docType.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (doc.aadhaarNumber != null)
                    Text('No: ${doc.aadhaarNumber}', style: TextStyle(fontSize: 12, color: textMuted)),
                  if (doc.panNumber != null)
                    Text('No: ${doc.panNumber}', style: TextStyle(fontSize: 12, color: textMuted)),
                  Text(
                    doc.uploadedAt.toString().split(' ')[0],
                    style: TextStyle(fontSize: 10, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentPreview(String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppStateProvider state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus(state, LeadStatus.Approved),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Approve', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _updateStatus(state, LeadStatus.Rejected),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reject', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
