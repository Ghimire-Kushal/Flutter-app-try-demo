class AttendanceSubject {
  final String id;
  String name;
  int totalClasses;
  int attendedClasses;

  AttendanceSubject({
    required this.id,
    required this.name,
    this.totalClasses = 0,
    this.attendedClasses = 0,
  });

  double get percentage =>
      totalClasses == 0 ? 0.0 : (attendedClasses / totalClasses) * 100;

  bool get isSafe => percentage >= 75;

  int get classesNeededFor75 {
    if (percentage >= 75) return 0;
    // solve: (attended + x) / (total + x) >= 0.75
    if (totalClasses == 0) return 0;
    int x = 0;
    while ((attendedClasses + x) / (totalClasses + x) < 0.75) {
      x++;
      if (x > 1000) break;
    }
    return x;
  }

  int get classesCanMiss {
    if (percentage < 75) return 0;
    // solve: attended / (total + x) >= 0.75
    int x = 0;
    while (totalClasses + x > 0 &&
        attendedClasses / (totalClasses + x) >= 0.75) {
      x++;
      if (x > 1000) break;
    }
    return x - 1;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalClasses': totalClasses,
        'attendedClasses': attendedClasses,
      };

  factory AttendanceSubject.fromJson(Map<String, dynamic> json) =>
      AttendanceSubject(
        id: json['id'] as String,
        name: json['name'] as String,
        totalClasses: json['totalClasses'] as int? ?? 0,
        attendedClasses: json['attendedClasses'] as int? ?? 0,
      );
}
