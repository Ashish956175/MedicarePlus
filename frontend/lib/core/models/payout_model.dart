class Payout {
  final int id;
  final int doctorId;
  final double amount;
  final String status; // PENDING, PAID
  final String processedAt;
  final String transactionId;
  final String? paymentMethod;
  final String? transactionReference;
  final String? notes;
  final String? bankDetailsSnapshot;

  Payout({
    required this.id,
    required this.doctorId,
    required this.amount,
    required this.status,
    required this.processedAt,
    required this.transactionId,
    this.paymentMethod,
    this.transactionReference,
    this.notes,
    this.bankDetailsSnapshot,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'],
      doctorId: json['doctorId'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      processedAt: json['processedAt'] ?? '',
      transactionId: json['transactionId'] ?? '',
      paymentMethod: json['paymentMethod'],
      transactionReference: json['transactionReference'],
      notes: json['notes'],
      bankDetailsSnapshot: json['bankDetailsSnapshot'],
    );
  }
}
