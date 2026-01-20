import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Rüya tabiri servisi
/// Google Gemini API kullanarak rüyaları yorumlar
class DreamInterpretationService {
  static const String _apiKey = 'AIzaSyDbnTcHFYi-eexcars1zCguBtyrWxkGyAk';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _textModel = 'gemini-2.5-flash-lite';

  /// Rüyayı yorumlar
  /// [dreamText] - Kullanıcının girdiği rüya metni
  /// [isPremium] - Premium kullanıcı mı (tam yorum için true)
  ///
  /// Premium kullanıcılar için tam yorum döner
  /// Non-premium için kısa önizleme + premium teşvik mesajı döner
  Future<DreamInterpretationResult> interpretDream({
    required String dreamText,
    required bool isPremium,
  }) async {
    if (dreamText.trim().isEmpty) {
      return DreamInterpretationResult.error('Lütfen rüyanızı yazın.');
    }

    if (dreamText.trim().length < 10) {
      return DreamInterpretationResult.error(
          'Rüyanızı daha detaylı anlatın (en az 10 karakter).');
    }

    try {
      final prompt = _buildDreamPrompt(dreamText);
      final response = await _sendToGemini(prompt);

      if (response.isEmpty) {
        return DreamInterpretationResult.error(
            'Rüya yorumu alınamadı. Lütfen tekrar deneyin.');
      }

      if (isPremium) {
        // Premium kullanıcı - tam yorumu göster
        return DreamInterpretationResult(
          success: true,
          fullInterpretation: response,
          isPremiumContent: true,
        );
      } else {
        // Non-premium kullanıcı - kısa önizleme göster
        final preview = _generatePreview(response);
        return DreamInterpretationResult(
          success: true,
          previewInterpretation: preview,
          fullInterpretation: response,
          isPremiumContent: false,
        );
      }
    } catch (e) {
      debugPrint('Dream interpretation error: $e');
      return DreamInterpretationResult.error(
          'Rüya yorumlanırken bir hata oluştu: $e');
    }
  }

  /// Rüya yorumlama prompt'u oluşturur - İslami metodoloji
  String _buildDreamPrompt(String dreamText) {
    return '''
Sen 'Eloa' adında, İslami rüya tabiri geleneğine hakim, bilge ve dürüst bir rüya yorumcususun.

📚 METODOLOJİN:
1. KLASİK İSLAMİ KAYNAKLAR: İbn Sîrîn, İmam Nablusî ve İbn Şahîn'in eserlerindeki sembol anlamlarını esas al.
2. KUR'AN VE HADİS ÇERÇEVESİ: Hz. Yusuf'un rüya yorumu metodolojisini takip et. Gayb bilgisi iddiasında bulunma, kesinlik söyleme.
3. KİŞİSEL BAĞLAM: Rüyayı gören kişinin hâline, ruh durumuna ve yaşadıklarına göre yorumla.
4. PSİKOLOJİK KATMAN: İslami çerçeveyi bozmadan bilinçaltı ve zihinsel yükü destekleyici olarak değerlendir.

KULLANICININ RÜYASI:
"$dreamText"

GÖREVİN:
Bu rüyayı İslami kaynaklara dayalı, kişiye özel ve dengeli bir şekilde yorumla.

ÖNCELİKLE RÜYA TÜRÜNÜ BELİRLE:
- RAHMANİ RÜYA: Hayırlı, yorumlanabilir rüya
- NEFSANİ RÜYA: Günlük zihinsel meşguliyetlerden kaynaklanan rüya
- ŞEYTANİ RÜYA: Korku/kabus niteliğinde, yorumlanmaz, önemsenmez

YAPI (Bu başlıkları kullan):

🌙 RÜYANIN TÜRÜ VE GENEL DEĞERLENDİRME
Önce rüyanın türünü (Rahmani/Nefsani/Şeytani) belirle ve genel anlamını özetle.
Şeytani ise: "Bu rüya üzerinde durulmamalı, eûzü çekilmeli ve unutulmalıdır" de ve yorumu kısa kes.

📖 KLASİK KAYNAKLARA GÖRE SEMBOL ANALİZİ
Rüyadaki sembolleri İbn Sîrîn ve Nablusî'nin eserlerine göre yorumla.
Her sembolün klasik anlamını açıkla.

🔍 KİŞİYE ÖZEL YORUM
"Aynı rüya iki kişide farklı yorumlanır" prensibine göre:
- Kişinin muhtemel ruh hâli
- Hayatında olabilecek durumlar
- Bu rüyanın ona özel mesajı

💡 HAYIR MI UYARI MI?
Rüyanın hayırlı bir müjde mi yoksa uyarıcı bir mesaj mı olduğunu belirt.
Uyarı ise nazikçe ve korkutmadan açıkla.

🤲 TAVSİYELER VE DUA
- Rüyadan çıkan 2-3 somut tavsiye
- Varsa okunabilecek dua veya zikir önerisi
- "Allah en doğrusunu bilir" ile bitir

KURALLAR:
1. "Sen" diliyle hitap et, samimi ama saygılı ol.
2. Kesinlik iddiasında BULUNMA. "...olabilir", "...işaret edebilir" gibi ifadeler kullan.
3. Korku satma, dengeli ol.
4. Uydurma sembol ekleme, sadece klasik kaynaklardaki anlamları kullan.
5. Her bölüm en az 2-3 cümle olsun.
6. Toplam 450-550 kelime civarında olsun.
7. Emoji başlıklarını aynen kullan.
8. Türkçe yaz.
9. Rüyadaki detaylara özellikle dikkat et ve onlara atıf yap.
10. "Allah en doğrusunu bilir" (Vallahu a'lem) ile mutlaka bitir.
''';
  }

