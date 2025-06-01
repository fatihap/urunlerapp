import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/urun.dart';
import '../states/sepet_state.dart';

class SepetCubit extends Cubit<SepetState> {
  

  SepetCubit() : super(const SepetState());
  String kullaniciAdi ='';
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
  
    final kayitliAd = prefs.getString('kullaniciAdi')?.trim();
    kullaniciAdi = (kayitliAd != null && kayitliAd.isNotEmpty) ? kayitliAd : "fatihapaydn";

    await fetchSepetUrunleri();
  }

  Future<void> fetchSepetUrunleri() async {
    if (kullaniciAdi == null) return;

    emit(state.copyWith(status: SepetStatus.loading));

    final url = Uri.parse("http://kasimadalan.pe.hu/urunler/sepettekiUrunleriGetir.php");

    try {
      final response = await http.post(
        url,
        body: {"kullaniciAdi": kullaniciAdi!},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["success"] == 1) {
          final List<dynamic> urunListesi = jsonData["urunler_sepeti"];
          int hesaplananToplam = 0;

          List<Urun> tempList = [];
          Map<int, int> tempAdetMap = {};

          for (var item in urunListesi) {
            final urun = Urun(
              id: item["sepetId"],
              ad: item["ad"],
              resim: item["resim"],
              kategori: item["kategori"],
              fiyat: item["fiyat"],
              marka: item["marka"],
            );
            final int siparisAdeti = item["siparisAdeti"];

            tempList.add(urun);
            tempAdetMap[urun.id] = siparisAdeti;
            hesaplananToplam += urun.fiyat * siparisAdeti;
          }

          emit(state.copyWith(
            sepetUrunleri: tempList,
            adetMap: tempAdetMap,
            toplamTutar: hesaplananToplam,
            status: SepetStatus.success,
          ));
        } else {
          emit(state.copyWith(
            status: SepetStatus.failure,
            errorMessage: "Sepet verisi alınamadı.",
          ));
        }
      } else {
        emit(state.copyWith(
          status: SepetStatus.failure,
          errorMessage: "Sunucu hatası: ${response.statusCode}",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SepetStatus.failure,
        errorMessage: "Hata: İnternet bağlantınızı kontrol edin.",
      ));
    }
  }

  Future<void> urunSil(int sepetId) async {
    if (kullaniciAdi == null) return;

    emit(state.copyWith(isProcessing: true));

    final url = Uri.parse("http://kasimadalan.pe.hu/urunler/sepettenUrunSil.php");

    try {
      final response = await http.post(
        url,
        body: {"sepetId": sepetId.toString(), "kullaniciAdi": kullaniciAdi!},
      );

      final json = jsonDecode(response.body);

      if (json["success"] == 1) {
        final updatedUrunler = List<Urun>.from(state.sepetUrunleri)
          ..removeWhere((e) => e.id == sepetId);
        
        final updatedAdetMap = Map<int, int>.from(state.adetMap)
          ..remove(sepetId);
        
        final updatedToplam = updatedUrunler.fold(
          0,
          (tutar, urun) => tutar + urun.fiyat * (updatedAdetMap[urun.id] ?? 1),
        );

        emit(state.copyWith(
          sepetUrunleri: updatedUrunler,
          adetMap: updatedAdetMap,
          toplamTutar: updatedToplam,
          isProcessing: false,
          status: SepetStatus.success,
        ));
      } else {
        emit(state.copyWith(
          isProcessing: false,
          status: SepetStatus.failure,
          errorMessage: "Silme başarısız: ${json["message"]}",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        status: SepetStatus.failure,
        errorMessage: "İnternet bağlantısı yok veya sunucu hatası.",
      ));
    }
  }
}
