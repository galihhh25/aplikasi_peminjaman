import 'package:flutter/material.dart';
import 'package:projek_ukk/role_admin/daftar_petugas_page.dart';
import 'profile_admin_page.dart';
import 'dasboard_admin_page.dart';
import 'alat_admin_page.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const AlatAdminPage();
        break;
      case 2:
        page = const DaftarPetugasPage();
        break;
      case 3:
        page = const ProfileAdminPage();
        break;
      default:
        page = const DashboardPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF0B2540),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: 'Alat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.badge),
          label: 'Petugas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
