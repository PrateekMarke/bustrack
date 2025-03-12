

class SeatingArrengement {
  final String id;
  final String driverName;
  final String busNumber;
  final int totalSeats;
  final Map<String, TimeSlot> timeSeats;
  final List<String> selectedStudents; // ✅ Add this line

  SeatingArrengement({
    required this.id,
    required this.driverName,
    required this.busNumber,
    required this.totalSeats,
    required this.timeSeats,
    required this.selectedStudents, // ✅ Add this line
  });

  factory SeatingArrengement.fromFirestore(
      Map<String, dynamic> data, String id) {
    Map<String, TimeSlot> timeSeats = {};
    if (data['timeSeats'] != null) {
      (data['timeSeats'] as Map<String, dynamic>).forEach((key, value) {
        timeSeats[key] = TimeSlot.fromMap(value as Map<String, dynamic>);
      });
    }

    return SeatingArrengement(
      id: id,
      driverName: data['driverName'] ?? '',
      busNumber: data['busNumber'] ?? '',
      totalSeats: data['totalSeats'] ?? 0,
      timeSeats: timeSeats,
      selectedStudents: List<String>.from(data['selectedStudents'] ?? []), // ✅ Fix here
    );
  }
}

class TimeSlot {
  final String? allotedTo;
  bool isPresent;
  String? bookedBy;

  TimeSlot({
    required this.allotedTo,
    required this.isPresent,
    this.bookedBy,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      allotedTo: map['seatId'] ?? '',
      isPresent: map['isPresent'] ?? true,
      bookedBy: map['bookedBy'],
    );
  }
}
