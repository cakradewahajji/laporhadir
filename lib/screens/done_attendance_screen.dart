import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DoneAttendanceScreen extends StatefulWidget {
  final String tanggal; // misal "20 September 2024"
  final String jamMasuk;
  final String jamPulang;
  final String locationDatang;
  final String locationPulang;

  const DoneAttendanceScreen({
    Key? key,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamPulang,
    required this.locationDatang,
    required this.locationPulang,
  }) : super(key: key);

  @override
  State<DoneAttendanceScreen> createState() => _DoneAttendanceScreenState();
}

class _DoneAttendanceScreenState extends State<DoneAttendanceScreen> {
  final TextEditingController _workController = TextEditingController();
  DateTime? _networkTime;
  bool _buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchNetworkTime();
  }

  @override
  void dispose() {
    Intl.defaultLocale = 'id_ID';
    _workController.dispose();
    super.dispose();
  }

  // Simulasi pengambilan waktu dari server (bukan waktu handphone)
  Future<void> _fetchNetworkTime() async {
    await Future.delayed(const Duration(seconds: 1));
    DateTime nt =
        DateTime.now(); // Gantikan dengan pemanggilan API untuk mendapatkan waktu server
    setState(() {
      _networkTime = nt;
      _buttonEnabled = _checkButtonEnabled(nt);
    });
  }

  // Cek apakah tombol absen pulang boleh aktif berdasarkan waktu server
  bool _checkButtonEnabled(DateTime currentTime) {
    // Misalnya: Senin-Kamis aktif jika waktu >= 16:00, Jumat >= 16:30
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
    // Cek jika sudah absen pulang: jika jamPulang tidak "-" dan tidak kosong
    final bool alreadyAbsenPulang =
        widget.jamPulang.trim() != "-" && widget.jamPulang.isNotEmpty;
    // Cek untuk status cuti, ijin, sakit, atau dinas (diasumsikan jika jamMasuk bernilai "-" dan tidak kosong)
    final bool absenIjin =
        widget.jamMasuk.trim() == "-" && widget.jamMasuk.isNotEmpty;
    // Jika salah satu kondisi terpenuhi, maka disable text area dan tombol absen pulang.
    final bool disableAbsen = alreadyAbsenPulang || absenIjin;

    // Jika waktu server belum tersedia, tampilkan loading.
    if (_networkTime == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Parse tanggal attendance yang dioper
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
    // Jika hari berbeda, maka disable tombol dan text area.
    final bool disableDueToDifferentDay = !isSameDay;

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
            // Tampilkan tanggal attendance di atas
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
            // Text area untuk pekerjaan hari ini
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pekerjaan Hari Ini:",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _workController,
              maxLines: 5,
              enabled: !(disableAbsen || disableDueToDifferentDay),
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
            // Tombol Absen Pulang: nonaktif jika disableAbsen atau jika hari sudah berbeda
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    ((!(disableAbsen || disableDueToDifferentDay)) &&
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
            // Info waktu server (opsional)
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
