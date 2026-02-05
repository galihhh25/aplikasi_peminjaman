import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/features/login_page.dart';
import '/role_admin/dasboard_admin_page.dart';
import '/role_petugas/dasboard_petugas_page.dart';
import '/role_peminjam/dasboard_peminjam_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;

  String? role;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();

    supabase.auth.onAuthStateChange.listen((_) {
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        role = null;
        loading = false;
      });
      return;
    }

    try {
      // ================= ADMIN =================
      final admin = await supabase
          .from('users')
          .select('role')
          .eq('userid', user.id)
          .maybeSingle();

      if (admin != null &&
          admin['role'] != null &&
          admin['role'].toString().toLowerCase() == 'admin') {
        setState(() {
          role = 'admin';
          loading = false;
        });
        return;
      }

      // ================= PETUGAS =================
      final petugas = await supabase
          .from('petugas')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (petugas != null) {
        setState(() {
          role = 'petugas';
          loading = false;
        });
        return;
      }

      // ================= PEMINJAM =================
      setState(() {
        role = 'peminjam';
        loading = false;
      });
    } catch (e) {
      debugPrint('AUTH ERROR: $e');
      setState(() {
        role = null;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (supabase.auth.currentUser == null) {
      return const LoginPage();
    }

    if (role == 'admin') {
      return const DashboardPage();
    }

    if (role == 'petugas') {
      return const DashboardPetugasPage();
    }

    return const DashboardPeminjamPage();
  }
}
