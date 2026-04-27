# 8086 Assembly ASCII Labirent Oyunu

8086 mikroişlemci mimarisi üzerinde, Assembly dili kullanılarak geliştirilmiş, düşük seviyeli donanım kontrolü ve oyun mantığını birleştiren bir labirent oyunudur.

## 🚀 Proje Hakkında
Bu proje, mikroişlemcilerin bellek yönetimi, kesme (interrupt) servisleri ve video belleği kontrolü gibi temel prensiplerini anlamak amacıyla geliştirilmiştir. Kullanıcı, ASCII karakterlerden oluşan bir labirentte '@' karakterini kontrol ederek, süre bitmeden çıkış noktasına ('E') ulaşmaya çalışır.

## ✨ Özellikler
* **3 Farklı Zorluk Seviyesi:**
    * **Kolay:** 20x20 Harita - 60 Saniye
    * **Orta:** 22x22 Harita - 90 Saniye
    * **Zor:** 24x24 Harita - 120 Saniye
* **Dinamik Geri Sayım:** Sistem saati (`INT 1Ah`) kullanılarak gerçek zamanlı süre takibi.
* **Çarpışma Kontrolü:** Duvarlardan geçişi engelleyen 16-bit bellek ofset hesaplama algoritması.
* **Asenkron Girdi:** Oyun akışını durdurmayan (non-blocking) klavye okuma mekanizması.
* **Gelişmiş UX:** Oyun içi menüye dönüş (ESC) ve oyun sonu bekleme ekranı.

## 🛠 Kullanılan Teknolojiler & Kesmeler
* **Emu8086:** Geliştirme ve emülasyon ortamı.
* **INT 10h:** Video servisleri (İmleç konumu, karakter basma, ekran temizleme).
* **INT 16h:** Klavye servisleri (Girdi okuma ve tampon kontrolü).
* **INT 1Ah:** Sistem saati (Süre hesaplama).
* **INT 21h:** DOS servisleri (String yazdırma ve program sonlandırma).

## 🎮 Nasıl Çalıştırılır?
1.  Bilgisayarınıza **Emu8086** emülatörünü kurun.
2.  `MazeGame.asm` dosyasındaki kodları emülatöre yapıştırın.
3.  **Emulate** butonuna basın.
4.  Açılan pencerede **Run** diyerek oyunu başlatın.

### Kontroller
* **W / w:** Yukarı Hareket
* **A / a:** Sola Hareket
* **S / s:** Aşağı Hareket
* **D / d:** Sağa Hareket
* **ESC:** Menüye Dön / Çıkış

## 📋 Teknik Detaylar
Haritalar bellekte tek boyutlu diziler (1D Array) olarak tutulur. Karakterin hareketi sırasında hedef koordinatın fiziksel adresi aşağıdaki formülle hesaplanır:
`Ofset = (Y * Harita_Genişliği) + X`

Bu hesaplama sonucunda elde edilen bellek adresindeki karakter kontrol edilerek hareketin geçerliliği sorgulanır.

## 👤 Hazırlayan
**Kuzey Yağız Yıldız**
* Marmara Üniversitesi
