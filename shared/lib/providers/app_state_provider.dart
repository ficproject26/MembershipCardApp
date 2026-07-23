import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/user_model.dart';
import '../models/lead_model.dart';
import '../models/transaction_model.dart';
import '../models/config_model.dart';
import '../models/staff_model.dart';
import '../models/kyc_document_model.dart';
import '../services/agent_service.dart';
import '../services/lead_service.dart' as ls;
import '../services/pricing_service.dart';
import '../services/staff_service.dart';
import '../services/notification_service.dart';
import '../services/commission_service.dart';
import '../services/api_client.dart';

class AppStateProvider extends ChangeNotifier {
  // Services
  final AgentService _agentService = AgentService();
  final ls.LeadService _leadService = ls.LeadService();
  final PricingService _pricingService = PricingService();
  final StaffService _staffService = StaffService();
  final CommissionService _commissionService = CommissionService();
  
  IO.Socket? _systemSocket;

  // Theme State
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Loading states
  bool _isLoadingAgents = false;
  bool _isLoadingLeads = false;
  bool _isLoadingPricing = false;
  bool _isLoadingStaff = false;
  bool _isLoadingCommissions = false;
  bool get isLoadingAgents => _isLoadingAgents;
  bool get isLoadingLeads => _isLoadingLeads;
  bool get isLoadingPricing => _isLoadingPricing;
  bool get isLoadingStaff => _isLoadingStaff;
  bool get isLoadingCommissions => _isLoadingCommissions;

  String? _error;
  String? get error => _error;

  // Active Role State
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  bool _isTL = false;
  bool get isTL => _isTL;

  bool _isStaff = false;
  bool get isStaff => _isStaff;

  String? _currentAgentId;
  String? get currentAgentId => _currentAgentId;

  String? _currentStaffId;
  String? get currentStaffId => _currentStaffId;

  AgentModel? get currentAgent {
    if (_isAdmin || _isTL || _isStaff || _currentAgentId == null) return null;
    try {
      return _agents.firstWhere((a) => a.id == _currentAgentId);
    } catch (_) {
      return null;
    }
  }

  StaffModel? get currentStaff {
    if (!_isStaff || _currentStaffId == null) return null;
    try {
      return _staff.firstWhere((s) => s.id == _currentStaffId);
    } catch (_) {
      return null;
    }
  }

  void loginAsAdmin() {
    _isAdmin = true;
    _isTL = false;
    _isStaff = false;
    _currentAgentId = null;
    _currentStaffId = null;
    fetchAllData();
    notifyListeners();
  }

  void loginAsTL() {
    _isAdmin = false;
    _isTL = true;
    _isStaff = false;
    _currentAgentId = null;
    _currentStaffId = null;
    fetchAllData();
    notifyListeners();
  }

  void loginAsAgent(String agentId) {
    _isAdmin = false;
    _isTL = false;
    _isStaff = false;
    _currentAgentId = agentId;
    _currentStaffId = null;
    initSocket();
    fetchAgentLeads(agentId);
    // Register FCM token
    NotificationService().registerToken(agentId, 'agent');
    notifyListeners();
  }

  void loginAsStaff(String staffId) {
    _isAdmin = false;
    _isTL = false;
    _isStaff = true;
    _currentStaffId = staffId;
    _currentAgentId = null;
    fetchAllData();
    // Register FCM token
    NotificationService().registerToken(staffId, 'staff');
    notifyListeners();
  }

  void logout() {
    _isAdmin = false;
    _isTL = false;
    _isStaff = false;
    _currentAgentId = null;
    _currentStaffId = null;
    notifyListeners();
  }

