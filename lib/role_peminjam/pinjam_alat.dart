import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dasboard_peminjam_page.dart';

/* =========================================================
   FORM PEMINJAMAN PAGE
========================================================= */

class FormPeminjamanPage extends StatefulWidget {
  final Map<String, dynamic> alat;

  const FormPeminjamanPage({
    super.key,
    required this.alat,
  });

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController keperluanController = TextEditingController();

  DateTime? tanggalPinjam;
  DateTime? tanggalKembali;

  bool loading = false;

  Future<void> submitPeminjaman() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (namaController.text.isEmpty ||
        jumlahController.text.isEmpty ||
        keperluanController.text.isEmpty ||
        tanggalPinjam == null ||
        tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Data durung lengkap')),
      );
      return;
    }

    final int jumlahPinjam = int.parse(jumlahController.text);
    final int stokSekarang = widget.alat['stok'];

    // 🔴 CEK STOK
    if (jumlahPinjam > stokSekarang) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Stok ora cukup')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 1️⃣ INSERT KE TABEL PEMINJAMAN
      await supabase.from('peminjaman').insert({
        'user_id': user.id,
        'alat_id': widget.alat['id'],
        'nama_peminjam': namaController.text,
        'jumlah': jumlahPinjam,
        'tanggal_pinjam': tanggalPinjam!.toIso8601String(),
        'tanggal_kembali': tanggalKembali!.toIso8601String(),
        'keperluan': keperluanController.text,
        'status': 'menunggu',
      });

      // 2️⃣ UPDATE STOK ALAT  ⬅️ KUNCI UTAMA
      await supabase.from('alat').update({
        'stok': stokSekarang - jumlahPinjam,
      }).eq('id', widget.alat['id']);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Peminjaman berhasil diajukan')),
      );

      // balik dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPeminjamPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> pilihTanggal(bool isPinjam) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        isPinjam ? tanggalPinjam = picked : tanggalKembali = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Peminjaman'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.alat['nama_alat'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Peminjam',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Pinjam',
                  border: const OutlineInputBorder(),
                  helperText: 'Stok tersedia: ${widget.alat['stok']}',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Tanggal Pinjam'),
                subtitle: Text(
                  tanggalPinjam == null
                      ? 'Pilih tanggal'
                      : tanggalPinjam!.toString().split(' ')[0],
                ),
                trailing: const Icon(Icons.date_range),
                onTap: () => pilihTanggal(true),
              ),
              ListTile(
                title: const Text('Tanggal Kembali'),
                subtitle: Text(
                  tanggalKembali == null
                      ? 'Pilih tanggal'
                      : tanggalKembali!.toString().split(' ')[0],
                ),
                trailing: const Icon(Icons.date_range),
                onTap: () => pilihTanggal(false),
              ),
              TextField(
                controller: keperluanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keperluan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : submitPeminjaman,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Ajukan Peminjaman',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
