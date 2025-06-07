import 'package:project_tpm_teori/models/user_model.dart';
import 'package:project_tpm_teori/networks/base_network.dart';

abstract class DetailUserView {
  void showLoading();
  void hideLoading();
  void showDetailData(User detail);
  void showError(String msg);
}

class DetailUserPresenter {
  final DetailUserView view;
  DetailUserPresenter(this.view);

  Future<void> loadDetailUser(String endpoint, String email) async {
    view.showLoading();
    try {
      final Map<String, dynamic> data =
          await BaseNetwork.getDataByEmail(endpoint, email);
      final userdetail = User.fromJson(data);
      view.showDetailData(userdetail);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}
