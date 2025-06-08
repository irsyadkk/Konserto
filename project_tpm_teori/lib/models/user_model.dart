class User {
  final int id;
  final String nama;
  final String email;
  final int umur;
  final String? accessToken;

  User({
    required this.id,
    required this.email,
    required this.umur,
    required this.nama,
    this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json, [String? token]) {
    return User(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? "",
      email: json['email'] ?? "",
      umur: json['umur'] ?? 0,
      accessToken: token,
    );
  }
}
