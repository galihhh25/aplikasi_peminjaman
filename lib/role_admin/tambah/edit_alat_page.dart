import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAlatPage extends StatefulWidget {
  final Map<String, dynamic> alat;
  const EditAlatPage({super.key, required this.alat});

  @override
  State<EditAlatPage> createState() => _EditAlatPageState();
}

class _EditAlatPageState extends State<EditAlatPage> {
  final supabase = Supabase.instance.client;

  final namaAlat = TextEditingController();
  final spesifikasi = TextEditingController();
  final kondisi = TextEditingController();
  final stok = TextEditingController();

  // 🔽 KATEGORI
  final List<String> kategoriList = [
    'Bola Besar',
    'Bola Kecil',
    'Tongkat',
    'Jaring Net',
    'Kun',
  ];
  String? selectedKategori;

  Uint8List? imageBytes;
  final picker = ImagePicker();
  bool loading = false;

  static const Color primaryBlue = Color(0xFF0E2A47);

  @override
  void initState() {
    super.initState();
    namaAlat.text = widget.alat['nama_alat'];
    spesifikasi.text = widget.alat['spesifikasi'] ?? '';
    kondisi.text = widget.alat['kondisi'] ?? '';
    stok.text = widget.alat['stok'].toString();
    selectedKategori = widget.alat['kategori'];
  }

  Future<void> pickImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => imageBytes = bytes);
    }
  }

  Future<String?> uploadGambar() async {
    if (imageBytes == null) return widget.alat['gambar'];

    final fileName = 'alat_${DateTime.now().millisecondsSinceEpoch}.png';

    await supabase.storage.from('alat').uploadBinary(
          fileName,
          imageBytes!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('alat').getPublicUrl(fileName);
  }

  Future<void> simpanPerubahan() async {
    if (namaAlat.text.isEmpty || stok.text.isEmpty || selectedKategori == null)
      return;

    setState(() => loading = true);

    try {
      final imageUrl = await uploadGambar();

      await supabase.from('alat').update({
        'nama_alat': namaAlat.text,
        'kategori': selectedKategori,
        'spesifikasi': spesifikasi.text,
        'kondisi': kondisi.text,
        'stok': int.parse(stok.text),
        'gambar': imageUrl,
      }).eq('id', widget.alat['id']);

      await supabase.from('log_aktivitas').insert({
  'user_id': supabase.auth.currentUser!.id,
  'log_aktivitas': 'Admin mengedit data alat: ${namaAlat.text}',
});

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
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
        title: const Text('Edit Alat', style: TextStyle(color: Colors.white)),
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

              // 🔽 DROPDOWN KATEGORI
              DropdownButtonFormField<String>(
                value: selectedKategori,
                items: kategoriList
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(k),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedKategori = v),
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
                          child: Image.memory(imageBytes!, fit: BoxFit.cover),
                        )
                      : widget.alat['gambar'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                widget.alat['gambar'],
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 48),
                                SizedBox(height: 6),
                                Text('Ubah Gambar'),
                              ],
                            ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: loading ? null : simpanPerubahan,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
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
