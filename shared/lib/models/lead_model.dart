import 'dart:convert';

enum LeadStatus { Stage1Pending, Stage1Approved, Stage1Rejected, Stage2Pending, Stage2Approved, Stage2Rejected, Stage3Pending, Stage3Approved, Stage3Rejected, Approved, Rejected, Dispatched, Pending, Process, Followup, Converted, Selected, KYC_Pending, KYC_Verified, KYC_Rejected }

class LeadModel {
  final String id;
  final String agentCode;
  final String? agentName;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String serviceType; // 'Credit Card', 'Loan', 'Jobs', 'Insurance', 'IT Projects', 'BPO Services'
  final Map<String, String> details;
  final LeadStatus status;
  final DateTime dateCreated;
  final String? rejectionReason;
  final String? bankMessage;
  final String? kycLink;

  LeadModel({
    required this.id,
    required this.agentCode,
    this.agentName,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.serviceType,
    required this.details,
    this.status = LeadStatus.Pending,
    required this.dateCreated,
    this.rejectionReason,
    this.bankMessage,
    this.kycLink,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> parsedDetails = {};
    try {
      final rawDetails = json['details'];
      if (rawDetails is String) {
        final decoded = jsonDecode(rawDetails);
        if (decoded is Map) {
          parsedDetails = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } else if (rawDetails is Map) {
        parsedDetails = rawDetails.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}

    // Lookup the agentCode from the included agent relation, if present
    final agentCode = (json['agent'] != null
        ? json['agent']['agentCode'] as String?
        : null) ?? json['agentCode'] as String? ?? '';
    final agentName = json['agent'] != null ? json['agent']['name'] as String? : null;

    return LeadModel(
      id: json['id'] as String,
      agentCode: agentCode,
      agentName: agentName,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerEmail: json['customerEmail'] as String?,
      serviceType: json['serviceType'] as String,
      details: parsedDetails,
      status: LeadStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'Pending'),
        orElse: () => LeadStatus.Pending,
      ),
      dateCreated: DateTime.tryParse(json['dateCreated'] as String? ?? '') ?? DateTime.now(),
      rejectionReason: json['rejectionReason'] as String?,
      bankMessage: json['bankMessage'] as String?,
      kycLink: json['kycLink'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentCode': agentCode,
      'agentName': agentName,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'serviceType': serviceType,
      'details': jsonEncode(details),
      'status': status.name,
      'dateCreated': dateCreated.toIso8601String(),
      'rejectionReason': rejectionReason,
      'bankMessage': bankMessage,
      'kycLink': kycLink,
    };
  }

  LeadModel copyWith({
    String? id,
    String? agentCode,
    String? agentName,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? serviceType,
    Map<String, String>? details,
    LeadStatus? status,
    DateTime? dateCreated,
    String? rejectionReason,
    String? bankMessage,
    String? kycLink,
  }) {
    return LeadModel(
      id: id ?? this.id,
      agentCode: agentCode ?? this.agentCode,
      agentName: agentName ?? this.agentName,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      serviceType: serviceType ?? this.serviceType,
      details: details ?? this.details,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      bankMessage: bankMessage ?? this.bankMessage,
      kycLink: kycLink ?? this.kycLink,
    );
  }
}
