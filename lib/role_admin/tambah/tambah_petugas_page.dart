import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahPetugasPage extends StatefulWidget {
  const TambahPetugasPage({super.key});

  @override
  State<TambahPetugasPage> createState() => _TambahPetugasPageState();
}

class _TambahPetugasPageState extends State<TambahPetugasPage> {
  static const Color primaryBlue = Color(0xFF0E2A47);

  final nama = TextEditingController();
  final email = TextEditingController();
  final telp = TextEditingController();
  final alamat = TextEditingController();
  final password = TextEditingController();

  Uint8List? foto;
  final picker = ImagePicker();

  Future<void> pickFoto() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      foto = await img.readAsBytes();
      setState(() {});
    }
  }

  Future<void> simpanPetugas() async {
    final supabase = Supabase.instance.client;

    try {
      // 1️⃣ SIGN UP AUTH
      final authRes = await supabase.auth.signUp(
        email: email.text.trim(),
        password: password.text,
      );

      final user = authRes.user;
      if (user == null) throw 'Gagal membuat akun';

      // 2️⃣ UPLOAD FOTO
      String? fotoUrl;
      if (foto != null) {
        final fileName =
            'user_${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';

        await supabase.storage
            .from('foto_profile')
            .uploadBinary(fileName, foto!);

        fotoUrl =
            supabase.storage.from('foto_profile').getPublicUrl(fileName);
      }

      // 3️⃣ INSERT KE TABLE USERS
      await supabase.from('users').insert({
        'userid': user.id,
        'email': email.text,
        'role': 'petugas',
        'nama': nama.text,
        'nomertelpon': telp.text,
        'alamat': alamat.text,
        'foto_profile': fotoUrl,
      });

      // 4️⃣ LOGOUT AKUN PETUGAS
      await supabase.auth.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Petugas berhasil ditambahkan')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title:
            const Text('Tambah Petugas', style: TextStyle(color: Colors.black)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Foto Profil',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: foto != null ? MemoryImage(foto!) : null,
                    child: foto == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: pickFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Unggah Foto'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              field('Nama Lengkap', nama),
              field('Email', email),
              field('Password Login', password),
              field('Nomor Telpon', telp),
              field('Alamat Lengkap', alamat, max: 3),
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
                      onPressed: simpanPetugas,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              )
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: max,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
