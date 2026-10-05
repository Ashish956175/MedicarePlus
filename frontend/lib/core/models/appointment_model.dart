class Appointment {
  final int id;
  final int userId;
  final int doctorId;
  final String date;
  final String timeSlot;
  final String status;
  final int? payoutId;

  Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.payoutId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['userId'],
      doctorId: json['doctorId'],
      date: json['date'],
      timeSlot: json['timeSlot'],
      status: json['status'],
      payoutId: json['payoutId'],
    );
  }
}
