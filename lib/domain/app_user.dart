/// Pengguna yang sudah tervalidasi sebagai customer (dokumen `users`).
class AppUser {
  const AppUser({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl = '',
  });

  final String uid;
  final String username;
  final String name;
  final String email;
  final String role;
  final String photoUrl;

  factory AppUser.fromMap(String uid, Map<String, Object?> m) => AppUser(
    uid: uid,
    username: (m['username'] as String?) ?? '',
    name: (m['name'] as String?) ?? '',
    email: (m['email'] as String?) ?? '',
    role: (m['role'] as String?) ?? '',
    photoUrl: (m['photoURL'] as String?) ?? '',
  );

  AppUser copyWith({String? name, String? photoUrl}) => AppUser(
    uid: uid,
    username: username,
    name: name ?? this.name,
    email: email,
    role: role,
    photoUrl: photoUrl ?? this.photoUrl,
  );
}
