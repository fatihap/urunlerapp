class Urun {
  final int id;
  final String ad;
  final String marka;
  final String kategori;
  final String resim;
  final int fiyat;

  Urun({
    required this.id,
    required this.ad,
    required this.fiyat,
    required this.kategori,
    required this.marka,
    required this.resim,
  });

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      id: json['id'],
      ad: json['ad'],
      kategori: json['kategori'],
      marka: json['marka'],
      resim: json['resim'],
      fiyat: json['fiyat'],
    );
  }
}
