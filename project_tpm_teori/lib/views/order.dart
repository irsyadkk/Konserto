import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_tpm_teori/models/pengunjung_model.dart';
import 'package:project_tpm_teori/models/tiket_model.dart';
import 'package:project_tpm_teori/presenters/detailpengunjung_presenter.dart';
import 'package:project_tpm_teori/presenters/detailtiket_presenter.dart';
import 'package:project_tpm_teori/views/payment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  final int id;
  final String endpoint;
  const OrderPage({super.key, required this.id, required this.endpoint});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    implements DetailTiketView, DetailPengunjungView {
  late DetailPengunjungPresenter _detailPengunjungPresenter;
  late DetailTiketPresenter _detailTiketPresenter;
  List<Pengunjung> _pengunjungList = [];
  bool _isLoading = false;
  Tiket? _detailData;
  String _selectedCur = 'IDR';
  String _selectedZone = 'WIB';
  String? _errorMsg = "";
  int? umur;

  final Map<String, double> _exchangeRates = {
    'IDR': 1.0,
    'USD': 0.000061,
    'EUR': 0.000054,
    'SGD': 0.000079,
    'JPY': 0.008787,
    'MYR': 0.00026,
  };
  final Map<String, int> _zonaList = {
    'WIB': 7,
    'WITA': 8,
    'WIT': 9,
    'LONDON': 0,
  };

  String convertJam(String jam) {
    //waktu lokal
    final time = DateFormat("HH:mm").parseUtc(jam);
    //ubah waktu ke utc
    final timeUtc = time.subtract(Duration(hours: 7));
    int targetZoneUtc = _zonaList[_selectedZone] ?? 7;
    //tambah berdasarkan utc
    final adjusted = timeUtc.add(Duration(hours: targetZoneUtc));
    return DateFormat('HH:mm').format(adjusted);
  }

  String convertHarga(int harga) {
    double rate = _exchangeRates[_selectedCur] ?? 1;
    double converted = harga * rate;
    return _selectedCur == 'IDR'
        ? 'IDR ${harga.toString()}'
        : '$_selectedCur ${converted.toStringAsFixed(2)}';
  }

  @override
  void initState() {
    super.initState();
    _detailTiketPresenter = DetailTiketPresenter(this);
    _detailPengunjungPresenter = DetailPengunjungPresenter(this);
    fetchdetail();
    fetchUserTiket();
    getUmur();
  }

  void getUmur() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      umur = int.tryParse(prefs.getInt('user_umur').toString()) ?? 0;
    });
  }

  void fetchdetail() {
    _detailTiketPresenter.loadDetailTiket(widget.endpoint, widget.id);
  }

  void fetchUserTiket() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null) {
      _detailPengunjungPresenter.loadDetailPengunjung('pengunjung', email);
    }
  }

  bool checkTicket(String namaTiket) {
    return _pengunjungList.any((pengunjung) => pengunjung.tiket == namaTiket);
  }

  @override
  void showDataPengunjungByEmail(List<Pengunjung> pengunjungList) {
    setState(() {
      _pengunjungList = pengunjungList;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showDetailData(Tiket detail) {
    setState(() {
      _detailData = detail;
    });
  }

  @override
  void showError(String msg) {
    setState(() {
      _errorMsg = msg;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  Widget buildInfoCard(String title, String value, {Color? color}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? const Color.fromARGB(255, 40, 40, 40),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 255, 196, 35),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCardHarga(String title, String value, {Color? color}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? const Color.fromARGB(255, 40, 40, 40),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 255, 196, 35),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 150),
                DropdownButton<String>(
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  value: _selectedCur,
                  items: _exchangeRates.keys.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCur = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCardJam(String title, String jam, {Color? color}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? const Color.fromARGB(255, 40, 40, 40),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 255, 196, 35),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  jam,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                DropdownButton<String>(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  dropdownColor: Colors.grey[900],
                  value: _selectedZone,
                  items: _zonaList.keys.map((String zona) {
                    return DropdownMenuItem<String>(
                      value: zona,
                      child: Text(zona),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedZone = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellowAccent,
        title: Text(
          'Order Tiket ${_detailData?.nama}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.yellowAccent))
          : _detailData != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildInfoCard("Tanggal", _detailData!.tanggal),
                      buildInfoCardJam("Jam", convertJam(_detailData!.jam)),
                      buildInfoCardHarga(
                          "Harga", convertHarga(_detailData!.harga)),
                      buildInfoCard("Quota", _detailData!.quota.toString()),
                      const SizedBox(height: 24),
                      _detailData!.quota <= 0
                          ? const Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "Maaf, kuota tiket habis !",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : umur! <= 16
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    "Maaf, umur kamu tidak mencukupi !",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : checkTicket(_detailData!.nama)
                                  ? const Padding(
                                      padding: EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        "Kamu sudah memesan tiket ini !",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PayMentPage(
                                                    id: widget.id,
                                                    nama: _detailData!.nama,
                                                  )),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 255, 196, 35),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 32, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Bayar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                    ],
                  ),
                )
              : Center(child: Text(_errorMsg!)),
    );
  }
}
