class KehadiranModel {
  final String guidPegawai;
  final String namaPegawai;
  final String tanggal;
  final String tipe;
  final String jamMasuk;
  final double latitudeMasuk;
  final double longitudeMasuk;
  final String keteranganMasuk;
  final String jamPulang;
  final double latitudePulang;
  final double longitudePulang;
  final String keteranganPulang;

  KehadiranModel({
    required this.guidPegawai,
    required this.namaPegawai,
    required this.tanggal,
    required this.tipe,
    required this.jamMasuk,
    required this.latitudeMasuk,
    required this.longitudeMasuk,
    required this.keteranganMasuk,
    required this.jamPulang,
    required this.latitudePulang,
    required this.longitudePulang,
    required this.keteranganPulang,
  });

  factory KehadiranModel.fromJson(Map<String, dynamic> json) {
    return KehadiranModel(
      guidPegawai: json['guid_pegawai'] ?? '',
      namaPegawai: json['nama_pegawai'] ?? '',
      tanggal: json['tanggal'] ?? '',
      tipe: json['tipe'] ?? '',
      jamMasuk: json['jam_masuk'] ?? '',
      latitudeMasuk: (json['latitude_masuk'] ?? 0).toDouble(),
      longitudeMasuk: (json['longitude_masuk'] ?? 0).toDouble(),
      keteranganMasuk: json['keterangan_masuk'] ?? '',
      jamPulang: json['jam_pulang'] ?? '',
      latitudePulang: (json['latitude_pulang'] ?? 0).toDouble(),
      longitudePulang: (json['longitude_pulang'] ?? 0).toDouble(),
      keteranganPulang: json['keterangan_pulang'] ?? '',
    );
  }
}
