import 'package:project_tpm_teori/networks/base_network.dart';

abstract class OrderView {
  void onOrderSuccess();
  void onOrderFail();
  void showLoading();
  void hideLoading();
  void showError(String msg);
}

class OrderPresenter {
  final OrderView view;
  OrderPresenter(this.view);

  Future<void> orderTiket(
      String endpoint, Map<String, dynamic> data, int id) async {
    view.showLoading();
    try {
      await BaseNetwork.order(endpoint, data, id);
      view.onOrderSuccess();
    } catch (e) {
      view.onOrderFail();
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}
