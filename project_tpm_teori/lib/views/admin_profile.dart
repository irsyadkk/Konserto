import 'package:flutter/material.dart';
import 'package:project_tpm_teori/presenters/logout_presenter.dart';
import 'package:project_tpm_teori/views/login.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage>
    implements LogoutView {
  late LogoutPresenter _logoutPresenter;

  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _logoutPresenter = LogoutPresenter(this);
  }

  @override
  void hideLoading() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onLogoutSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void showError(String msg) {
    if (!mounted) return;
    setState(() {
      _errorMsg = msg;
    });
  }

  @override
  void showLoading() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
  }

  void logoutHandler() async {
    await _logoutPresenter.LogoutUser('logout');
  }

  @override
  Widget build(BuildContext context) {
    final Color goldYellow = const Color(0xfff7c846);
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Admin Profile"),
          automaticallyImplyLeading: false,
          foregroundColor: goldYellow,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () {
                logoutHandler();
              },
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.yellowAccent))
            : _errorMsg != null
                ? Center(
                    child: Text("Error: $_errorMsg",
                        style: const TextStyle(color: Colors.redAccent)),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(24.0),
                    child: Column(children: [
                      const SizedBox(height: 50),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 120,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  AssetImage("assets/images/profile.jpeg"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Irsyad Khairullah",
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "123220176",
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Card(
                        shadowColor: goldYellow,
                        elevation: 5,
                        margin: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Kelas : ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'TPM IF- D',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Umur : ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '20 Tahun',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Email : ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'i****************@gmail.com',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'No. Hp : ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '********75',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ])));
  }
}
