import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../../models/palmistry/palmistry_data.dart';
import '../../../models/palmistry/palmistry_app_data.dart';
import '../../../models/palmistry/palmistry_ethics.dart';
import '../../../services/palmistry_service.dart';
import '../../../services/ai_analysis_service.dart';

class PalmistryProvider extends ChangeNotifier {
  final PalmistryService _service = PalmistryService();

  List<PalmistryTopic> _topics = [];
  ManualQuestionsData? _manualQuestions;

  // New Data
  AppCategoryMap? _appCategoryMap;
  ReadingRulesData? _readingRules;

  EthicsData? _ethicsData;
  PalmistrySynthesisData? _synthesisData; // Loaded from File 35

  bool _isLoading = false;
  bool _hasAcceptedDisclaimer = false;

  // Stores selected features: Map<SectionID, PalmistryFeature>
  // We use SectionID as key assuming they are unique across topics.
  // If not, we should compound key "TopicID_SectionID".
  // Looking at data, "hand_shapes", "life_line_general" seem unique enough but "starting_point" might repeat?
  // "starting_point" appears in Life Line. Might also appear in Head Line?
  // To be safe, let's use a nested map or compound key.
  final Map<String, Map<String, PalmistryFeature>> _selectedFeatures = {};

  // Storage for user uploaded images (File 10 requirement)
  final List<XFile> _selectedImages = [];

  // Stores manual answers: Map<QuestionID, PalmistryOption>
  final Map<String, PalmistryOption> _manualAnswers = {};

  List<PalmistryTopic> get topics => _topics;
  ManualQuestionsData? get manualQuestions => _manualQuestions;

  // New Getters
  List<AppCategory> get appCategories => _appCategoryMap?.appCategories ?? [];
  ReadingRulesData? get readingRules => _readingRules;
  EthicsData? get ethicsData => _ethicsData;

  bool get isLoading => _isLoading;
  bool get hasAcceptedDisclaimer => _hasAcceptedDisclaimer;

