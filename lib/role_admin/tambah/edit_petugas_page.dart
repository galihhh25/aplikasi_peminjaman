import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPetugasPage extends StatefulWidget {
  final Map<String, dynamic> petugas;

  const EditPetugasPage({super.key, required this.petugas});

  @override
  State<EditPetugasPage> createState() => _EditPetugasPageState();
}

class _EditPetugasPageState extends State<EditPetugasPage> {
  static const Color primaryBlue = Color(0xFF0E2A47);

  final supabase = Supabase.instance.client;

  final nama = TextEditingController();
  final email = TextEditingController();
  final telp = TextEditingController();
  final alamat = TextEditingController();
  final password = TextEditingController(); // ✅ TAMBAH PASSWORD

  Uint8List? fotoBaru;
  String? fotoLama;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.petugas;

    nama.text = p['nama']?.toString() ?? '';
    email.text = p['email']?.toString() ?? '';
    telp.text = p['nomertelpon']?.toString() ?? '';
    alamat.text = p['alamat']?.toString() ?? '';
    fotoLama = p['foto'];
  }

  @override
  void dispose() {
    nama.dispose();
    email.dispose();
    telp.dispose();
    alamat.dispose();
    password.dispose();
    super.dispose();
  }

  ImageProvider? getAvatarImage() {
    if (fotoBaru != null) return MemoryImage(fotoBaru!);
    if (fotoLama != null && fotoLama!.isNotEmpty) {
      return NetworkImage(fotoLama!);
    }
    return null;
  }

  Future<void> pickFoto() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      fotoBaru = await img.readAsBytes();
      setState(() {});
    }
  }

  Future<void> updatePetugas() async {
    try {
      String? fotoUrl = fotoLama;

      // ===== UPLOAD FOTO =====
      if (fotoBaru != null) {
        final fileName = 'petugas_${DateTime.now().millisecondsSinceEpoch}.png';
        await supabase.storage.from('foto_petugas').uploadBinary(
              fileName,
              fotoBaru!,
              fileOptions: const FileOptions(upsert: true),
            );
        fotoUrl = supabase.storage.from('foto_petugas').getPublicUrl(fileName);
      }

      // ===== UPDATE DATA PETUGAS =====
      await supabase.from('users').update({
        'nama': nama.text,
        'email': email.text,
        'nomertelpon': int.tryParse(telp.text) ?? 0,
        'alamat': alamat.text,
        'foto': fotoUrl,
      }).eq('id', widget.petugas['id']);

      // ===== UPDATE PASSWORD (JIKA DIISI) =====
      if (password.text.isNotEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(password: password.text),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Petugas berhasil diupdate')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
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
            const Text('Edit Petugas', style: TextStyle(color: Colors.black)),
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
                    backgroundImage: getAvatarImage(),
                    child: getAvatarImage() == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: pickFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ganti Foto'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              field('Nama Lengkap', nama, icon: Icons.person),
              const SizedBox(height: 12),
              field('Email', email, icon: Icons.email),
              const SizedBox(height: 12),

              // 🔐 PASSWORD BARU (OPSIONAL)
              field('Password Baru (opsional)', password, icon: Icons.lock),

              const SizedBox(height: 12),
              field('Nomor Telpon', telp, icon: Icons.phone, number: true),
              const SizedBox(height: 12),
              field('Alamat Lengkap', alamat, icon: Icons.location_on, max: 3),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: updatePetugas,
                      child: const Text('Update'),
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
    IconData? icon,
    bool number = false,
    int max = 1,
  }) {
    return TextField(
      controller: c,
      maxLines: max,
      obscureText: icon == Icons.lock, // 🔐 sembunyikan password
      keyboardType: number ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
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
