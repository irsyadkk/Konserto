import 'package:project_tpm_teori/models/tiket_model.dart';
import 'package:project_tpm_teori/networks/base_network.dart';

abstract class DetailTiketView {
  void showLoading();
  void hideLoading();
  void showDetailData(Tiket detail);
  void showError(String msg);
}

class DetailTiketPresenter {
  final DetailTiketView view;
  DetailTiketPresenter(this.view);

  Future<void> loadDetailTiket(String endpoint, int id) async {
    view.showLoading();
    try {
      final Map<String, dynamic> data =
          await BaseNetwork.getDetailData(endpoint, id);
      final tiketDetail = Tiket.fromJson(data);
      view.showDetailData(tiketDetail);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}
