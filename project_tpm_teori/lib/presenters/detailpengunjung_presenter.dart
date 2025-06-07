import 'package:project_tpm_teori/models/pengunjung_model.dart';
import 'package:project_tpm_teori/networks/base_network.dart';

abstract class DetailPengunjungView {
  void showLoading();
  void hideLoading();
  void showDataPengunjungByEmail(List<Pengunjung> pengunjungList);
  void showError(String msg);
}

class DetailPengunjungPresenter {
  final DetailPengunjungView view;
  DetailPengunjungPresenter(this.view);

  Future<void> loadDetailPengunjung(String endpoint, String email) async {
    view.showLoading();
    try {
      final List<dynamic> data =
          await BaseNetwork.getDataListByEmail(endpoint, email);
      final pengunjungList =
          data.map((json) => Pengunjung.fromJson(json)).toList();
      view.showDataPengunjungByEmail(pengunjungList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}
