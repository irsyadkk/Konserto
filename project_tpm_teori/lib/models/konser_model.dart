class Konser {
  final int id;
  final String nama;
  final String poster;
  final String tanggal;
  final String jam;
  final String lokasi;
  final double latitude;
  final double longitude;
  final String bintangtamu;

  Konser({
    required this.id,
    required this.nama,
    required this.poster,
    required this.tanggal,
    required this.jam,
    required this.lokasi,
    required this.latitude,
    required this.longitude,
    required this.bintangtamu,
  });

  factory Konser.fromJson(Map<String, dynamic> json) {
    return Konser(
        id: json['id'] ?? 0,
        nama: json['nama'] ?? "",
        poster: json['poster'] ?? "",
        tanggal: json['tanggal'] ?? "",
        jam: json['jam'] ?? "",
        lokasi: json['lokasi'] ?? "",
        latitude: json['latitude'] ?? 0,
        longitude: json['longitude'] ?? 0,
        bintangtamu: json['bintangtamu'] ?? "");
  }
}
