# Personal Assistant App

Kişisel asistan uygulaması - Notlarınızı yönetin, sesli komutlar verin ve günlük görevlerinizi takip edin.

## 📱 Özellikler

### ✨ Temel Özellikler
- **Not Yönetimi**: Notlar oluşturun, düzenleyin ve silin
- **Sesli Komutlar**: Doğal dil işleme ile sesli not ekleme
- **Görsel Desteği**: Notlarınıza görsel ekleyebilme
- **Bildirimler**: Hatırlatıcı bildirimleri
- **Günlük Takip**: Bugünün notlarını görüntüleme
- **Takvim Görünümü**: Tarihlere göre gruplanmış notlar
- **Kullanıcı Profili**: Kişiselleştirilmiş hoş geldin ekranı

### 🎯 Öne Çıkan Özellikler
- **İlk Açılış Deneyimi**: Kullanıcı adı ile kişiselleştirilmiş karşılama
- **Tamamlama Durumu**: Notları tamamlandı olarak işaretleme
- **Tarih Bazlı Organizasyon**: Notlar otomatik olarak tarihlerine göre gruplanır
- **Gecikmiş Notlar**: Tamamlanmamış ve gecikmiş notları görüntüleme

## 🏗️ Proje Yapısı

```
PersonalAssistantApp/
├── PersonalAssistantApp/
│   ├── Models/
│   │   └── Note.swift              # Not modeli
│   ├── Views/
│   │   ├── ContentView.swift       # Ana görünüm
│   │   ├── WelcomeView.swift       # Hoş geldin ekranı
│   │   ├── AddTaskView.swift       # Not ekleme ekranı
│   │   ├── DailyTasksView.swift    # Takvim görünümü
│   │   ├── NoteDetailView.swift    # Not detay ekranı
│   │   ├── VoiceInputView.swift    # Sesli giriş ekranı
│   │   ├── ProfileView.swift       # Profil ekranı
│   │   ├── TaskListView.swift      # Not listesi görünümü
│   │   └── ImagePicker.swift       # Görsel seçici
│   ├── ViewModel/
│   │   └── NoteViewModel.swift     # Not iş mantığı
│   ├── Repositories/
│   │   └── NoteRepository.swift    # Veri kalıcılığı
│   ├── Services/
│   │   ├── SpeechManager.swift     # Ses tanıma servisi
│   │   ├── NaturalLanguageProcessor.swift  # Doğal dil işleme
│   │   ├── NotificationManager.swift       # Bildirim yönetimi
│   │   ├── ImageManager.swift      # Görsel yönetimi
│   │   └── UserManager.swift       # Kullanıcı yönetimi
│   └── PersonalAssistantAppApp.swift  # Uygulama giriş noktası
├── PersonalAssistantAppTests/      # Unit testler
└── PersonalAssistantAppUITests/    # UI testler
```

## 🚀 Kurulum

### Gereksinimler
- Xcode 14.0 veya üzeri
- iOS 16.0 veya üzeri
- Swift 5.7+

### Adımlar
1. Projeyi klonlayın veya indirin
2. `PersonalAssistantApp.xcodeproj` dosyasını Xcode ile açın
3. Hedef cihazı veya simülatörü seçin
4. `Cmd + R` ile projeyi çalıştırın

## 📖 Kullanım

### İlk Açılış
1. Uygulama ilk açıldığında hoş geldin ekranı görüntülenir
2. Adınızı girin ve devam edin
3. Ana ekrana yönlendirilirsiniz

### Not Ekleme
- **Manuel Ekleme**: Sağ alttaki `+` butonuna tıklayın
- **Sesli Ekleme**: Sol alttaki mikrofon butonuna tıklayın ve komutunuzu söyleyin
  - Örnek: "Yarın saat 10'da toplantı notu ekle"
  - Örnek: "Bugün alışveriş listesi oluştur"

### Not Yönetimi
- **Tamamlama**: Notun yanındaki checkbox'a tıklayın
- **Düzenleme**: Nota tıklayarak detay ekranına gidin
- **Silme**: Notu sola kaydırarak silin
- **Görsel Ekleme**: Not detay ekranından görsel ekleyebilirsiniz

### Takvim Görünümü
- Alt menüden "Takvim" sekmesine geçin
- Tüm notlarınız tarihlere göre gruplanmış olarak görüntülenir

## 🔧 Teknik Detaylar

### Mimari
- **MVVM Pattern**: Model-View-ViewModel mimarisi kullanılmıştır
- **SwiftUI**: Modern SwiftUI framework'ü ile geliştirilmiştir
- **Combine**: Reactive programlama için Combine framework'ü kullanılmıştır

### Veri Saklama
- **UserDefaults**: Kullanıcı adı ve notlar için yerel saklama
- **FileManager**: Görseller için dosya sistemi kullanımı

### İzinler
Uygulama aşağıdaki izinleri gerektirir:
- **Mikrofon**: Sesli komutlar için
- **Bildirimler**: Hatırlatıcılar için
- **Fotoğraf Kütüphanesi**: Görsel ekleme için

### Servisler
- **SpeechManager**: Ses tanıma ve konuşma sentezi
- **NaturalLanguageProcessor**: Doğal dil komutlarını parse etme
- **NotificationManager**: Yerel bildirimleri yönetme
- **ImageManager**: Görsel kaydetme ve silme işlemleri
- **UserManager**: Kullanıcı verilerini yönetme

## 🧪 Test

### Unit Testler
```bash
# Xcode'da testleri çalıştırın
Cmd + U
```

### UI Testler
UI testleri `PersonalAssistantAppUITests` klasöründe bulunmaktadır.

## 📝 Lisans

Bu proje kişisel kullanım için geliştirilmiştir.

## 👤 Geliştirici

**Ayşe Fulya**
- Oluşturulma Tarihi: Ekim 2025

## 🔄 Güncellemeler

### Versiyon 1.0
- İlk sürüm
- Not yönetimi
- Sesli komut desteği
- Bildirim sistemi
- Görsel desteği
- Takvim görünümü

## 🤝 Katkıda Bulunma

Bu proje kişisel bir projedir. Sorularınız veya önerileriniz için issue açabilirsiniz.

## 📞 İletişim

Sorularınız için GitHub issues kullanabilirsiniz.

---

**Not**: Bu uygulama iOS platformu için geliştirilmiştir ve App Store'da yayınlanmamıştır.
