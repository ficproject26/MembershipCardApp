enum MembershipTier { Basic, Silver, Gold, Diamond, Platinum }

enum KycStatus { NotSubmitted, Pending, Approved, Rejected }

class AgentModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String agentCode;
  final MembershipTier membership;
  final String? referredBy; // Referrer's agentCode
  final double walletBalance;
  final double totalEarnings;
  final KycStatus kycStatus;
  final String? aadhaarNumber;
  final String? panNumber;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankAccountName;
  final String? photoUrl;
  final DateTime dateJoined;

  AgentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.agentCode,
    required this.membership,
    this.referredBy,
    this.walletBalance = 0.0,
    this.totalEarnings = 0.0,
    this.kycStatus = KycStatus.NotSubmitted,
    this.aadhaarNumber,
    this.panNumber,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankAccountName,
    this.photoUrl,
    required this.dateJoined,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      agentCode: json['agentCode'] as String,
      membership: MembershipTier.values.firstWhere(
        (e) => e.name == (json['membership'] as String? ?? 'Silver'),
        orElse: () => MembershipTier.Basic,
      ),
      referredBy: json['referredBy'] as String?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name == (json['kycStatus'] as String? ?? 'NotSubmitted'),
        orElse: () => KycStatus.NotSubmitted,
      ),
      aadhaarNumber: json['aadhaarNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankIfscCode: json['bankIfscCode'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      dateJoined: DateTime.tryParse(json['dateJoined'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'agentCode': agentCode,
      'membership': membership.name,
      'referredBy': referredBy,
      'walletBalance': walletBalance,
      'totalEarnings': totalEarnings,
      'kycStatus': kycStatus.name,
      'aadhaarNumber': aadhaarNumber,
      'panNumber': panNumber,
      'bankAccountNumber': bankAccountNumber,
      'bankIfscCode': bankIfscCode,
      'bankAccountName': bankAccountName,
      'photoUrl': photoUrl,
      'dateJoined': dateJoined.toIso8601String(),
    };
  }

  AgentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? agentCode,
    MembershipTier? membership,
    String? referredBy,
    double? walletBalance,
    double? totalEarnings,
    KycStatus? kycStatus,
    String? aadhaarNumber,
    String? panNumber,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankAccountName,
    String? photoUrl,
    DateTime? dateJoined,
  }) {
    return AgentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      agentCode: agentCode ?? this.agentCode,
      membership: membership ?? this.membership,
      referredBy: referredBy ?? this.referredBy,
      walletBalance: walletBalance ?? this.walletBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      kycStatus: kycStatus ?? this.kycStatus,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      photoUrl: photoUrl ?? this.photoUrl,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }
}
