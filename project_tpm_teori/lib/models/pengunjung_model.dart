class Pengunjung {
  final int id;
  final String nama;
  final int umur;
  final String email;
  final String tiket;

  Pengunjung(
      {required this.id,
      required this.nama,
      required this.umur,
      required this.email,
      required this.tiket});

  factory Pengunjung.fromJson(Map<String, dynamic> json) {
    return Pengunjung(
        id: json['id'] ?? 0,
        nama: json['nama'] ?? "",
        umur: json['umur'] ?? "",
        email: json['email'] ?? "",
        tiket: json['tiket'] ?? "");
  }
}
