import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_ukk/role_admin/tambah/tambah_petugas_page.dart';
import 'package:projek_ukk/role_admin/tambah/edit_petugas_page.dart';

class DaftarPetugasPage extends StatefulWidget {
  const DaftarPetugasPage({super.key});

  @override
  State<DaftarPetugasPage> createState() => _DaftarPetugasPageState();
}

class _DaftarPetugasPageState extends State<DaftarPetugasPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> petugas = [];
  bool loading = true;

  static const Color primaryBlue = Color(0xFF0E2A47);

  @override
  void initState() {
    super.initState();
    loadPetugas();
  }

  // ================= LOAD PETUGAS =================
  Future<void> loadPetugas() async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('role', 'petugas') // 🔥 FILTER PETUGAS
          .order('created_at', ascending: false);

      setState(() {
        petugas = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= HAPUS PETUGAS =================
  Future<void> konfirmasiHapus(Map<String, dynamic> p) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Petugas'),
        content: Text('Yakin arep ngapus ${p['nama']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      await supabase.from('users').delete().eq('userid', p['userid']);
      loadPetugas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          'Daftar Petugas',
          style: TextStyle(color: Colors.white),
        ),
      ),

      // ================= TAMBAH PETUGAS =================
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahPetugasPage(),
            ),
          );

          if (result == true) {
            loadPetugas();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : petugas.isEmpty
              ? const Center(
                  child: Text(
                    'Data petugas kosong',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: petugas.length,
                  itemBuilder: (context, i) {
                    return kartuPetugas(petugas[i]);
                  },
                ),
    );
  }

  // ================= KARTU PETUGAS =================
  Widget kartuPetugas(Map<String, dynamic> p) {
    final foto = p['foto_profile'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryBlue,
            backgroundImage:
                foto != null && foto != '' ? NetworkImage(foto) : null,
            child: foto == null || foto == ''
                ? Text(
                    p['nama'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['nama'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p['email'] ?? '-',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Text(
                  p['nomertelpon']?.toString() ?? '-',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPetugasPage(petugas: p),
                    ),
                  );
                  loadPetugas();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => konfirmasiHapus(p),
              ),
            ],
          )
        ],
      ),
    );
  }
}
