import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urunlerapp/screens/sepet_sayfa.dart';

import '../models/urun.dart';
import '../values/constants.dart';

class UrunDetaySayfasi extends StatefulWidget {
  final Urun urun;

  const UrunDetaySayfasi({Key? key, required this.urun}) : super(key: key);

  @override
  State<UrunDetaySayfasi> createState() => _UrunDetaySayfasiState();
}

class _UrunDetaySayfasiState extends State<UrunDetaySayfasi> with SingleTickerProviderStateMixin {
  int adet = 1;
  int sepetAdeti = 0;
  bool isAdding = false;
  int sepetId = 0;
  String kullaniciAdiKey = 'kullaniciAdi';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> sepeteEkle() async {
    setState(() {
      isAdding = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final kullaniciAdi =
        prefs.getString(kullaniciAdiKey)?.trim().isNotEmpty == true
        ? prefs.getString(kullaniciAdiKey)!
        : "fatihapaydn";

    final url = Uri.parse(
      "http://kasimadalan.pe.hu/urunler/sepeteUrunEkle.php",
    );

    final body = {
      "ad": widget.urun.ad,
      "resim": widget.urun.resim,
      "kategori": widget.urun.kategori,
      "fiyat": widget.urun.fiyat.toInt().toString(),
      "marka": widget.urun.marka,
      "siparisAdeti": adet.toString(),
      "kullaniciAdi": kullaniciAdi,
    };

    print(">>> Gönderilen Body: $body");

    try {
      final response = await http.post(url, body: body);
      final json = jsonDecode(response.body);
      print(">>> Sunucu cevabı: $json");

      if (json["success"] == 1) {
        setState(() {
          sepetAdeti += adet;
          isAdding = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ürün sepete eklendi."),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          isAdding = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata: ${json['message']}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isAdding = false;
      });

      print(">>> HATA: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bir hata oluştu. Lütfen tekrar deneyin."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.8),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shopping_bag_outlined, 
                      color: colorScheme.primary,
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SepetSayfa()),
                      );
                    },
                  ),
                  if (sepetAdeti > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.error.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          sepetAdeti.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ürün görseli
          Hero(
            tag: "urun_${widget.urun.id}",
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.network(
                      "${Constants.apiurl}/resimler/${widget.urun.resim}",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 80,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  // Kategori ve marka etiketleri
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.urun.kategori,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.urun.marka,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Ürün detayları
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: Container(
                width: double.infinity,
                color: colorScheme.surface,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.urun.ad,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "${widget.urun.fiyat} ₺",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Marka ve Kategori bilgileri
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  icon: Icons.branding_watermark_outlined,
                                  title: "Marka",
                                  value: widget.urun.marka,
                                  theme: theme,
                                  colorScheme: colorScheme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoItem(
                                  icon: Icons.category_outlined,
                                  title: "Kategori",
                                  value: widget.urun.kategori,
                                  theme: theme,
                                  colorScheme: colorScheme,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Adet seçici
                          Text(
                            "Adet",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Azaltma butonu
                                _buildQuantityButton(
                                  icon: Icons.remove,
                                  onPressed: adet > 1 && !isAdding
                                      ? () {
                                          setState(() {
                                            adet--;
                                          });
                                        }
                                      : null,
                                  colorScheme: colorScheme,
                                ),
                                
                                // Miktar göstergesi
                                Container(
                                  width: 50,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  child: Text(
                                    adet.toString(),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                
                                // Artırma butonu
                                _buildQuantityButton(
                                  icon: Icons.add,
                                  onPressed: !isAdding
                                      ? () {
                                          setState(() {
                                            adet++;
                                          });
                                        }
                                      : null,
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Ürün açıklaması (Mock veri)
                          Text(
                            "Ürün Açıklaması",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${widget.urun.ad}, ${widget.urun.marka} markasının kaliteli ürünlerinden biridir. Bu ürün dayanıklılığı ve şık tasarımı ile öne çıkmaktadır.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Alt sepete ekleme butonu
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isAdding ? null : sepeteEkle,
            icon: isAdding
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(Icons.shopping_bag_outlined, color: colorScheme.onPrimary),
            label: Text(
              isAdding ? "Ekleniyor..." : "Sepete Ekle",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: colorScheme.shadow.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: onPressed == null ? colorScheme.surfaceVariant : colorScheme.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: onPressed == null 
                ? colorScheme.onSurfaceVariant.withOpacity(0.5) 
                : colorScheme.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
  }
