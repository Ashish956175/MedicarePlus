class Availability {
  final int? id;
  final int doctorId;
  final String date;
  final String timeSlot;

  Availability({
    this.id,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      id: json['id'],
      doctorId: json['doctorId'],
      date: json['date'],
      timeSlot: json['timeSlot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'date': date,
      'timeSlot': timeSlot,
    };
  }
}
