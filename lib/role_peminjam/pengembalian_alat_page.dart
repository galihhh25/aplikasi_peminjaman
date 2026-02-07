import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengembalianPage extends StatefulWidget {
  final int peminjamanId;
  final int alatId;
  final int jumlah;
  final String namaAlat;
  final DateTime tanggalJatuhTempo;

  const PengembalianPage({
    super.key,
    required this.peminjamanId,
    required this.alatId,
    required this.jumlah,
    required this.namaAlat,
    required this.tanggalJatuhTempo,
  });

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  DateTime? tanggalPengembalian;

  int hariTelat = 0;
  int dendaTelat = 0;
  int dendaKerusakan = 0;
  int totalDenda = 0;

  static const int dendaPerHari = 5000;

  String kondisi = 'Baik';

  final Map<String, bool> kerusakan = {
    'Robek': false,
    'Pecah': false,
    'Kempes': false,
    'Patah': false,
    'Hilang Sebagian': false,
    'Tidak Layak Pakai': false,
  };

  final List<String> kerusakanBerat = [
    'Patah',
    'Tidak Layak Pakai',
    'Hilang Sebagian',
  ];

  final List<String> kerusakanRingan = [
    'Robek',
    'Pecah',
    'Kempes',
  ];

  @override
  void initState() {
    super.initState();
    jumlahController.text = widget.jumlah.toString();
    tanggalPengembalian = DateTime.now();
    _hitungSemua();
  }

  // ================= HITUNG =================

  void _hitungSemua() {
    _hitungDendaTelat();
    _hitungKondisi();
    totalDenda = dendaTelat + dendaKerusakan;
  }

  void _hitungDendaTelat() {
    if (tanggalPengembalian!.isAfter(widget.tanggalJatuhTempo)) {
      hariTelat =
          tanggalPengembalian!.difference(widget.tanggalJatuhTempo).inDays;
      dendaTelat = hariTelat * dendaPerHari;
    } else {
      hariTelat = 0;
      dendaTelat = 0;
    }
  }

  void _hitungKondisi() {
    final dipilih =
        kerusakan.entries.where((e) => e.value).map((e) => e.key).toList();

    final adaBerat = dipilih.any((e) => kerusakanBerat.contains(e));
    final jumlahRingan =
        dipilih.where((e) => kerusakanRingan.contains(e)).length;

    if (dipilih.isEmpty) {
      kondisi = 'Baik';
      dendaKerusakan = 0;
    } else if (adaBerat || dipilih.length >= 3) {
      kondisi = 'Rusak Berat';
      dendaKerusakan = 50000;
    } else if (jumlahRingan == 2) {
      kondisi = 'Rusak Sedang';
      dendaKerusakan = 25000;
    } else {
      kondisi = 'Rusak Ringan';
      dendaKerusakan = 10000;
    }
  }

  Color _warnaKondisi() {
    switch (kondisi) {
      case 'Rusak Berat':
        return Colors.red;
      case 'Rusak Sedang':
        return Colors.amber;
      case 'Rusak Ringan':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // ================= DATABASE =================

  Future<void> kembalikanAlat() async {
    try {
      // ambil stok alat
      final alat = await supabase
          .from('alat')
          .select('stok')
          .eq('id', widget.alatId)
          .single();

      final int stokSekarang = alat['stok'];

      // update stok
      await supabase.from('alat').update({
        'stok': stokSekarang + widget.jumlah,
      }).eq('id', widget.alatId);

      // update status peminjaman
      await supabase.from('peminjaman').update({
        'status': 'dikembalikan',
      }).eq('id', widget.peminjamanId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengembalian berhasil disimpan')),
      );

      Navigator.pop(context, true); // 🔥 refresh dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pengembalian Alat'),
        backgroundColor: const Color(0xFF0E2A47),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Nama Alat'),
              Text(widget.namaAlat),

              _label('Jumlah Dikembalikan'),
              TextFormField(
                controller: jumlahController,
                readOnly: true,
                decoration: _input(),
              ),

              _label('Tanggal Pengembalian'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${tanggalPengembalian!.day}-${tanggalPengembalian!.month}-${tanggalPengembalian!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: tanggalPengembalian!,
                    firstDate: widget.tanggalJatuhTempo,
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      tanggalPengembalian = picked;
                      _hitungSemua();
                    });
                  }
                },
              ),

              _label('Kondisi'),
              Text(
                kondisi,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _warnaKondisi(),
                ),
              ),

              const SizedBox(height: 10),
              _label('Detail Kerusakan'),
              ...kerusakan.keys.map((k) {
                return CheckboxListTile(
                  title: Text(k),
                  value: kerusakan[k],
                  onChanged: (v) {
                    setState(() {
                      kerusakan[k] = v!;
                      _hitungSemua();
                    });
                  },
                );
              }),

              const Divider(),
              Text('Denda Telat : Rp $dendaTelat'),
              Text('Denda Kerusakan : Rp $dendaKerusakan'),
              Text(
                'Total Denda : Rp $totalDenda',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E2A47),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      kembalikanAlat(); // 🔥 inti kabeh
                    }
                  },
                  child: const Text('Simpan Pengembalian'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  InputDecoration _input() =>
      const InputDecoration(border: OutlineInputBorder());
}
