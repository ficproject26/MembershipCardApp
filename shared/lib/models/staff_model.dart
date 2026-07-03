enum StaffRole {
  creditCardTL,
  loanTL,
  insuranceTL,
  itProjectManager,
  hr,
  itSupport,
  kycDepartment,
  accountTeam,
  ficHelpDesk,
  other,
}

extension StaffRoleExtension on StaffRole {
  String get displayName {
    switch (this) {
      case StaffRole.creditCardTL:
        return 'Credit Card TL';
      case StaffRole.loanTL:
        return 'Loan TL';
      case StaffRole.insuranceTL:
        return 'Insurance Dashboard TL';
      case StaffRole.itProjectManager:
        return 'IT Project Manager';
      case StaffRole.hr:
        return 'HR';
      case StaffRole.itSupport:
        return 'IT Support';
      case StaffRole.kycDepartment:
        return 'KYC Department';
      case StaffRole.accountTeam:
        return 'Account Team';
      case StaffRole.ficHelpDesk:
        return 'FIC Help Desk';
      case StaffRole.other:
        return 'Other';
    }
  }

  static StaffRole fromString(String roleStr) {
    final lower = roleStr.toLowerCase().replaceAll(' ', '');
    return StaffRole.values.firstWhere(
      (e) => e.name.toLowerCase() == lower || e.displayName.toLowerCase().replaceAll(' ', '') == lower,
      orElse: () {
        if (lower.contains('kyc')) return StaffRole.kycDepartment;
        if (lower.contains('credit')) return StaffRole.creditCardTL;
        if (lower.contains('loan')) return StaffRole.loanTL;
        if (lower.contains('insurance')) return StaffRole.insuranceTL;
        return StaffRole.other;
      },
    );
  }
}

class StaffModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final StaffRole role;
  final String? department;
  final DateTime dateJoined;

  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.department,
    required this.dateJoined,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: StaffRoleExtension.fromString(json['role']),
      department: json['department'],
      dateJoined: DateTime.parse(json['dateJoined']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'department': department,
      'dateJoined': dateJoined.toIso8601String(),
    };
  }
}
