import 'analysis_category.dart';

/// Senaryo bazlı analiz için veri yöneticisi
/// Her AnalysisCategory'yi ilgili JSON dosyalarına eşler
class AnalysisDataManager {
  AnalysisDataManager._();

  /// Kategori -> JSON dosya yolları eşlemesi
  static const Map<AnalysisCategory, List<String>> _categoryFileMap = {
    // ═══════════════════════════════════════════════════════════
    // AŞK VE İLİŞKİLER
    // ═══════════════════════════════════════════════════════════
    AnalysisCategory.loveGeneral: [
      'assets/config/line_heart.json',
      'assets/config/mount_venus.json',
    ],
    AnalysisCategory.marriage: [
      'assets/config/line_marriage.json',
      'assets/config/mount_jupiter.json',
    ],
    AnalysisCategory.children: [
      'assets/config/line_children.json',
    ],
    AnalysisCategory.passion: [
      'assets/config/ring_venus.json',
      'assets/config/mount_venus.json',
    ],

    // ═══════════════════════════════════════════════════════════
    // ZENGİNLİK VE KARİYER
    // ═══════════════════════════════════════════════════════════
    AnalysisCategory.wealth: [
      'assets/config/sign_triangle.json',
      'assets/config/other_lines.json',
      'assets/config/digit_thumb.json',
    ],
    AnalysisCategory.career: [
      'assets/config/line_fate.json',
      'assets/config/mount_saturn.json',
      'assets/config/digit_middle.json',
    ],
    AnalysisCategory.fame: [
      'assets/config/line_sun.json',
      'assets/config/mount_sun.json',
      'assets/config/digit_ring.json',
    ],

    // ═══════════════════════════════════════════════════════════
    // GİZEM VE TEHLİKE
    // ═══════════════════════════════════════════════════════════
    AnalysisCategory.danger: [
      'assets/config/line_influence.json',
      'assets/config/mount_mars.json',
      'assets/config/signs_general.json',
    ],
    AnalysisCategory.mystic: [
      'assets/config/line_intuition.json',
      'assets/config/mount_moon.json',
      'assets/config/mount_plain_and_palm.json',
    ],
    AnalysisCategory.travel: [
      'assets/config/line_travel.json',
    ],

    // ═══════════════════════════════════════════════════════════
    // SAĞLIK VE KARAKTER
    // ═══════════════════════════════════════════════════════════
    AnalysisCategory.health: [
      'assets/config/line_life.json',
      'assets/config/line_health.json',
      'assets/config/fingernails.json',
      'assets/config/hand_color.json',
    ],
    AnalysisCategory.character: [
      'assets/config/hand_shape.json',
      'assets/config/line_head.json',
      'assets/config/finger_tips.json',
      'assets/config/digit_index.json',
    ],

    // ═══════════════════════════════════════════════════════════
    // TAM ANALİZ (Tüm benzersiz dosyalar)
    // ═══════════════════════════════════════════════════════════
    AnalysisCategory.full: [
      // El Şekli ve Yapısı
      'assets/config/hand_shape.json',
      'assets/config/hand_color.json',
      // Parmak Yapısı
      'assets/config/finger_tips.json',
      'assets/config/finger_structure.json',
      'assets/config/finger_comparison.json',
      'assets/config/fingernails.json',
      // Bireysel Parmaklar
      'assets/config/digit_thumb.json',
      'assets/config/digit_index.json',
      'assets/config/digit_middle.json',
      'assets/config/digit_ring.json',
      'assets/config/digit_little.json',
      // Ana Çizgiler
      'assets/config/line_life.json',
      'assets/config/line_head.json',
      'assets/config/line_heart.json',
      'assets/config/line_fate.json',
      'assets/config/line_sun.json',
      'assets/config/line_health.json',
      'assets/config/line_intuition.json',
      // Diğer Çizgiler
      'assets/config/line_marriage.json',
      'assets/config/line_children.json',
      'assets/config/line_travel.json',
      'assets/config/line_influence.json',
      'assets/config/other_lines.json',
      // Tepeler
      'assets/config/mount_jupiter.json',
      'assets/config/mount_saturn.json',
      'assets/config/mount_sun.json',
      'assets/config/mount_mercury.json',
      'assets/config/mount_venus.json',
      'assets/config/mount_moon.json',
      'assets/config/mount_mars.json',
      'assets/config/mount_plain_and_palm.json',
      // İşaretler
      'assets/config/ring_venus.json',
      'assets/config/signs_general.json',
      'assets/config/sign_triangle.json',
    ],
  };

  /// Belirli bir kategori için dosya yollarını döndür
  static List<String> getFilesForCategory(AnalysisCategory category) {
    return List.unmodifiable(_categoryFileMap[category] ?? []);
  }

  /// Tüm benzersiz dosya yollarını döndür
  static Set<String> getAllUniqueFiles() {
    final allFiles = <String>{};
    for (final files in _categoryFileMap.values) {
      allFiles.addAll(files);
    }
    return allFiles;
  }

  /// Bir dosyanın hangi kategorilerde kullanıldığını bul
  static List<AnalysisCategory> getCategoriesUsingFile(String filePath) {
    final categories = <AnalysisCategory>[];
    for (final entry in _categoryFileMap.entries) {
      if (entry.value.contains(filePath)) {
        categories.add(entry.key);
      }
    }
    return categories;
  }

  /// Kategorinin tahmini soru sayısını hesapla
  static int getEstimatedQuestionCount(AnalysisCategory category) {
    final files = getFilesForCategory(category);
    // Ortalama her dosyada 3 soru var
    return files.length * 3;
  }

