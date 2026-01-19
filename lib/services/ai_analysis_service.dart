import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/analysis_category.dart';
import '../models/analysis_data_manager.dart';

/// Görsel tabanlı el analizi servisi
/// Google Gemini API kullanarak el fotoğraflarını analiz eder
class AiAnalysisService {
  static const String _apiKey = 'AIzaSyDbnTcHFYi-eexcars1zCguBtyrWxkGyAk';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _visionModel = 'gemini-2.5-flash-lite';
  static const String _textModel = 'gemini-2.5-flash-lite';

  /// El fotoğrafını analiz eder ve seçili kategoriye göre sonuçlar döndürür
  Future<AiAnalysisResult> analyzeHand({
    required File imageFile,
    required AnalysisCategory category,
    required String handType,
  }) async {
    try {
      // Step 1: JSON bağlamını yükle
      final jsonContext = await _loadJsonContext(category);

      if (jsonContext.isEmpty) {
        return AiAnalysisResult.error('Analiz verileri yüklenemedi.');
      }

      // Step 2: Görseli hazırla
      final imageBytes = await imageFile.readAsBytes();
      final mimeType = _getMimeType(imageFile.path);

      // Step 3: Prompt oluştur
      final prompt = _buildAnalysisPrompt(
        category: category,
        handType: handType,
        jsonContext: jsonContext,
      );

      // Step 4: Gemini API'ye gönder
      final response = await _sendToGeminiVision(imageBytes, mimeType, prompt);

      // Step 5: Yanıtı parse et
      return _parseResponse(response, category);
    } on SocketException {
      return AiAnalysisResult.error(
          'İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.');
    } on FormatException catch (e) {
      return AiAnalysisResult.error(
          'Analiz sonuçları işlenemedi: ${e.message}');
    } catch (e) {
      return AiAnalysisResult.error('Analiz sırasında bir hata oluştu: $e');
    }
  }

  /// Bellek üzerindeki görsel verisi ile analiz yapar (kamera için)
  Future<AiAnalysisResult> analyzeHandFromBytes({
    required Uint8List imageBytes,
    required AnalysisCategory category,
    required String handType,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      // Step 1: JSON bağlamını yükle
      final jsonContext = await _loadJsonContext(category);

      if (jsonContext.isEmpty) {
        return AiAnalysisResult.error('Analiz verileri yüklenemedi.');
      }

      // Step 2: Prompt oluştur
      final prompt = _buildAnalysisPrompt(
        category: category,
        handType: handType,
        jsonContext: jsonContext,
      );

      // Step 3: Gemini API'ye gönder
      final response = await _sendToGeminiVision(imageBytes, mimeType, prompt);

      // Step 4: Yanıtı parse et
      return _parseResponse(response, category);
    } on SocketException {
      return AiAnalysisResult.error(
          'İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.');
    } catch (e) {
      return AiAnalysisResult.error('Analiz sırasında bir hata oluştu: $e');
    }
  }

