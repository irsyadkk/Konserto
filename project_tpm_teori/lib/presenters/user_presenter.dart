import 'package:project_tpm_teori/models/user_model.dart';
import 'package:project_tpm_teori/networks/base_network.dart';

abstract class UserView {
  void showLoading();
  void hideLoading();
  void showUserList(List<User> userList);
  void showError(String msg);
}

class UserPresenter {
  final UserView view;
  UserPresenter(this.view);

  Future<void> loadUserData(String endpoint) async {
    view.showLoading();
    try {
      final List<dynamic> data = await BaseNetwork.getData(endpoint);
      final userList = data.map((json) => User.fromJson(json)).toList();
      view.showUserList(userList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}
