import 'package:project_tpm_teori/models/konser_model.dart';
import 'package:project_tpm_teori/networks/base_network.dart';

abstract class KonserView {
  void showLoading();
  void hideLoading();
  void showKonserList(List<Konser> konserList);
  void showError(String msg);
}

class KonserPresenter {
  final KonserView view;
  KonserPresenter(this.view);

  Future<void> loadKonserData(String endpoint) async {
    view.showLoading();
    try {
      final List<dynamic> data = await BaseNetwork.getData(endpoint);
      final konserList = data.map((json) => Konser.fromJson(json)).toList();
      view.showKonserList(konserList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }

  Future<void> editKonserData(
      String endpoint, Map<String, dynamic> data, int id) async {
    view.showLoading();
    try {
      await BaseNetwork.edit(endpoint, data, id);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }

  Future<void> addKonserData(String endpoint, Map<String, dynamic> data) async {
    view.showLoading();
    try {
      await BaseNetwork.post(endpoint, data);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }

  Future<void> deleteKonserData(String endpoint, int id) async {
    view.showLoading();
    try {
      await BaseNetwork.delete(endpoint, id);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}
