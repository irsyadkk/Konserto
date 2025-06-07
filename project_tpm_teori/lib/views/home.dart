import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project_tpm_teori/models/konser_model.dart';
import 'package:project_tpm_teori/models/profile_photo.dart';
import 'package:project_tpm_teori/presenters/konser_presenter.dart';
import 'package:project_tpm_teori/utils/encryption.dart';
import 'package:project_tpm_teori/views/detail.dart';
import 'package:project_tpm_teori/views/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements KonserView {
  late KonserPresenter _presenter;
  bool _isloading = true;
  List<Konser> _konserList = [];
  List<Konser> _filteredKonserList = [];
  String? _errorMsg;
  String? userName;
  String? localPhotoPath;

  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _presenter = KonserPresenter(this);
    _searchController.addListener(_onSearchChanged);
    getUserName();
    fetchData();
    loadLocalPhoto();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredKonserList = _konserList
          .where((konser) => konser.nama.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void showKonserList(List<Konser> konserList) {
    setState(() {
      _konserList = konserList;
      _filteredKonserList = konserList;
    });
  }

  Future<void> loadLocalPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null) {
      final box = Hive.box<ProfilePhoto>('profile_photos');
      final photo = box.get(email);
      final decryptedPath =
          photo != null ? EncryptionHelper.decryptText(photo.photoPath) : null;
      setState(() {
        localPhotoPath = decryptedPath;
      });
    }
  }

  void fetchData() {
    _presenter.loadKonserData('konser');
  }

  Future<void> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String? nama = prefs.getString('user_nama');
    setState(() {
      userName = nama;
    });
  }

  @override
  void hideLoading() => setState(() => _isloading = false);
  @override
  void showError(String msg) => setState(() => _errorMsg = msg);
  @override
  void showLoading() => setState(() => _isloading = true);
  @override
  void onAddFail() {}

  @override
  void onAddSuccess() {}

  @override
  void onEditFail() {}

  @override
  void onEditSuccess() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellowAccent,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                cursorColor: Colors.yellowAccent,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Cari Konser...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : Text('Halo, $userName !'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredKonserList = _konserList;
                });
              },
            )
          else
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
                loadLocalPhoto();
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: localPhotoPath != null
                    ? FileImage(File(localPhotoPath!))
                    : null,
                child: localPhotoPath == null
                    ? const Icon(Icons.person, size: 30, color: Colors.black)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isloading
            ? Center(
                child: CircularProgressIndicator(color: Colors.yellowAccent))
            : _errorMsg != null
                ? Center(
                    child: Text(
                      "Error: $_errorMsg",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredKonserList.length,
                    itemBuilder: (context, index) {
                      final konser = _filteredKonserList[index];
                      return _concertCard(konser);
                    },
                  ),
      ),
    );
  }

  Widget _concertCard(Konser konser) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(id: konser.id)),
          );
          if (result == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: const Text("Pembelian tiket berhasil !"),
              ),
            );
          } else if (result == 'fail') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: const Text("Pembelian tiket gagal !"),
              ),
            );
          }
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                konser.poster,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey[800],
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image,
                            size: 60, color: Colors.white70),
                        SizedBox(height: 8),
                        Text(
                          'Gambar tidak tersedia',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    konser.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${konser.lokasi}, ${konser.tanggal}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
