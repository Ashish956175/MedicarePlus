class AuditLog {
  final int id;
  final String action;
  final String performedBy;
  final String target;
  final DateTime timestamp;
  final String details;

  AuditLog({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.target,
    required this.timestamp,
    required this.details,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      action: json['action'],
      performedBy: json['performedBy'],
      target: json['target'],
      timestamp: DateTime.parse(json['timestamp']),
      details: json['details'] ?? '',
    );
  }
}
