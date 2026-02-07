import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key, required Map<String, dynamic> alat});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final supabase = Supabase.instance.client;

  final namaAlat = TextEditingController();
  final spesifikasi = TextEditingController();
  final kondisi = TextEditingController();
  final stok = TextEditingController();

  Uint8List? imageBytes;
  final picker = ImagePicker();
  bool loading = false;

  static const Color primaryBlue = Color(0xFF0E2A47);

  // ===== KATEGORI =====
  String? selectedKategori;
  final List<String> kategoriList = [
    'Bola Besar',
    'Bola Kecil',
    'Tongkat',
    'Jaring Net',
    'Kun',
  ];

  Future<void> pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => imageBytes = bytes);
    }
  }

  Future<String?> uploadGambar() async {
    if (imageBytes == null) return null;

    final fileName = 'alat_${DateTime.now().millisecondsSinceEpoch}.png';

    await supabase.storage.from('alat').uploadBinary(
          fileName,
          imageBytes!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('alat').getPublicUrl(fileName);
  }

  Future<void> simpanProduk() async {
    if (namaAlat.text.isEmpty ||
        stok.text.isEmpty ||
        selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kabeh data sek')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final imageUrl = await uploadGambar();

      await supabase.from('alat').insert({
        'nama_alat': namaAlat.text,
        'kategori': selectedKategori,
        'spesifikasi': spesifikasi.text,
        'kondisi': kondisi.text,
        'stok': int.parse(stok.text),
        'gambar': imageUrl,
      });

      await supabase.from('log_aktivitas').insert({
  'user_id': supabase.auth.currentUser!.id,
  'log_aktivitas': 'Admin menambahkan alat: ${namaAlat.text}',
});

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal simpan: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Tambah Alat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              field('Nama Alat', namaAlat),
              const SizedBox(height: 12),

              // ===== DROPDOWN KATEGORI =====
              DropdownButtonFormField<String>(
                value: selectedKategori,
                items: kategoriList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedKategori = val;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              field('Spesifikasi', spesifikasi, max: 3),
              const SizedBox(height: 12),
              field('Kondisi', kondisi),
              const SizedBox(height: 12),
              field('Stok', stok, number: true),
              const SizedBox(height: 16),

              // ===== GAMBAR =====
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(
                            imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 48),
                            SizedBox(height: 6),
                            Text('Tambah Gambar'),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBlue,
                        side: const BorderSide(color: primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: loading ? null : simpanProduk,
                      child: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget field(
    String label,
    TextEditingController c, {
    int max = 1,
    bool number = false,
  }) {
    return TextField(
      controller: c,
      maxLines: max,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