  /// Seçili kategoriye ait JSON dosyalarını yükler ve birleştirir
  Future<String> _loadJsonContext(AnalysisCategory category) async {
    final filePaths = AnalysisDataManager.getFilesForCategory(category);
    final StringBuffer contextBuffer = StringBuffer();

    contextBuffer.writeln('=== EL OKUMA KURALLARI VE REFERANS VERİLERİ ===\n');

    for (final path in filePaths) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final fileName = path.split('/').last.replaceAll('.json', '');

        contextBuffer.writeln('--- $fileName ---');
        contextBuffer.writeln(jsonString);
        contextBuffer.writeln('\n');
      } catch (e) {
        // Dosya yüklenemezse devam et
        continue;
      }
    }

    return contextBuffer.toString();
  }

  /// Analiz prompt'unu oluşturur
  String _buildAnalysisPrompt({
    required AnalysisCategory category,
    required String handType,
    required String jsonContext,
  }) {
    final categoryFocus = AnalysisDataManager.getAIFocusPrompt(category);

    return '''
SEN KADİM BİLGİLERE HAKİM, SON DERECE DİKKATLİ VE YARATICI BİR EL OKUYUCUSUSUN (PALMİST).

GÖREV:
Ekteki $handType el fotoğrafını analiz et.
Analiz odağı: $categoryFocus

REFERANS VERİLERİ (KRİTİK ÖNEMDE):
Aşağıdaki JSON verileri, el okuma kurallarını ve olası seçenekleri içerir.
BU REFERANS LİSTESİNDEKİ EN KÜÇÜK DETAYI BİLE ATLAMA. EĞER FOTOĞRAFTA VARSA, MUTLAKA TESPİT ET.
Standart kalıpların dışına çık, görseldeki İNCE VE BENZERSİZ detayları (küçük adacıklar, zincirlenmeler, çatallanmalar, benler, lekeler) özellikle ara.

$jsonContext

TALİMATLAR:
1. **GÖRÜNTÜ KALİTESİ KONTROLÜ (İLK ADIM):**
   - Fotoğraf net mi?
   - Elin avuç içi çizgileri okunabiliyor mu?
   - Işık yeterli mi?
   - Eğer fotoğraf bulanıksa, karanlıksa veya el yoksa: "image_quality": "poor" ve "hand_detected": false döndür.

2. **DETAYLI ANALİZ:**
   - Her JSON sorusu için, görsele en uygun seçeneği bul.
   - Sadece belirgin çizgileri değil, silik veya ince çizgileri de fark et.
   - "unique_features" alanına, bu ele özgü en az 3 belirgin görsel detay yaz (Örn: "Akıl çizgisinin sonunda belirgin çatal", "Jüpiter tepesinde yıldız işareti", "Hayat çizgisi üzerinde derin bir ada").

3. **YORUMLAMA TARZI:**
   - Seçenekleri belirlerken "ortalama" veya "bilinmiyor" demekten kaçın. Gördüğün en ufak detayı değerlendir.
   - Analizinde cesur ol.

ÇIKTI FORMATI:
Yanıtını SADECE aşağıdaki JSON formatında ver. Başka açıklama ekleme.

{
  "success": true,
  "image_quality": "good|fair|poor",
  "quality_reason": "Eğer poor ise nedeni (karanlık, bulanık vb)",
  "hand_detected": true,
  "unique_features": ["Detay 1", "Detay 2", "Detay 3"],
  "matches": [
    {
      "question_id": "referans_json_id",
      "category": "Soru kategorisi",
      "question_text": "Soru metni",
      "matched_option": {
        "label": "Seçilen seçenek etiketi",
        "description": "Seçenek açıklaması",
        "analysis_result": "Analiz sonucu",
        "confidence": "high|medium|low"
      },
      "visual_evidence": "Bu sonuca varmamı sağlayan görsel detay (Örn: Çizgi serçe parmağın altında kavisleniyor)"
    }
  ],
  "notes": "Genel gözlemler"
}

ÖNEMLİ:
- Sadece JSON döndür.
- Kötü görüntü gelirse acımasız ol, "poor" olarak işaretle.
- İyi görüntüde ise en ince detayı bile kaçırma.
''';
  }

  /// Birden fazla fotoğrafı analiz eder (daha detaylı sonuç için)
  Future<AiAnalysisResult> analyzeMultipleImages({
    required List<File> imageFiles,
    required AnalysisCategory category,
    required String handType,
  }) async {
    if (imageFiles.isEmpty) {
      return AiAnalysisResult.error('Analiz için fotoğraf bulunamadı.');
    }

    try {
      // Step 1: JSON bağlamını yükle
      final jsonContext = await _loadJsonContext(category);

      if (jsonContext.isEmpty) {
        return AiAnalysisResult.error('Analiz verileri yüklenemedi.');
      }

      // Step 2: Tüm görselleri hazırla
      final List<Map<String, dynamic>> imageContents = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final imageBytes = await imageFiles[i].readAsBytes();
        final mimeType = _getMimeType(imageFiles[i].path);
        final base64Image = base64Encode(imageBytes);

        // Gemini format: inline_data
        imageContents.add({
          'inline_data': {
            'mime_type': mimeType,
            'data': base64Image,
          },
        });
      }

      // Step 3: Çoklu fotoğraf için özel prompt
      final prompt = _buildMultiImagePrompt(
        category: category,
        handType: handType,
        jsonContext: jsonContext,
        imageCount: imageFiles.length,
      );

      // Step 4: Gemini API'ye çoklu görsel gönder
      final response = await _sendMultipleImagesToGemini(imageContents, prompt);

      // Step 5: Yanıtı parse et
      return _parseResponse(response, category);
    } on SocketException {
      return AiAnalysisResult.error(
          'İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.');
    } on FormatException catch (e) {
      return AiAnalysisResult.error(
          'Analiz sonuçları işlenemedi: ${e.message}');
    } catch (e) {
      return AiAnalysisResult.error('Analiz sırasında bir hata oluştu: $e');
    }
  }

  /// Çoklu fotoğraf analizi için özel prompt
  String _buildMultiImagePrompt({
    required AnalysisCategory category,
    required String handType,
    required String jsonContext,
    required int imageCount,
  }) {
    final categoryFocus = AnalysisDataManager.getAIFocusPrompt(category);

    return '''
SEN KADİM BİLGİLERE HAKİM, SON DERECE DİKKATLİ VE YARATICI BİR EL OKUYUCUSUSUN (PALMİST).

GÖREV:
Sana $imageCount adet $handType el fotoğrafı gönderiliyor. Bunlar aynı elin detay görüntüleri.
Analiz odağı: $categoryFocus

REFERANS VERİLERİ (KRİTİK ÖNEMDE):
Aşağıdaki JSON verileri, el okuma kurallarını ve olası seçenekleri içerir.
BU REFERANS LİSTESİNDEKİ EN KÜÇÜK DETAYI BİLE ATLAMA.

$jsonContext

TALİMATLAR:
1. **GÖRÜNTÜ KALİTESİ KONTROLÜ:**
   - Fotoğraflardan en az biri net ve okunabilir mi?
   - Değilse "image_quality": "poor" ver.

2. **DETAYLI ANALİZ:**
   - Çoklu açıları kullanarak çizgilerin derinliğini, adacıkları, zincirlenmeleri yakala.
   - Her JSON sorusuna en uygun cevabı bul.
   - "unique_features" listesine bu elde gördüğün en karakteristik 3 özelliği (görsel olarak) ekle.

3. **YORUMLAMA TARZI:**
   - "Emin değilim" deme, görselleri birleştir ve en güçlü ihtimali seç.
   - Yaratıcı ol, standart kalıpları zorla.

ÇIKTI FORMATI:
Yanıtını SADECE aşağıdaki JSON formatında ver. Başka açıklama ekleme.

{
  "success": true,
  "image_quality": "good|fair|poor",
  "quality_reason": "string",
  "hand_detected": true,
  "unique_features": ["Detay 1", "Detay 2", "Detay 3"],
  "analysis_depth": "detailed",
  "images_analyzed": $imageCount,
  "matches": [
    {
      "question_id": "referans_json_id",
      "category": "Soru kategorisi",
      "question_text": "Soru metni",
      "matched_option": {
        "label": "Seçilen seçenek etiketi",
        "analysis_result": "Analiz sonucu",
        "confidence": "high|medium|low"
      },
      "source_images": ["image_1"],
      "visual_evidence": "string"
    }
  ],
  "notes": "Çoklu fotoğraf genel gözlem"
}
''';
  }

  /// Birden fazla görseli Gemini Vision API'ye gönderir
  Future<String> _sendMultipleImagesToGemini(
    List<Map<String, dynamic>> imageContents,
    String prompt,
  ) async {
    // Gemini format: parts array with text and inline_data
    final List<Map<String, dynamic>> parts = [
      {'text': prompt},
      ...imageContents,
    ];

    final body = jsonEncode({
      'contents': [
        {
          'parts': parts,
        },
      ],
      'generationConfig': {
        'maxOutputTokens': 4096,
        'temperature': 0.3,
      },
    });

    final url = '$_baseUrl/$_visionModel:generateContent?key=$_apiKey';

    print('GEMINI_CALL: _sendMultipleImagesToGemini STARTED');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      print(
          'GEMINI_ERROR: Status ${response.statusCode} - Body: ${response.body}');
      throw Exception('API hatası: ${response.statusCode} - ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body);

    // Debug: Log token usage metadata
    final usage = jsonResponse['usageMetadata'];
    if (usage != null) {
      debugPrint('--- Gemini API Usage (Multiple Images) ---');
      debugPrint('Prompt Tokens: ${usage['promptTokenCount']}');
      debugPrint('Candidate Tokens: ${usage['candidatesTokenCount']}');
      debugPrint('Total Tokens: ${usage['totalTokenCount']}');
      debugPrint('------------------------------------------');
      print(
          'GEMINI_LOG (Multi): Prompt=${usage['promptTokenCount']}, Candidates=${usage['candidatesTokenCount']}, Total=${usage['totalTokenCount']}');
    }

    final responseContent =
        jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
    return responseContent;
  }

  /// Görseli Gemini Vision API'ye gönderir
  Future<String> _sendToGeminiVision(
    Uint8List imageBytes,
    String mimeType,
    String prompt,
  ) async {
    final base64Image = base64Encode(imageBytes);

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'maxOutputTokens': 4096,
        'temperature': 0.3,
      },
    });

    final url = '$_baseUrl/$_visionModel:generateContent?key=$_apiKey';

    print('GEMINI_CALL: _sendToGeminiVision STARTED');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      print(
          'GEMINI_ERROR: Status ${response.statusCode} - Body: ${response.body}');
      throw Exception('API hatası: ${response.statusCode} - ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body);

    // Debug: Log token usage metadata
    final usage = jsonResponse['usageMetadata'];
    if (usage != null) {
      debugPrint('--- Gemini API Usage (Vision) ---');
      debugPrint('Prompt Tokens: ${usage['promptTokenCount']}');
      debugPrint('Candidate Tokens: ${usage['candidatesTokenCount']}');
      debugPrint('Total Tokens: ${usage['totalTokenCount']}');
      debugPrint('----------------------------------');
      print(
          'GEMINI_LOG (Vision): Prompt=${usage['promptTokenCount']}, Candidates=${usage['candidatesTokenCount']}, Total=${usage['totalTokenCount']}');
    }

    final content =
        jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
    return content;
  }

  /// Metin tabanlı Gemini API çağrısı
  Future<String> _sendToGeminiText(String prompt) async {
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'maxOutputTokens': 4096,
        'temperature': 0.7,
      },
    });

    final url = '$_baseUrl/$_textModel:generateContent?key=$_apiKey';

    print('GEMINI_CALL: _sendToGeminiText STARTED');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      print(
          'GEMINI_ERROR: Status ${response.statusCode} - Body: ${response.body}');
      throw Exception('API hatası: ${response.statusCode} - ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body);

    // Debug: Log token usage metadata
    final usage = jsonResponse['usageMetadata'];
    if (usage != null) {
      debugPrint('--- Gemini API Usage (Text) ---');
      debugPrint('Prompt Tokens: ${usage['promptTokenCount']}');
      debugPrint('Candidate Tokens: ${usage['candidatesTokenCount']}');
      debugPrint('Total Tokens: ${usage['totalTokenCount']}');
      debugPrint('--------------------------------');
      print(
          'GEMINI_LOG (Text): Prompt=${usage['promptTokenCount']}, Candidates=${usage['candidatesTokenCount']}, Total=${usage['totalTokenCount']}');
    }

    final content =
        jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
    return content;
  }

  /// API yanıtını parse eder
  AiAnalysisResult _parseResponse(
      String responseText, AnalysisCategory category) {
    if (responseText.isEmpty) {
      return AiAnalysisResult.error('Boş yanıt alındı.');
    }

    try {
      // JSON bloğunu ayıkla (```json ... ``` içinden)
      String jsonString = responseText;

      final jsonMatch =
          RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(responseText);
      if (jsonMatch != null) {
        jsonString = jsonMatch.group(1) ?? responseText;
      } else {
        // Direkt JSON olabilir
        final startIndex = responseText.indexOf('{');
        final endIndex = responseText.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          jsonString = responseText.substring(startIndex, endIndex + 1);
        }
      }

      final Map<String, dynamic> parsed = jsonDecode(jsonString);

      // Başarı kontrolü
      // Başarı ve Kalite kontrolü
      final success = parsed['success'] as bool? ?? false;
      final handDetected = parsed['hand_detected'] as bool? ?? false;
      final quality = parsed['image_quality']?.toString() ?? 'unknown';
      final qualityReason = parsed['quality_reason']?.toString();

      if (!handDetected || quality == 'poor') {
        return AiAnalysisResult.error(
            'GÖRSEL YETERSİZ: ${qualityReason ?? "Fotoğraf çok bulanık veya el görünmüyor."}');
      }

      if (!success) {
        return AiAnalysisResult.error(
            parsed['notes']?.toString() ?? 'Analiz tamamlanamadı.');
      }

      // Eşleşmeleri çıkar
      final matches = (parsed['matches'] as List<dynamic>?)
              ?.map((m) => Map<String, dynamic>.from(m as Map))
              .toList() ??
          [];

      // Unique features (if available) - not currently stored in result class but can be added to notes
      final uniqueFeatures =
          (parsed['unique_features'] as List<dynamic>?)?.join(', ');

      return AiAnalysisResult(
        success: true,
        category: category,
        imageQuality: quality,
        matches: matches,
        notes: uniqueFeatures != null
            ? "Tespit Edilen Özel İşaretler: $uniqueFeatures\n\n${parsed['notes'] ?? ''}"
            : parsed['notes']?.toString(),
      );
    } on FormatException catch (e) {
      return AiAnalysisResult.error('Yanıt formatı geçersiz: ${e.message}');
    }
  }

  /// Dosya uzantısından MIME tipini belirler
  String _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Analiz sonuçlarından detaylı yorum üretir
  Future<String> generateDetailedCommentary({
    required AiAnalysisResult analysisResult,
    required String handType,
  }) async {
    if (!analysisResult.success || analysisResult.matches.isEmpty) {
      return 'Analiz sonuçları yetersiz olduğu için detaylı yorum oluşturulamadı.';
    }

    try {
      final categoryLabel =
          analysisResult.category?.questionTitle ?? 'Genel Analiz';

      // Eşleşmelerden özet oluştur
      final StringBuffer resultsBuffer = StringBuffer();
      for (final match in analysisResult.matches) {
        final category = match['category'] ?? '';
        final optionData = match['matched_option'] as Map<String, dynamic>?;
        if (optionData != null) {
          final label = optionData['label'] ?? '';
          final analysisText = optionData['analysis_result'] ?? '';
          resultsBuffer.writeln('$category - $label: $analysisText');
        }
      }

      final prompt = '''
Sen 'Eloa' adında, binlerce yıllık kadim el analizi bilgisine hakim, mistik ve bilge bir el okuyucususun.

Kullanıcı "$handType" elinin fotoğrafını yükledi ve "$categoryLabel" analizi istedi.

YAPAY ZEKA GÖRSEL ANALİZ SONUÇLARI:
${resultsBuffer.toString()}
NOTLAR: ${analysisResult.notes ?? ''}

GÖREVİN:
Bu sonuçları birleştirerek kullanıcıya **KİŞİYE ÖZEL** ve **YARATICI** bir yorum yaz.
Sıradan bir rapor gibi madde madde yazma. Mistik bir hikaye anlatır gibi akıcı olsun.
Kullanıcının elindeki ÖZEL DETAYLARA ("Görsel Kanıt" ve "Notlar" kısmındaki) mutlaka atıfta bulun. Örneğin: "Serçe parmağının altındaki o küçük kavis..." gibi.
Standart kalıpları ("Akıl çizgin düz olduğu için mantıklısın") kullanma. Daha derin, metaforik ve etkileyici cümleler kur.
Hem olumlu hem de uyarıcı yönleri dengeli anlat.
400-500 kelime civarında, doyurucu bir metin olsun.
Türkçe yaz.
''';

      return await _sendToGeminiText(prompt);
    } catch (e) {
      return 'Detaylı yorum oluşturulurken hata: $e';
    }
  }

  /// Kullanıcının kendi seçtiği özelliklere dayalı yorum üretir
  /// Kullanıcının kendi seçtiği özelliklere ve görsellere dayalı yorum üretir
  Future<String> generatePalmistryInterpretation(
    String userSelections, {
    List<dynamic>? images, // List<XFile> or List<File>
  }) async {
    // Load all palmistry JSON rules for context
    final jsonContext = await _loadAllPalmistryContext();

    // If no images, use text-only model
    if (images == null || images.isEmpty) {
      final prompt = '''
Sen 'Eloa' adında, binlerce yıllık kadim el analizi bilgisine hakim, mistik ve bilge bir el okuyucususun.

Kullanıcı, elindeki işaretleri ve çizgileri kendisi inceleyerek şu verileri sağladı:

$userSelections

Görevin:
Bu verileri bütüncül bir şekilde analiz et ve yorumla.
Kullanıcıya "sen" diye hitap et.
Samimi, mistik, akıcı ve etkileyici bir dil kullan.
Sadece sağlanan verilere dayan, uydurma yapma ama veriler arasındaki bağlantıları kur (örn. Akıl çizgisi şöyle ama başparmak böyle ise...).
Olumlu ve geliştirilmesi gereken yönleri dengeli anlat.
''';

      try {
        return await _sendToGeminiText(prompt);
      } catch (e) {
        return 'Yorum oluşturulurken bir hata oluştu: $e';
      }
    } else {
      // Use Vision model with images + text + JSON CONTEXT
      final prompt = '''
SEN KADİM BİLGİLERE HAKİM, SON DERECE DİKKATLİ VE YARATICI BİR EL OKUYUCUSUSUN (PALMİST).

GÖREV:
Kullanıcı, el fotoğraflarını yükledi. Aşağıda hem kullanıcının manuel cevapları hem de EL OKUMA KURALLARI VERİ TABANI var.
SENİN GÖREVİN: Fotoğrafı bu kurallara göre analiz etmek. Her çizgiyi, tepeyi, parmağı veri tabanındaki seçeneklerle karşılaştır.

KULLANICININ MANUEL CEVAPLARI:
$userSelections

=== EL OKUMA KURALLARI VE REFERANS VERİ TABANI ===
Aşağıdaki JSON verileri, EL OKUMA KURALLARINI ve OLASI SEÇENEKLERİ içerir.
HER BİR JSON dosyasındaki "options" veya "sections" kısımlarını incele.
Fotoğraftaki eli bu seçeneklerle EŞLEŞTIR. Hangi seçenek fotoğraftaki ele uyuyorsa ONU SEÇ.

$jsonContext

=== TALİMATLAR ===

1. **GÖRÜNTÜ KALİTESİ KONTROLÜ (İLK ADIM - ÇOK KRİTİK):**
   - Fotoğrafta bir insan eli var mı?
   - Avuç içi çizgileri okunabilir mi?
   - Işık yeterli mi?
   - EĞER GÖRÜNTÜ KÖTÜYSE: Analiz yapma. Sadece {"success": false, "error_code": "POOR_IMAGE", "reason": "Sebep"} döndür.

2. **GÖRSEL VE JSON ÇAPRAZ ANALİZİ (ANA GÖREV):**
   - Fotoğraftaki EL ŞEKLİNE bak -> JSON'daki "01_sekil_bakimindan_eller" ile karşılaştır. Hangisi uyuyor?
   - Fotoğraftaki HAYAT ÇİZGİSİNE bak -> JSON'daki "20_hayat_cizgisi" ile karşılaştır. Çizgi uzun mu kısa mı? Derin mi silik mi?
   - Fotoğraftaki AKIL ÇİZGİSİNE bak -> JSON'daki "21_akil_cizgisi" ile karşılaştır. Düz mü eğimli mi?
   - Fotoğraftaki KALP ÇİZGİSİNE bak -> JSON'daki "22_kalp_cizgisi" ile karşılaştır.
   - Fotoğraftaki KADER ÇİZGİSİNE (varsa) bak -> JSON "23_kader_cizgisi"
   - Fotoğraftaki TEPELERE bak (dolgun mu düz mü) -> ilgili JSON'lar (12-19)
   - Fotoğraftaki PARMAKLARA bak (uzun mu kısa mı, uç şekli) -> ilgili JSON'lar (07-10)
   - HER ÖZELLİK İÇİN JSON'dan en uygun "option"ı seç ve sonuca ekle.

3. **BENZERSİZ DETAYLARI YAKALA:**
   - JSON'da olmayan ama fotoğrafta gördüğün işaretleri not al (Ben, Yıldız, Üçgen, Adacık, Çatallanma).
   - Bunları "unique_visual_features" listesine ekle.

4. **SENTEZ VE YORUM:**
   - Tüm eşleşmeleri birleştirerek tutarlı bir karakter portresi çiz.
   - Çelişkileri mantıklı şekilde çöz (Örn: Zayıf Başparmak varsa irade düşük demektir).
   - Kişiye özel, mistik ve akıcı bir dille yaz.

ÇIKTI FORMATI (KESİNLİKLE BU ŞEMAYA UY, SADECE JSON DÖNDÜR):

{
  "success": true,
  "image_quality": "good|fair|poor",
  "hand_shape_match": "Tespit edilen el şekli (Örn: Kare El, Spatül El)",
  "unique_visual_features": ["Tespit edilen benzersiz detay 1", "Detay 2"],
  "line_analysis": {
    "hayat_cizgisi": "Kısa özet",
    "akil_cizgisi": "Kısa özet",
    "kalp_cizgisi": "Kısa özet",
    "kader_cizgisi": "Kısa özet veya yok"
  },
  "archetype": "string (Örn: BİLGE GEZGİN, PRATİK YÖNETİCİ)",
  "archetype_description": "string (1 cümle özet)",
  "traits": {
    "Mantık": int (0-100),
    "İrade": int (0-100),
    "Tutku": int (0-100),
    "Sezgi": int (0-100)
  },
  "synthesis_notes": ["Sentez notu 1", "Sentez notu 2"],
  "detailed_commentary": "string (En az 400 kelime. Mistik, kişiye özel, görsel detaylara atıf yapan bir yazı.)"
}
''';

      try {
        // Convert images to base64 content blocks (Gemini format)
        final List<Map<String, dynamic>> imageParts = [];
        for (var img in images) {
          Uint8List bytes;
          String path = '';

          if (img is File) {
            bytes = await img.readAsBytes();
            path = img.path;
          } else {
            // Handle XFile
            bytes = await img.readAsBytes();
            path = img.path;
          }

          final mimeType = _getMimeType(path);
          final base64Image = base64Encode(bytes);

          // Gemini inline_data format
          imageParts.add({
            'inline_data': {
              'mime_type': mimeType,
              'data': base64Image,
            },
          });
        }

        // Gemini format: parts array with text and inline_data
        final List<Map<String, dynamic>> parts = [
          {'text': prompt},
          ...imageParts,
        ];

        final body = jsonEncode({
          'contents': [
            {
              'parts': parts,
            },
          ],
          'generationConfig': {
            'maxOutputTokens': 8192, // Large output for detailed analysis
            'temperature': 0.3,
          },
        });

        final url = '$_baseUrl/$_visionModel:generateContent?key=$_apiKey';

        print('GEMINI_CALL: generatePalmistryInterpretation STARTED');
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
              },
              body: body,
            )
            .timeout(const Duration(
                seconds: 180)); // Increased timeout for complex analysis

        if (response.statusCode != 200) {
          print(
              'GEMINI_ERROR: Status ${response.statusCode} - Body: ${response.body}');
          debugPrint('Gemini API Hata Detayı: ${response.body}');
          throw Exception(
              'API hatası: ${response.statusCode} - ${response.body}');
        }

        final jsonResponse = jsonDecode(response.body);

        // Debug: Log token usage metadata
        final usage = jsonResponse['usageMetadata'];
        if (usage != null) {
          debugPrint('--- Gemini API Usage (Interpretation) ---');
          debugPrint('Prompt Tokens: ${usage['promptTokenCount']}');
          debugPrint('Candidate Tokens: ${usage['candidatesTokenCount']}');
          debugPrint('Total Tokens: ${usage['totalTokenCount']}');
          debugPrint('-----------------------------------------');

          // Also use standard print to ensure visibility in some environments
          print(
              'GEMINI_LOG: Prompt=${usage['promptTokenCount']}, Candidates=${usage['candidatesTokenCount']}, Total=${usage['totalTokenCount']}');
        }

        final responseContent = jsonResponse['candidates']?[0]?['content']
                ?['parts']?[0]?['text'] ??
            '';
        return responseContent;
      } catch (e) {
        return 'Görsel analiz ve yorumlama sırasında hata oluştu: $e';
      }
    }
  }

  /// Tüm temel el okuma JSON kurallarını SIKIŞTIRARAK yükler (Token Optimizasyonu)
  /// Bu fonksiyon, uzun book_content açıklamalarını kısa anahtar kelime listelerine dönüştürür.
  Future<String> _loadAllPalmistryContext() async {
    final StringBuffer contextBuffer = StringBuffer();

    // Key palmistry data files to load
    final keyFiles = [
      'assets/data/01_sekil_bakimindan_eller.json',
      'assets/data/06_basparmak_ve_bogumlari.json',
      'assets/data/07_isaret_parmagi_jupiter.json',
      'assets/data/08_orta_parmak_saturn.json',
      'assets/data/09_yuzuk_parmagi_gunes.json',
      'assets/data/10_serce_parmagi_merkur.json',
      'assets/data/12_venus_tepesi_zuhre.json',
      'assets/data/13_jupiter_tepesi_musteri.json',
      'assets/data/14_saturn_tepesi_zuhal.json',
      'assets/data/15_gunes_tepesi_apollon.json',
      'assets/data/16_merkur_tepesi_utarid.json',
      'assets/data/17_mars_tepesi_ve_yaylasi.json',
      'assets/data/18_ay_tepesi_kamer.json',
      'assets/data/20_hayat_cizgisi.json',
      'assets/data/21_akil_cizgisi.json',
      'assets/data/22_kalp_cizgisi.json',
      'assets/data/23_kader_cizgisi.json',
      'assets/data/24_gunes_cizgisi.json',
      'assets/data/11_el_isaretleri_semboller.json',
    ];

    contextBuffer.writeln('=== SIKIŞTIRMLI EL OKUMA VERİ TABANI ===');
    contextBuffer.writeln('Format: ID | İsim | Anahtar Özellikler');
    contextBuffer.writeln('');

    for (final path in keyFiles) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final fileName = path.split('/').last.replaceAll('.json', '');
        final compressed = _compressJsonContent(jsonString, fileName);
        contextBuffer.writeln(compressed);
      } catch (e) {
        // Skip if file not found
        continue;
      }
    }

    return contextBuffer.toString();
  }

  /// JSON içeriğini sıkıştırır - sadece ID, isim ve anahtar kelimeleri çıkarır
  String _compressJsonContent(String jsonString, String fileName) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final StringBuffer buffer = StringBuffer();

      // Kategori başlığı
      final categoryInfo = data['category_info'];
      if (categoryInfo != null) {
        buffer.writeln('### ${categoryInfo['title'] ?? fileName}');
      } else {
        buffer.writeln('### $fileName');
      }

      // Farklı JSON yapılarını destekle
      _extractAndCompressItems(data, buffer, 'hand_shapes');
      _extractAndCompressItems(data, buffer, 'features');
      _extractAndCompressItems(data, buffer, 'sections');
      _extractAndCompressItems(data, buffer, 'options');
      _extractAndCompressItems(data, buffer, 'characteristics');
      _extractAndCompressItems(data, buffer, 'lines');
      _extractAndCompressItems(data, buffer, 'mounts');
      _extractAndCompressItems(data, buffer, 'symbols');

      // questions içindeki options
      if (data['questions'] != null) {
        for (var question in data['questions']) {
          if (question['options'] != null) {
            for (var option in question['options']) {
              final id = option['id'] ?? option['label'] ?? '';
              final name = option['name'] ?? option['label'] ?? '';
              final keywords = _extractKeywords(option['book_content'] ??
                  option['analysis_result'] ??
                  option['description'] ??
                  '');
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
      // Sıkıştırma başarısız olursa, en azından dosya adını döndür
      return '### $fileName (Sıkıştırma hatası)\n';
    }
  }

  /// Belirli bir anahtar altındaki öğeleri sıkıştırır
  void _extractAndCompressItems(
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
            item['analysis_result'] ??
            '';
        final keywords = _extractKeywords(content);

        if (id.isNotEmpty || name.isNotEmpty) {
          buffer.writeln('- $id | $name | $keywords');
        }

        // İç içe sections veya features varsa onları da işle
        if (item['features'] != null && item['features'] is List) {
          for (var feature in item['features']) {
            if (feature is Map<String, dynamic>) {
              final fId = feature['id'] ?? '';
              final fName = feature['name'] ?? '';
              final fContent =
                  feature['book_content'] ?? feature['description'] ?? '';
              final fKeywords = _extractKeywords(fContent);
              buffer.writeln('  - $fId | $fName | $fKeywords');
            }
          }
        }
      }
    }
  }

  /// Uzun metinden anahtar kelimeleri çıkarır (max 60 karakter)
  String _extractKeywords(String text) {
    if (text.isEmpty) return '';

    // Metni temizle ve kısalt
    String cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // İlk 60 karakteri al ve son kelimeyi tamamla
    if (cleaned.length <= 60) return cleaned;

    String truncated = cleaned.substring(0, 60);
    int lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 40) {
      truncated = truncated.substring(0, lastSpace);
    }

    return '$truncated...';
  }
}

