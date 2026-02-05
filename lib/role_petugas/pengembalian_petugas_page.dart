import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PantauPengembalianPage extends StatefulWidget {
  const PantauPengembalianPage({super.key});

  static const Color primaryBlue = Color(0xFF0E2A47);

  @override
  State<PantauPengembalianPage> createState() => _PantauPengembalianPageState();
}

class _PantauPengembalianPageState extends State<PantauPengembalianPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchPengembalian();
  }

  Future<void> fetchPengembalian() async {
    final res = await supabase
        .from('pengembalian')
        .select()
        .order('tanggal_kembali', ascending: false);

    setState(() {
      data = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PantauPengembalianPage.primaryBlue,
      appBar: AppBar(
        backgroundColor: PantauPengembalianPage.primaryBlue,
        elevation: 0,
        title: const Text(
          'Pantau Pengembalian',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : data.isEmpty
              ? const Center(
                  child: Text(
                    'Durung ono data pengembalian',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return PengembalianCard(item: data[index]);
                  },
                ),
    );
  }
}

/* ================= CARD ================= */
class PengembalianCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const PengembalianCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item['status'] ?? 'dipinjam';
    final warna = status == 'dikembalikan' ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warna, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['nama_alat'] ?? '-',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: warna.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: warna,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          infoRow('Peminjam', item['nama_peminjam'] ?? '-'),
          infoRow('Tgl Pinjam', item['tanggal_pinjam'] ?? '-'),
          infoRow('Tgl Kembali', item['tanggal_kembali'] ?? '-'),
          infoRow('Kondisi', item['kondisi_kembali'] ?? '-'),
        ],
      ),
    );
  }

  Widget infoRow(String kiri, String kanan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              kiri,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Text(
            kanan,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
