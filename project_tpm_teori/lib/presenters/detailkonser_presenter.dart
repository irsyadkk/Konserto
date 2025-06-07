import 'package:project_tpm_teori/models/konser_model.dart';
import 'package:project_tpm_teori/networks/base_network.dart';

abstract class DetailKonserView {
  void showLoading();
  void hideLoading();
  void showDetailData(Konser detail);
  void showError(String msg);
}

class DetailKonserPresenter {
  final DetailKonserView view;
  DetailKonserPresenter(this.view);

  Future<void> loadDetailKonser(String endpoint, int id) async {
    view.showLoading();
    try {
      final Map<String, dynamic> data =
          await BaseNetwork.getDetailData(endpoint, id);
      final konserDetail = Konser.fromJson(data);
      view.showDetailData(konserDetail);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}