  // Configuration State — defaults used until backend responds
  List<MembershipPricing> _pricings = [
    MembershipPricing(tier: MembershipTier.Basic, price: 0, benefits: ['Basic Dashboard Access']),
    MembershipPricing(tier: MembershipTier.Silver, price: 999, benefits: ['Credit Card Leads', 'Loan Leads', 'Basic Dashboard', '5% Direct Referrals']),
    MembershipPricing(tier: MembershipTier.Gold, price: 1999, benefits: ['Credit Card Leads', 'Loan Leads', 'Jobs Search/Listing', '8% Direct Referrals', '2% Indirect Referrals']),
    MembershipPricing(tier: MembershipTier.Diamond, price: 4999, benefits: ['Credit Card Leads', 'Loan Leads', 'Jobs Listings', 'Insurance Leads', '10% Direct Referrals', '3% Indirect Referrals', 'Priority KYC Review']),
    MembershipPricing(tier: MembershipTier.Platinum, price: 9999, benefits: ['Credit Card Leads', 'Loan Leads', 'Jobs Listings', 'Insurance Leads', 'IT Projects Leads', 'BPO Services Leads', '12% Direct Referrals', '5% Indirect Referrals', 'Dedicated Account Manager']),
  ];
  List<MembershipPricing> get pricings => _pricings;

  double getTierRate(CommissionConfig config, MembershipTier tier) {
    switch (tier) {
      case MembershipTier.Basic:
        return 0.0;
      case MembershipTier.Silver:
        return config.silverRate;
      case MembershipTier.Gold:
        return config.goldRate;
      case MembershipTier.Diamond:
        return config.diamondRate;
      case MembershipTier.Platinum:
        return config.platinumRate;
    }
  }

  List<CommissionConfig> _commissions = [
    CommissionConfig(serviceType: 'Credit Card', silverRate: 1000.0, goldRate: 1500.0, diamondRate: 1800.0, platinumRate: 2000.0),
    CommissionConfig(serviceType: 'Loan', silverRate: 1200.0, goldRate: 1800.0, diamondRate: 2200.0, platinumRate: 2500.0),
    CommissionConfig(serviceType: 'Jobs', silverRate: 400.0, goldRate: 700.0, diamondRate: 900.0, platinumRate: 1000.0),
    CommissionConfig(serviceType: 'Insurance', silverRate: 1500.0, goldRate: 2200.0, diamondRate: 2700.0, platinumRate: 3000.0),
    CommissionConfig(serviceType: 'IT Projects', silverRate: 3000.0, goldRate: 4500.0, diamondRate: 5500.0, platinumRate: 6000.0),
    CommissionConfig(serviceType: 'BPO Services', silverRate: 2500.0, goldRate: 3500.0, diamondRate: 4500.0, platinumRate: 5000.0),
    CommissionConfig(serviceType: 'App Referral', silverRate: 300.0, goldRate: 500.0, diamondRate: 600.0, platinumRate: 700.0),
    CommissionConfig(serviceType: 'Plan Upgrade', silverRate: 500.0, goldRate: 800.0, diamondRate: 1000.0, platinumRate: 1200.0),
  ];
  List<CommissionConfig> get commissions => _commissions;

  // Data from backend
  List<AgentModel> _agents = [];
  List<AgentModel> get agents => _agents;

  List<StaffModel> _staff = [];
  List<StaffModel> get staff => _staff;

  List<LeadModel> _leads = [];
  List<LeadModel> get leads => _leads;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  List<String> _notifications = [
    'Welcome to FIC Membership Club Agent Network!',
    'Double Referral Commission is live this week for Platinum Members!',
  ];
  List<String> get notifications => _notifications;

  Map<String, String> _eligibleNotes = {
    'Credit Card': '• Customer Age must be 21+\n• CIBIL score must be > 700\n• Minimum monthly income ₹25,000\n• No prior defaults on loans or credit cards.',
    'Loan': '• Minimum salary ₹20,000\n• Good CIBIL Score\n• Must have 6 months bank statement.',
    'Jobs': '• Ensure candidate resume is clear and updated.',
    'Insurance': '• Submit KYC documents along with application.',
    'IT Projects': '• Clearly define scope and budget before submitting.',
    'BPO Services': '• Minimum 5 agents required for contract.',
    'Plan Upgrade': '• Earn commission when your referred agent upgrades their membership tier.',
  };
  Map<String, String> get eligibleNotes => _eligibleNotes;

