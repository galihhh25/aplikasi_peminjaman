import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'alat_Petugas_page.dart';
import 'pengembalian_petugas_page.dart';
import 'profile_petugas_page.dart';

class DashboardPetugasPage extends StatefulWidget {
  const DashboardPetugasPage({super.key});

  @override
  State<DashboardPetugasPage> createState() => _DashboardPetugasPageState();
}

class _DashboardPetugasPageState extends State<DashboardPetugasPage> {
  int _currentIndex = 0;
  final Color primaryBlue = const Color(0xFF0E2A47);

  final List<Widget> _pages = const [
    DashboardPetugasContent(),
    AlatPetugasPage(),
    PantauPengembalianPage(),
    ProfilePetugasPage(),
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
        onTap: (index) => setState(() => _currentIndex = index),
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
            icon: Icon(Icons.notifications),
            label: 'Pengembalian',
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
            'Dashboard Petugas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.badge, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/* ================= DASHBOARD CONTENT ================= */

class DashboardPetugasContent extends StatefulWidget {
  const DashboardPetugasContent({super.key});

  @override
  State<DashboardPetugasContent> createState() =>
      _DashboardPetugasContentState();
}

class _DashboardPetugasContentState extends State<DashboardPetugasContent> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> peminjamanList = [];

  @override
  void initState() {
    super.initState();
    _listenPeminjaman();
  }

  void _listenPeminjaman() {
    supabase
        .from('peminjaman')
        .stream(primaryKey: ['id'])
        .eq('status', 'menunggu')
        .listen((data) {
          if (!mounted) return;
          setState(() {
            peminjamanList = List<Map<String, dynamic>>.from(data);
          });
        });
  }

  /// ===== URL GAMBAR DARI SUPABASE STORAGE =====
  String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return supabase.storage
        .from('alat') // 🔴 GANTI sesuai nama bucket
        .getPublicUrl(path);
  }

  Future<void> setujui(int id) async {
    await supabase
        .from('peminjaman')
        .update({'status': 'disetujui'}).eq('id', id);

    if (!mounted) return;
    setState(() {
      peminjamanList.removeWhere((e) => e['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Peminjaman disetujui')),
    );
  }

  Future<void> tolak(int id) async {
    try {
      // 1️⃣ Ambil data peminjaman
      final peminjaman = await supabase
          .from('peminjaman')
          .select('alat_id, jumlah')
          .eq('id', id)
          .single();

      final int alatId = peminjaman['alat_id'];
      final int jumlahPinjam = peminjaman['jumlah'];

      // 2️⃣ Ambil stok alat saiki
      final alat =
          await supabase.from('alat').select('stok').eq('id', alatId).single();

      final int stokSekarang = alat['stok'];

      // 3️⃣ Balekno stok
      await supabase
          .from('alat')
          .update({'stok': stokSekarang + jumlahPinjam}).eq('id', alatId);

      // 4️⃣ Update status peminjaman
      await supabase
          .from('peminjaman')
          .update({'status': 'ditolak'}).eq('id', id);

      if (!mounted) return;

      setState(() {
        peminjamanList.removeWhere((e) => e['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('❌ Peminjaman ditolak & stok dikembalikan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permintaan Peminjaman',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: peminjamanList.isEmpty
                ? const Center(
                    child: Text(
                      'Durung ono peminjaman',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: peminjamanList.length,
                    itemBuilder: (context, index) {
                      final item = peminjamanList[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// ===== GAMBAR =====
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: Image.network(
                                imageUrl(item['gambar']), // ✅ BENER
                                height: 170,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  height: 170,
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(Icons.image, size: 60),
                                  ),
                                ),
                              ),
                            ),

                            /// ===== ISI =====
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama_alat'] ?? 'Nama Alat',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _row('Nama Peminjam',
                                      item['nama_peminjam'] ?? '-'),
                                  _row('Jumlah Pinjam',
                                      item['jumlah']?.toString() ?? '0'),
                                  _row(
                                    'Tanggal Pinjam',
                                    item['tanggal_pinjam'] != null
                                        ? item['tanggal_pinjam']
                                            .toString()
                                            .split('T')[0]
                                        : '-',
                                  ),
                                  _row(
                                    'Tanggal Kembali',
                                    item['tanggal_kembali'] != null
                                        ? item['tanggal_kembali']
                                            .toString()
                                            .split('T')[0]
                                        : '-',
                                  ),
                                  _row('Keperluan', item['keperluan'] ?? '-'),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => setujui(item['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: const Text('Setujui'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => tolak(item['id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: const Text('Tolak'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
