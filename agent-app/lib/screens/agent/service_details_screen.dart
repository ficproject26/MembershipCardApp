import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'services_tab.dart'; // To get ServiceItem
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceItem service;

  const ServiceDetailsScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  String _selectedFilter = 'All';

  String _getStatusText(LeadModel lead, String serviceTitle) {
    String statusText = lead.status.name;
    if (serviceTitle == 'Credit Card') {
      if (lead.status == LeadStatus.Stage1Pending || lead.status == LeadStatus.Stage2Pending) statusText = 'Pending';
      else if (lead.status == LeadStatus.Stage2Approved) statusText = 'Verified';
      else if (lead.status == LeadStatus.Stage3Pending) statusText = 'Awaiting Bank';
      else if (lead.status == LeadStatus.Approved) statusText = 'Approved';
      else if (lead.status == LeadStatus.Rejected || lead.status == LeadStatus.Stage1Rejected || lead.status == LeadStatus.Stage2Rejected || lead.status == LeadStatus.Stage3Rejected) statusText = 'Rejected';
    } else if (serviceTitle == 'Loan') {
      if (lead.status == LeadStatus.Pending) statusText = 'Pending';
      else if (lead.status == LeadStatus.Stage1Approved) statusText = 'Verify';
      else if (lead.status == LeadStatus.Stage2Approved) statusText = 'Bank';
      else if (lead.status == LeadStatus.Dispatched) statusText = 'Disbursed';
    } else if (serviceTitle == 'Insurance') {
      if (lead.status == LeadStatus.Pending) statusText = 'Submitted';
      else if (lead.status == LeadStatus.Stage1Approved) statusText = 'KYC';
      else if (lead.status == LeadStatus.Stage2Approved) statusText = 'Underwriting';
      else if (lead.status == LeadStatus.Approved) statusText = 'Active';
    } else if (serviceTitle == 'IT Projects') {
      if (lead.status == LeadStatus.Pending) statusText = 'Proposed';
      else if (lead.status == LeadStatus.Stage1Approved) statusText = 'Requirements';
      else if (lead.status == LeadStatus.Stage2Approved) statusText = 'In Development';
      else if (lead.status == LeadStatus.Stage3Approved) statusText = 'Testing';
      else if (lead.status == LeadStatus.Approved) statusText = 'Delivered';
      else if (lead.status == LeadStatus.Rejected || lead.status == LeadStatus.Stage1Rejected) statusText = 'Cancelled';
    } else if (serviceTitle == 'BPO Services') {
      if (lead.status == LeadStatus.Pending) statusText = 'Submitted';
      else if (lead.status == LeadStatus.Stage1Approved) statusText = 'Training';
      else if (lead.status == LeadStatus.Approved) statusText = 'Live';
      else if (lead.status == LeadStatus.Rejected) statusText = 'Dropped';
    }
    if (statusText == lead.status.name) {
      statusText = statusText.replaceAll('Stage1', 'Stage 1 ').replaceAll('Stage2', 'Stage 2 ').replaceAll('Stage3', 'Stage 3 ');
    }
    return statusText;
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final state = Provider.of<AppStateProvider>(context);
    final isDark = state.isDarkMode;
    
    // Filter leads for this service by this agent
    final agentLeads = state.leads.where((l) => 
      l.serviceType == service.title && 
      l.agentCode == state.currentAgent?.agentCode
    ).toList();

    int approvedCount = agentLeads.where((l) => l.status == LeadStatus.Approved).length;
    int rejectedCount = agentLeads.where((l) => 
      l.status == LeadStatus.Rejected || 
      l.status == LeadStatus.Stage1Rejected || 
      l.status == LeadStatus.Stage2Rejected ||
      l.status == LeadStatus.Stage3Rejected).length;
    int dispatchedCount = agentLeads.where((l) => l.status == LeadStatus.Dispatched).length;
    int notDispatchedCount = agentLeads.where((l) => l.status == LeadStatus.Approved).length;

    // Service-specific KPI definitions
    final Map<String, List<Map<String, dynamic>>> serviceKpis = {
      'Credit Card': [
        {'label': 'Pending', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage1Pending || l.status == LeadStatus.Stage2Pending || l.status == LeadStatus.Stage3Pending).length, 'color': Colors.blue},
        {'label': 'Verified', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage2Approved).length, 'color': Colors.amber},
        {'label': 'Approved', 'count': approvedCount, 'color': Colors.green},
        {'label': 'Rejected', 'count': rejectedCount, 'color': Colors.red},
      ],
      'Loan': [
        {'label': 'Pending', 'count': agentLeads.where((l) => l.status == LeadStatus.Pending).length, 'color': Colors.blue},
        {'label': 'Verify', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage1Approved).length, 'color': Colors.amber},
        {'label': 'Bank', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage2Approved).length, 'color': Colors.orange},
        {'label': 'Approved', 'count': approvedCount, 'color': Colors.green},
        {'label': 'Disbursed', 'count': dispatchedCount, 'color': Colors.teal},
        {'label': 'Rejected', 'count': rejectedCount, 'color': Colors.red},
      ],
      'Jobs': [
        {'label': 'Pending', 'count': agentLeads.where((l) => l.status == LeadStatus.Pending).length, 'color': Colors.blue},
        {'label': 'Process', 'count': agentLeads.where((l) => l.status == LeadStatus.Process).length, 'color': Colors.amber},
        {'label': 'Followup', 'count': agentLeads.where((l) => l.status == LeadStatus.Followup).length, 'color': Colors.orange},
        {'label': 'Converted', 'count': agentLeads.where((l) => l.status == LeadStatus.Converted).length, 'color': Colors.teal},
        {'label': 'Selected', 'count': agentLeads.where((l) => l.status == LeadStatus.Selected).length, 'color': Colors.green},
      ],
      'Insurance': [
        {'label': 'Submitted', 'count': agentLeads.where((l) => l.status == LeadStatus.Pending).length, 'color': Colors.blue},
        {'label': 'KYC', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage1Approved).length, 'color': Colors.amber},
        {'label': 'Underwriting', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage2Approved).length, 'color': Colors.orange},
        {'label': 'Active', 'count': approvedCount, 'color': Colors.green},
        {'label': 'Rejected', 'count': rejectedCount, 'color': Colors.red},
      ],
      'IT Projects': [
        {'label': 'Proposed', 'count': agentLeads.where((l) => l.status == LeadStatus.Pending).length, 'color': Colors.blue},
        {'label': 'Requirements', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage1Approved).length, 'color': Colors.amber},
        {'label': 'In Development', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage2Approved).length, 'color': Colors.orange},
        {'label': 'Testing', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage3Approved).length, 'color': Colors.purple},
        {'label': 'Delivered', 'count': approvedCount, 'color': Colors.green},
        {'label': 'Cancelled', 'count': rejectedCount, 'color': Colors.red},
      ],
      'BPO Services': [
        {'label': 'Submitted', 'count': agentLeads.where((l) => l.status == LeadStatus.Pending).length, 'color': Colors.blue},
        {'label': 'Training', 'count': agentLeads.where((l) => l.status == LeadStatus.Stage1Approved).length, 'color': Colors.amber},
        {'label': 'Live', 'count': approvedCount, 'color': Colors.green},
        {'label': 'Dropped', 'count': rejectedCount, 'color': Colors.red},
      ],
    };

    List<Map<String, dynamic>> rawKpis = serviceKpis[service.title] ?? [
      {'label': 'Pending', 'count': agentLeads.where((l) => l.status == LeadStatus.Pending).length, 'color': Colors.blue},
      {'label': 'Approved', 'count': approvedCount, 'color': Colors.green},
      {'label': 'Dispatched', 'count': dispatchedCount, 'color': Colors.teal},
      {'label': 'Rejected', 'count': rejectedCount, 'color': Colors.red},
    ];

    final kpis = [
      {'label': 'All', 'count': agentLeads.length, 'color': Colors.blueAccent},
      ...rawKpis,
    ];

    final filteredLeads = _selectedFilter == 'All' 
      ? agentLeads 
      : agentLeads.where((l) => _getStatusText(l, service.title) == _selectedFilter || (l.status.name == _selectedFilter)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(service.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              service.desc,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          if (state.eligibleNotes[service.title] != null && state.eligibleNotes[service.title]!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blueAccent, size: 18),
                      const SizedBox(width: 8),
                      const Text('Eligible Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(state.eligibleNotes[service.title]!, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
              children: [
                for (int idx = 0; idx < kpis.length; idx++)
                  _buildKpiCard(context, kpis[idx]['label'] as String, kpis[idx]['count'] as int, kpis[idx]['color'] as Color),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filteredLeads.isEmpty
                ? Center(
                    child: Text('No referrals found for $_selectedFilter.'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredLeads.map((lead) {
                          String statusText = _getStatusText(lead, service.title);

                          return DataRow(
                            selected: false,
                            onSelectChanged: (selected) {
                              if (selected == true) {
                                if (service.title == 'Credit Card') {
                                  if (lead.status == LeadStatus.Stage1Approved) {
                                    _showCreditCardStage2Wizard(context, state, lead);
                                  } else if (lead.status == LeadStatus.Stage2Approved) {
                                    _showCreditCardStage3Wizard(context, state, lead);
                                  }
                                }
                              }
                            },
                            cells: [
                              DataCell(Text(lead.customerName?.isNotEmpty == true ? lead.customerName! : 'Customer')),
                              DataCell(Text(statusText)),
                              DataCell(Text(lead.dateCreated.toString().split(' ')[0])),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (service.title == 'Credit Card') {
            _showCreditCardStage1Wizard(context, state);
          } else {
            _showLeadSubmissionWizard(context, state, service);
          }
        },
        backgroundColor: service.color,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Referral', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showCreditCardStage1Wizard(BuildContext context, AppStateProvider state) {
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    final mobileController = TextEditingController();
    final emailController = TextEditingController();
    final panController = TextEditingController();
    final pincodeController = TextEditingController();
    final fatherController = TextEditingController();
    final motherController = TextEditingController();
    final addressController = TextEditingController();
    final companyController = TextEditingController();
    final designationController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Submit Credit Card Lead'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Full Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: dobController, decoration: const InputDecoration(labelText: 'Date of Birth (DD/MM/YYYY)', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: mobileController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Customer Contact Number', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: panController, decoration: const InputDecoration(labelText: 'Customer PAN Card', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: pincodeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Customer Pincode', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: fatherController, decoration: const InputDecoration(labelText: 'Father Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: motherController, decoration: const InputDecoration(labelText: 'Mother Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Residential Address', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: designationController, decoration: const InputDecoration(labelText: 'Designation', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3B6E)),
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    mobileController.text.trim().isEmpty ||
                    panController.text.trim().isEmpty ||
                    pincodeController.text.trim().isEmpty) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Notification"),
                      content: const Text('Please fill out required fields (Name, Mobile, PAN, and Pincode)'),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                    ),
                  );
                  return;
                }

                state.submitLead(
                  customerName: nameController.text.trim(),
                  customerPhone: mobileController.text.trim(),
                  customerEmail: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                  serviceType: 'Credit Card',
                  details: {
                    'DOB': dobController.text.trim(),
                    'PAN': panController.text.trim(),
                    'Pincode': pincodeController.text.trim(),
                    'Father Name': fatherController.text.trim(),
                    'Mother Name': motherController.text.trim(),
                    'Email': emailController.text.trim(),
                    'Residential Address': addressController.text.trim(),
                    'Company Name': companyController.text.trim(),
                    'Designation': designationController.text.trim(),
                  },
                  status: LeadStatus.Stage2Pending,
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    width: 400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: const Text('Credit Card Lead Submitted Successfully! Awaiting TL Approval.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Submit Lead', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCreditCardStage2Wizard(BuildContext context, AppStateProvider state, LeadModel lead) {
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    final mobileController = TextEditingController();
    final panController = TextEditingController(text: lead.details['PAN'] ?? '');
    final fatherController = TextEditingController();
    final motherController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final companyController = TextEditingController();
    final designationController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Complete Credit Card Form (Stage 2)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: dobController, decoration: const InputDecoration(labelText: 'Date of Birth', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: mobileController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile No', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: panController, decoration: const InputDecoration(labelText: 'PAN NO', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: fatherController, decoration: const InputDecoration(labelText: 'Father Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: motherController, decoration: const InputDecoration(labelText: 'Mother Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Residential Address', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company Name', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: designationController, decoration: const InputDecoration(labelText: 'Designation', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3B6E)),
              onPressed: () {
                if (nameController.text.trim().isEmpty || mobileController.text.trim().isEmpty) {
                  showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Please fill out all required fields'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                  return;
                }

                state.submitStage2Lead(
                  lead.id,
                  nameController.text.trim(),
                  mobileController.text.trim(),
                  {
                    'DOB': dobController.text.trim(),
                    'PAN': panController.text.trim(),
                    'Father Name': fatherController.text.trim(),
                    'Mother Name': motherController.text.trim(),
                    'Email': emailController.text.trim(),
                    'Residential Address': addressController.text.trim(),
                    'Company Name': companyController.text.trim(),
                    'Designation': designationController.text.trim(),
                  },
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                    content: Text('Stage 2 Submitted Successfully! Awaiting final TL Approval.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Submit Lead', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCreditCardStage3Wizard(BuildContext context, AppStateProvider state, LeadModel lead) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Submit Bank Message (Stage 3)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Paste the exact message the customer received from the bank below:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bank Confirmation Message',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3B6E)),
              onPressed: () {
                if (messageController.text.trim().isEmpty) {
                  showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Please paste the bank message.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                  return;
                }

                state.submitStage3Lead(lead.id, messageController.text.trim());

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                    content: Text('Stage 3 Submitted! Awaiting Final Approval.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Submit to TL', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showLeadSubmissionWizard(
    BuildContext context,
    AppStateProvider state,
    ServiceItem service,
  ) {
    // Shared controllers
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    String? selectedResume;
    String? uploadedResumeUrl;

    // Specific controllers based on service
    final Map<String, TextEditingController> controllers = {};
    String dropdownValue = '';
    List<String> dropdownOptions = [];
    String dropdownLabel = '';

    if (service.title == 'Loan') {
      dropdownLabel = 'Type of Loan';
      dropdownOptions = ['Personal Loan', 'Home Loan', 'Business Loan', 'Car Loan', 'Gold Loan'];
      dropdownValue = dropdownOptions.first;
    } else if (service.title == 'Jobs') {
      controllers['Desired Role'] = TextEditingController();
    } else if (service.title == 'Insurance') {
      dropdownLabel = 'Insurance Category';
      dropdownOptions = ['Term Life Insurance', 'Health Insurance', 'Motor Insurance', 'Corporate Health'];
      dropdownValue = dropdownOptions.first;
    } else if (service.title == 'IT Projects') {
      dropdownLabel = 'Project Type';
      dropdownOptions = ['Web Application', 'Mobile App', 'Cloud Infrastructure', 'UI/UX Design', 'Custom Software'];
      dropdownValue = dropdownOptions.first;
    } else if (service.title == 'BPO Services') {
      controllers['Agents Required'] = TextEditingController();
      dropdownLabel = 'Service Type';
      dropdownOptions = ['Inbound Customer Support', 'Outbound Sales', 'Tech Support', 'Data Entry', 'Back Office'];
      dropdownValue = dropdownOptions.first;
    } else {
      // Fallback
      for (var key in service.detailsKeys) {
        controllers[key] = TextEditingController();
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Submit ${service.title} Lead'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Customer Full Name', isDense: true),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Customer Contact Number', isDense: true),
                    ),
                    const SizedBox(height: 10),
                    if (dropdownOptions.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: dropdownValue,
                        decoration: InputDecoration(labelText: dropdownLabel, isDense: true),
                        items: dropdownOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() { dropdownValue = val; });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (service.title == 'Jobs') ...[
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'doc', 'docx'],
                              );
                              if (result != null) {
                                final file = result.files.single;
                                final fileName = file.name;
                                MultipartFile multipartFile;
                                if (kIsWeb) {
                                  multipartFile = MultipartFile.fromBytes(file.bytes!, filename: fileName);
                                } else {
                                  multipartFile = await MultipartFile.fromFile(file.path!, filename: fileName);
                                }
                                final formData = FormData.fromMap({
                                  'file': multipartFile,
                                });
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(child: CircularProgressIndicator()),
                                );
                                try {
                                  final response = await ApiClient.instance.post('/chat/media', data: formData);
                                  final uploadedUrl = response.data['mediaUrl'];
                                  Navigator.pop(context); // Close loading indicator
                                  setState(() {
                                    selectedResume = fileName;
                                    uploadedResumeUrl = uploadedUrl;
                                  });
                                } catch (e) {
                                  Navigator.pop(context); // Close loading indicator
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Error'),
                                      content: Text('Failed to upload file: $e'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.upload_file, size: 18),
                            label: const Text('Upload Resume'),
                          ),
                          const SizedBox(width: 10),
                          if (selectedResume != null)
                            Expanded(child: Text(selectedResume!, style: const TextStyle(color: Colors.green, fontSize: 12), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    ...controllers.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TextField(
                              controller: entry.value,
                              keyboardType: entry.key.contains('Amount') || entry.key.contains('Age') || entry.key.contains('Income') || entry.key.contains('Years') || entry.key.contains('Agents') || entry.key.contains('Duration')
                                  ? TextInputType.number : TextInputType.text,
                              decoration: InputDecoration(
                                labelText: entry.key,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3B6E)),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Please fill out required fields'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                      return;
                    }
                    if (service.title == 'Jobs' && selectedResume == null) {
                      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Please upload a resume'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
                      return;
                    }

                    final Map<String, String> finalDetails = {};
                    if (dropdownLabel.isNotEmpty) {
                      finalDetails[dropdownLabel] = dropdownValue;
                    }
                    controllers.forEach((k, v) {
                      finalDetails[k] = v.text.trim();
                    });
                    if (service.title == 'Jobs') {
                      finalDetails['Resume'] = selectedResume ?? '';
                      finalDetails['ResumeUrl'] = uploadedResumeUrl ?? '';
                    }

                    state.submitLead(
                      customerName: nameController.text.trim(),
                      customerPhone: phoneController.text.trim(),
                      customerEmail: null,
                      serviceType: service.title,
                      details: finalDetails,
                      status: LeadStatus.Pending,
                    );

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(behavior: SnackBarBehavior.floating, width: 400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                        content: Text('${service.title} Lead Submitted Successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Submit Lead', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, int count, Color color) {
    bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.3), width: isSelected ? 2 : 1),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
