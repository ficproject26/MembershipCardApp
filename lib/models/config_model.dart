import 'user_model.dart';

class MembershipPricing {
  final int? id;
  final MembershipTier tier;
  final double price;
  final List<String> benefits;

  MembershipPricing({
    this.id,
    required this.tier,
    required this.price,
    required this.benefits,
  });

  factory MembershipPricing.fromJson(Map<String, dynamic> json) {
    List<String> parsedBenefits = [];
    final rawBenefits = json['benefits'];
    if (rawBenefits is String) {
      parsedBenefits = rawBenefits.split(',').map((b) => b.trim()).where((b) => b.isNotEmpty).toList();
    } else if (rawBenefits is List) {
      parsedBenefits = rawBenefits.map((b) => b.toString()).toList();
    }

    return MembershipPricing(
      id: json['id'] as int?,
      tier: MembershipTier.values.firstWhere(
        (e) => e.name == (json['tier'] as String? ?? 'Silver'),
        orElse: () => MembershipTier.Silver,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      benefits: parsedBenefits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier.name,
      'price': price,
      'benefits': benefits.join(','),
    };
  }
}

class CommissionConfig {
  final int? id;
  final String serviceType;
  final double directRate;
  final double indirectRate;

  CommissionConfig({
    this.id,
    required this.serviceType,
    required this.directRate,
    required this.indirectRate,
  });

  factory CommissionConfig.fromJson(Map<String, dynamic> json) {
    return CommissionConfig(
      id: json['id'] as int?,
      serviceType: json['serviceType'] as String,
      directRate: (json['directRate'] as num?)?.toDouble() ?? 0.0,
      indirectRate: (json['indirectRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'directRate': directRate,
      'indirectRate': indirectRate,
    };
  }
}
