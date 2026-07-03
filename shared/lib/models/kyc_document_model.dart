class KycDocument {
  final String id;
  final String leadId;
  final String docType;
  final String filePath;
  final String? aadhaarNumber;
  final String? panNumber;
  final String? url;
  final DateTime uploadedAt;

  KycDocument({
    required this.id,
    required this.leadId,
    required this.docType,
    required this.filePath,
    this.aadhaarNumber,
    this.panNumber,
    this.url,
    required this.uploadedAt,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    return KycDocument(
      id: json['id'] ?? '',
      leadId: json['leadId'] ?? '',
      docType: json['docType'] ?? '',
      filePath: json['filePath'] ?? '',
      aadhaarNumber: json['aadhaarNumber'],
      panNumber: json['panNumber'],
      url: json['url'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
    );
  }
}
