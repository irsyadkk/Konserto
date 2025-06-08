import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:project_tpm_teori/presenters/order_presenter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayMentPage extends StatefulWidget {
  final int id;
  final String nama;
  const PayMentPage({super.key, required this.id, required this.nama});

  @override
  State<PayMentPage> createState() => _PayMentPageState();
}

class _PayMentPageState extends State<PayMentPage> implements OrderView {
  OrderPresenter? _orderPresenter;
  final _emailController = TextEditingController();
  final _namaController = TextEditingController();
  final _umurController = TextEditingController();
  String nfcData = "";
  bool _isLoading = false;
  bool _nfcSessionStarted = false;
  String? _errorMsg;
  Timer? _nfcStatusTimer;
  bool _lastNfcStatus = false;

  @override
  void initState() {
    super.initState();
    _orderPresenter = OrderPresenter(this);
    getUserData();
    startNfcStatusMonitoring();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaController.text = prefs.getString('user_nama') ?? '';
      _umurController.text = prefs.getInt('user_umur')?.toString() ?? '';
      _emailController.text = prefs.getString('user_email') ?? '';
    });
  }

  void startNfcStatusMonitoring() {
    _nfcStatusTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      bool currentStatus = await NfcManager.instance.isAvailable();
      if (!currentStatus) {
        setState(() {
          nfcData = "Mohon Aktifkan NFC Untuk Melakukan Pembayaran !";
        });
      }
      if (currentStatus != _lastNfcStatus) {
        setState(() {
          _lastNfcStatus = currentStatus;
          nfcData = currentStatus
              ? "Tap Kartu Untuk Melakukan Pembayaran !"
              : "Mohon Aktifkan NFC Untuk Melakukan Pembayaran !";
        });
        if (currentStatus) {
          orderHandler();
        }
      }
    });
  }

  @override
  void dispose() {
    _nfcStatusTimer?.cancel();
    super.dispose();
  }

  void orderHandler() async {
    if (_nfcSessionStarted) return;
    _nfcSessionStarted = true;
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      await NfcManager.instance.stopSession();

      Future.delayed(Duration.zero, () {
        if (mounted && _orderPresenter != null) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                title: Text(
                  'Yakin ingin membeli tiket ${widget.nama} ?',
                  style: TextStyle(color: Colors.white),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              _nfcSessionStarted = false;
                            },
                            child: Text('Batal',
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                order();
                                _nfcSessionStarted = false;
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: Text(
                                "Beli",
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      });
    });
  }

  void order() async {
    final data = {
      'nama': _namaController.text,
      'umur': _umurController.text,
      'email': _emailController.text,
    };
    await _orderPresenter?.orderTiket('order', data, widget.id);
    _nfcSessionStarted = false;
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void onOrderSuccess() {
    _nfcSessionStarted = false;
    Navigator.pop(context);
    Navigator.pop(context, 'payment_success');
  }

  @override
  void onOrderFail() {
    _nfcSessionStarted = false;
    Navigator.pop(context);
    Navigator.pop(context, 'payment_fail');
  }

  @override
  void showError(String msg) {
    setState(() {
      _errorMsg = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellowAccent,
        title: Text("Payment"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.yellowAccent))
          : _errorMsg != null
              ? Center(
                  child: Text("Error: $_errorMsg",
                      style: const TextStyle(color: Colors.redAccent)),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          nfcData,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