/// AI analiz sonucu modeli
class AiAnalysisResult {
  final bool success;
  final String? errorMessage;
  final AnalysisCategory? category;
  final String? imageQuality;
  final List<Map<String, dynamic>> matches;
  final String? notes;

  AiAnalysisResult({
    required this.success,
    this.errorMessage,
    this.category,
    this.imageQuality,
    this.matches = const [],
    this.notes,
  });

  /// Hata durumu için factory constructor
  factory AiAnalysisResult.error(String message) {
    return AiAnalysisResult(
      success: false,
      errorMessage: message,
      matches: [],
    );
  }

  /// Hata olup olmadığını kontrol eder
  bool get hasError => !success || errorMessage != null;

  /// Eşleşme sayısı
  int get matchCount => matches.length;

  /// Yüksek güvenli eşleşme sayısı
  int get highConfidenceCount {
    return matches.where((m) {
      final option = m['matched_option'] as Map<String, dynamic>?;
      return option?['confidence'] == 'high';
    }).length;
  }

  /// Genel güven skoru (0.0 - 1.0)
  double get confidence {
    if (matches.isEmpty) return 0.0;

    int total = matches.length;
    int highCount = 0;
    int mediumCount = 0;

    for (final m in matches) {
      final option = m['matched_option'] as Map<String, dynamic>?;
      final conf = option?['confidence']?.toString().toLowerCase();
      if (conf == 'high') {
        highCount++;
      } else if (conf == 'medium') {
        mediumCount++;
      }
    }

    // high = 1.0, medium = 0.6, low = 0.3 ağırlıklı ortalama
    return (highCount * 1.0 +
            mediumCount * 0.6 +
            (total - highCount - mediumCount) * 0.3) /
        total;
  }

  /// Tüm eşleşmelerin analiz sonuçlarını liste olarak döndürür
  List<String> get analysisTexts {
    return matches
        .map((m) {
          final option = m['matched_option'] as Map<String, dynamic>?;
          return option?['analysis_result']?.toString() ?? '';
        })
        .where((text) => text.isNotEmpty)
        .toList();
  }

  /// JSON formatına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'errorMessage': errorMessage,
      'category': category?.name,
      'imageQuality': imageQuality,
      'matches': matches,
      'notes': notes,
    };
  }

  @override
  String toString() {
    if (!success) {
      return 'AiAnalysisResult(error: $errorMessage)';
    }
    return 'AiAnalysisResult(matches: $matchCount, quality: $imageQuality)';
  }
}
