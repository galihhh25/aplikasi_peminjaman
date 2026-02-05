import 'package:flutter/material.dart';

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

  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  DateTime? tanggalPengembalian;

  String kondisi = 'Baik';
  int hariTelat = 0;
  int dendaTelat = 0;
  int dendaKerusakan = 0;
  int totalDenda = 0;

  static const int dendaPerHari = 5000;

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
    _hitungDendaTelat();
    _hitungTotalDenda();
  }

  /// ================= KERUSAKAN =================
  void _hitungKondisi() {
    final dipilih =
        kerusakan.entries.where((e) => e.value).map((e) => e.key).toList();

    final adaBerat = dipilih.any((e) => kerusakanBerat.contains(e));
    final jumlahRingan =
        dipilih.where((e) => kerusakanRingan.contains(e)).length;

    if (dipilih.isEmpty) {
      kondisi = 'Baik';
    } else if (adaBerat || dipilih.length >= 3) {
      kondisi = 'Rusak Berat';
    } else if (jumlahRingan == 2) {
      kondisi = 'Rusak Sedang';
    } else {
      kondisi = 'Rusak Ringan';
    }

    _hitungDendaKerusakan();
    _hitungTotalDenda();
  }

  void _hitungDendaKerusakan() {
    switch (kondisi) {
      case 'Rusak Ringan':
        dendaKerusakan = 10000;
        break;
      case 'Rusak Sedang':
        dendaKerusakan = 25000;
        break;
      case 'Rusak Berat':
        dendaKerusakan = 50000;
        break;
      default:
        dendaKerusakan = 0;
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

  /// ================= DENDA TELAT =================
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

  void _hitungTotalDenda() {
    totalDenda = dendaTelat + dendaKerusakan;
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalPengembalian!,
      firstDate: widget.tanggalJatuhTempo,
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        tanggalPengembalian = picked;
        _hitungDendaTelat();
        _hitungTotalDenda();
      });
    }
  }

  /// ================= UI =================
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
                decoration: _inputDecoration(
                  hint: 'Jumlah otomatis',
                ),
              ),
              _label('Tanggal Pengembalian'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${tanggalPengembalian!.day}-${tanggalPengembalian!.month}-${tanggalPengembalian!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pilihTanggal(context),
              ),
              _label('Kondisi Otomatis'),
              Text(
                kondisi,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _warnaKondisi(),
                ),
              ),
              const SizedBox(height: 12),
              _label('Detail Kerusakan'),
              Column(
                children: kerusakan.keys.map((item) {
                  return CheckboxListTile(
                    title: Text(item),
                    value: kerusakan[item],
                    onChanged: (value) {
                      setState(() {
                        kerusakan[item] = value!;
                        _hitungKondisi();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              _label('Rincian Denda'),
              Text('Denda Telat : Rp $dendaTelat'),
              Text('Denda Kerusakan : Rp $dendaKerusakan'),
              const Divider(),
              Text(
                'Total Denda : Rp $totalDenda',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _label('Catatan'),
              TextFormField(
                controller: catatanController,
                maxLines: 3,
                decoration: _inputDecoration(hint: 'Opsional'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E2A47),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      debugPrint('Total Denda: $totalDenda');

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengembalian berhasil disimpan'),
                        ),
                      );
                      Navigator.pop(context);
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  InputDecoration _inputDecoration({String hint = ''}) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      );
}
