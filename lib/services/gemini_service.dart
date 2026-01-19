import 'dart:convert';
import 'package:http/http.dart' as http;

/// Groq API (Llama) servisini yönetir ve analiz sonuçlarını yorumlar.
class GeminiService {
  final String apiKey;
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  GeminiService(this.apiKey);

  /// Kullanıcının el analiz sonuçlarını alır ve AI ile yorumlar.
  Future<String> generatePersonalityAnalysis({
    required List<String> analysisResults,
    required String handType,
    required String categoryType,
  }) async {
    try {
      final prompt = _buildPrompt(analysisResults, handType, categoryType);
      return await _sendToGroq(prompt);
    } catch (e) {
      return 'Bağlantı hatası: Analiz oluşturulamadı. Lütfen internetinizi kontrol edip tekrar deneyin. ($e)';
    }
  }

  /// Groq API'ye metin isteği gönderir
  Future<String> _sendToGroq(String prompt) async {
    final body = jsonEncode({
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'max_tokens': 2048,
      'temperature': 0.7,
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('API hatası: ${response.statusCode} - ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body);
    final content = jsonResponse['choices']?[0]?['message']?['content'] ?? '';

    return content.isNotEmpty
        ? content
        : 'Yıldızlar şu an sessiz... Lütfen tekrar deneyin.';
  }

  String _buildPrompt(
      List<String> results, String handType, String categoryType) {
    final attributes = results.map((e) => "- $e").join("\n");

    // Kategori bazlı prompt yapısını belirle
    final categoryPrompt = _getCategorySpecificPrompt(categoryType);

    return '''
Sen 'Eloa' adında, binlerce yıllık kadim İlm-i Sima ve El Analizi bilgilerine hakim, 
mistik, bilge ve son derece deneyimli bir el okuyucususun. Dürüst ama nazik bir üslubun var.

Kullanıcı "$handType" elini analiz ettirdi.
Seçilen analiz türü: $categoryType

Elde edilen teknik veriler şunlar:
$attributes

Görevin:
Bu verileri derinlemesine analiz ederek kullanıcıya "$categoryType" odaklı, kapsamlı ve DENGELI bir analiz yaz.

$categoryPrompt

Kurallar:
1. "Sen" diliyle hitap et, samimi ama saygılı ol.
2. Sadece olumlu şeyler söyleme - gerçekçi ve dengeli ol.
3. Teknik terimler kullanma (JSON, veri, madde gibi).
4. Her bölüm en az 2-3 cümle olsun.
5. Mistik ama ayakları yere basan bir üslup kullan.
6. Toplam 400-500 kelime civarında olsun.
7. Emoji başlıklarını aynen kullan.
8. Türkçe yaz.
9. Sadece seçilen analiz türüne odaklan, diğer konulara girme.
''';
  }

  String _getCategorySpecificPrompt(String categoryType) {
    switch (categoryType) {
      case 'Aşk ve İlişkiler':
        return '''
YAPI (Bu başlıkları kullan):

💕 AŞK HAYATIN
Romantik ilişkilerde nasıl biri olduğunu, aşka bakış açını ve tutkularını anlat.

💞 İLİŞKİ DİNAMİKLERİN
Partnerle nasıl iletişim kurduğunu, ilişkilerde güçlü ve zayıf yönlerini belirt.

💍 BAĞLILIK VE SADAKAT
Uzun süreli ilişkilere bakışını, evlilik ve bağlılık konusundaki eğilimlerini anlat.

⚠️ DİKKAT ETMENİ GEREKEN YÖNLER
İlişkilerde dikkat etmen gereken 2-3 konuyu nazikçe belirt.

🔮 AŞK TAVSİYELERİ
İlişki hayatında mutluluğu yakalamak için 2-3 somut tavsiye ver.
''';
      case 'Kariyer ve Para':
        return '''
YAPI (Bu başlıkları kullan):

💼 KARİYER POTANSİYELİN
Hangi iş alanlarında başarılı olabileceğini, yeteneklerini ve güçlü yönlerini anlat.

💰 PARA VE REFAH
Para kazanma yeteneğini, finansal alışkanlıklarını (tutumlu mu, yatırımcı mı, savurgan mı) belirt.

📈 İŞ HAYATINDA GÜÇLÜ YÖNLERİN
Liderlik, takım çalışması, yaratıcılık gibi iş dünyasındaki avantajlarını anlat.

⚠️ DİKKAT ETMENİ GEREKEN YÖNLER
Kariyer ve para konusunda dikkat etmen gereken 2-3 noktayı nazikçe belirt.

🔮 KARİYER TAVSİYELERİ
Başarıya ulaşmak için 2-3 somut tavsiye ver.
''';
      case 'Karakter ve Potansiyel':
        return '''
YAPI (Bu başlıkları kullan):

🌟 KARAKTERİNİN TEMELLERİ
Kişiliğinin en belirgin özelliklerini, değerlerini ve yaşam felsefeni anlat.

🧠 ZIHINSEL YAPIN
Düşünme tarzını, problem çözme yeteneğini ve zihinsel güçlerini belirt.

💎 GİZLİ POTANSİYELLERİN
Henüz tam olarak keşfetmediğin yeteneklerini ve potansiyellerini anlat.

⚠️ GELİŞTİRMEN GEREKEN YÖNLER
Karakter olarak dikkat etmen gereken 2-3 noktayı nazikçe belirt.

🔮 KİŞİSEL GELİŞİM TAVSİYELERİ
Kendini geliştirmek için 2-3 somut tavsiye ver.
''';
      case 'Sağlık ve Zindelik':
        return '''
YAPI (Bu başlıkları kullan):

🏃 FİZİKSEL ENERJİN
Genel enerji seviyeni, fiziksel dayanıklılığını ve vücut yapını anlat.

🧘 MENTAL SAĞLIĞIN
Zihinsel dengen, stresle başa çıkma yeteneğin ve duygusal dayanıklılığını belirt.

💪 GÜÇLÜ YÖNLER
Sağlık açısından avantajlı yönlerini ve doğal dirençlerini anlat.

⚠️ DİKKAT ETMENİ GEREKEN ALANLAR
Sağlık konusunda dikkat etmen gereken 2-3 noktayı nazikçe belirt.

🔮 SAĞLIK TAVSİYELERİ
Daha sağlıklı bir yaşam için 2-3 somut tavsiye ver.

NOT: Bu analiz tıbbi tavsiye değildir, sadece geleneksel el okuma bilgilerine dayanmaktadır.
''';
      case 'Detaylı Tam Analiz':
      default:
        return '''
YAPI (Bu başlıkları kullan):

🌟 GÜÇLÜ YÖNLERİN
Kullanıcının en belirgin 3-4 olumlu özelliğini detaylı anlat.

⚠️ DİKKAT ETMENİ GEREKEN YÖNLER
Kullanıcının 2-3 zayıf yönünü nazikçe belirt.

💼 KARİYER VE PARA
İş hayatında başarılı olabileceği alanları ve para eğilimlerini belirt.

❤️ İLİŞKİLER VE DUYGUSAL YAPI
Aşk hayatında nasıl biri olduğunu ve ilişkilerdeki güçlü/zayıf yönlerini anlat.

🔮 GENEL YORUM VE TAVSİYELER
Kısa özet ve 2-3 somut tavsiye ver.
''';
    }
  }
}
