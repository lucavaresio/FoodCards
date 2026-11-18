class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('uid')) {
      throw const FormatException('Chiave obbligatoria mancante: uid');
    }
    if (!json.containsKey('email')) {
      throw const FormatException('Chiave obbligatoria mancante: email');
    }
    if (!json.containsKey('displayName')) {
      throw const FormatException('Chiave obbligatoria mancante: displayName');
    }
    if (!json.containsKey('createdAt')) {
      throw const FormatException('Chiave obbligatoria mancante: createdAt');
    }

    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) => other is AppUser && other.uid == uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'AppUser(uid: $uid, displayName: $displayName)';
}
