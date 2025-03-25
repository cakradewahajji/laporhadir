import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'done_attendance_screen.dart';
import '../models/kehadiran_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/kehadiran_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasSyncedUser = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _tabController = TabController(length: 4, vsync: this);

    // Panggil fetchKehadiran setelah frame pertama agar context sudah tersedia.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final kehadiranProv = Provider.of<KehadiranProvider>(
        context,
        listen: false,
      );
      if (auth.isAuthenticated) {
        kehadiranProv.fetchKehadiran(auth.token);
      }
    });
  }

  void _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    Intl.defaultLocale = 'id_ID';
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false);
    if (auth.isAuthenticated && !_hasSyncedUser) {
      _hasSyncedUser = true;
      print("Memanggil synchronizeUser dengan token: ${auth.token}");
      user.synchronizeUser(auth.token).then((_) {
        print("Selesai synchronizeUser.");
        setState(() {});
      });
    }
  }

  // Helper: Konversi string waktu "HH:mm:ss" ke menit
  int parseTime(String time) {
    if (time == "-" || time.isEmpty) return -1;
    final parts = time.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Helper: Menghitung status tambahan (misalnya, Telat, Mendahului, dll)
  String computeExtraStatus(String status, String jamMasuk, String jamPulang) {
    if (status == "Dinas" || status == "Cuti" || status == "Sakit") return "";
    if (jamMasuk == "-" || jamMasuk.isEmpty) return "";
    if ((status == "WFH" || status == "WFA" || status == "WFO") &&
        (jamPulang == "-" || jamPulang.isEmpty)) {
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

  // Helper: Menghasilkan label badge berdasarkan status
  String _getBadgeLabel(String status, String jamMasuk, String jamPulang) {
    final extra = computeExtraStatus(status, jamMasuk, jamPulang);
    if (extra == "Belum Absen Pulang") return "In Progress";
    if (extra == "Telat" || extra == "Mendahului") return "Terlambat";
    if (status == "Sakit" || status == "Cuti" || status == "Dinas")
      return "Lainnya";
    return "Selesai";
  }

  // Helper: Menghasilkan warna badge berdasarkan label
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

  // Helper: Mendapatkan ikon berdasarkan status
  IconData getStatusIcon(String status) {
    if (status == "WFH") return Icons.home;
    if (status == "WFO") return Icons.work;
    if (status == "Sakit") return Icons.local_hospital;
    if (status == "Cuti") return Icons.beach_access;
    if (status == "Dinas") return Icons.directions_bus;
    return Icons.info;
  }

  // Helper: Format tanggal dari API (asumsi format "YYYY-MM-DD")
  String formatTanggal(String tanggal) {
    DateTime dateParsed = DateTime.tryParse(tanggal) ?? DateTime.now();
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dateParsed);
  }

  // Filter data kehadiran berdasarkan tab menggunakan List<KehadiranModel>
  List<KehadiranModel> filterData(List<KehadiranModel> data, int tabIndex) {
    List<KehadiranModel> sortedList = List<KehadiranModel>.from(data);
    sortedList.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a.tanggal) ?? DateTime.now();
      DateTime dateB = DateTime.tryParse(b.tanggal) ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
    switch (tabIndex) {
      case 0:
        return sortedList;
      case 1:
        return sortedList.where((item) {
          final status = item.tipe;
          final jamPulang = item.jamPulang;
          return ((status == "WFH" || status == "WFA" || status == "WFO") &&
              (jamPulang == "-" || jamPulang.isEmpty));
        }).toList();
      case 2:
        return sortedList.where((item) {
          final status = item.tipe;
          final extra = computeExtraStatus(
            status,
            item.jamMasuk,
            item.jamPulang,
          );
          return extra == "Telat" || extra == "Mendahului";
        }).toList();
      case 3:
        return sortedList.where((item) {
          final status = item.tipe;
          return status == "Sakit" || status == "Cuti" || status == "Dinas";
        }).toList();
      default:
        return sortedList;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data kehadiran dari provider
    final kehadiranProv = Provider.of<KehadiranProvider>(context);
    // Ambil data user untuk menampilkan full name
    final userProvider = Provider.of<UserProvider>(context);
    final String fullName =
        userProvider.fullname ??
        (userProvider.name.isNotEmpty ? userProvider.name : "User");

    // Jika data kehadiran sedang loading atau terjadi error, tampilkan indikator
    if (kehadiranProv.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (kehadiranProv.errorMessage != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${kehadiranProv.errorMessage}')),
      );
    }

    final List<KehadiranModel> kehadiranList = kehadiranProv.kehadiranList;

    // Cek apakah ada kehadiran pada hari ini (menggunakan tanggal API yang berbentuk "YYYY-MM-DD")
    final DateTime today = DateTime.now();
    final bool attendanceExistsForToday = kehadiranList.any((item) {
      final DateTime recordDate =
          DateTime.tryParse(item.tanggal) ?? DateTime.now();
      return recordDate.day == today.day &&
          recordDate.month == today.month &&
          recordDate.year == today.year;
    });

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFEF),
        appBar: AppBar(
          title: Text(
            "LAPOR HADIR - $fullName",
            style: const TextStyle(color: Colors.white),
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
                  "Welcome,\n$fullName",
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
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
            buildList(0, kehadiranList),
            buildList(1, kehadiranList),
            buildList(2, kehadiranList),
            buildList(3, kehadiranList),
          ],
        ),
      ),
    );
  }

  Widget buildList(int tabIndex, List<KehadiranModel> data) {
    List<KehadiranModel> filtered = filterData(data, tabIndex);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final String status = item.tipe;
        final String jamMasuk = item.jamMasuk;
        final String jamPulang = item.jamPulang;
        final String tanggal = item.tanggal;
        final String keteranganMasuk = item.keteranganMasuk;
        final String keteranganPulang = item.keteranganPulang;
        final String badgeLabel = _getBadgeLabel(status, jamMasuk, jamPulang);
        final Color badgeColor = _getBadgeColor(badgeLabel);

        String dateTimeText = DateFormat(
          'EEEE, d MMMM yyyy',
          'id_ID',
        ).format(DateTime.tryParse(tanggal) ?? DateTime.now());

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DoneAttendanceScreen(
                      jamMasuk: jamMasuk,
                      jamPulang: jamPulang,
                      locationDatang:
                          item.latitudeMasuk == 0
                              ? "N/A"
                              : "Latitude: ${item.latitudeMasuk}, Longitude: ${item.longitudeMasuk}",
                      locationPulang:
                          item.latitudePulang == 0
                              ? "N/A"
                              : "Latitude: ${item.latitudePulang}, Longitude: ${item.longitudePulang}",
                      keteranganMasuk: item.keteranganMasuk,
                      keteranganPulang: item.keteranganPulang,
                      tanggal: DateFormat(
                        'EEEE, d MMMM yyyy',
                        'id_ID',
                      ).format(DateTime.tryParse(tanggal) ?? DateTime.now()),
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
                // Baris pertama: ikon status, title, dan badge
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
                        status,
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
