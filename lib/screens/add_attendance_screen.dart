import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddAttendanceScreen extends StatefulWidget {
  const AddAttendanceScreen({Key? key}) : super(key: key);

  @override
  _AddAttendanceScreenState createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  String? _selectedStatus;
  DateTime? _serverTime;
  bool _hasCheckedIn = false;
  DateTime? _checkInTime;

  @override
  void initState() {
    super.initState();
    _fetchServerTime();
  }

  // Simulasi pengambilan waktu dari server (bukan jam handphone)
  Future<void> _fetchServerTime() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _serverTime =
          DateTime.now(); // Gantikan dengan pemanggilan API untuk waktu server
    });
  }

  // Format waktu dan tanggal
  String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String formatDate(DateTime time) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(time);
  }

  // Fungsi untuk menangani aksi absen masuk
  void _handleAbsenMasuk() {
    setState(() {
      _hasCheckedIn = true;
      _checkInTime = _serverTime;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Absen datang berhasil")));
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_serverTime == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Gunakan waktu server untuk cek apakah tombol absen boleh muncul (jam >= 06:00)
    final bool isAfterSix = _serverTime!.hour >= 6;
    final bool disableAbsen = _hasCheckedIn;
    final DateTime displayCheckInTime =
        _hasCheckedIn ? _checkInTime! : _serverTime!;

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Tambah Absensi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F2452),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan tanggal di atas
            Text(
              formatDate(displayCheckInTime),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                          formatTime(displayCheckInTime),
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
                      children: const [
                        Text(
                          "Absen Pulang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2452),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "-",
                          style: TextStyle(
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
            // Pilihan status absensi hanya aktif jika belum absen
            const Text(
              'Pilih Keterangan Absensi:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2452),
              ),
            ),
            const SizedBox(height: 8),
            Container(
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
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('WFO'),
                    value: 'WFH',
                    groupValue: _selectedStatus,
                    activeColor: const Color(0xFF1F2452),
                    onChanged:
                        disableAbsen
                            ? null
                            : (value) {
                              setState(() {
                                _selectedStatus = value as String?;
                              });
                            },
                  ),
                  RadioListTile(
                    title: const Text('WFH'),
                    value: 'WFA',
                    groupValue: _selectedStatus,
                    activeColor: const Color(0xFF1F2452),
                    onChanged:
                        disableAbsen
                            ? null
                            : (value) {
                              setState(() {
                                _selectedStatus = value as String?;
                              });
                            },
                  ),
                  RadioListTile(
                    title: const Text('Sakit'),
                    value: 'Sakit',
                    groupValue: _selectedStatus,
                    activeColor: const Color(0xFF1F2452),
                    onChanged:
                        disableAbsen
                            ? null
                            : (value) {
                              setState(() {
                                _selectedStatus = value as String?;
                              });
                            },
                  ),
                  RadioListTile(
                    title: const Text('Cuti'),
                    value: 'Cuti',
                    groupValue: _selectedStatus,
                    activeColor: const Color(0xFF1F2452),
                    onChanged:
                        disableAbsen
                            ? null
                            : (value) {
                              setState(() {
                                _selectedStatus = value as String?;
                              });
                            },
                  ),
                  RadioListTile(
                    title: const Text('Dinas'),
                    value: 'Dinas',
                    groupValue: _selectedStatus,
                    activeColor: const Color(0xFF1F2452),
                    onChanged:
                        disableAbsen
                            ? null
                            : (value) {
                              setState(() {
                                _selectedStatus = value as String?;
                              });
                            },
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Tombol Absen Masuk: hanya aktif jika waktu server >= 06:00, belum absen, dan status telah dipilih
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (isAfterSix && !disableAbsen && _selectedStatus != null)
                        ? _handleAbsenMasuk
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2452),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Absen Masuk',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            if (!isAfterSix)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Tombol absen akan muncul mulai dari jam 06:00',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
