import 'package:flutter/material.dart';
import 'alat_admin_page.dart';
import 'daftar_petugas_page.dart';
import 'profile_admin_page.dart';

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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Alat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge),
            label: 'Petugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _headerDashboard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
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

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoCard(
            title: 'Petugas Aktif',
            value: '3 Orang',
            icon: Icons.badge,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  title: 'Total Peminjam',
                  value: '18',
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoCard(
                  title: 'Alat Dipinjam',
                  value: '27',
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: const [
                BorrowItem(
                  nama: 'Budi Santoso',
                  alat: 'TV Samsung',
                  status: 'Dipinjam',
                ),
                BorrowItem(
                  nama: 'Siti Aminah',
                  alat: 'Proyektor Epson',
                  status: 'Dikembalikan',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

/* ================= ITEM ================= */

class BorrowItem extends StatelessWidget {
  final String nama;
  final String alat;
  final String status;

  const BorrowItem({
    super.key,
    required this.nama,
    required this.alat,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDipinjam = status == 'Dipinjam';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDipinjam ? Colors.orange : Colors.green,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(alat, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDipinjam
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isDipinjam ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
