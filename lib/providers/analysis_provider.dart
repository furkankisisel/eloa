import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../services/gemini_service.dart';
import '../models/analysis_category.dart';
import '../models/analysis_data_manager.dart';

/// AnalysisProvider uygulama durumunu yönetir.
/// Senaryo bazlı analiz sistemi ile çalışır.
class AnalysisProvider extends ChangeNotifier {
  int? _selectedHandIndex; // 0 = Sol, 1 = Sağ
  AnalysisCategory? _selectedCategory;

  // AI Commentary - Groq API
  static const String _apiKey =
      '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';
  late final GeminiService _geminiService;
  String? _aiCommentary;
  bool _isLoadingAI = false;
  String? _aiError;

  AnalysisProvider() {
    _geminiService = GeminiService(_apiKey);
  }

  // Module management for sequential analysis
  List<String> _modulePaths = [];
  int _currentModuleIndex = 0;

  // Questions loaded from the current module
  List<Map<String, dynamic>> _questions = [];

  // Accumulated results across modules
  final List<Map<String, dynamic>> _accumulatedResults = [];
  // Track selected option per question id for current module
  final Map<dynamic, Map<String, dynamic>> _selectedOptions = {};

  bool _isAnalysisCompleted = false;

  int? get selectedHandIndex => _selectedHandIndex;
  bool get hasSelection => _selectedHandIndex != null;
  AnalysisCategory? get selectedCategory => _selectedCategory;

  String get selectedHandLabel {
    if (_selectedHandIndex == null) return 'Seçilmedi';
    return _selectedHandIndex == 0 ? 'Sol (Potansiyel)' : 'Sağ (Aktif)';
  }

  String get selectedCategoryLabel {
    return _selectedCategory?.questionTitle ?? 'Seçilmedi';
  }

  /// AI promptu için kategori odak alanı
  String get categoryFocusPrompt {
    return _selectedCategory != null
        ? AnalysisDataManager.getAIFocusPrompt(_selectedCategory!)
        : 'genel el analizi';
  }

  List<Map<String, dynamic>> get questions => _questions;
  List<Map<String, dynamic>> get accumulatedResults => _accumulatedResults;
  int get currentModuleIndex => _currentModuleIndex;
  int get totalModules => _modulePaths.length;
  bool get isAnalysisCompleted => _isAnalysisCompleted;
  Map<dynamic, Map<String, dynamic>> get selectedOptions => _selectedOptions;

  // AI getters
  String? get aiCommentary => _aiCommentary;
  bool get isLoadingAI => _isLoadingAI;
  String? get aiError => _aiError;

  /// El tipi string olarak (kamera ekranı için)
  String get selectedHandType {
    if (_selectedHandIndex == null) return 'Sağ';
    return _selectedHandIndex == 0 ? 'Sol' : 'Sağ';
  }

  void selectHand(int index) {
    if (index != _selectedHandIndex) {
      _selectedHandIndex = index;
      notifyListeners();
    }
  }

  /// String bazlı el seçimi (hand_selection_screen için uyumluluk)
  void setHand(String handType) {
    if (handType.contains('Sol')) {
      _selectedHandIndex = 0;
    } else {
      _selectedHandIndex = 1;
    }
    notifyListeners();
  }

