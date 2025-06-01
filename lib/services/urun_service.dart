import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:urunlerapp/values/constants.dart';

import '../models/urun.dart';

class UrunService {
  final String url = "${Constants.apiurl}/tumUrunleriGetir.php";
final Dio _dio = Dio();

  Future<List<Urun>> urunleriGetir() async {
    try {
      final response = await _dio.get(url);

      // Gelen veri string ise decode edelim
      final decoded = json.decode(response.data);

      final List<dynamic> urunlerJson = decoded['urunler'];

      return urunlerJson.map((e) => Urun.fromJson(e)).toList();
    } catch (e) {
      print(e);
      throw Exception("Veri alınamadı: $e");
      
    }
  }
}
