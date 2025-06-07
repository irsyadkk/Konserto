import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart' as loc;
import 'package:project_tpm_teori/models/konser_model.dart';
import 'package:project_tpm_teori/models/pengunjung_model.dart';
import 'package:project_tpm_teori/models/profile_photo.dart';
import 'package:project_tpm_teori/models/tiket_model.dart';
import 'package:project_tpm_teori/models/user_model.dart';
import 'package:project_tpm_teori/presenters/konser_presenter.dart';
import 'package:project_tpm_teori/presenters/pengunjung_presenter.dart';
import 'package:project_tpm_teori/presenters/tiket_presenter.dart';
import 'package:project_tpm_teori/presenters/user_presenter.dart';
import 'package:project_tpm_teori/utils/encryption.dart';
import 'package:project_tpm_teori/views/pickloc.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

enum AdminMenu { konser, tiket, pengunjung, user }

class _AdminPageState extends State<AdminPage>
    implements PengunjungView, KonserView, UserView, TiketView {
  late Box box;
  late PengunjungPresenter _presenterPengunjung;
  late KonserPresenter _presenterKonser;
  late UserPresenter _presenterUser;
  late TiketPresenter _presenterTiket;

  int selectedIndex = 2;
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errormsg;
  DateTime? _selectedDate;
  LatLng? _pickedLatLng;
  loc.Location _location = loc.Location();
  loc.LocationData? _currentPos;
  StreamSubscription<loc.LocationData>? _locationsub;

  List<Pengunjung> _pengunjungList = [];
  List<Konser> _konserList = [];
  List<User> _userList = [];
  List<Tiket> _tiketList = [];
  List<Konser> _filteredKonserList = [];
  List<User> _filteredUserList = [];
  List<Tiket> _filteredTiketList = [];
  final _namaController = TextEditingController();
  final _posterController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _jamController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _bintangtamuController = TextEditingController();
  final _hargaController = TextEditingController();
  final _quotaController = TextEditingController();
  final _konserSearchController = TextEditingController();
  final _userSearchController = TextEditingController();
  final _tiketSearchController = TextEditingController();

  AdminMenu _selectedMenu = AdminMenu.konser;

  TextEditingController? getCurrentSearchController() {
    switch (_selectedMenu) {
      case AdminMenu.konser:
        return _konserSearchController;
      case AdminMenu.user:
        return _userSearchController;
      case AdminMenu.tiket:
        return _tiketSearchController;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    box = Hive.box<ProfilePhoto>('profile_photos');
    _presenterPengunjung = PengunjungPresenter(this);
    _presenterKonser = KonserPresenter(this);
    _presenterUser = UserPresenter(this);
    _presenterTiket = TiketPresenter(this);
    _konserSearchController.addListener(_onSearchKonserChanged);
    _userSearchController.addListener(_onSearchUserChanged);
    _tiketSearchController.addListener(_onSearchTiketChanged);
    fetchKonser();
  }

  void onItemTapped(int index) {
    if (!mounted) return;
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _konserSearchController.dispose();
    _userSearchController.dispose();
    _tiketSearchController.dispose();
    _locationsub?.cancel();
    super.dispose();
  }

  Future<bool> getLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    loc.PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return false;
    }

    final locationData = await _location.getLocation();
    setState(() {
      _currentPos = locationData;
    });
    return true;
  }

  void _onSearchKonserChanged() {
    if (!mounted) return;
    final query = _konserSearchController.text.toLowerCase();
    setState(() {
      _filteredKonserList = _konserList
          .where((konser) => konser.nama.toLowerCase().contains(query))
          .toList();
    });
  }

  void _onSearchUserChanged() {
    if (!mounted) return;
    final query = _userSearchController.text.toLowerCase();
    setState(() {
      _filteredUserList = _userList.where((user) {
        return user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onSearchTiketChanged() {
    if (!mounted) return;
    final query = _tiketSearchController.text.toLowerCase();
    setState(() {
      _filteredTiketList = _tiketList.where((tiket) {
        return tiket.nama.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void hideLoading() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showError(String msg) {
    if (!mounted) return;
    setState(() {
      _errormsg = msg;
    });
  }

  @override
  void showPengunjungList(List<Pengunjung> pengunjungList) {
    if (!mounted) return;
    setState(() {
      _pengunjungList = pengunjungList;
    });
  }

  @override
  void showKonserList(List<Konser> konserList) {
    _konserList = konserList;
    _filteredKonserList = konserList;
  }

  @override
  void showUserList(List<User> userList) {
    _userList = userList;
    _filteredUserList = userList;
  }

  @override
  void showTiketList(List<Tiket> tiketList) {
    _tiketList = tiketList;
    _filteredTiketList = tiketList;
  }

  @override
  void showLoading() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errormsg = null;
    });
  }

  void fetchPengunjung() {
    _selectedMenu = AdminMenu.pengunjung;
    _presenterPengunjung.loadPengunjungData('pengunjung');
  }

  void fetchKonser() {
    _selectedMenu = AdminMenu.konser;
    _presenterKonser.loadKonserData('konser');
  }

  void fetchUser() {
    _selectedMenu = AdminMenu.user;
    _presenterUser.loadUserData('users');
  }

  void fetchTiket() {
    _selectedMenu = AdminMenu.tiket;
    _presenterTiket.loadTiketData('tiket');
  }

  void addKonserHandler() {
    _namaController.clear();
    _posterController.clear();
    _tanggalController.clear();
    _jamController.clear();
    _lokasiController.clear();
    _bintangtamuController.clear();
    _hargaController.clear();
    _quotaController.clear();
    _currentPos = null;
    _pickedLatLng = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Tambah Konser',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(labelText: 'Nama'),
                  style: TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: _posterController,
                  decoration: InputDecoration(labelText: 'Poster URL'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.url,
                ),
                TextField(
                  controller: _tanggalController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Tanggal'),
                  style: TextStyle(color: Colors.white),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _selectedDate = picked;
                      _tanggalController.text =
                          "${picked.toLocal()}".split(' ')[0];
                    }
                  },
                ),
                TextField(
                  controller: _jamController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Jam (WIB)'),
                  style: TextStyle(color: Colors.white),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      _jamController.text =
                          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                TextField(
                  controller: _lokasiController,
                  decoration: InputDecoration(labelText: 'Lokasi'),
                  style: TextStyle(color: Colors.white),
                  enabled: false,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentPos == null) {
                      bool locationReady = await getLocation();

                      if (!locationReady || _currentPos == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Mohon Nyalakan Lokasi dan Izinkan Aplikasi !",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                    LatLng initialLatLng;
                    if (_pickedLatLng != null) {
                      initialLatLng = _pickedLatLng!;
                    } else {
                      initialLatLng = LatLng(
                        _currentPos!.latitude!,
                        _currentPos!.longitude!,
                      );
                    }

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PickLocationPage(initLatLng: initialLatLng),
                      ),
                    );

                    if (result != null && result is Map) {
                      LatLng selectedLatLng = result['latlng'];
                      String address = result['address'];

                      setState(() {
                        _pickedLatLng = selectedLatLng;
                        _lokasiController.text = address;
                      });
                    }
                  },
                  child: Text("Pilih Lokasi di Map"),
                ),
                TextField(
                  controller: _bintangtamuController,
                  decoration: InputDecoration(labelText: 'Bintang Tamu'),
                  style: TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: _hargaController,
                  decoration: InputDecoration(labelText: 'Harga (IDR)'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _quotaController,
                  decoration: InputDecoration(labelText: 'Quota'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_namaController.text.isEmpty ||
                    _tanggalController.text.isEmpty ||
                    _lokasiController.text.isEmpty ||
                    _jamController.text.isEmpty ||
                    _posterController.text.isEmpty ||
                    _bintangtamuController.text.isEmpty ||
                    _hargaController.text.isEmpty ||
                    _quotaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Mohon Isi Semua Field !',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (int.tryParse(_hargaController.text) == null ||
                    int.tryParse(_quotaController.text) == null ||
                    int.tryParse(_hargaController.text)! < 0 ||
                    int.tryParse(_quotaController.text)! < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Mohon isi harga & quota dengan nilai yang valid !',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  await postKonser();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Konser & Tiket Berhasil Ditambahkan !',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  fetchKonser();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> postKonser() async {
    final nama = _namaController.text.trim();
    final tanggal = _tanggalController.text.trim();
    final lokasi = _lokasiController.text.trim();
    final jam = _jamController.text.trim();
    final poster = _posterController.text.trim();
    final bintangtamu = _bintangtamuController.text.trim();
    final harga = _hargaController.text.trim();
    final quota = _quotaController.text.trim();
    final data = {
      'nama': nama,
      'poster': poster,
      'tanggal': tanggal,
      'jam': jam,
      'lokasi': lokasi,
      'latitude': _pickedLatLng?.latitude.toString(),
      'longitude': _pickedLatLng?.longitude.toString(),
      'bintangtamu': bintangtamu,
      'harga': harga,
      'quota': quota
    };
    await _presenterKonser.addKonserData('konser', data);
  }

  void editKonserHandler(Konser konser) {
    _namaController.text = konser.nama;
    _tanggalController.text = konser.tanggal;
    _jamController.text = konser.jam.substring(0, 5);
    _lokasiController.text = konser.lokasi;
    _posterController.text = konser.poster;
    _bintangtamuController.text = konser.bintangtamu;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Edit Konser',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(labelText: 'Nama'),
                  style: TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: _posterController,
                  decoration: InputDecoration(labelText: 'Poster URL'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.url,
                ),
                TextField(
                  controller: _tanggalController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Tanggal'),
                  style: TextStyle(color: Colors.white),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _selectedDate = picked;
                      _tanggalController.text =
                          "${picked.toLocal()}".split(' ')[0];
                    }
                  },
                ),
                TextField(
                  controller: _jamController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Jam (WIB)'),
                  style: TextStyle(color: Colors.white),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      _jamController.text =
                          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                TextField(
                  controller: _lokasiController,
                  decoration: InputDecoration(labelText: 'Lokasi'),
                  style: TextStyle(color: Colors.white),
                  enabled: false,
                ),
                ElevatedButton(
                  onPressed: () async {
                    LatLng initLatLng =
                        LatLng(konser.latitude, konser.longitude);

                    if (_pickedLatLng != null) {
                      initLatLng = _pickedLatLng!;
                    }

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PickLocationPage(initLatLng: initLatLng),
                      ),
                    );

                    if (result != null && result is Map) {
                      LatLng selectedLatLng = result['latlng'];
                      String address = result['address'];

                      setState(() {
                        _pickedLatLng = selectedLatLng;
                        _lokasiController.text = address;
                      });
                    }
                  },
                  child: Text("Pilih Lokasi di Map"),
                ),
                TextField(
                  controller: _bintangtamuController,
                  decoration: InputDecoration(labelText: 'Bintang Tamu'),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await deleteKonserHandler(konser.id);
                      Navigator.pop(context);
                      fetchKonser();
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(
                      "Hapus",
                      style: TextStyle(color: Colors.white),
                    )),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text('Batal', style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_namaController.text.isEmpty ||
                        _tanggalController.text.isEmpty ||
                        _lokasiController.text.isEmpty ||
                        _jamController.text.isEmpty ||
                        _posterController.text.isEmpty ||
                        _bintangtamuController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Mohon Isi Semua Field !',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } else {
                      await updateKonser(konser.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Konser Berhasil Diedit !',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      fetchKonser();
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> updateKonser(int id) async {
    final nama = _namaController.text.trim();
    final tanggal = _tanggalController.text.trim();
    final jam = _jamController.text.trim();
    final lokasi = _lokasiController.text.trim();
    final poster = _posterController.text.trim();
    final bintangtamu = _bintangtamuController.text.trim();

    if (nama.isNotEmpty &&
        tanggal.isNotEmpty &&
        jam.isNotEmpty &&
        lokasi.isNotEmpty &&
        poster.isNotEmpty &&
        bintangtamu.isNotEmpty) {
      final data = {
        'nama': nama,
        'poster': poster,
        'tanggal': tanggal,
        'jam': jam,
        'lokasi': lokasi,
        'latitude': _pickedLatLng?.latitude.toString(),
        'longitude': _pickedLatLng?.longitude.toString(),
        'bintangtamu': bintangtamu
      };
      await _presenterKonser.editKonserData('konser', data, id);
    }
  }

  Future<void> deleteKonserHandler(int id) async {
    await _presenterKonser.deleteKonserData('konser', id);
  }

  void editTiketHandler(Tiket tiket) {
    _hargaController.text = tiket.harga.toString();
    _quotaController.text = tiket.quota.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Edit Tiket',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _hargaController,
                  decoration: InputDecoration(labelText: 'Harga (IDR)'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _quotaController,
                  decoration: InputDecoration(labelText: 'Quota'),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_quotaController.text.isEmpty ||
                    _hargaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Mohon Isi Semua Field !',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (int.tryParse(_hargaController.text) == null ||
                    int.tryParse(_quotaController.text) == null ||
                    int.tryParse(_hargaController.text)! < 0 ||
                    int.tryParse(_quotaController.text)! < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Mohon isi harga & quota dengan nilai yang valid !',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  await updateTiket(tiket.id);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tiket Berhasil Diedit !',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  fetchTiket();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateTiket(int id) async {
    final harga = _hargaController.text.trim();
    final quota = _quotaController.text.trim();
    if (harga.isNotEmpty && quota.isNotEmpty) {
      final data = {'harga': harga, 'quota': quota};
      await _presenterTiket.editTiketData('tiket', data, id);
    }
  }

  Widget _buildDrawer() {
    final Color goldYellow = const Color(0xfff7c846);
    return Drawer(
      child: Container(
        color: Colors.black87,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: goldYellow, fontSize: 25),
              ),
            ),
            ListTile(
              title:
                  const Text('Konser', style: TextStyle(color: Colors.white)),
              selected: _selectedMenu == AdminMenu.konser,
              onTap: () {
                Navigator.pop(context);
                fetchKonser();
                setState(() {
                  _selectedMenu = AdminMenu.konser;
                  _errormsg = null;
                });
              },
            ),
            ListTile(
              title: const Text('Tiket', style: TextStyle(color: Colors.white)),
              selected: _selectedMenu == AdminMenu.tiket,
              onTap: () {
                Navigator.pop(context);
                fetchTiket();
                setState(() {
                  _selectedMenu = AdminMenu.tiket;
                  _errormsg = null;
                });
              },
            ),
            ListTile(
              title: const Text('Pengunjung',
                  style: TextStyle(color: Colors.white)),
              selected: _selectedMenu == AdminMenu.pengunjung,
              onTap: () {
                Navigator.pop(context);
                fetchPengunjung();
              },
            ),
            ListTile(
              title: const Text('User', style: TextStyle(color: Colors.white)),
              selected: _selectedMenu == AdminMenu.user,
              onTap: () {
                Navigator.pop(context);
                fetchUser();
                setState(() {
                  _selectedMenu = AdminMenu.user;
                  _errormsg = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    final Color goldYellow = const Color(0xfff7c846);

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.yellowAccent));
    }
    if (_errormsg != null) {
      return Center(
          child: Text("Error: $_errormsg",
              style: const TextStyle(color: Colors.red)));
    }

    switch (_selectedMenu) {
      case AdminMenu.pengunjung:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data Pengunjung:',
                  style: TextStyle(
                      color: goldYellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_pengunjungList.isEmpty)
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.group_off, size: 64, color: Colors.white54),
                      SizedBox(height: 12),
                      Text(
                        "Belum ada pengunjung !",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pengunjungList.length,
                  itemBuilder: (context, index) {
                    final pengunjung = _pengunjungList[index];
                    return Card(
                      color: Colors.white10,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(pengunjung.nama,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(pengunjung.tiket,
                            style: const TextStyle(color: Colors.white70)),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      case AdminMenu.konser:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  addKonserHandler();
                },
                icon: const Icon(Icons.add, color: Colors.white),
              ),
              Text(
                'Data Konser:',
                style: TextStyle(
                  color: goldYellow,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_filteredKonserList.isEmpty)
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.event_busy, size: 64, color: Colors.white54),
                      SizedBox(height: 12),
                      Text(
                        "Belum ada konser yang tersedia !",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredKonserList.length,
                  itemBuilder: (context, index) {
                    final konser = _filteredKonserList[index];
                    return Card(
                      color: Colors.white10,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Image.network(
                          konser.poster,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                        ),
                        title: Text(
                          konser.nama,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${konser.lokasi}, ${konser.tanggal}, ${konser.jam.substring(0, 5)} WIB",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Colors.redAccent),
                          onPressed: () {
                            editKonserHandler(konser);
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );

      case AdminMenu.user:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data User:',
                  style: TextStyle(
                      color: goldYellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_filteredUserList.isEmpty)
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.person_off, size: 64, color: Colors.white54),
                      SizedBox(height: 12),
                      Text(
                        "Belum ada user !",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredUserList.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUserList[index];
                    final profilePhoto = box.get(user.email);
                    final encryptedPath = profilePhoto?.photoPath;
                    final decryptedPath =
                        (encryptedPath != null && encryptedPath.isNotEmpty)
                            ? EncryptionHelper.decryptText(encryptedPath)
                            : null;
                    return Card(
                      color: Colors.white10,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: (decryptedPath != null &&
                                decryptedPath.isNotEmpty)
                            ? CircleAvatar(
                                backgroundImage: FileImage(File(decryptedPath)),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                        title: Text(user.email),
                        subtitle: Text("${user.nama}, ${user.umur} Tahun",
                            style: const TextStyle(color: Colors.white70)),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      case AdminMenu.tiket:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Data Tiket:',
                  style: TextStyle(
                      color: goldYellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_filteredTiketList.isEmpty)
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.event_busy, size: 64, color: Colors.white54),
                      SizedBox(height: 12),
                      Text(
                        "Belum ada tiket yang tersedia !",
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredTiketList.length,
                  itemBuilder: (context, index) {
                    final tiket = _filteredTiketList[index];
                    return Card(
                      color: Colors.white10,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(tiket.nama),
                        subtitle: Text(
                            "Quota: ${tiket.quota}, Rp ${tiket.harga}/Tiket",
                            style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: Colors.redAccent),
                          onPressed: () {
                            editTiketHandler(tiket);
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color goldYellow = const Color(0xfff7c846);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: _isSearching && getCurrentSearchController() != null
            ? TextField(
                controller: getCurrentSearchController(),
                autofocus: true,
                cursorColor: goldYellow,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _selectedMenu == AdminMenu.konser ||
                          _selectedMenu == AdminMenu.tiket
                      ? 'Cari Konser...'
                      : 'Cari Email...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : Text('Admin'),
        backgroundColor: Colors.black,
        foregroundColor: goldYellow,
        actions: [
          if (getCurrentSearchController() != null)
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    getCurrentSearchController()!.clear();
                    if (_selectedMenu == AdminMenu.konser) {
                      _filteredKonserList = _konserList;
                    } else if (_selectedMenu == AdminMenu.user) {
                      _filteredUserList = _userList;
                    } else if (_selectedMenu == AdminMenu.tiket) {
                      _filteredTiketList = _tiketList;
                    }
                  });
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBodyContent(),
    );
  }
}