  void acceptDisclaimer() {
    _hasAcceptedDisclaimer = true;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _service.getAllTopics(),
        _service.getManualQuestions(),
        _service.getAppCategoryMap(),
        _service.getReadingRules(),
        _service.getEthicsData(),
        _service.getSynthesisData(),
      ]);

      _topics = results[0] as List<PalmistryTopic>;
      _manualQuestions = results[1] as ManualQuestionsData?;
      _appCategoryMap = results[2] as AppCategoryMap?;
      _readingRules = results[3] as ReadingRulesData?;
      _ethicsData = results[4] as EthicsData?;
      _synthesisData = results[5] as PalmistrySynthesisData?;
    } catch (e) {
      debugPrint('Error in provider loadData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper to find a specific topic by its source filename (from config)
  /// key: "23_kader_cizgisi.json" -> matches topic id "23_kader_cizgisi"
  PalmistryTopic? getTopicBySource(String sourceJson) {
    final id = sourceJson.replaceAll('.json', '');
    try {
      return _topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Helper to find specific manual questions required by a category
  /// Now collects from all subcategories
  List<PalmistryQuestion> getQuestionsForCategory(AppCategory category) {
    if (_manualQuestions == null) return [];

    final allQs = [
      ..._manualQuestions!.tactileQuestions,
      ..._manualQuestions!.flexibilityQuestions,
      ..._manualQuestions!.colorConfirmationQuestions,
    ];

    List<PalmistryQuestion> result = [];
    Set<String> addedQuestionIds = {}; // Prevent duplicates

    for (var subCategory in category.subcategories) {
      for (var input in subCategory.requiredData.manualInputs) {
        try {
          if (!addedQuestionIds.contains(input.questionType)) {
            final q =
                allQs.firstWhere((q) => q.questionId == input.questionType);
            result.add(q);
            addedQuestionIds.add(input.questionType);
          }
        } catch (_) {
          // Question not found
        }
      }
    }

    return result;
  }

  /// Helper to find specific manual questions required by a subcategory
  List<PalmistryQuestion> getQuestionsForSubCategory(SubCategory subCategory) {
    if (_manualQuestions == null) return [];

    final allQs = [
      ..._manualQuestions!.tactileQuestions,
      ..._manualQuestions!.flexibilityQuestions,
      ..._manualQuestions!.colorConfirmationQuestions,
    ];

    List<PalmistryQuestion> result = [];

    for (var input in subCategory.requiredData.manualInputs) {
      try {
        final q = allQs.firstWhere((q) => q.questionId == input.questionType);
        result.add(q);
      } catch (_) {
        // Question not found
      }
    }

    return result;
  }

  /// Helper to get a specific disclaimer by ID
  Disclaimer? getDisclaimer(String id) {
    try {
      return _ethicsData?.disclaimers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  void selectFeature(
      String topicId, String sectionId, PalmistryFeature feature) {
    if (!_selectedFeatures.containsKey(topicId)) {
      _selectedFeatures[topicId] = {};
    }
    _selectedFeatures[topicId]![sectionId] = feature;
    notifyListeners();
  }

  PalmistryFeature? getSelectedFeature(String topicId, String sectionId) {
    return _selectedFeatures[topicId]?[sectionId];
  }

  void answerQuestion(String questionId, PalmistryOption option) {
    _manualAnswers[questionId] = option;
    notifyListeners();
  }

  PalmistryOption? getAnswer(String questionId) {
    return _manualAnswers[questionId];
  }

  // Image Management Methods
  List<XFile> get selectedImages => _selectedImages;

  void addImage(XFile image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  void removeImage(XFile image) {
    _selectedImages.remove(image);
    notifyListeners();
  }

  /// SENTEZ KATMANI (Synthesis Layer)
  /// Ham ID listesini alıp, hiyerarşi ve çatışma kurallarına göre analiz notları üretir.
  /// Ayrıca seçilen kategoriye göre (Token tasarrufu için) sadece ilgili kombinasyonları tarar.
  List<String> _applySynthesisLayer(List<String> rawIds, {String? categoryId}) {
    if (_synthesisData == null) return [];

    List<String> notes = [];

    // 1. HİYERARŞİ KONTROLÜ (Bu her analizde olmalı, temel mihenk taşı)
    bool hasWeakThumb =
        rawIds.contains('kisa_basparmak') || rawIds.contains('zayif_basparmak');
    bool hasLogic = rawIds.contains('duz_akil_cizgisi');

    if (hasWeakThumb) {
      notes.add(
          "ÖNEMLİ HİYERARŞİ KURALI: Kullanıcıda 'Zayıf/Kısa Başparmak' tespit edildi. Bu işaret diğer tüm yeteneklerin (sanat, iş, başarı) önünde bir engeldir (İrade Zayıflığı). Lütfen raporda diğer olumlu işaretleri yorumlarken 'Potansiyelin var ancak disiplin eksikliğin olabilir' şeklinde temkinli konuş.");
    }

    if (hasLogic) {
      notes.add(
          "ÖNEMLİ HİYERARŞİ KURALI: Kullanıcıda 'Düz Akıl Çizgisi' var. Kişi ne kadar duygusal görünürse görünsün (Kalp çizgisi vb.), son kararları Mantık verir. Romantik yorumları mantık çerçevesinde dengele.");
    }

    // 2. KATEGORİ BAZLI FİLTRELEME VE KOMBİNASYON TARAMASI
    // Token tasarrufu için her kuralı göndermiyoruz.
    // CategoryId'ye göre basit bir filtreleme yapıyoruz.

    // Varsayılan: Hepsi (Genel analiz ise)
    List<SynthesisCombination> targetCombos =
        _synthesisData!.commonCombinations;

    if (categoryId != null) {
      if (categoryId.contains('kariyer') || categoryId.contains('para')) {
        targetCombos = targetCombos
            .where((c) =>
                    c.comboId.contains('basari') ||
                    c.comboId.contains('yonetici') ||
                    c.comboId.contains('zeka') ||
                    c.comboId.contains('tembel') // Tembellik kariyerle ilgili
                )
            .toList();
      } else if (categoryId.contains('ask') || categoryId.contains('iliski')) {
        targetCombos = targetCombos
            .where((c) =>
                    c.comboId.contains('ask') ||
                    c.comboId.contains('duygu') ||
                    c.comboId.contains('mantik') // Aşk vs Mantık
                )
            .toList();
      }
      // Diğer kategoriler için varsayılan liste kalabilir veya genişletilebilir.
    }

    for (var combo in targetCombos) {
      // Eğer kullanıcının özellikleri, kuralın tüm bileşenlerini içeriyorsa
      if (combo.components.every((c) => rawIds.contains(c))) {
        notes.add(
            "SENTEZLENMİŞ ÖZEL KOMBİNASYON TESPİTİ: Bu kişide '${combo.synthesis}' durumu mevcuttur. Lütfen raporun karakter analizini bu sentez üzerine kur.");
      }
    }

    // 3. ÇATIŞMA YÖNETİMİ
    // Senaryoları manuel kontrol etmek gerekebilir çünkü JSON'da 'scenario' text olarak var.
    // Burada yaygın birkaç örneği hardcode ediyoruz ya da ID eşleşmesi yapıyoruz.

    if (rawIds.contains('genis_el_ayasi') &&
        rawIds.contains('kapali_parmaklar')) {
      final resolution = _synthesisData!.conflictResolution
          .firstWhere(
              (c) =>
                  c.conflictType.contains('Cömert') &&
                  c.conflictType.contains('Cimri'),
              orElse: () => SynthesisConflictResolution(
                  conflictType: '',
                  scenario: '',
                  resolution:
                      'Seçici cömertlik: Sevdiklerine açık, başkalarına kapalı.'))
          .resolution;
      notes.add("ÇATIŞMA ÇÖZÜMÜ: $resolution");
    }

    if (rawIds.contains('onemli_akil_cizgisi') && // Örnek ID
        (rawIds.contains('zincirli_akil_cizgisi') ||
            rawIds.contains('silik_akil_cizgisi'))) {
      // Conflict resolving logic based on synthesis data
      // Note: Specific ID checks depend on exact ID strings in DB
    }

    return notes;
  }

  /// Generates a summary string of all selected features and answers to send to AI
  String generateAnalysisPrompt({String? categoryId}) {
    // Added optional categoryId
    final buffer = StringBuffer();

    // Inject Guardrails and Persona if available
    if (_ethicsData != null) {
      buffer.writeln('SİSTEM VE PERSONA TALİMATLARI:');
      buffer.writeln('Kimlik: ${_ethicsData!.corePhilosophy.manifesto}');
      buffer.writeln(
          'YASAKLI KELİMELER: ${_ethicsData!.corePhilosophy.appIdentity.forbiddenTerms.join(", ")}');
      buffer.writeln(
          'TERCİH EDİLEN KELİMELER: ${_ethicsData!.corePhilosophy.appIdentity.preferredTerms.join(", ")}');

      buffer.writeln('\nYAPAY ZEKA KURALLARI (KESİN UYULACAK):');
      for (var rule in _ethicsData!.aiGuardrails.rules) {
        buffer.writeln('- ${rule.rule}: ${rule.instruction}');
      }
    }

    buffer.writeln('\n------------------------------------------------\n');
    buffer.writeln('Kullanıcının El Analizi Verileri:\n');

    // Add selected visual features
    _selectedFeatures.forEach((topicId, sections) {
      // Find topic name for better context
      String topicName = topicId;
      try {
        topicName =
            _topics.firstWhere((t) => t.id == topicId).categoryInfo.title;
      } catch (_) {}

      buffer.writeln('--- $topicName ---');

      sections.forEach((sectionId, feature) {
        buffer.writeln('- ${feature.name}: ${feature.bookContent}');
      });
      buffer.writeln();
    });

    // Add manual answers
    if (_manualAnswers.isNotEmpty) {
      buffer.writeln('--- Ek Bilgiler ve Hissedilen Özellikler ---');
      _manualAnswers.forEach((qId, option) {
        // Find question text if possible
        String questionText = qId;
        if (_manualQuestions != null) {
          var allQs = [
            ..._manualQuestions!.tactileQuestions,
            ..._manualQuestions!.flexibilityQuestions,
            ..._manualQuestions!.colorConfirmationQuestions
          ];
          final q = allQs.firstWhere((q) => q.questionId == qId,
              orElse: () => PalmistryQuestion(options: []));
          if (q.text.isNotEmpty) questionText = q.text;
        }

        buffer.writeln('Soru: $questionText');
        buffer.writeln('Cevap: ${option.answer}');
        if (option.implication != null) {
          buffer.writeln('Anlamı: ${option.implication}');
        }
        buffer.writeln();
      });
    }

    // --- SENTEZ VE AKILLI ANALİZ ---
    // Ham verileri topla
    final List<String> rawIds = [];
    _selectedFeatures.values.forEach((sections) {
      sections.values.forEach((feature) {
        if (feature.id.isNotEmpty) rawIds.add(feature.id);
      });
    });
    _manualAnswers.values.forEach((option) {
      if (option.jsonId != null && option.jsonId!.isNotEmpty) {
        rawIds.add(option.jsonId!);
      }
    });

    // Sentez Katmanını Çalıştır (Kategori filtresi ile)
    final synthesisNotes = _applySynthesisLayer(rawIds, categoryId: categoryId);

    if (synthesisNotes.isNotEmpty) {
      buffer.writeln(
          '\nKRİTİK ANALİZ VE SENTEZ YÖNERGELERİ (BUNLARA ÖNCELİK VER):');
      for (var note in synthesisNotes) {
        buffer.writeln('- $note');
      }
      buffer.writeln('\n------------------------------------------------\n');
    }

    return buffer.toString();
  }

  /// Loads JSON files specific to the selected subcategory (COMPRESSED for token optimization)
  Future<String> _loadSubCategoryJsonContext(SubCategory subCategory) async {
    final StringBuffer contextBuffer = StringBuffer();
    final Set<String> sourceJsonFiles = {};

    // Collect all source JSON files from visual and manual inputs
    for (var input in subCategory.requiredData.visualInputs) {
      sourceJsonFiles.add(input.sourceJson);
    }
    for (var input in subCategory.requiredData.manualInputs) {
      sourceJsonFiles.add(input.sourceJson);
    }

    contextBuffer
        .writeln('=== SEÇILEN KATEGORI: ${subCategory.displayTitle} ===');
    contextBuffer.writeln('Açıklama: ${subCategory.description}\n');
    contextBuffer.writeln(
        '=== SIKIŞTIRMLI VERİ TABANI (Format: ID | İsim | Özellikler) ===\n');

    for (final fileName in sourceJsonFiles) {
      try {
        final path = 'assets/data/$fileName';
        final jsonString = await rootBundle.loadString(path);
        final cleanFileName = fileName.replaceAll('.json', '');

        // Sıkıştırılmış format kullan
        final compressed = _compressJsonForContext(jsonString, cleanFileName);
        contextBuffer.writeln(compressed);
      } catch (e) {
        debugPrint('JSON yüklenemedi: $fileName - $e');
        continue;
      }
    }

    return contextBuffer.toString();
  }

  /// JSON içeriğini sıkıştırır - sadece ID, isim ve kısa açıklama çıkarır
  String _compressJsonForContext(String jsonString, String fileName) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      final StringBuffer buffer = StringBuffer();

      // Kategori başlığı
      final categoryInfo = data['category_info'];
      buffer.writeln('### ${categoryInfo?['title'] ?? fileName}');

      // Farklı JSON yapılarını destekle
      _compressItems(data, buffer, 'hand_shapes');
      _compressItems(data, buffer, 'features');
      _compressItems(data, buffer, 'sections');
      _compressItems(data, buffer, 'options');
      _compressItems(data, buffer, 'characteristics');
      _compressItems(data, buffer, 'lines');
      _compressItems(data, buffer, 'mounts');
      _compressItems(data, buffer, 'symbols');

      // questions içindeki options
      if (data['questions'] != null) {
        for (var question in data['questions']) {
          if (question['options'] != null) {
            for (var option in question['options']) {
              final id = option['id'] ?? option['label'] ?? '';
              final name = option['name'] ?? option['label'] ?? '';
              final keywords = _shortenText(
                  option['book_content'] ?? option['analysis_result'] ?? '');
              if (id.isNotEmpty || name.isNotEmpty) {
                buffer.writeln('- $id | $name | $keywords');
              }
            }
          }
        }
      }

      buffer.writeln('');
      return buffer.toString();
    } catch (e) {
      return '### $fileName (Sıkıştırma hatası)\n';
    }
  }

  /// Belirli bir anahtar altındaki öğeleri sıkıştırır
  void _compressItems(
      Map<String, dynamic> data, StringBuffer buffer, String key) {
    if (data[key] == null) return;

    final items = data[key];
    if (items is! List) return;

    for (var item in items) {
      if (item is Map<String, dynamic>) {
        final id = item['id'] ?? '';
        final name = item['name'] ?? item['label'] ?? item['title'] ?? '';
        final content = item['book_content'] ??
            item['description'] ??
            item['content'] ??
            '';
        final keywords = _shortenText(content);

        if (id.isNotEmpty || name.isNotEmpty) {
          buffer.writeln('- $id | $name | $keywords');
        }

        // İç içe features varsa onları da işle
        if (item['features'] != null && item['features'] is List) {
          for (var feature in item['features']) {
            if (feature is Map<String, dynamic>) {
              final fId = feature['id'] ?? '';
              final fName = feature['name'] ?? '';
              final fContent =
                  feature['book_content'] ?? feature['description'] ?? '';
              buffer.writeln('  - $fId | $fName | ${_shortenText(fContent)}');
            }
          }
        }
      }
    }
  }

  /// Metni 60 karaktere kısaltır
  String _shortenText(String text) {
    if (text.isEmpty) return '';
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= 60) return cleaned;

    String truncated = cleaned.substring(0, 60);
    int lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 40) truncated = truncated.substring(0, lastSpace);
    return '$truncated...';
  }

  Future<Map<String, dynamic>?> analyzeWithAI(
      {SubCategory? subCategory}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Generate text part of the prompt
      String promptText = generateAnalysisPrompt(
        categoryId: subCategory?.subcategoryId,
      );

      // 2. Add subcategory-specific JSON context if available
      if (subCategory != null) {
        final jsonContext = await _loadSubCategoryJsonContext(subCategory);

        // Add strong category focus instruction
        final categoryFocusPrompt = '''

=== ÖNEMLİ: KATEGORI ODAĞI TALİMATI ===

KULLANICI SADECE ŞU KATEGORİ HAKKINDA BİLGİ İSTİYOR:
📌 Kategori: ${subCategory.displayTitle}
📌 Açıklama: ${subCategory.description}

KRİTİK KURALLAR:
1. ❌ DİĞER KONULARA DEĞİNME: Kullanıcı "${subCategory.displayTitle}" hakkında bilgi istedi. 
   Kariyer, aşk, sağlık gibi DİĞER kategorilerden bahsetme.
   
2. ✅ SADECE BU KATEGORİYE ODAKLAN: Analizini ve yorumunu TAMAMEN bu kategori ile sınırla.
   Örneğin:
   - Eğer kategori "Sindirim Sistemi" ise → SADECE sindirim, mide, bağırsak sağlığı hakkında yaz
   - Eğer kategori "Meslek Yatkınlığı" ise → SADECE kariyer ve meslek hakkında yaz
   - Eğer kategori "Aşk Hayatı" ise → SADECE romantik ilişkiler hakkında yaz

3. ✅ KISA VE ÖZ OL: Kullanıcı spesifik bir konu hakkında bilgi istiyor. 
   Genel el analizi yapma, sadece seçilen konuya odaklan.

4. ❌ "GENEL YORUM" YAPMA: "Genel olarak...", "Ayrıca...", "Bunun yanında..." gibi 
   ifadelerle başka konulara geçme.

ÖRNEK YANLIŞ YAKLAŞIM:
"Sindirim sisteminiz güçlü. Ayrıca kariyerinizde de başarılı olacaksınız..." ❌

ÖRNEK DOĞRU YAKLAŞIM:
"Sindirim sisteminiz güçlü. Metabolizmanız hızlı çalışıyor..." ✅

$jsonContext
''';

        promptText += categoryFocusPrompt;
      }

      // 3. Call service with images
      final resultJsonString =
          await AiAnalysisService().generatePalmistryInterpretation(
        promptText,
        images: _selectedImages,
      );

      // Check if service returned a plain text error message
      if (resultJsonString.startsWith('Görsel analiz') ||
          resultJsonString.startsWith('Detaylı yorum') ||
          resultJsonString.startsWith('API hatası')) {
        debugPrint("AI Service Error: $resultJsonString");
        return {
          'success': false,
          'reason': resultJsonString,
          'error_code': 'API_ERROR'
        };
      }

      // 4. Parse output
      String cleanJson = resultJsonString;
      if (cleanJson.contains('```json')) {
        cleanJson = cleanJson.split('```json')[1].split('```')[0].trim();
      } else if (cleanJson.contains('```')) {
        cleanJson = cleanJson.split('```')[1].split('```')[0].trim();
      }

      final Map<String, dynamic> data = json.decode(cleanJson);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      debugPrint("AI Analysis Error: $e");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearAll() {
    _selectedFeatures.clear();
    _manualAnswers.clear();
    _selectedImages.clear();
    notifyListeners();
  }
}
