import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoneAttendanceScreen extends StatefulWidget {
  final String tanggal; // misal "20 September 2024"
  final String jamMasuk;
  final String jamPulang;
  final String locationDatang;
  final String locationPulang;
  final String keteranganMasuk; // Rencana Kerja
  final String keteranganPulang; // Pekerjaan Hari Ini

  const DoneAttendanceScreen({
    Key? key,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamPulang,
    required this.locationDatang,
    required this.locationPulang,
    required this.keteranganMasuk,
    required this.keteranganPulang,
  }) : super(key: key);

  @override
  State<DoneAttendanceScreen> createState() => _DoneAttendanceScreenState();
}

class _DoneAttendanceScreenState extends State<DoneAttendanceScreen> {
  // Controller untuk masing-masing text field
  final TextEditingController _rencanaController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();

  DateTime? _networkTime;
  bool _buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller berdasarkan nilai yang sudah ada
    if (widget.keteranganMasuk.trim() != "-" &&
        widget.keteranganMasuk.isNotEmpty) {
      _rencanaController.text = widget.keteranganMasuk;
    }
    if (widget.keteranganPulang.trim() != "-" &&
        widget.keteranganPulang.isNotEmpty) {
      _pekerjaanController.text = widget.keteranganPulang;
    }
    _fetchNetworkTime();
  }

  @override
  void dispose() {
    _rencanaController.dispose();
    _pekerjaanController.dispose();
    super.dispose();
  }

  // Simulasi pengambilan waktu dari server (ganti dengan API call jika perlu)
  Future<void> _fetchNetworkTime() async {
    await Future.delayed(const Duration(seconds: 1));
    DateTime nt = DateTime.now(); // Ganti dengan pemanggilan API jika perlu
    setState(() {
      _networkTime = nt;
      _buttonEnabled = _checkButtonEnabled(nt);
    });
  }

  // Cek apakah tombol absen pulang boleh aktif berdasarkan waktu server
  bool _checkButtonEnabled(DateTime currentTime) {
    // Contoh logika: Senin-Kamis aktif jika waktu >= 16:00, Jumat >= 16:30
    if (currentTime.weekday >= 1 && currentTime.weekday <= 4) {
      if (currentTime.hour > 16 ||
          (currentTime.hour == 16 && currentTime.minute >= 0)) {
        return true;
      }
    } else if (currentTime.weekday == 5) {
      if (currentTime.hour > 16 ||
          (currentTime.hour == 16 && currentTime.minute >= 30)) {
        return true;
      }
    }
    return false;
  }

  void _handleAbsenPulang() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Konfirmasi"),
            content: const Text("Apakah anda sudah selesai bekerja?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tidak"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke dashboard
                },
                child: const Text("Ya"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan kondisi untuk absensi
    final bool alreadyAbsenPulang =
        widget.jamPulang.trim() != "-" && widget.jamPulang.isNotEmpty;
    final bool absenIjin =
        widget.jamMasuk.trim() == "-" && widget.jamMasuk.isNotEmpty;
    final bool disableAbsen = alreadyAbsenPulang || absenIjin;

    if (_networkTime == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Parse tanggal attendance (diasumsikan format "EEEE, dd MMMM yyyy")
    final DateTime attendanceDate = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).parse(widget.tanggal);
    final String formattedDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(attendanceDate);

    // Cek apakah hari pada waktu server sama dengan tanggal attendance
    final bool isSameDay =
        attendanceDate.year == _networkTime!.year &&
        attendanceDate.month == _networkTime!.month &&
        attendanceDate.day == _networkTime!.day;
    final bool disableDueToDifferentDay = !isSameDay;

    // Tentukan apakah field rencana kerja dan pekerjaan hari ini editable
    final bool rencanaEditable =
        widget.keteranganMasuk.trim() == "-" || widget.keteranganMasuk.isEmpty;
    final bool pekerjaanEditable =
        widget.keteranganPulang.trim() == "-" ||
        widget.keteranganPulang.isEmpty;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Absen Pulang",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F2452),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tampilkan tanggal attendance
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tanggal: $formattedDate",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            // Row dengan dua card: Absen Datang dan Absen Pulang
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Absen Datang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2452),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.jamMasuk,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF1F2452),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Absen Pulang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2452),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.jamPulang,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF1F2452),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lokasi Datang
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lokasi Datang:",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.locationDatang,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            // Lokasi Pulang
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lokasi Pulang:",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.locationPulang,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            // Field Rencana Kerja (keterangan masuk)
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Rencana Kerja:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _rencanaController,
              maxLines: 5,
              enabled:
                  rencanaEditable &&
                  !(disableAbsen || disableDueToDifferentDay),
              decoration: InputDecoration(
                hintText: "Ketik rencana kerja hari ini...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            // Field Pekerjaan Hari Ini (keterangan pulang)
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Pekerjaan Hari Ini:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _pekerjaanController,
              maxLines: 5,
              enabled:
                  pekerjaanEditable &&
                  !(disableAbsen || disableDueToDifferentDay),
              decoration: InputDecoration(
                hintText: "Ketik pekerjaan hari ini...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const Spacer(),
            // Tombol Absen Pulang
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (!(disableAbsen || disableDueToDifferentDay) &&
                            _buttonEnabled)
                        ? _handleAbsenPulang
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2452),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Absen Pulang",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Info waktu server
            Text(
              "Waktu Server: ${_networkTime!.toLocal().toString().substring(0, 19)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
