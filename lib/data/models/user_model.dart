/// Domain user. Identity comes from Firebase Auth (uid).
/// Profile fields live in Firestore at users/{uid}.
class AppUser {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String dob;
  final String location;
  final DateTime createdAt;
  final bool profileComplete;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.phone = '',
    this.dob = '',
    this.location = '',
    required this.createdAt,
    this.profileComplete = false,
  });

  AppUser copyWith({
    String? name,
    String? phone,
    String? dob,
    String? location,
    bool? profileComplete,
  }) =>
      AppUser(
        uid: uid,
        email: email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        dob: dob ?? this.dob,
        location: location ?? this.location,
        createdAt: createdAt,
        profileComplete: profileComplete ?? this.profileComplete,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone,
        'dob': dob,
        'location': location,
        'createdAt': createdAt.toIso8601String(),
        'profileComplete': profileComplete,
      };

  static AppUser fromMap(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] as String,
        email: m['email'] as String,
        name: (m['name'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        dob: (m['dob'] ?? '') as String,
        location: (m['location'] ?? '') as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        profileComplete: (m['profileComplete'] ?? false) as bool,
      );
}
