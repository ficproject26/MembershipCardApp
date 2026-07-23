import 'user_model.dart';

class MembershipPricing {
  final String? id;
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
      id: json['id'] as String?,
      tier: MembershipTier.values.firstWhere(
        (e) => e.name == (json['tier'] as String? ?? 'Silver'),
        orElse: () => MembershipTier.Basic,
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
  final String? id;
  final String serviceType;
  final double silverRate;
  final double goldRate;
  final double diamondRate;
  final double platinumRate;

  CommissionConfig({
    this.id,
    required this.serviceType,
    required this.silverRate,
    required this.goldRate,
    required this.diamondRate,
    required this.platinumRate,
  });

  factory CommissionConfig.fromJson(Map<String, dynamic> json) {
    return CommissionConfig(
      id: json['id'] as String?,
      serviceType: json['serviceType'] as String,
      silverRate: (json['silverRate'] as num?)?.toDouble() ?? 0.0,
      goldRate: (json['goldRate'] as num?)?.toDouble() ?? 0.0,
      diamondRate: (json['diamondRate'] as num?)?.toDouble() ?? 0.0,
      platinumRate: (json['platinumRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'silverRate': silverRate,
      'goldRate': goldRate,
      'diamondRate': diamondRate,
      'platinumRate': platinumRate,
    };
  }
}
