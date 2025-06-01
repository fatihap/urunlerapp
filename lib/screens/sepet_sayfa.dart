import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:urunlerapp/screens/urun_list.dart';

import '../models/urun.dart';
import '../values/constants.dart';

class SepetSayfa extends StatefulWidget {
  const SepetSayfa({Key? key}) : super(key: key);

  @override
  State<SepetSayfa> createState() => _SepetSayfaState();
}

class _SepetSayfaState extends State<SepetSayfa>
    with SingleTickerProviderStateMixin {
  List<Urun> sepetUrunleri = [];
  Map<int, int> adetMap = {};
  bool isLoading = true;
  int toplamTutar = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final String kullaniciAdi = "fatihapaydn";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    sepetUrunleriniGetir();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> sepetUrunleriniGetir() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "http://kasimadalan.pe.hu/urunler/sepettekiUrunleriGetir.php",
    );

    try {
      final response = await http.post(
        url,
        body: {"kullaniciAdi": kullaniciAdi},
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

          setState(() {
            sepetUrunleri = tempList;
            adetMap = tempAdetMap;
            toplamTutar = hesaplananToplam;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sepet verisi alınamadı.")),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sunucu hatası: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hata: İnternet bağlantınızı kontrol edin."),
        ),
      );
    }
  }

  Future<void> urunSil(int sepetId) async {
    final url = Uri.parse(
      "http://kasimadalan.pe.hu/urunler/sepettenUrunSil.php",
    );

    try {
      final response = await http.post(
        url,
        body: {"sepetId": sepetId.toString(), "kullaniciAdi": kullaniciAdi},
      );

      final json = jsonDecode(response.body);

      if (json["success"] == 1) {
        setState(() {
          sepetUrunleri.removeWhere((e) => e.id == sepetId);
          adetMap.remove(sepetId);
          toplamTutar = sepetUrunleri.fold(
            0,
            (tutar, urun) => tutar + urun.fiyat * (adetMap[urun.id] ?? 1),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ürün sepetten kaldırıldı.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Silme başarısız: ${json["message"]}")),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("İnternet bağlantısı yok veya sunucu hatası."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Sepetim",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceVariant,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : sepetUrunleri.isEmpty
          ? _buildEmptyCart(theme)
          : _buildCartContent(theme, colorScheme),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return FadeTransition(
      opacity: _animation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              "Sepetiniz boş",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Alışverişe başlayarak sepetinize ürün ekleyebilirsiniz",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // UrunListesi sayfasına yönlendirme
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const UrunListesi(), // Burası düzeltildi
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text("Alışverişe Başla"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: AnimatedList(
            initialItemCount: sepetUrunleri.length,
            itemBuilder: (context, index, animation) {
              final urun = sepetUrunleri[index];
              final adet = adetMap[urun.id] ?? 1;
              final toplam = urun.fiyat * adet;

              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutQuint,
                      ),
                    ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) => urunSil(urun.id),
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Sil',
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: colorScheme.surfaceVariant,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  "${Constants.apiurl}/resimler/${urun.resim}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.image_not_supported_outlined,
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.5),
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        urun.ad,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),

                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      Text(
                                        'Adet Fiyat',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),

                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Spacer(),
                                      Text(
                                        'Toplam',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),

                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    urun.marka,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          "$adet Adet",
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        "${urun.fiyat} ₺",
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                      ),
                                      Text(
                                        "$toplam",
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
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
          ),
        ),
        _buildTotalPrice(theme, colorScheme),
      ],
    );
  }

  Widget _buildTotalPrice(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Toplam Tutar",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  "$toplamTutar ₺",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Sipariş onaylama işlemi buraya eklenecek
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Siparişiniz onaylandı!"),
                    backgroundColor: colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                "Siparişi Onayla",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