  AppStateProvider() {
    _initSystemSocket();
    Future.microtask(() {
      fetchAllData();
    });
  }

  void _initSystemSocket() {
    try {
      final serverUrl = ApiClient.instance.options.baseUrl;
      _systemSocket = IO.io(serverUrl, IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build());

      _systemSocket?.connect();

      _systemSocket?.onConnect((_) {
        debugPrint('Connected to System Socket for auto-refresh');
      });

      _systemSocket?.on('system_data_changed', (data) {
        debugPrint('System data changed: $data');
        fetchAllData(); // Auto-refresh all data!
      });

      _systemSocket?.onDisconnect((_) {
        debugPrint('Disconnected from System Socket');
      });
    } catch (e) {
      debugPrint('Error initializing system socket: $e');
    }
  }

  Future<AgentModel?> registerAgent({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required MembershipTier membership,
    String? referredBy,
  }) async {
    final code = 'FIC${Random().nextInt(8999) + 1000}';
    try {
      final newAgent = await _agentService.createAgent({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'agentCode': code,
        'membership': membership.name,
        if (referredBy != null && referredBy.isNotEmpty) 'referredBy': referredBy,
      });
      _agents.add(newAgent);
      
      // Issue App Referral Commission if referredBy is present
      if (referredBy != null && referredBy.isNotEmpty) {
        CommissionConfig refConfig = _commissions.firstWhere(
          (c) => c.serviceType == 'App Referral',
          orElse: () => CommissionConfig(serviceType: 'App Referral', silverRate: 300.0, goldRate: 500.0, diamondRate: 600.0, platinumRate: 700.0),
        );

        int refIdx = _agents.indexWhere((a) => a.agentCode == referredBy);
        if (refIdx != -1) {
          final refAg = _agents[refIdx];
          final payout = getTierRate(refConfig, refAg.membership);

          final updatedRefAg = refAg.copyWith(
            walletBalance: refAg.walletBalance + payout,
            totalEarnings: refAg.totalEarnings + payout,
          );
          _agents[refIdx] = updatedRefAg;

          try {
            await _agentService.updateAgent(refAg.id, {
              'walletBalance': updatedRefAg.walletBalance,
              'totalEarnings': updatedRefAg.totalEarnings,
            });
          } catch (_) {}

          _transactions.insert(0, TransactionModel(
            id: 'tx_${Random().nextInt(1000000)}',
            agentCode: refAg.agentCode,
            amount: payout,
            type: TransactionType.DirectCommission,
            status: TransactionStatus.Success,
            description: 'Direct Comm. for App Referral (${newAgent.name})',
            date: DateTime.now(),
          ));
        }
      }

      addNotification('New agent ${newAgent.name} joined as ${newAgent.membership.name} tier!');
      notifyListeners();
      return newAgent;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<AgentModel?> agentLogin(String email, String password) async {
    try {
      _error = null;
      final agent = await _agentService.loginAgent(email, password);
      loginAsAgent(agent.id);
      if (!_agents.any((a) => a.id == agent.id)) {
        _agents.add(agent);
      }
      return agent;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _error = null;
      await _agentService.forgotPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<StaffModel?> registerStaff({
    required String name,
    required String email,
    required String phoneNumber,
    required StaffRole role,
    required String password,
  }) async {
    try {
      if (_staff.any((s) => s.email.toLowerCase() == email.toLowerCase())) {
        throw Exception('A staff member with this email already exists.');
      }
      if (_staff.any((s) => s.phoneNumber == phoneNumber)) {
        throw Exception('A staff member with this phone number already exists.');
      }

      final newStaff = await _staffService.createStaff({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role.name,
        'password': password,
      });
      _staff.add(newStaff);
      addNotification('New staff member ${newStaff.name} joined as ${role.displayName}!');
      notifyListeners();
      return newStaff;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<StaffModel?> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _staffService.updateStaff(id, data);
      final idx = _staff.indexWhere((s) => s.id == id);
      if (idx != -1) _staff[idx] = updated;
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteStaff(String id) async {
    try {
      await _staffService.deleteStaff(id);
      _staff.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }


  Future<StaffModel?> staffLogin(String email, String password) async {
    try {
      _error = null;
      final staff = await _staffService.loginStaff(email, password);
      loginAsStaff(staff.id);
      // Add to local list if not already present
      if (!_staff.any((s) => s.id == staff.id)) {
        _staff.add(staff);
      }
      return staff;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ─── Data Fetching ────────────────────────────────────────────────────────

  Future<void> fetchAllData() async {
    initSocket();
    List<Future> tasks = [
      fetchPricing(),
      fetchCommissions(),
    ];

    if (_currentAgentId != null) {
      tasks.add(fetchAgentLeads(_currentAgentId!));
    } else if (_currentStaffId != null) {
      tasks.add(fetchAgents());
      tasks.add(fetchStaff());
      tasks.add(fetchLeads());
    } else {
      // Default (not logged in)
      tasks.add(fetchAgents());
      tasks.add(fetchStaff());
      tasks.add(fetchLeads());
    }

    await Future.wait(tasks);
  }

  Future<void> fetchAgents() async {
    _isLoadingAgents = true;
    _error = null;
    notifyListeners();
    try {
      _agents = await _agentService.getAllAgents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingAgents = false;
      notifyListeners();
    }
  }

  Future<void> fetchStaff() async {
    _isLoadingStaff = true;
    notifyListeners();
    try {
      _staff = await _staffService.getAllStaff();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingStaff = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeads() async {
    _isLoadingLeads = true;
    _error = null;
    notifyListeners();
    try {
      _leads = await _leadService.getAllLeads();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingLeads = false;
      notifyListeners();
    }
  }

  Future<void> fetchAgentLeads(String agentId) async {
    _isLoadingLeads = true;
    _error = null;
    notifyListeners();
    try {
      _leads = await _leadService.getLeadsByAgent(agentId);
      _agents = await _agentService.getAllAgents();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingLeads = false;
      notifyListeners();
    }
  }

  void initSocket() {
    if (_systemSocket != null && _systemSocket!.connected) return;
    try {
      _systemSocket = IO.io(
        ApiClient.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );
      _systemSocket!.connect();
      _systemSocket!.on('system_data_changed', (data) {
        if (data is Map && (data['model'] == 'Lead' || data['model'] == 'Agent')) {
          if (_currentAgentId != null) {
            fetchAgentLeads(_currentAgentId!);
          } else {
            fetchLeads();
          }
        }
      });
    } catch (e) {
      debugPrint('Socket connection error: $e');
    }
  }

  Future<void> updateLeadStatus(String id, String newStatus) async {
    LeadStatus statusEnum = LeadStatus.values.firstWhere(
      (e) => e.name == newStatus,
      orElse: () => LeadStatus.Pending,
    );
    await verifyLead(id, statusEnum);
  }

  Future<void> fetchPricing() async {
    _isLoadingPricing = true;
    notifyListeners();
    try {
      final result = await _pricingService.getAllPricing();
      print('DEBUG: fetchPricing result: ${result.length} items fetched');
      if (result.isNotEmpty) {
        for (var p in result) {
          int idx = _pricings.indexWhere((existing) => existing.tier == p.tier);
          if (idx != -1) {
            _pricings[idx] = p;
          } else {
            _pricings.add(p);
          }
        }
      }
      print('DEBUG: _pricings is now ${_pricings.map((e) => e.tier.name + ":" + e.price.toString()).toList()}');
    } catch (e) {
      print('DEBUG ERROR: fetchPricing failed: $e');
    } finally {
      _isLoadingPricing = false;
      notifyListeners();
    }
  }

  Future<void> fetchCommissions() async {
    _isLoadingCommissions = true;
    notifyListeners();
    try {
      final result = await _commissionService.getAllCommissions();
      if (result.isNotEmpty) {
        for (var c in result) {
          int idx = _commissions.indexWhere((existing) => existing.serviceType == c.serviceType);
          if (idx != -1) {
            _commissions[idx] = c;
          } else {
            _commissions.add(c);
          }
        }
      }
    } catch (e) {
      print('DEBUG ERROR: fetchCommissions failed: $e');
    } finally {
      _isLoadingCommissions = false;
      notifyListeners();
    }
  }

  // ─── Configuration Updates (Admin) ───────────────────────────────────────

  void updateEligibleNote(String service, String note) {
    _eligibleNotes[service] = note;
    notifyListeners();
  }

  Future<void> updatePricing(MembershipTier tier, double newPrice) async {
    int idx = _pricings.indexWhere((p) => p.tier == tier);
    if (idx == -1) return;

    final existing = _pricings[idx];
    _pricings[idx] = MembershipPricing(
      id: existing.id,
      tier: tier,
      price: newPrice,
      benefits: existing.benefits,
    );
    notifyListeners();

    // Sync to backend
    try {
      if (existing.id != null) {
        await _pricingService.updatePricing(existing.id!, {'price': newPrice});
      } else {
        await _pricingService.createPricing({
          'tier': tier.name,
          'price': newPrice,
          'benefits': existing.benefits.join(','),
        });
        await fetchPricing();
      }
      addNotification('Admin updated membership pricing for ${tier.name} to ₹$newPrice');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void addBenefit(MembershipTier tier, String benefit) {
    int idx = _pricings.indexWhere((p) => p.tier == tier);
    if (idx != -1) {
      final updatedBenefits = List<String>.from(_pricings[idx].benefits)..add(benefit);
      _pricings[idx] = MembershipPricing(
        id: _pricings[idx].id,
        tier: tier,
        price: _pricings[idx].price,
        benefits: updatedBenefits,
      );
      notifyListeners();
      _syncBenefits(idx);
    }
  }

  void updateBenefit(MembershipTier tier, int benefitIdx, String newBenefit) {
    int idx = _pricings.indexWhere((p) => p.tier == tier);
    if (idx != -1 && benefitIdx >= 0 && benefitIdx < _pricings[idx].benefits.length) {
      final updatedBenefits = List<String>.from(_pricings[idx].benefits);
      updatedBenefits[benefitIdx] = newBenefit;
      _pricings[idx] = MembershipPricing(
        id: _pricings[idx].id,
        tier: tier,
        price: _pricings[idx].price,
        benefits: updatedBenefits,
      );
      notifyListeners();
      _syncBenefits(idx);
    }
  }

  void deleteBenefit(MembershipTier tier, int benefitIdx) {
    int idx = _pricings.indexWhere((p) => p.tier == tier);
    if (idx != -1 && benefitIdx >= 0 && benefitIdx < _pricings[idx].benefits.length) {
      final updatedBenefits = List<String>.from(_pricings[idx].benefits)..removeAt(benefitIdx);
      _pricings[idx] = MembershipPricing(
        id: _pricings[idx].id,
        tier: tier,
        price: _pricings[idx].price,
        benefits: updatedBenefits,
      );
      notifyListeners();
      _syncBenefits(idx);
    }
  }

  Future<void> _syncBenefits(int idx) async {
    final p = _pricings[idx];
    try {
      if (p.id != null) {
        await _pricingService.updatePricing(p.id!, {'benefits': p.benefits.join(',')});
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> updateCommission(String service, double silver, double gold, double diamond, double platinum) async {
    try {
      await _commissionService.updateCommission(service, {
        'silverRate': silver,
        'goldRate': gold,
        'diamondRate': diamond,
        'platinumRate': platinum,
      });
      await fetchCommissions();
      addNotification('Admin configured commission for $service: Silver ₹${silver.toStringAsFixed(0)}, Gold ₹${gold.toStringAsFixed(0)}, Diamond ₹${diamond.toStringAsFixed(0)}, Platinum ₹${platinum.toStringAsFixed(0)}');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─── System Notifications ─────────────────────────────────────────────────

  void addNotification(String msg) {
    _notifications.insert(0, msg);
    notifyListeners();
  }

  // ─── Lead Actions ─────────────────────────────────────────────────────────

  Future<void> submitLead({
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    required String serviceType,
    required Map<String, String> details,
    LeadStatus status = LeadStatus.Pending,
  }) async {
    final agent = currentAgent;
    if (agent == null) return;

    try {
      final newLead = await _leadService.createLead({
        'agentId': agent.id,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerEmail': customerEmail,
        'serviceType': serviceType,
        'details': jsonEncode(details),
        'status': status.name,
      });
      final leadWithAgentCode = newLead.agentCode.isEmpty 
          ? newLead.copyWith(agentCode: agent.agentCode) 
          : newLead;
      _leads.insert(0, leadWithAgentCode);
      addNotification('Agent ${agent.agentCode} submitted a new lead for ${customerName ?? "New Customer"} ($serviceType).');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> submitStage2Lead(String leadId, String name, String phone, Map<String, String> extraDetails) async {
    int idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx == -1) return;

    final lead = _leads[idx];
    final newDetails = Map<String, String>.from(lead.details)..addAll(extraDetails);

    final updated = lead.copyWith(
      customerName: name,
      customerPhone: phone,
      details: newDetails,
      status: LeadStatus.Stage2Pending,
    );
    _leads[idx] = updated;
    notifyListeners();

    try {
      await _leadService.updateLead(leadId, {
        'customerName': name,
        'customerPhone': phone,
        'details': jsonEncode(newDetails),
        'status': LeadStatus.Stage2Pending.name,
      });
      addNotification('Agent ${lead.agentCode} submitted Stage 2 for $name.');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> submitStage3Lead(String leadId, String bankMessage) async {
    int idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx == -1) return;

    final lead = _leads[idx];
    final updated = lead.copyWith(bankMessage: bankMessage, status: LeadStatus.Stage3Pending);
    _leads[idx] = updated;
    notifyListeners();

    try {
      await _leadService.updateLead(leadId, {
        'bankMessage': bankMessage,
        'status': LeadStatus.Stage3Pending.name,
      });
      addNotification('Agent ${lead.agentCode} submitted Bank Message for lead ${lead.id}.');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> generateKycLink(String leadId) async {
    try {
      final link = await _leadService.generateKycLink(leadId);
      await fetchLeads();
      return link;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<KycDocument>> getKycDocuments(String leadId) async {
    try {
      return await _leadService.getKycDocuments(leadId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> verifyLead(String leadId, LeadStatus newStatus, {String? reason}) async {
    int idx = _leads.indexWhere((l) => l.id == leadId);
    LeadModel? lead;

    if (idx != -1) {
      lead = _leads[idx].copyWith(status: newStatus, rejectionReason: reason);
      _leads[idx] = lead;
      notifyListeners();
    }

    try {
      final updatedLead = await _leadService.updateLead(leadId, {
        'status': newStatus.name,
        if (reason != null) 'rejectionReason': reason,
      });
      if (idx != -1) {
        _leads[idx] = updatedLead;
      } else {
        _leads.add(updatedLead);
      }
      lead = updatedLead;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return;
    }

    if (lead == null) return;

    bool shouldPayCommission = false;
    if (lead.serviceType == 'Loan') {
      if (newStatus == LeadStatus.Dispatched) shouldPayCommission = true;
    } else if (lead.serviceType == 'IT Projects') {
      if (newStatus == LeadStatus.Stage2Approved || newStatus == LeadStatus.Approved) shouldPayCommission = true;
    } else {
      if (newStatus == LeadStatus.Approved) shouldPayCommission = true;
    }

    if (shouldPayCommission) {
      CommissionConfig commission = _commissions.firstWhere(
        (c) => c.serviceType == lead!.serviceType,
        orElse: () => CommissionConfig(serviceType: lead!.serviceType, silverRate: 400.0, goldRate: 700.0, diamondRate: 900.0, platinumRate: 1000.0),
      );

      int agentIdx = _agents.indexWhere((a) => a.agentCode == lead!.agentCode || a.id == lead!.agentCode);
      if (agentIdx != -1) {
        final ag = _agents[agentIdx];
        double directPayout = getTierRate(commission, ag.membership);

        final updatedAgent = ag.copyWith(
          walletBalance: ag.walletBalance + directPayout,
          totalEarnings: ag.totalEarnings + directPayout,
        );
        _agents[agentIdx] = updatedAgent;

        // Update agent balance on backend
        try {
          await _agentService.updateAgent(ag.id, {
            'walletBalance': updatedAgent.walletBalance,
            'totalEarnings': updatedAgent.totalEarnings,
          });
        } catch (_) {}

        _transactions.insert(0, TransactionModel(
          id: 'tx_${Random().nextInt(1000000)}',
          agentCode: ag.agentCode,
          amount: directPayout,
          type: TransactionType.DirectCommission,
          status: TransactionStatus.Success,
          description: 'Direct Comm. for approved lead #${lead.id} (${lead.customerName ?? "Customer"})',
          date: DateTime.now(),
        ));
      }
      double displayPayout = agentIdx != -1 ? getTierRate(commission, _agents[agentIdx].membership) : 0.0;
      addNotification('Lead approved: Direct commission of ₹${displayPayout.toStringAsFixed(0)} paid to ${lead.agentCode}');
    } else if (newStatus == LeadStatus.Rejected) {
      addNotification('Lead rejected for ${lead.customerName ?? "Customer"}: $reason');
    }

    notifyListeners();
  }

  // ─── Wallet & Withdrawal Actions ──────────────────────────────────────────

  Future<void> requestWithdrawal(double amount) async {
    final agent = currentAgent;
    if (agent == null || agent.walletBalance < amount) return;

    int idx = _agents.indexWhere((a) => a.id == agent.id);
    if (idx != -1) {
      _agents[idx] = agent.copyWith(walletBalance: agent.walletBalance - amount);
      notifyListeners();

      try {
        await _agentService.updateAgent(agent.id, {'walletBalance': agent.walletBalance - amount});
      } catch (e) {
        _error = e.toString();
      }

      _transactions.insert(0, TransactionModel(
        id: 'tx_${Random().nextInt(1000000)}',
        agentCode: agent.agentCode,
        amount: amount,
        type: TransactionType.Withdrawal,
        status: TransactionStatus.Pending,
        description: 'Payout Request to Bank Account',
        date: DateTime.now(),
      ));

      addNotification('Agent ${agent.agentCode} requested a withdrawal of ₹$amount');
      notifyListeners();
    }
  }

  void processPayout(String txId, TransactionStatus newStatus) {
    int txIdx = _transactions.indexWhere((t) => t.id == txId);
    if (txIdx == -1) return;

    final tx = _transactions[txIdx];
    _transactions[txIdx] = tx.copyWith(status: newStatus);

    if (newStatus == TransactionStatus.Success) {
      addNotification('Withdrawal payout of ₹${tx.amount} approved and transfer completed for agent ${tx.agentCode}');
    } else if (newStatus == TransactionStatus.Rejected) {
      int agentIdx = _agents.indexWhere((a) => a.agentCode == tx.agentCode);
      if (agentIdx != -1) {
        final ag = _agents[agentIdx];
        _agents[agentIdx] = ag.copyWith(walletBalance: ag.walletBalance + tx.amount);
        unawaited(_agentService.updateAgent(ag.id, {'walletBalance': ag.walletBalance + tx.amount}));
      }
      addNotification('Withdrawal payout of ₹${tx.amount} rejected and refunded to agent ${tx.agentCode}');
    }

    notifyListeners();
  }

  // ─── KYC Actions ─────────────────────────────────────────────────────────

  Future<void> submitKyc({
    required String aadhaar,
    required String pan,
    required String bankAccountNumber,
    required String bankIfscCode,
    required String bankAccountName,
    required String photoUrl,
  }) async {
    final agent = currentAgent;
    if (agent == null) return;

    int idx = _agents.indexWhere((a) => a.id == agent.id);
    if (idx != -1) {
      _agents[idx] = agent.copyWith(
        kycStatus: KycStatus.Pending,
        aadhaarNumber: aadhaar,
        panNumber: pan,
        bankAccountNumber: bankAccountNumber,
        bankIfscCode: bankIfscCode,
        bankAccountName: bankAccountName,
        photoUrl: photoUrl,
      );
      notifyListeners();

      try {
        await _agentService.updateAgent(agent.id, {
          'kycStatus': KycStatus.Pending.name,
          'aadhaarNumber': aadhaar,
          'panNumber': pan,
          'bankAccountNumber': bankAccountNumber,
          'bankIfscCode': bankIfscCode,
          'bankAccountName': bankAccountName,
          'photoUrl': photoUrl,
        });
        addNotification('Agent ${agent.agentCode} submitted documents for KYC Verification.');
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> verifyKyc(String agentId, KycStatus status) async {
    int idx = _agents.indexWhere((a) => a.id == agentId);
    if (idx == -1) return;

    final ag = _agents[idx];
    _agents[idx] = ag.copyWith(kycStatus: status);
    notifyListeners();

    try {
      await _agentService.updateAgent(agentId, {'kycStatus': status.name});
      addNotification('KYC Verification for agent ${ag.agentCode} updated to ${status.name}.');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─── Upgrade Membership ──────────────────────────────────────────────────

  Future<void> upgradeAgentMembership(MembershipTier tier) async {
    final agent = currentAgent;
    if (agent == null) return;

    final pricing = _pricings.firstWhere((p) => p.tier == tier);

    int idx = _agents.indexWhere((a) => a.id == agent.id);
    if (idx != -1) {
      _agents[idx] = agent.copyWith(membership: tier);
      notifyListeners();

      try {
        await _agentService.updateAgent(agent.id, {'membership': tier.name});
        _transactions.insert(0, TransactionModel(
          id: 'tx_${Random().nextInt(1000000)}',
          agentCode: agent.agentCode,
          amount: pricing.price,
          type: TransactionType.Upgrade,
          status: TransactionStatus.Success,
          description: 'Membership Upgrade to ${tier.name} via Razorpay',
          date: DateTime.now(),
        ));
        
        // Award Plan Upgrade Commission to Referrer
        if (agent.referredBy != null && agent.referredBy!.isNotEmpty) {
          CommissionConfig upgradeConfig = _commissions.firstWhere(
            (c) => c.serviceType == 'Plan Upgrade',
            orElse: () => CommissionConfig(serviceType: 'Plan Upgrade', silverRate: 500.0, goldRate: 800.0, diamondRate: 1000.0, platinumRate: 1200.0),
          );
          int refIdx = _agents.indexWhere((a) => a.agentCode == agent.referredBy);
          if (refIdx != -1) {
            final refAg = _agents[refIdx];
            final payout = getTierRate(upgradeConfig, refAg.membership);
            final updatedRefAg = refAg.copyWith(
              walletBalance: refAg.walletBalance + payout,
              totalEarnings: refAg.totalEarnings + payout,
            );
            _agents[refIdx] = updatedRefAg;
            try {
              await _agentService.updateAgent(refAg.id, {
                'walletBalance': updatedRefAg.walletBalance,
                'totalEarnings': updatedRefAg.totalEarnings,
              });
            } catch (_) {}
            _transactions.insert(0, TransactionModel(
              id: 'tx_${Random().nextInt(1000000)}',
              agentCode: refAg.agentCode,
              amount: payout,
              type: TransactionType.DirectCommission,
              status: TransactionStatus.Success,
              description: 'Commission for Agent ${agent.agentCode} Plan Upgrade (${tier.name})',
              date: DateTime.now(),
            ));
          }
        }

        addNotification('Agent ${agent.agentCode} upgraded membership to ${tier.name}!');
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }
}
