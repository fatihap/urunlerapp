import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urunlerapp/screens/urun_list.dart';

import 'register.dart';

class GirisSayfasi extends StatefulWidget {
  const GirisSayfasi({super.key});

  @override
  State<GirisSayfasi> createState() => _GirisSayfasiState();
}

// Global bir key olmaktan çok, ilgili widget'ın state'inde tutulması daha iyi bir yaklaşımdır.
// String kullaniciAdiKey = 'kullaniciAdi';

class _GirisSayfasiState extends State<GirisSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController kullaniciAdiController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();

  bool beniHatirla = false;
  bool sifreGizli = true;

  @override
  void initState() {
    super.initState();
    _loadRememberMePreferences(); // Kayıtlı tercihleri yükle
  }

  // Kayıtlı tercihleri yüklemek için yeni metod
  Future<void> _loadRememberMePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      beniHatirla = prefs.getBool('beniHatirla') ?? false;
      if (beniHatirla) {
        kullaniciAdiController.text = prefs.getString('savedKullaniciAdi') ?? '';
      }
    });
  }

  // Beni hatırla tercihini kaydetmek için yeni metod
  Future<void> _saveRememberMePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('beniHatirla', beniHatirla);
    if (beniHatirla) {
      await prefs.setString('savedKullaniciAdi', kullaniciAdiController.text);
    } else {
      await prefs.remove('savedKullaniciAdi'); // Beni hatırla seçimi kaldırılırsa sil
    }
  }

  @override
  Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      
      backgroundColor: const Color(0xFFF5F7FA), // Ürünler listesiyle uyumlu arka plan
      appBar: AppBar(
        // AppBar tamamen kaldırıldı veya basit bir başlık için gizlendi
        // Arka plan rengiyle uyumlu hale getirilip, başlık ana gövdeye taşındı
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // AppBar'ı görünmez yap
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Yatayda tüm genişliği kapla
            children: [
              const SizedBox(height: 60), // Üstte daha fazla boşluk

              // --- Uygulama Başlığı ve Hoş Geldiniz Metni ---
              Text(
                "Hoş Geldiniz!",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Devam etmek için giriş yapın veya kayıt olun.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // --- Giriş Formu ---
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: kullaniciAdiController,
                      decoration: InputDecoration(
                        labelText: "Kullanıcı Adı",
                        hintText: "kullanıcı adınızı girin",
                        prefixIcon: Icon(Icons.person_outline, color: Colors.teal.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), // Daha yuvarlak
                          borderSide: BorderSide.none, // Kenarlık olmasın
                        ),
                        filled: true, // Arka plan rengi olsun
                        fillColor: Colors.white, // Beyaz arka plan
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        focusedBorder: OutlineInputBorder( // Odaklandığında kenarlık rengi
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder( // Normal durumda kenarlık
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                     /* validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen kullanıcı adınızı girin';
                        }
                        return null;
                      },
                      */
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: sifreController,
                      obscureText: sifreGizli,
                      decoration: InputDecoration(
                        labelText: "Şifre",
                        hintText: "şifrenizi girin",
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade600),
                        suffixIcon: IconButton(
                          icon: Icon(
                            sifreGizli ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            setState(() {
                              sifreGizli = !sifreGizli;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                      ),
                  /*    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi girin';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalıdır';
                        }
                        return null;
                      },
                      */
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible( // Beni Hatırla yazısının taşmasını engellemek için
                          child: CheckboxListTile(
                            value: beniHatirla,
                            onChanged: (val) {
                              setState(() {
                                beniHatirla = val ?? false;
                              });
                            },
                            title: Text(
                              "Beni Hatırla",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true, // Daha az boşluk
                            contentPadding: EdgeInsets.zero, // İç boşluğu sıfırla
                            activeColor: Colors.teal.shade600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Şifremi unuttum özelliği eklenebilir
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Şifremi unuttum özelliği yakında!"),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                          child: Text(
                            "Şifremi Unuttum?",
                            style: TextStyle(
                              color: Colors.teal.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon( // FilledButton yerine Elevated, daha esnek stil için
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Gerçek kimlik doğrulama mekanizması burada olmalı
                          // Şimdilik sadece başarılı mesajı ve navigasyon
                          
                          await _saveRememberMePreferences(); // Tercihleri kaydet

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Giriş başarılı! Yönlendiriliyorsunuz..."),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );

                          // Gecikmeli navigasyon ile Snackbar'ın görünürlüğünü artır
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pushReplacement( // Geri tuşuyla buraya dönmeyi engelle
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UrunListesi(),
                              ),
                            );
                          });
                        }
                      },
                      icon: const Icon(Icons.login_rounded, size: 24), // Daha modern ikon
                      label: const Text(
                        "Giriş Yap",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onTertiaryContainer,// Ana buton rengi
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55), // Daha büyük buton
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18), // Daha yuvarlak kenarlar
                        ),
                        elevation: 8, // Hafif gölge
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KayitSayfasi(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 24), // Daha modern ikon
                      label: const Text(
                        "Hesap Oluştur", // Metni daha açıklayıcı yaptık
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:colorScheme.onTertiaryContainer,
                        side: BorderSide(color: colorScheme.onTertiaryContainer, width: 2), // Kenarlık rengi ve kalınlığı
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2, // Hafif gölge
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // --- Alt Bilgi / Logo Bölümü ---
              Text(
                "© 2025 Ürünler Uygulaması",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}