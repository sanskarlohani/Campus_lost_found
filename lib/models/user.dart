class User {
  final String name;
  final String email;
  final String sic;
  final String year;
  final String semester;
  final String college;
  final String uid;
  final int karmaPoints;

  User({
    this.name = '',
    this.email = '',
    this.sic = '',
    this.year = '',
    this.semester = '',
    this.college = '',
    this.karmaPoints = 0,
    String? uid,
  }) : uid = uid ?? '';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      sic: json['sic'] as String? ?? '',
      year: json['year'] as String? ?? '',
      semester: json['semester'] as String? ?? '',
      college: json['college'] as String? ?? '',
      karmaPoints: json['karmaPoints'] as int? ?? 0,
      uid: json['uid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'sic': sic,
      'year': year,
      'semester': semester,
      'college': college,
      'uid': uid,
      'karmaPoints': karmaPoints,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? sic,
    String? year,
    String? semester,
    String? college,
    String? uid,
    int? karmaPoints,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      sic: sic ?? this.sic,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      college: college ?? this.college,
      uid: uid ?? this.uid,
      karmaPoints: karmaPoints ?? this.karmaPoints,
    );
  }
}
