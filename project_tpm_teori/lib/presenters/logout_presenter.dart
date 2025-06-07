import 'package:project_tpm_teori/networks/base_network.dart';

abstract class LogoutView {
  void showLoading();
  void hideLoading();
  void onLogoutSuccess();
  void showError(String msg);
}

class LogoutPresenter {
  final LogoutView view;
  LogoutPresenter(this.view);

  Future<void> LogoutUser(String endpoint) async {
    view.showLoading();
    try {
      await BaseNetwork.logoutUser(endpoint);
      view.onLogoutSuccess();
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}
