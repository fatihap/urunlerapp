import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/urun.dart';
import '../states/urun_detail_state.dart';

class UrunDetailCubit extends Cubit<UrunDetailState> {
  UrunDetailCubit({required Urun urun})
      : super(UrunDetailState(urun: urun));

  void incrementAdet() {
    emit(state.copyWith(adet: state.adet + 1));
  }

  void decrementAdet() {
    if (state.adet > 1) {
      emit(state.copyWith(adet: state.adet - 1));
    }
  }

  Future<void> sepeteEkle() async {
    emit(state.copyWith(isAdding: true));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final kullaniciAdi = prefs.getString('kullaniciAdi')?.trim().isNotEmpty == true
        ? prefs.getString('kullaniciAdi')!
        : "fatihapaydn";

    final url = Uri.parse(
      "http://kasimadalan.pe.hu/urunler/sepeteUrunEkle.php",
    );

    final body = {
      "ad": state.urun.ad,
      "resim": state.urun.resim,
      "kategori": state.urun.kategori,
      "fiyat": state.urun.fiyat.toString(),
      "marka": state.urun.marka,
      "siparisAdeti": state.adet.toString(),
      "kullaniciAdi": kullaniciAdi,
    };

    try {
      final response = await http.post(url, body: body);
      final json = jsonDecode(response.body);

      if (json["success"] == 1) {
        emit(state.copyWith(
          sepetAdeti: state.sepetAdeti + state.adet,
          isAdding: false,
          status: UrunDetailStatus.success,
        ));
      } else {
        emit(state.copyWith(
          isAdding: false,
          status: UrunDetailStatus.failure,
          errorMessage: "Hata: ${json['message']}",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isAdding: false,
        status: UrunDetailStatus.failure,
        errorMessage: "Bir hata oluştu. Lütfen tekrar deneyin.",
      ));
    }
  }
}
