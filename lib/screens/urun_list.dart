import 'package:flutter/material.dart';

import '../models/urun.dart';
import '../services/urun_service.dart';
import '../values/constants.dart';
import 'urun_detail.dart';

class UrunListesi extends StatefulWidget {
  const UrunListesi({Key? key}) : super(key: key);

  @override
  State<UrunListesi> createState() => _UrunListesiState();
}

class _UrunListesiState extends State<UrunListesi> {
  late Future<List<Urun>> _urunler;
  String _arama = '';
  String _seciliKategori = 'Tümü';

  @override
  void initState() {
    super.initState();
    _urunler = UrunService().urunleriGetir();
  }

  @override
  Widget build(BuildContext context) {

        final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
 backgroundColor: colorScheme.surface,
       appBar: AppBar(
        title: const Text(
          "Ürünler",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 26, // Daha büyük başlık
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // AppBar saydam olsun
        elevation: 0, // Gölge olmasın
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ colorScheme.onTertiaryContainer,  colorScheme.onTertiaryContainer,], // Daha canlı bir gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)), // Alt köşeler yuvarlak
          ),
        ),
        toolbarHeight: 80, // AppBar yüksekliği artırıldı
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Yatayda 20, altta 20 boşluk
        child: Column(
          children: [
            const SizedBox(height: 20), // AppBar ile arama çubuğu arasına boşluk

            // --- 🔍 Şık Arama Alanı ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35), // Daha yuvarlak hatlar
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20, // Daha geniş ve yumuşak gölge
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.teal.shade600, size: 26), // Daha büyük ikon
                  hintText: "Ürün ara...",
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _arama = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 18),

            // --- 🎯 Modern Kategori Filtresi ---
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30), // Tam bir hap şeklinde
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _seciliKategori,
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w700, // Daha kalın font
                      fontSize: 16,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    icon: Icon(Icons.filter_alt_outlined, color: Colors.teal.shade600, size: 24), // Daha anlamlı bir filtre ikonu
                    items: ["Tümü", "Aksesuar", "Kozmetik", "Teknoloji"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _seciliKategori = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25), // Ürün ızgarası ile filtre arasına boşluk

            // --- 📦 Gelişmiş Ürün Izgarası ---
            Expanded(
              child: FutureBuilder<List<Urun>>(
                future: _urunler,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
                        strokeWidth: 4, // Daha kalın yüklenme çubuğu
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sentiment_dissatisfied_outlined, color: Colors.red.shade400, size: 70),
                          const SizedBox(height: 15),
                          Text(
                            "Ürünler yüklenirken bir hata oluştu:\n${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade400, fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, color: Colors.grey.shade400, size: 70),
                          const SizedBox(height: 15),
                          Text(
                            "Gösterilecek ürün bulunamadı.",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 17, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final urunler = snapshot.data!
                        .where((u) =>
                            (_seciliKategori == 'Tümü' ||
                                u.kategori == _seciliKategori) &&
                            u.ad.toLowerCase().contains(_arama))
                        .toList();

                    if (urunler.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_outlined, color: Colors.grey.shade400, size: 70),
                            const SizedBox(height: 15),
                            Text(
                              "Aradığınız kriterlere uygun ürün bulunamadı.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18, // Daha da artırılmış boşluk
                        mainAxisSpacing: 18, // Daha da artırılmış boşluk
                        childAspectRatio: 0.70, // Kartları biraz daha uzun yaptık
                      ),
                      itemCount: urunler.length,
                      itemBuilder: (context, index) {
                        final urun = urunler[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UrunDetaySayfasi(urun: urun),
                              ),
                            );
                          },
                          child: Hero(
                            tag: 'urun_${urun.id}',
                            child: Material( // Hero içinde Material widgetı kullanarak ripple efekti ve gölgeyi koruyoruz
                              color: Colors.transparent, // Transparan olmalı
                              child: InkWell( // Ripple efekti için InkWell
                                borderRadius: BorderRadius.circular(28),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UrunDetaySayfasi(urun: urun),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28), // Daha yuvarlak
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12), // Daha belirgin gölge
                                        blurRadius: 22,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 📸 Ürün resmi
                                      Expanded( // Resmi flex içine alarak taşmayı engelliyoruz
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                                          child: Image.network(
                                            "${Constants.apiurl}/resimler/${urun.resim}",
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.grey.shade200,
                                              child: Center(
                                                child: Icon(Icons.broken_image, size: 55, color: Colors.grey.shade400),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(14), // Biraz daha fazla iç boşluk
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              urun.ad,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18, // Daha büyük ürün adı
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              urun.marka,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 15), // Fiyat ile arasına boşluk
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "${urun.fiyat} ₺",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800, // Daha belirgin fiyat
                                                    fontSize: 17,
                                                    color: Colors.teal.shade600,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(10), // Daha büyük dokunma alanı
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal.shade50,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.shopping_cart_outlined, // Orijinal ikona döndük, daha temiz
                                                    size: 22, // Daha büyük ikon
                                                    color: Colors.teal.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}