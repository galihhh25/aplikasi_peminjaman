import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'alat_admin_page.dart';
import 'daftar_petugas_page.dart';
import 'profile_admin_page.dart';

/* ================= DASHBOARD PAGE ================= */

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final Color primaryBlue = const Color(0xFF0E2A47);

  final List<Widget> _pages = const [
    DashboardContent(),
    AlatAdminPage(),
    DaftarPetugasPage(),
    ProfileAdminPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentIndex == 0) _headerDashboard(),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0B2540),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.tv), label: 'Alat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.badge), label: 'Petugas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _headerDashboard() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Dashboard Admin',
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/* ================= DASHBOARD CONTENT ================= */

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final supabase = Supabase.instance.client;

  int totalPetugas = 0;
  int totalPeminjam = 0;
  int alatDipinjam = 0;

  List<Map<String, dynamic>> peminjamanTerbaru = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final petugas = await supabase
          .from('users')
          .select('userid')
          .eq('role', 'petugas');

      final peminjam = await supabase
          .from('users')
          .select('userid')
          .eq('role', 'peminjam');

      final dipinjam = await supabase
          .from('peminjaman')
          .select('id')
          .inFilter('status', ['dipinjam', 'disetujui']);

      final terbaru = await supabase.from('peminjaman').select('''
            id,
            status,
            users:user_id (nama),
            alat:alat_id (nama_alat)
          ''').order('id', ascending: false).limit(5);

      setState(() {
        totalPetugas = petugas.length;
        totalPeminjam = peminjam.length;
        alatDipinjam = dipinjam.length;
        peminjamanTerbaru = List<Map<String, dynamic>>.from(terbaru);
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoCard(
            title: 'Petugas Aktif',
            value: '$totalPetugas Orang',
            icon: Icons.badge,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _infoCard(
                  title: 'Total Peminjam',
                  value: '$totalPeminjam',
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoCard(
                  title: 'Alat Dipinjam',
                  value: '$alatDipinjam',
                  icon: Icons.build,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Peminjaman Terbaru',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: peminjamanTerbaru.length,
            itemBuilder: (context, i) {
              final item = peminjamanTerbaru[i];
              return BorrowItem(
                nama: item['users']?['nama'] ?? '-',
                alat: item['alat']?['nama_alat'] ?? '-',
                status: item['status'] ?? '-',
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Log Aktivitas Admin & Petugas',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          const LogAktivitasSection(),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient:
            LinearGradient(colors: [color.withOpacity(0.9), color.withOpacity(0.6)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

/* ================= LOG AKTIVITAS ================= */

class LogAktivitasSection extends StatefulWidget {
  const LogAktivitasSection({super.key});

  @override
  State<LogAktivitasSection> createState() => _LogAktivitasSectionState();
}

class _LogAktivitasSectionState extends State<LogAktivitasSection> {
  final supabase = Supabase.instance.client;
  bool loading = true;

  List<Map<String, dynamic>> adminLogs = [];
  List<Map<String, dynamic>> petugasLogs = [];

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<void> _loadLog() async {
  try {
    final res = await supabase.from('log_aktivitas').select('''
      id,
      log_aktivitas,
      waktu,
      users:user_id (
        nama,
        role
      )
    ''').order('waktu', ascending: false).limit(20);

    final list = List<Map<String, dynamic>>.from(res);

    setState(() {
      adminLogs =
          list.where((e) => e['users']?['role'] == 'admin').toList();
      petugasLogs =
          list.where((e) => e['users']?['role'] == 'petugas').toList();
      loading = false;
    });
  } catch (e) {
    debugPrint('Log error: $e');
    loading = false;
  }
}


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Aktivitas Admin', Colors.blue),
        _list(adminLogs, true),
        const SizedBox(height: 20),
        _title('Aktivitas Petugas', Colors.green),
        _list(petugasLogs, false),
      ],
    );
  }

  Widget _title(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _list(List<Map<String, dynamic>> data, bool isAdmin) {
    if (data.isEmpty) {
      return const Text('Belum ada aktivitas',
          style: TextStyle(color: Colors.white70));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final item = data[i];
        return BorrowItem(
          nama: item['users']?['nama'] ?? 'Sistem',
          alat: item['log_aktivitas'] ?? '-',
          status: item['users']?['role'] ?? '-',
        );
      },
    );
  }
}

/* ================= ITEM ================= */

class BorrowItem extends StatelessWidget {
  final String nama;
  final String alat;
  final String status;

  const BorrowItem(
      {super.key,
      required this.nama,
      required this.alat,
      required this.status});

  @override
  Widget build(BuildContext context) {
    final aktif = status == 'admin' || status == 'petugas';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: aktif ? Colors.blue : Colors.green,
            child: const Icon(Icons.inventory, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(alat, style: const TextStyle(color: Colors.grey)),
                ]),
          ),
          Text(status.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
