import 'package:flutter/material.dart';
import 'package:projek_ukk/role_peminjam/daftar_alat_page.dart';
import 'package:projek_ukk/role_peminjam/profile_peminjam_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_ukk/role_peminjam/pengembalian_alat_page.dart';

/* ================= DASHBOARD PAGE ================= */

class DashboardPeminjamPage extends StatefulWidget {
  const DashboardPeminjamPage({super.key});

  @override
  State<DashboardPeminjamPage> createState() => _DashboardPeminjamPageState();
}

class _DashboardPeminjamPageState extends State<DashboardPeminjamPage> {
  int _currentIndex = 0;

  static const Color primaryBlue = Color(0xFF0E2A47);
  static const Color secondaryBlue = Color(0xFF0B2540);

  final List<Widget> _pages = const [
    DashboardPeminjamContent(),
    DaftarAlatPage(),
    RiwayatPeminjamanPage(),
    ProfilePeminjamPage(),
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
        backgroundColor: secondaryBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Alat'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _headerDashboard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Dashboard Peminjam',
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

class DashboardPeminjamContent extends StatelessWidget {
  const DashboardPeminjamContent({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      return const Center(
        child: Text('User durung login', style: TextStyle(color: Colors.white)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          const Text(
            'Barang sing tak silih',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: supabase
                  .from('peminjaman')
                  .select('''
                    id,
                    alat_id,
                    jumlah,
                    tanggal_pinjam,
                    tanggal_kembali,
                    keperluan,
                    status,
                    alat:alat_id (
                      nama_alat,
                      gambar
                    )
                  ''')
                  .eq('user_id', user.id)
                  .order('id', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Durung ono peminjaman',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final item = data[i];
                    final alat = item['alat'];

                    if (alat == null) {
                      return const SizedBox();
                    }

                    return AlatDashboardCard(
                      alat: alat,
                      item: item,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= CARD ================= */

class AlatDashboardCard extends StatefulWidget {
  final Map<String, dynamic> alat;
  final Map<String, dynamic> item;

  const AlatDashboardCard({
    super.key,
    required this.alat,
    required this.item,
  });

  @override
  State<AlatDashboardCard> createState() => _AlatDashboardCardState();
}

class _AlatDashboardCardState extends State<AlatDashboardCard> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.item['status'];
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ditolak':
        return Colors.red;
      case 'disetujui':
        return Colors.green;
      case 'dipinjam':
        return Colors.blue;
      case 'dikembalikan':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showButton = status == 'disetujui' || status == 'dipinjam';

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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: widget.alat['gambar'] != null
                ? Image.network(
                    widget.alat['gambar'],
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 170,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image, size: 60),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.alat['nama_alat'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _row('Jumlah', widget.item['jumlah']?.toString()),
                _row(
                  'Tanggal Pinjam',
                  widget.item['tanggal_pinjam']?.toString().split('T')[0],
                ),
                _row(
                  'Tanggal Kembali',
                  widget.item['tanggal_kembali']?.toString().split('T')[0],
                ),
                _row('Keperluan', widget.item['keperluan']),
                const SizedBox(height: 12),
                showButton
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PengembalianPage(
                                  peminjamanId: widget.item['id'],
                                  alatId: widget.item['alat_id'],
                                  jumlah: widget.item['jumlah'],
                                  namaAlat: widget.alat['nama_alat'],
                                  tanggalJatuhTempo: DateTime.parse(
                                    widget.item['tanggal_kembali'],
                                  ),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Kembalikan Alat'),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _statusColor(status),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          status == 'dikembalikan'
                              ? 'ALAT SUDAH DIKEMBALIKAN'
                              : status.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= RIWAYAT ================= */

class RiwayatPeminjamanPage extends StatelessWidget {
  const RiwayatPeminjamanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Riwayat Peminjaman',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
