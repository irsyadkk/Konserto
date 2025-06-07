import 'package:flutter/material.dart';
import 'package:project_tpm_teori/views/home.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color yellowAccent = const Color(0xfff7c846);
    final Color redAccent = const Color(0xfffc574e);
    final Color greenAccent = const Color(0xff8ae98d);
    final Color blueAccent = const Color(0xff4e8afc);
    final Color purpleAccent = const Color(0xffa74efc);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: yellowAccent,
        title: const Text('Profil Pengguna'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage:
                  AssetImage('assets/images/user.jpg'), // Anggap aja ini gambar
            ),
            const SizedBox(height: 16),
            Text('Kucing',
                style: TextStyle(
                    color: yellowAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Kucing@example.com', style: TextStyle(color: Colors.white70)),
            Text('+62 812-3456-7890', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Text('Film yang Sudah Ditonton',
                style: TextStyle(
                    color: yellowAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _filmItem('Fast Furious', 'Action - Sci-Fi', redAccent),
            const SizedBox(height: 12),
            _filmItem('Sinetron', 'Drama - Indonesia', greenAccent),
            const SizedBox(height: 24),
            Text('List Tontonan Saya',
                style: TextStyle(
                    color: yellowAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _filmItem('Warkop DKI', 'Comedy - Lucu', blueAccent),
            const SizedBox(height: 12),
            _filmItem('Jumbo', 'Kartun - Animasi', purpleAccent),
          ],
        ),
      ),
    );
  }

  Widget _filmItem(String title, String genre, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16)),
              Text(genre, style: const TextStyle(color: Colors.black87)),
            ],
          ),
          const Icon(Icons.check_circle, color: Colors.black),
        ],
      ),
    );
  }
}
