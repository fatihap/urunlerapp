import 'package:equatable/equatable.dart';
import '../models/urun.dart';

enum UrunListStatus { initial, loading, success, failure }

class UrunListState extends Equatable {
  final List<Urun> urunler;
  final String arama;
  final String seciliKategori;
  final UrunListStatus status;
  final String? errorMessage;

  const UrunListState({
    this.urunler = const [],
    this.arama = '',
    this.seciliKategori = 'Tümü',
    this.status = UrunListStatus.initial,
    this.errorMessage,
  });

  List<Urun> get filteredUrunler => urunler
      .where(
        (u) =>
            (seciliKategori == 'Tümü' || u.kategori == seciliKategori) &&
            u.ad.toLowerCase().contains(arama.toLowerCase()),
      )
      .toList();

  UrunListState copyWith({
    List<Urun>? urunler,
    String? arama,
    String? seciliKategori,
    UrunListStatus? status,
    String? errorMessage,
  }) {
    return UrunListState(
      urunler: urunler ?? this.urunler,
      arama: arama ?? this.arama,
      seciliKategori: seciliKategori ?? this.seciliKategori,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [urunler, arama, seciliKategori, status, errorMessage];
}
