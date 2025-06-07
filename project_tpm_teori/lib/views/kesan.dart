import 'package:flutter/material.dart';

class KesanPesanPage extends StatefulWidget {
  const KesanPesanPage({super.key});

  @override
  State<KesanPesanPage> createState() => _KesanPesanPageState();
}

class _KesanPesanPageState extends State<KesanPesanPage> {
  @override
  Widget build(BuildContext context) {
    final Color goldYellow = const Color(0xfff7c846);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Kesan & Pesan"),
        automaticallyImplyLeading: false,
        foregroundColor: goldYellow,
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Card(
          shadowColor: goldYellow,
          elevation: 5,
          margin: EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kesan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Divider(
                  thickness: 1,
                ),
                Text(
                  'Wow. TPM keren sekali. saya sangat suka TPM, karena TPM membuat tidur saya tidak nyenyak selama 2 minggu.',
                  style: TextStyle(fontSize: 15),
                ),
                Divider(
                  thickness: 4,
                ),
                Text(
                  'Saran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Divider(
                  thickness: 1,
                ),
                Text(
                  'Gaada.',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
