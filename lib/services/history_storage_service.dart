import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_history.dart';

/// Geçmiş analizleri SharedPreferences'de saklayan servis
class HistoryStorageService {
  static const String _historyKey = 'eloa_analysis_history';
  static const int _maxHistoryItems = 50; // Maksimum kayıt sayısı

  static HistoryStorageService? _instance;

  HistoryStorageService._();

  static HistoryStorageService get instance {
    _instance ??= HistoryStorageService._();
    return _instance!;
  }

  /// Tüm geçmiş analizleri yükle
  Future<List<AnalysisHistory>> loadAllAnalyses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      final histories = <AnalysisHistory>[];
      for (final json in historyJson) {
        try {
          histories.add(AnalysisHistory.decode(json));
        } catch (e) {
          // Hatalı veriyi atla
          continue;
        }
      }

      // En yeniden en eskiye sırala
      histories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return histories;
    } catch (e) {
      return [];
    }
  }

  /// Yeni analizi kaydet
  Future<bool> saveAnalysis(AnalysisHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_historyKey) ?? [];

      // Yeni analizi başa ekle
      final encoded = history.encode();
      existing.insert(0, encoded);

      // Maksimum kayıt sayısını aşmamak için eski kayıtları sil
      while (existing.length > _maxHistoryItems) {
        existing.removeLast();
      }

      return await prefs.setStringList(_historyKey, existing);
    } catch (e) {
      return false;
    }
  }

  /// Belirli bir analizi sil
  Future<bool> deleteAnalysis(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_historyKey) ?? [];

      final updated = existing.where((json) {
        try {
          final history = AnalysisHistory.decode(json);
          return history.id != id;
        } catch (e) {
          return false; // Hatalı veriyi de sil
        }
      }).toList();

      return await prefs.setStringList(_historyKey, updated);
    } catch (e) {
      return false;
    }
  }

  /// Belirli bir analizi ID ile getir
  Future<AnalysisHistory?> getAnalysisById(String id) async {
    try {
      final histories = await loadAllAnalyses();
      return histories.firstWhere(
        (h) => h.id == id,
        orElse: () => throw Exception('Not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Tüm geçmişi temizle
  Future<bool> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_historyKey);
    } catch (e) {
      return false;
    }
  }

  /// Toplam kayıt sayısı
  Future<int> getHistoryCount() async {
    final histories = await loadAllAnalyses();
    return histories.length;
  }

  /// Kategoriye göre filtrele
  Future<List<AnalysisHistory>> getAnalysesByCategory(String categoryId) async {
    final histories = await loadAllAnalyses();
    return histories.where((h) => h.categoryId == categoryId).toList();
  }

  /// Son N analizi getir
  Future<List<AnalysisHistory>> getRecentAnalyses({int limit = 5}) async {
    final histories = await loadAllAnalyses();
    return histories.take(limit).toList();
  }

  /// Analizi güncelle (örn: AI yorumu ekle)
  Future<bool> updateAnalysis(AnalysisHistory updated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_historyKey) ?? [];

      final updatedList = existing.map((json) {
        try {
          final history = AnalysisHistory.decode(json);
          if (history.id == updated.id) {
            return updated.encode();
          }
          return json;
        } catch (e) {
          return json;
        }
      }).toList();

      return await prefs.setStringList(_historyKey, updatedList);
    } catch (e) {
      return false;
    }
  }
}
