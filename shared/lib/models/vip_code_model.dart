class VipCodeModel {
  final String id;
  final String code;
  final bool isUsed;
  final String? usedByName;
  final DateTime createdAt;

  VipCodeModel({
    required this.id,
    required this.code,
    this.isUsed = false,
    this.usedByName,
    required this.createdAt,
  });

  VipCodeModel copyWith({
    String? id,
    String? code,
    bool? isUsed,
    String? usedByName,
    DateTime? createdAt,
  }) {
    return VipCodeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      isUsed: isUsed ?? this.isUsed,
      usedByName: usedByName ?? this.usedByName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory VipCodeModel.fromJson(Map<String, dynamic> json) {
    return VipCodeModel(
      id: json['id'] ?? json['_id'] ?? '',
      code: json['code'] ?? '',
      isUsed: json['isUsed'] ?? false,
      usedByName: json['usedByName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'isUsed': isUsed,
      'usedByName': usedByName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
