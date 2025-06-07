import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_tpm_teori/models/pengunjung_model.dart';
import 'package:project_tpm_teori/models/profile_photo.dart';
import 'package:project_tpm_teori/models/user_model.dart';
import 'package:project_tpm_teori/presenters/detailpengunjung_presenter.dart';
import 'package:project_tpm_teori/presenters/detailuser_presenter.dart';
import 'package:project_tpm_teori/presenters/logout_presenter.dart';
import 'package:project_tpm_teori/presenters/user_presenter.dart';
import 'package:project_tpm_teori/utils/encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    implements DetailUserView, UserView, DetailPengunjungView, LogoutView {
  late DetailUserPresenter _detailUserPresenter;
  late UserPresenter _userPresenter;
  late DetailPengunjungPresenter _detailPengunjungPresenter;
  late LogoutPresenter _logoutPresenter;
  bool _isLoading = false;
  String? _errorMsg;
  User? _detailUser;
  List<Pengunjung> _pengunjungList = [];
  String? localPhotoPath;

  @override
  void initState() {
    super.initState();
    _detailUserPresenter = DetailUserPresenter(this);
    _userPresenter = UserPresenter(this);
    _detailPengunjungPresenter = DetailPengunjungPresenter(this);
    _logoutPresenter = LogoutPresenter(this);
    fetchUserDetail();
    fetchUserTiket();
    loadLocalPhoto();
  }

  Future<void> savePhoto(String email, String photoPath) async {
    final box = Hive.box<ProfilePhoto>('profile_photos');
    final encryptedPath = EncryptionHelper.encryptText(photoPath);
    final profilePhoto = ProfilePhoto(email: email, photoPath: encryptedPath);
    await box.put(email, profilePhoto);
  }

  Future<void> deletePhoto(String email) async {
    final box = Hive.box<ProfilePhoto>('profile_photos');
    await box.delete(email);
    setState(() {
      localPhotoPath = null;
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

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showError(String msg) {
    _errorMsg = msg;
  }

  @override
  void showLoading() {
    _isLoading = true;
  }

  @override
  void showDetailData(User detail) {
    setState(() {
      _detailUser = detail;
    });
  }

  @override
  void showDataPengunjungByEmail(List<Pengunjung> pengunjungList) {
    setState(() {
      _pengunjungList = pengunjungList;
    });
  }

  @override
  void onLogoutSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void fetchUserDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null) {
      _detailUserPresenter.loadDetailUser('users', email);
    }
  }

  void fetchUserTiket() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null) {
      _detailPengunjungPresenter.loadDetailPengunjung('pengunjung', email);
    }
  }

  void logoutHandler() async {
    await _logoutPresenter.LogoutUser('logout');
  }

  @override
  void showUserList(List<User> userList) {}

  Future<void> openCamera() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && email != null) {
      await savePhoto(email, pickedFile.path);
      await loadLocalPhoto();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: const Text("Foto Berhasil Ditambahkan !"),
        ),
      );
    }
  }

  Future<void> showCameraOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text("Ambil Foto",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await openCamera();
              },
            ),
            if (localPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.white),
                title: const Text("Hapus Foto",
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  if (email != null) {
                    await deletePhoto(email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: const Text("Foto Berhasil Dihapus !"),
                      ),
                    );
                  }
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellowAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () {
                logoutHandler();
              },
            ),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.yellowAccent))
          : _errorMsg != null
              ? Center(
                  child: Text("Error: $_errorMsg",
                      style: const TextStyle(color: Colors.redAccent)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 120,
                              backgroundColor: Colors.grey,
                              backgroundImage: localPhotoPath != null
                                  ? FileImage(File(localPhotoPath!))
                                  : null,
                              child: localPhotoPath == null
                                  ? const Icon(Icons.person,
                                      size: 90, color: Colors.black)
                                  : null,
                            ),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: InkWell(
                                onTap: showCameraOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _detailUser?.nama ?? '',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _detailUser?.email ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Tiket yang kamu miliki:",
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _pengunjungList.isEmpty
                          ? const Text(
                              "Belum ada tiket",
                              style: TextStyle(color: Colors.white70),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _pengunjungList.length,
                              itemBuilder: (context, index) {
                                final tiket = _pengunjungList[index].tiket;
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  color: Colors.grey[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.confirmation_num,
                                            color: Colors.white70),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            tiket,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }
}