  /// Sadece kategori seçimi (el seçimi sonraya bırakılıyor)
  void selectCategory(AnalysisCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Seçilen kategori ile analizi başlat (el seçimi yapıldıktan sonra çağrılır)
  Future<void> startAnalysisWithSelectedCategory() async {
    if (_selectedCategory == null) return;
    _modulePaths =
        List.from(AnalysisDataManager.getFilesForCategory(_selectedCategory!));
    _currentModuleIndex = 0;
    _accumulatedResults.clear();
    _selectedOptions.clear();
    _isAnalysisCompleted = false;
    _aiCommentary = null;
    _aiError = null;
    await loadNextModule();
  }

  /// Seçilen kategoriye göre analizi başlat ve modülleri yükle
  Future<void> startAnalysis(AnalysisCategory category) async {
    _selectedCategory = category;
    _modulePaths = List.from(AnalysisDataManager.getFilesForCategory(category));
    _currentModuleIndex = 0;
    _accumulatedResults.clear();
    _selectedOptions.clear();
    _isAnalysisCompleted = false;
    _aiCommentary = null;
    _aiError = null;
    await loadNextModule();
  }

  /// Loads the next analysis module JSON and updates the questions list.
  /// Returns true if a module was loaded, false if there are no more modules.
  Future<bool> loadNextModule() async {
    if (_currentModuleIndex >= _modulePaths.length) {
      _isAnalysisCompleted = true;
      notifyListeners();
      return false;
    }

    final path = _modulePaths[_currentModuleIndex];
    try {
      final jsonStr = await rootBundle.loadString(path);
      final dynamic data = json.decode(jsonStr);

      // Expecting questions under key 'questions'. Fallback: if array provided directly.
      if (data is Map<String, dynamic>) {
        final List<dynamic> q = (data['questions'] as List<dynamic>? ?? []);
        _questions =
            q.whereType<Map<String, dynamic>>().toList(growable: false);
      } else if (data is List) {
        _questions =
            data.whereType<Map<String, dynamic>>().toList(growable: false);
      } else {
        _questions = [];
      }

      notifyListeners();
      return true;
    } catch (e) {
      // If load fails, keep questions empty but proceed gracefully.
      _questions = [];
      notifyListeners();
      return false;
    }
  }

  /// Call when a module's questions are completed to accumulate its result and advance.
  /// The `moduleResult` should contain at least an 'analysis_result' field.
  Future<void> accumulateResults(Map<String, dynamic> moduleResult) async {
    // Normalize structure to ensure 'analysis_result' key exists.
    final normalized = <String, dynamic>{
      'moduleIndex': _currentModuleIndex,
      'analysis_result': moduleResult['analysis_result'] ?? moduleResult,
    };
    _accumulatedResults.add(normalized);

    // Advance to next module
    _currentModuleIndex++;
    _selectedOptions.clear();

    // If we've completed all modules, mark completion and clear questions.
    if (_currentModuleIndex >= _modulePaths.length) {
      _isAnalysisCompleted = true;
      _questions = [];
      notifyListeners();
      return;
    }

    // Otherwise load the next module
    await loadNextModule();
  }

  /// Select an option for a given question. `question` is the map from questions list, `option` is one of its option maps.
  void selectOption(
      Map<String, dynamic> question, Map<String, dynamic> option) {
    final qid = question['id'];
    _selectedOptions[qid] = option;
    notifyListeners();
  }

  /// Soruyu boş geç - analiz sonuçlarına dahil edilmeyecek
  void skipQuestion(Map<String, dynamic> question) {
    final qid = question['id'];
    _selectedOptions[qid] = {
      'isSkipped': true,
      'label': 'Boş Geçildi',
    };
    notifyListeners();
  }

  /// Resets the analysis flow (e.g., starting over or switching hand).
  Future<void> resetAnalysis() async {
    _currentModuleIndex = 0;
    _accumulatedResults.clear();
    _selectedOptions.clear();
    _isAnalysisCompleted = false;
    _aiCommentary = null;
    _isLoadingAI = false;
    _aiError = null;
    if (_modulePaths.isNotEmpty) {
      await loadNextModule();
    }
  }

  /// Tüm durumu sıfırla (yeni analiz için)
  void resetAll() {
    _selectedHandIndex = null;
    _selectedCategory = null;
    _modulePaths = [];
    _currentModuleIndex = 0;
    _questions = [];
    _accumulatedResults.clear();
    _selectedOptions.clear();
    _isAnalysisCompleted = false;
    _aiCommentary = null;
    _isLoadingAI = false;
    _aiError = null;
    notifyListeners();
  }

  /// Gemini AI'dan kişilik analizi yorumu al
  Future<void> generateAiCommentary() async {
    if (_accumulatedResults.isEmpty) {
      _aiError = 'Analiz sonuçları bulunamadı.';
      notifyListeners();
      return;
    }

    _isLoadingAI = true;
    _aiError = null;
    notifyListeners();

    try {
      // Birikmiş sonuçlardan ham metin listesi oluştur
      final List<String> rawResults = [];
      for (final module in _accumulatedResults) {
        final selections = module['selections'] as List<dynamic>? ?? [];
        for (final sel in selections) {
          if (sel is Map) {
            final category = sel['category']?.toString() ?? '';
            final label = sel['label']?.toString() ?? '';
            final analysisResult = sel['analysis_result']?.toString() ?? '';
            if (analysisResult.isNotEmpty) {
              rawResults.add('$category - $label: $analysisResult');
            }
          }
        }
      }

      final commentary = await _geminiService.generatePersonalityAnalysis(
        analysisResults: rawResults,
        handType: selectedHandLabel,
        categoryType: selectedCategoryLabel,
      );
      _aiCommentary = commentary;
      _aiError = null;
    } catch (e) {
      _aiError = 'Yapay zeka yorumu alınamadı: ${e.toString()}';
      _aiCommentary = null;
    } finally {
      _isLoadingAI = false;
      notifyListeners();
    }
  }
}
