import 'package:flutter/material.dart';
import 'package:project_tpm_teori/views/admin.dart';
import 'package:project_tpm_teori/views/admin_profile.dart';
import 'package:project_tpm_teori/views/kesan.dart';

class MainAdminPage extends StatefulWidget {
  const MainAdminPage({super.key});

  @override
  State<MainAdminPage> createState() => _MainAdminPageState();
}

class _MainAdminPageState extends State<MainAdminPage> {
  int selectedIndex = 1;

  final List<Widget> _pages = [
    const KesanPesanPage(),
    const AdminPage(),
    const AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final Color goldYellow = const Color(0xfff7c846);
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: goldYellow,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.comment), label: 'Kesan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Controller'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