  /// Gemini API'ye metin isteği gönderir
  Future<String> _sendToGemini(String prompt) async {
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

    debugPrint('DREAM_INTERPRETATION: Gemini API call started');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      debugPrint(
          'DREAM_ERROR: Status ${response.statusCode} - Body: ${response.body}');
      throw Exception('API hatası: ${response.statusCode}');
    }

    final jsonResponse = jsonDecode(response.body);

    // Debug: Log token usage metadata
    final usage = jsonResponse['usageMetadata'];
    if (usage != null) {
      debugPrint('--- Gemini API Usage (Dream) ---');
      debugPrint('Prompt Tokens: ${usage['promptTokenCount']}');
      debugPrint('Candidate Tokens: ${usage['candidatesTokenCount']}');
      debugPrint('Total Tokens: ${usage['totalTokenCount']}');
      debugPrint('--------------------------------');
    }

    final content =
        jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
    return content;
  }

  /// Non-premium kullanıcılar için kısa önizleme oluşturur
  /// İlk bölümü (🌙 RÜYANIN GENEL ANLAMI) gösterir
  String _generatePreview(String fullInterpretation) {
    // İlk 150-200 karakteri al veya ilk bölümü bul
    final lines = fullInterpretation.split('\n');
    final previewBuffer = StringBuffer();
    int charCount = 0;
    const maxChars = 200;

    for (final line in lines) {
      if (charCount >= maxChars) break;

      // İkinci emoji başlığına gelince dur (📖)
      if (line.contains('📖') && charCount > 50) {
        break;
      }

      previewBuffer.writeln(line);
      charCount += line.length;
    }

    return previewBuffer.toString().trim();
  }
}

/// Rüya yorumlama sonucu modeli
class DreamInterpretationResult {
  final bool success;
  final String? error;
  final String? previewInterpretation;
  final String? fullInterpretation;
  final bool isPremiumContent;

  DreamInterpretationResult({
    required this.success,
    this.error,
    this.previewInterpretation,
    this.fullInterpretation,
    this.isPremiumContent = false,
  });

  factory DreamInterpretationResult.error(String message) {
    return DreamInterpretationResult(
      success: false,
      error: message,
    );
  }

  /// Gösterilecek yorumu döndürür (premium veya preview)
  String get displayInterpretation {
    if (!success) return error ?? 'Bir hata oluştu.';

    if (isPremiumContent) {
      return fullInterpretation ?? '';
    } else {
      return previewInterpretation ?? '';
    }
  }
}
