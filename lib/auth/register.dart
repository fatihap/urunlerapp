import 'package:flutter/material.dart';

class KayitSayfasi extends StatefulWidget {
  const KayitSayfasi({super.key});

  @override
  State<KayitSayfasi> createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  final _formKey = GlobalKey<FormState>();
  final adSoyadController = TextEditingController();
  final kullaniciAdiController = TextEditingController();
  final telefonController = TextEditingController();
  final sifreController = TextEditingController();
  final sifreTekrarController = TextEditingController();
  bool sifreGizli = true;

  @override
  void dispose() {
    adSoyadController.dispose();
    kullaniciAdiController.dispose();
    telefonController.dispose();
    sifreController.dispose();
    sifreTekrarController.dispose();
    super.dispose();
  }

  void _kayitOl() {
    if (_formKey.currentState!.validate()) {
      // TODO: Burada gerçek kayıt (API çağrısı vb.) işlemleri yapılmalı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${kullaniciAdiController.text} olarak kaydınız başarılı!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      // Başarılı kayıt sonrası geri dön
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Giriş sayfasıyla aynı arka plan
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Saydam AppBar
        elevation: 0, // Gölge yok
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.teal.shade700, size: 28), // Daha modern geri tuşu
          onPressed: () => Navigator.of(context).pop(),
        ),
        toolbarHeight: 80, // AppBar yüksekliği artırıldı
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade500], // Canlı gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)), // Alt köşeler yuvarlak
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0), // Giriş sayfasıyla aynı yatay boşluk
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20), // AppBar altıyla form arasına boşluk

            // --- Başlık ---
            Text(
              "Yeni Hesap Oluştur",
              style: TextStyle(
                fontSize: 34, // Biraz daha küçük ama yine de dikkat çekici
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Hızlı ve kolayca kaydolun.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // --- Kayıt Formu ---
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Ad Soyad
                  TextFormField(
                    controller: adSoyadController,
                    decoration: InputDecoration(
                      labelText: "Ad Soyad",
                      hintText: "adınızı ve soyadınızı girin",
                      prefixIcon: Icon(Icons.person_outline, color: Colors.teal.shade600),
                      border: _getInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: _getContentPadding(),
                      focusedBorder: _getFocusedInputBorder(),
                      enabledBorder: _getEnabledInputBorder(),
                      errorBorder: _getErrorInputBorder(),
                      focusedErrorBorder: _getFocusedErrorInputBorder(),
                    ),
                    validator: (val) => val!.isEmpty ? 'Ad Soyad zorunludur' : null,
                  ),
                  const SizedBox(height: 20),

                  // Kullanıcı Adı
                  TextFormField(
                    controller: kullaniciAdiController,
                    decoration: InputDecoration(
                      labelText: "Kullanıcı Adı",
                      hintText: "kullanıcı adınızı belirleyin",
                      prefixIcon: Icon(Icons.account_circle_outlined, color: Colors.teal.shade600),
                      border: _getInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: _getContentPadding(),
                      focusedBorder: _getFocusedInputBorder(),
                      enabledBorder: _getEnabledInputBorder(),
                      errorBorder: _getErrorInputBorder(),
                      focusedErrorBorder: _getFocusedErrorInputBorder(),
                    ),
                    validator: (val) => val!.isEmpty ? 'Kullanıcı adı zorunludur' : null,
                  ),
                  const SizedBox(height: 20),

                  // Telefon
                  TextFormField(
                    controller: telefonController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Telefon Numarası",
                      hintText: "geçerli bir telefon numarası girin",
                      prefixIcon: Icon(Icons.phone_outlined, color: Colors.teal.shade600),
                      border: _getInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: _getContentPadding(),
                      focusedBorder: _getFocusedInputBorder(),
                      enabledBorder: _getEnabledInputBorder(),
                      errorBorder: _getErrorInputBorder(),
                      focusedErrorBorder: _getFocusedErrorInputBorder(),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) return 'Telefon numarası zorunludur';
                      if (val.length < 10) return 'Geçerli bir telefon numarası girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Şifre
                  TextFormField(
                    controller: sifreController,
                    obscureText: sifreGizli,
                    decoration: InputDecoration(
                      labelText: "Şifre",
                      hintText: "en az 6 karakterli bir şifre belirleyin",
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade600),
                      suffixIcon: IconButton(
                        icon: Icon(sifreGizli ? Icons.visibility_off : Icons.visibility, color: Colors.grey.shade500),
                        onPressed: () {
                          setState(() {
                            sifreGizli = !sifreGizli;
                          });
                        },
                      ),
                      border: _getInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: _getContentPadding(),
                      focusedBorder: _getFocusedInputBorder(),
                      enabledBorder: _getEnabledInputBorder(),
                      errorBorder: _getErrorInputBorder(),
                      focusedErrorBorder: _getFocusedErrorInputBorder(),
                    ),
                    validator: (val) =>
                        val!.length < 6 ? 'Şifre en az 6 karakter olmalı' : null,
                  ),
                  const SizedBox(height: 20),

                  // Şifre tekrar
                  TextFormField(
                    controller: sifreTekrarController,
                    obscureText: sifreGizli,
                    decoration: InputDecoration(
                      labelText: "Şifre (Tekrar)",
                      hintText: "şifrenizi tekrar girin",
                      prefixIcon: Icon(Icons.lock_reset_outlined, color: Colors.teal.shade600),
                      border: _getInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: _getContentPadding(),
                      focusedBorder: _getFocusedInputBorder(),
                      enabledBorder: _getEnabledInputBorder(),
                      errorBorder: _getErrorInputBorder(),
                      focusedErrorBorder: _getFocusedErrorInputBorder(),
                    ),
                    validator: (val) =>
                        val != sifreController.text ? 'Şifreler eşleşmiyor' : null,
                  ),
                  const SizedBox(height: 30),

                  // Kayıt butonu
                  ElevatedButton.icon(
                    onPressed: _kayitOl,
                    icon: const Icon(Icons.how_to_reg_rounded, size: 24), // Daha anlamlı bir kayıt ikonu
                    label: const Text(
                      "Hesap Oluştur",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 8,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Giriş sayfasına geri dön
                    },
                    child: Text(
                      "Zaten bir hesabın var mı? Giriş Yap",
                      style: TextStyle(
                        color: Colors.teal.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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
    );
  }

  // Ortak InputBorder stilleri için yardımcı metodlar
  OutlineInputBorder _getInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    );
  }

  EdgeInsetsGeometry _getContentPadding() {
    return const EdgeInsets.symmetric(vertical: 18, horizontal: 20);
  }

  OutlineInputBorder _getFocusedInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
    );
  }

  OutlineInputBorder _getEnabledInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    );
  }

  OutlineInputBorder _getErrorInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    );
  }

  OutlineInputBorder _getFocusedErrorInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    );
  }
}