  /// Kategori için AI prompt'unda kullanılacak odak alanını döndür
  static String getAIFocusPrompt(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.loveGeneral:
        return 'Duygusal Zeka ve İlişki Dinamiği üzerine detaylı analiz: 1. Bağlanma Stili (Kalp Çizgisi tipi - Mantıksal mı Tutkulu mu?), 2. Duygusal İfade Biçimi (Merkür Parmağı ve Kalp Çizgisi derinliği), 3. İki elin uyumu ve genel duygusal kapasite.';
      case AnalysisCategory.marriage:
        return 'Evlilik ve Uzun Süreli İlişkiler: 1. İlişki Sürdürülebilirliği (Evlilik çizgilerinin yapısı, sayısı ve derinliği), 2. Eş Potansiyeli ve Zamanlama, 3. Sadakat ve Bağlılık işaretleri.';
      case AnalysisCategory.children:
        return 'Aile ve Çocuk Potansiyeli: 1. Doğurganlık ve ebeveynlik kapasitesi, 2. Çocuk çizgileri (sayı, cinsiyet, sağlık), 3. Aile bağları kuvveti.';
      case AnalysisCategory.passion:
        return 'Tutku ve Dürtü Kontrolü: 1. Sadakat ve Dürtü Kontrolü (Venüs Tepesi dolgunluğu ve Başparmak irade açısı), 2. Cinsel Enerji ve Çekicilik (Venüs Kuşağı), 3. Yasak zevklere eğilim.';
      case AnalysisCategory.wealth:
        return 'Finansal Potansiyel ve Risk Yönetimi: 1. Ticari Zeka ve Girişimcilik (Merkür ve Akıl Çizgisi), 2. Risk Algısı ve Yatırımcı Profili (Güneş Parmağı ve El yapısı), 3. Tasarruf ve Birikim Kabiliyeti (Başparmak ve El kapalılık), 4. Maddi Şans (Avuç içi üçgenler ve Güneş çizgisi).';
      case AnalysisCategory.career:
        return 'Kariyer Yatkınlığı ve Liderlik: 1. Yönetim ve Otorite Potansiyeli (Jüpiter Tepesi ve İşaret Parmağı), 2. Çalışma Disiplini ve Odaklanma (Satürn Tepesi ve Kader Çizgisi), 3. Yaratıcılık ve İnovasyon Kapasitesi (Güneş Tepesi), 4. Uygun Çalışma Ortamı (Sanat, Ticaret, Hizmet?).';
      case AnalysisCategory.fame:
        return 'Şöhret ve Toplumsal Statü: 1. Tanınırlık İşaretleri (Güneş Çizgisi kalitesi ve uzunluğu), 2. Toplumsal Etki Gücü, 3. Başarı ve Ödül potansiyeli.';
      case AnalysisCategory.danger:
        return 'Riskler ve Uyarılar: 1. Hayatın zorlu dönemleri (Çizgilerdeki kesintiler, adacıklar), 2. Gizli Düşmanlar ve Engeller, 3. Sağlık ve Kaza riskleri.';
      case AnalysisCategory.mystic:
        return 'Sezgisel Kapasite ve Ruhsal Derinlik: 1. İçgörü ve 6. His (Süleyman Halkası ve Mistik Haç), 2. İnsan Sarraflığı (Merkür ve Jüpiter parmakları), 3. Empati Yeteneği ve Ruhsal Hassasiyet (Venüs Kuşağı), 4. Okült yetenekler.';
      case AnalysisCategory.travel:
        return 'Göç ve Adaptasyon Yeteneği: 1. Değişime Uyum Sağlama (Hayat Çizgisi sonlanma biçimi), 2. Keşif ve Macera Arzusu (Ay Tepesi üzerindeki seyahat çizgileri), 3. Köklenme ve Aidiyet İhtiyacı (Kader Çizgisi başlangıcı).';
      case AnalysisCategory.health:
        return 'Yaşam Enerjisi ve Biyolojik Direnç: 1. Fiziksel Vitalite / Pil Ömrü (Hayat Çizgisi kalitesi ve derinliği), 2. Stres Toleransı (Tırnak yapısı ve Akıl Çizgisi), 3. Sinir Sistemi Direnci (El üzerindeki ince çizgiler ve ağlar).';
      case AnalysisCategory.character:
        return 'Karakter ve Zihinsel Yapı: 1. Analitik vs Sezgisel Düşünce, 2. İrade Gücü ve Kararlılık, 3. Sosyal Yetenekler ve İletişim, 4. Genel Mizaç (Melankolik, Kolerik, Sangvinik, Flegmatik).';
      case AnalysisCategory.full:
        return 'DETAYLI TAM ANALİZ: 1. Finansal Potansiyel (Ticari Zeka, Risk, Birikim), 2. Duygusal Zeka (Bağlanma, Sadakat, İfade), 3. Kariyer ve Liderlik (Yönetim, Disiplin, Yaratıcılık), 4. Yaşam Enerjisi (Vitalite, Stres Toleransı), 5. Sezgisel Kapasite (6. His, Empati), 6. Göç ve Adaptasyon.';
    }
  }

  /// Popüler/öne çıkan kategorileri döndür
  static List<AnalysisCategory> getFeaturedCategories() {
    return [
      AnalysisCategory.marriage,
      AnalysisCategory.wealth,
      AnalysisCategory.career,
      AnalysisCategory.health,
    ];
  }

  /// Hızlı analiz kategorilerini döndür (kısa sürenler)
  static List<AnalysisCategory> getQuickAnalysisCategories() {
    return [
      AnalysisCategory.children,
      AnalysisCategory.travel,
      AnalysisCategory.loveGeneral,
    ];
  }
}
