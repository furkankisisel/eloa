import 'analysis_data_manager.dart';

/// Senaryo bazlı analiz kategorileri
/// Her biri kullanıcının sorabileceği spesifik bir soruya karşılık gelir
enum AnalysisCategory {
  // --- AŞK VE İLİŞKİLER ---
  loveGeneral, // Aşk Hayatım Nasıl Geçecek?
  marriage, // Ne Zaman Evleneceğim?
  children, // Çocuğum Olacak mı?
  passion, // Tutkular ve Cinsellik

  // --- ZENGİNLİK VE KARİYER ---
  wealth, // Zengin Olacak mıyım?
  career, // Kariyer ve İş Hayatım
  fame, // Şöhret ve Başarı

  // --- GİZEM VE TEHLİKE ---
  danger, // Gizli Düşmanlar ve Tehlikeler
  mystic, // Mistik Yetenekler ve 6. His
  travel, // Seyahat ve Yurt Dışı

  // --- SAĞLIK VE KARAKTER ---
  health, // Sağlık ve Ömür
  character, // Karakter ve Zeka

  // --- TAM ANALİZ ---
  full // Tüm Detaylı Analiz
}

/// AnalysisCategory için extension metodları
extension AnalysisCategoryExtension on AnalysisCategory {
  /// Kullanıcıya gösterilecek soru başlığı
  String get questionTitle {
    switch (this) {
      case AnalysisCategory.loveGeneral:
        return 'Aşk Hayatım Nasıl Geçecek?';
      case AnalysisCategory.marriage:
        return 'Ne Zaman Evleneceğim?';
      case AnalysisCategory.children:
        return 'Çocuğum Olacak mı?';
      case AnalysisCategory.passion:
        return 'Tutkularım ve Çekiciliğim';
      case AnalysisCategory.wealth:
        return 'Zengin Olacak mıyım?';
      case AnalysisCategory.career:
        return 'Kariyerim Nasıl Şekillenecek?';
      case AnalysisCategory.fame:
        return 'Şöhret ve Başarı Beni Bekliyor mu?';
      case AnalysisCategory.danger:
        return 'Gizli Düşmanlar ve Tehlikeler';
      case AnalysisCategory.mystic:
        return 'Mistik Yeteneklerim Var mı?';
      case AnalysisCategory.travel:
        return 'Yurt Dışı ve Seyahat Şansım';
      case AnalysisCategory.health:
        return 'Sağlığım ve Ömrüm';
      case AnalysisCategory.character:
        return 'Karakterim ve Zekam';
      case AnalysisCategory.full:
        return 'Detaylı Tam Analiz';
    }
  }

  /// Kısa açıklama
  String get subtitle {
    switch (this) {
      case AnalysisCategory.loveGeneral:
        return 'Kalp çizgisi ve Venüs tepesi analizi';
      case AnalysisCategory.marriage:
        return 'Evlilik çizgisi ve zamanlaması';
      case AnalysisCategory.children:
        return 'Çocuk çizgileri ve aile potansiyeli';
      case AnalysisCategory.passion:
        return 'Venüs halkası ve tutku işaretleri';
      case AnalysisCategory.wealth:
        return 'Para üçgeni ve zenginlik işaretleri';
      case AnalysisCategory.career:
        return 'Kader çizgisi ve iş hayatı';
      case AnalysisCategory.fame:
        return 'Güneş çizgisi ve başarı potansiyeli';
      case AnalysisCategory.danger:
        return 'Engel çizgileri ve düşman işaretleri';
      case AnalysisCategory.mystic:
        return 'Sezgi çizgisi ve mistik işaretler';
      case AnalysisCategory.travel:
        return 'Seyahat çizgileri ve göç potansiyeli';
      case AnalysisCategory.health:
        return 'Hayat çizgisi ve sağlık göstergeleri';
      case AnalysisCategory.character:
        return 'El şekli ve zihinsel yapı';
      case AnalysisCategory.full:
        return 'Tüm çizgiler, tepeler ve işaretler';
    }
  }

  /// Kategori ikonu
  String get iconName {
    switch (this) {
      case AnalysisCategory.loveGeneral:
        return 'favorite';
      case AnalysisCategory.marriage:
        return 'diamond';
      case AnalysisCategory.children:
        return 'child_care';
      case AnalysisCategory.passion:
        return 'local_fire_department';
      case AnalysisCategory.wealth:
        return 'monetization_on';
      case AnalysisCategory.career:
        return 'work';
      case AnalysisCategory.fame:
        return 'star';
      case AnalysisCategory.danger:
        return 'warning';
      case AnalysisCategory.mystic:
        return 'visibility';
      case AnalysisCategory.travel:
        return 'flight';
      case AnalysisCategory.health:
        return 'health_and_safety';
      case AnalysisCategory.character:
        return 'psychology';
      case AnalysisCategory.full:
        return 'auto_awesome';
    }
  }

  /// Tahmini analiz süresi (dakika)
  int get estimatedMinutes {
    switch (this) {
      case AnalysisCategory.children:
      case AnalysisCategory.travel:
        return 1;
      case AnalysisCategory.loveGeneral:
      case AnalysisCategory.marriage:
      case AnalysisCategory.passion:
        return 2;
      case AnalysisCategory.wealth:
      case AnalysisCategory.career:
      case AnalysisCategory.fame:
      case AnalysisCategory.danger:
      case AnalysisCategory.mystic:
        return 3;
      case AnalysisCategory.health:
      case AnalysisCategory.character:
        return 4;
      case AnalysisCategory.full:
        return 15;
    }
  }

  /// Soru sayısı (yaklaşık)
  int get questionCount {
    return AnalysisDataManager.getFilesForCategory(this).length *
        3; // Ortalama 3 soru/dosya
  }
}
