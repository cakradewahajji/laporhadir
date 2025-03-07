import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'done_attendance_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final String employeeName = "Cakradewa Hajji Perwira";
  // Dummy data absensi dengan field tanggal
  final List<Map<String, String>> attendanceList = [
    {
      "status": "WFO",
      "jamMasuk": "07:30",
      "jamPulang": "-",
      "tanggal": "Jumat, 07 Maret 2024",
    },
    {
      "status": "WFH",
      "jamMasuk": "07:45",
      "jamPulang": "16:15",
      "tanggal": "Kamis, 06 Maret 2025",
    },
    {
      "status": "WFH",
      "jamMasuk": "07:50",
      "jamPulang": "16:00",
      "tanggal": "Rabu, 05 Maret 2025",
    },
    {
      "status": "WFH",
      "jamMasuk": "07:30",
      "jamPulang": "15:59",
      "tanggal": "Selasa, 04 Maret 2025",
    },
    {
      "status": "WFO",
      "jamMasuk": "07:45",
      "jamPulang": "16:10",
      "tanggal": "Senin, 03 Maret 2025",
    },
    {
      "status": "WFO",
      "jamMasuk": "07:45",
      "jamPulang": "-",
      "tanggal": "Jumat, 29 Februari 2025",
    },
    {
      "status": "Sakit",
      "jamMasuk": "-",
      "jamPulang": "-",
      "tanggal": "Kamis, 28 Februari 2025",
    },
    {
      "status": "Cuti",
      "jamMasuk": "-",
      "jamPulang": "-",
      "tanggal": "Rabu, 27 Februari 2025",
    },
    {
      "status": "Dinas",
      "jamMasuk": "-",
      "jamPulang": "-",
      "tanggal": "Selasa, 26 Februari 2025",
    },
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    Intl.defaultLocale = 'id_ID';
    setState(() {}); // Update tampilan setelah inisialisasi locale
  }

  // Parsing waktu "HH:mm" menjadi menit
  int parseTime(String time) {
    if (time == "-") return -1;
    final parts = time.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Evaluasi kondisi ekstra:
  // "Telat": jika masuk > 07:45,
  // "Mendahului": jika (masuk == 07:30 dan pulang tidak tepat 16:00)
  //              atau (masuk == 07:45 dan pulang < 16:15),
  // "Belum Absen Pulang": jika WFH/WFA/WFO dan jamPulang masih "-"
  String computeExtraStatus(String status, String jamMasuk, String jamPulang) {
    if (status == "Dinas" || status == "Cuti" || status == "Sakit") return "";
    if (jamMasuk == "-") return "";
    if ((status == "WFH" || status == "WFA" || status == "WFO") &&
        jamPulang == "-") {
      return "Belum Absen Pulang";
    }
    final int masuk = parseTime(jamMasuk);
    final int pulang = parseTime(jamPulang);
    if (masuk == 450) {
      if (pulang != 960) return "Mendahului";
    } else if (masuk == 465) {
      if (pulang < 975) return "Mendahului";
    } else if (masuk > 465) {
      return "Telat";
    }
    return "";
  }

  // Warna card berdasarkan kondisi
  Color getAttendanceCardColor(
    String status,
    String jamMasuk,
    String jamPulang,
  ) {
    final String extra = computeExtraStatus(status, jamMasuk, jamPulang);
    if (extra == "Telat" || extra == "Mendahului") {
      return Colors.redAccent.withOpacity(0.7);
    } else if (extra == "Belum Absen Pulang") {
      return Colors.lightBlueAccent.withOpacity(0.7);
    } else if (status == "Sakit" || status == "Cuti" || status == "Dinas") {
      return const Color.fromARGB(255, 102, 106, 141).withOpacity(0.9);
    } else {
      return Colors.yellow[300]!.withOpacity(0.7);
    }
  }

  // Fungsi untuk menentukan ikon utama berdasarkan status
  IconData getStatusIcon(String status) {
    if (status == "WFH") return Icons.home;
    if (status == "WFO") return Icons.work;
    if (status == "Sakit") return Icons.local_hospital;
    if (status == "Cuti") return Icons.beach_access;
    if (status == "Dinas") return Icons.directions_bus;
    return Icons.info;
  }

  // Konversi string tanggal ke DateTime menggunakan locale id_ID
  DateTime parseTanggal(String tanggalStr) {
    final DateFormat formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    return formatter.parse(tanggalStr);
  }

  // Filter data berdasarkan tab
  List<Map<String, String>> filterData(int tabIndex) {
    final sortedList = List<Map<String, String>>.from(attendanceList);
    sortedList.sort((a, b) {
      final dateA = parseTanggal(a["tanggal"]!);
      final dateB = parseTanggal(b["tanggal"]!);
      return dateB.compareTo(dateA);
    });
    switch (tabIndex) {
      case 0:
        return sortedList;
      case 1:
        return sortedList.where((item) {
          final status = item["status"] ?? "";
          final jamPulang = item["jamPulang"] ?? "-";
          return (status == "WFH" || status == "WFA" || status == "WFO") &&
              jamPulang == "-";
        }).toList();
      case 2:
        return sortedList.where((item) {
          final status = item["status"] ?? "";
          final jamMasuk = item["jamMasuk"] ?? "-";
          final jamPulang = item["jamPulang"] ?? "-";
          final extra = computeExtraStatus(status, jamMasuk, jamPulang);
          return extra == "Telat" || extra == "Mendahului";
        }).toList();
      case 3:
        return sortedList.where((item) {
          final status = item["status"] ?? "";
          return status == "Sakit" || status == "Cuti" || status == "Dinas";
        }).toList();
      default:
        return sortedList;
    }
  }

  // Fungsi untuk menentukan label badge berdasarkan data
  String _getBadgeLabel(String status, String jamMasuk, String jamPulang) {
    final extra = computeExtraStatus(status, jamMasuk, jamPulang);
    if (extra == "Belum Absen Pulang") return "In Progress";
    if (extra == "Telat" || extra == "Mendahului") return "Terlambat";
    if (status == "Sakit" || status == "Cuti" || status == "Dinas")
      return "Lainnya";
    return "Selesai";
  }

  // Fungsi untuk menentukan warna badge berdasarkan label
  Color _getBadgeColor(String label) {
    switch (label) {
      case "In Progress":
        return Colors.blueAccent;
      case "Terlambat":
        return Colors.orange;
      case "Lainnya":
        return Colors.purple;
      case "Selesai":
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah hari ini sudah ada absensi
    final DateTime today = DateTime.now();
    final bool attendanceExistsForToday = attendanceList.any((record) {
      final DateTime recordDate = parseTanggal(record["tanggal"]!);
      return recordDate.day == today.day &&
          recordDate.month == today.month &&
          recordDate.year == today.year;
    });

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFEF),
        appBar: AppBar(
          title: const Text(
            "LAPOR HADIR",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF1F2452),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.yellow,
            labelColor: Colors.yellow,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(text: "All"),
              Tab(text: "Progress"),
              Tab(text: "Terlambat"),
              Tab(text: "Lainnya"),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  "Welcome,\n$employeeName",
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),

        // Jika sudah ada absensi hari ini, tidak tampilkan tombol "Tambah Absen"
        bottomNavigationBar:
            attendanceExistsForToday
                ? null
                : BottomAppBar(
                  color: const Color(0xFF1F2452),
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 6,
                  child: SizedBox(
                    height: 60,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/addAttendance');
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Tambah Absen",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F2452),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildList(0), // All
            buildList(1), // Progress
            buildList(2), // Terlambat
            buildList(3), // Lainnya
          ],
        ),
      ),
    );
  }

  Widget buildList(int tabIndex) {
    final data = filterData(tabIndex);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final String status = item["status"] ?? "";
        final String jamMasuk = item["jamMasuk"] ?? "-";
        final String jamPulang = item["jamPulang"] ?? "-";
        final String tanggal = item["tanggal"] ?? "-";
        final String badgeLabel = _getBadgeLabel(status, jamMasuk, jamPulang);
        final Color badgeColor = _getBadgeColor(badgeLabel);

        // Format tanggal menggunakan DateFormat (dalam bahasa Indonesia)
        String dateTimeText = DateFormat(
          'EEEE, d MMMM yyyy',
          'id_ID',
        ).format(parseTanggal(tanggal));

        return GestureDetector(
          onTap: () {
            // Navigasi ke halaman DoneAttendanceScreen dengan parameter
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DoneAttendanceScreen(
                      jamMasuk: jamMasuk,
                      jamPulang: jamPulang,
                      locationDatang: "Office Main Entrance",
                      locationPulang: "Office Exit",
                      tanggal: tanggal,
                    ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              // Border kiri dengan warna sesuai badge
              border: Border(left: BorderSide(color: badgeColor, width: 10)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row pertama: ikon status, title, dan badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      getStatusIcon(status),
                      color: const Color(0xFF1F2452),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        status == "WFH" || status == "WFA" || status == "WFO"
                            ? status
                            : status,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Row kedua: detail jam masuk & pulang
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "Masuk: $jamMasuk   |   Pulang: $jamPulang",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Row ketiga: tanggal dengan ikon kalender
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateTimeText,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
