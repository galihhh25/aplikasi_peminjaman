import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlatPetugasPage extends StatefulWidget {
  const AlatPetugasPage({super.key});

  static const Color primaryBlue = Color(0xFF0E2A47);

  @override
  State<AlatPetugasPage> createState() => _AlatPetugasPageState();
}

class _AlatPetugasPageState extends State<AlatPetugasPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> alatList = [];
  bool loading = true;

  String selectedKategori = 'Semua';

  final List<String> kategoriList = [
    'Semua',
    'Bola Besar',
    'Bola Kecil',
    'Tongkat',
    'Jaring Net',
    'Kun',
  ];

  @override
  void initState() {
    super.initState();
    fetchAlat();
  }

  Future<void> fetchAlat() async {
    final data =
        await supabase.from('alat').select().order('id', ascending: false);

    setState(() {
      alatList = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = alatList.where((alat) {
      final q = _searchController.text.toLowerCase();
      final nama = alat['nama_alat'].toString().toLowerCase();

      final cocokSearch = nama.contains(q);
      final cocokKategori = selectedKategori == 'Semua'
          ? true
          : alat['kategori'] == selectedKategori;

      return cocokSearch && cocokKategori;
    }).toList();

    return Container(
      color: AlatPetugasPage.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'Data Alat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Cari alat...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // FILTER KATEGORI
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kategoriList.length,
              itemBuilder: (context, index) {
                final kategori = kategoriList[index];
                final aktif = selectedKategori == kategori;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(kategori),
                    selected: aktif,
                    selectedColor: Colors.deepPurple,
                    backgroundColor: Colors.grey.shade300,
                    labelStyle: TextStyle(
                      color: aktif ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedKategori = kategori;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // LIST DATA
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Durung ono data alat',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return AlatCard(alat: filtered[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/* ================= CARD (VIEW ONLY) ================= */

class AlatCard extends StatelessWidget {
  final Map<String, dynamic> alat;

  const AlatCard({super.key, required this.alat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GAMBAR
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: alat['gambar'] != null
                ? Image.network(
                    alat['gambar'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image, size: 60),
                    ),
                  ),
          ),

          // ISI
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat['nama_alat'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                infoRow('Kategori', alat['kategori'] ?? '-'),
                infoRow('Kondisi', alat['kondisi'] ?? '-'),
                infoRow('Stok', alat['stok'].toString()),
                const SizedBox(height: 10),
                const Text(
                  'Spesifikasi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(alat['spesifikasi'] ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRow(String kiri, String kanan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(kiri)),
          Text(
            kanan,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
