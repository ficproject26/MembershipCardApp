class HrDashboardStats {
  final HrKpi kpi;
  final HrPipeline pipeline;
  final List<HrRecentApplication> recentApplications;
  final List<HrTopAgent> topAgents;

  HrDashboardStats({
    required this.kpi,
    required this.pipeline,
    required this.recentApplications,
    required this.topAgents,
  });

  factory HrDashboardStats.fromJson(Map<String, dynamic> json) {
    return HrDashboardStats(
      kpi: HrKpi.fromJson(json['kpi'] ?? {}),
      pipeline: HrPipeline.fromJson(json['pipeline'] ?? {}),
      recentApplications: (json['recentApplications'] as List? ?? [])
          .map((e) => HrRecentApplication.fromJson(e))
          .toList(),
      topAgents: (json['topAgents'] as List? ?? [])
          .map((e) => HrTopAgent.fromJson(e))
          .toList(),
    );
  }
}

class HrKpi {
  final int totalReferrals;
  final int pendingApplications;
  final int inProcess;
  final int selectedCandidates;

  HrKpi({
    required this.totalReferrals,
    required this.pendingApplications,
    required this.inProcess,
    required this.selectedCandidates,
  });

  factory HrKpi.fromJson(Map<String, dynamic> json) {
    return HrKpi(
      totalReferrals: json['totalReferrals'] ?? 0,
      pendingApplications: json['pendingApplications'] ?? 0,
      inProcess: json['inProcess'] ?? 0,
      selectedCandidates: json['selectedCandidates'] ?? 0,
    );
  }
}

class HrPipeline {
  final int applied;
  final int screening;
  final int interview;
  final int selected;
  final int joined;

  HrPipeline({
    required this.applied,
    required this.screening,
    required this.interview,
    required this.selected,
    required this.joined,
  });

  factory HrPipeline.fromJson(Map<String, dynamic> json) {
    return HrPipeline(
      applied: json['applied'] ?? 0,
      screening: json['screening'] ?? 0,
      interview: json['interview'] ?? 0,
      selected: json['selected'] ?? 0,
      joined: json['joined'] ?? 0,
    );
  }
}

class HrRecentApplication {
  final String id;
  final String name;
  final String role;
  final String mobile;
  final String date;
  final String agent;
  final String status;

  HrRecentApplication({
    required this.id,
    required this.name,
    required this.role,
    required this.mobile,
    required this.date,
    required this.agent,
    required this.status,
  });

  factory HrRecentApplication.fromJson(Map<String, dynamic> json) {
    return HrRecentApplication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      mobile: json['mobile'] ?? '',
      date: json['date'] ?? '',
      agent: json['agent'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class HrTopAgent {
  final String name;
  final int referrals;

  HrTopAgent({
    required this.name,
    required this.referrals,
  });

  factory HrTopAgent.fromJson(Map<String, dynamic> json) {
    return HrTopAgent(
      name: json['name'] ?? '',
      referrals: json['referrals'] ?? 0,
    );
  }
}
