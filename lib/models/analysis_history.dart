import 'dart:convert';

/// Kaydedilmiş analiz sonucu modeli
class AnalysisHistory {
  final String id;
  final DateTime createdAt;
  final String categoryId;
  final String categoryTitle;
  final String? subCategoryTitle;
  final String handType;
  final String? aiCommentary;
  final List<Map<String, dynamic>> matches;
  final double confidence;
  final String? archetype;
  final Map<String, int>? traits;
  final List<String>? uniqueFeatures;
  final String? notes;

  AnalysisHistory({
    required this.id,
    required this.createdAt,
    required this.categoryId,
    required this.categoryTitle,
    this.subCategoryTitle,
    required this.handType,
    this.aiCommentary,
    required this.matches,
    this.confidence = 0.0,
    this.archetype,
    this.traits,
    this.uniqueFeatures,
    this.notes,
  });

  /// Benzersiz ID oluştur
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// JSON'dan oluştur
  factory AnalysisHistory.fromJson(Map<String, dynamic> json) {
    return AnalysisHistory(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      categoryId: json['categoryId'] as String? ?? '',
      categoryTitle: json['categoryTitle'] as String,
      subCategoryTitle: json['subCategoryTitle'] as String?,
      handType: json['handType'] as String,
      aiCommentary: json['aiCommentary'] as String?,
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      archetype: json['archetype'] as String?,
      traits: json['traits'] != null
          ? Map<String, int>.from(json['traits'] as Map)
          : null,
      uniqueFeatures: (json['uniqueFeatures'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      notes: json['notes'] as String?,
    );
  }

  /// JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'categoryId': categoryId,
      'categoryTitle': categoryTitle,
      'subCategoryTitle': subCategoryTitle,
      'handType': handType,
      'aiCommentary': aiCommentary,
      'matches': matches,
      'confidence': confidence,
      'archetype': archetype,
      'traits': traits,
      'uniqueFeatures': uniqueFeatures,
      'notes': notes,
    };
  }

  /// String olarak encode et (SharedPreferences için)
  String encode() => jsonEncode(toJson());

  /// String'den decode et
  static AnalysisHistory decode(String source) {
    return AnalysisHistory.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  /// Kopyala ve güncelle
  AnalysisHistory copyWith({
    String? id,
    DateTime? createdAt,
    String? categoryId,
    String? categoryTitle,
    String? subCategoryTitle,
    String? handType,
    String? aiCommentary,
    List<Map<String, dynamic>>? matches,
    double? confidence,
    String? archetype,
    Map<String, int>? traits,
    List<String>? uniqueFeatures,
    String? notes,
  }) {
    return AnalysisHistory(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      subCategoryTitle: subCategoryTitle ?? this.subCategoryTitle,
      handType: handType ?? this.handType,
      aiCommentary: aiCommentary ?? this.aiCommentary,
      matches: matches ?? this.matches,
      confidence: confidence ?? this.confidence,
      archetype: archetype ?? this.archetype,
      traits: traits ?? this.traits,
      uniqueFeatures: uniqueFeatures ?? this.uniqueFeatures,
      notes: notes ?? this.notes,
    );
  }

  /// Eşleşme sayısı
  int get matchCount => matches.length;

  /// Tarih formatı (görüntüleme için)
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    }
  }

  /// Kısa özet metni
  String get shortSummary {
    if (aiCommentary != null && aiCommentary!.isNotEmpty) {
      final words = aiCommentary!.split(' ');
      if (words.length > 20) {
        return '${words.take(20).join(' ')}...';
      }
      return aiCommentary!;
    }
    return 'El analizi tamamlandı';
  }

  @override
  String toString() {
    return 'AnalysisHistory(id: $id, category: $categoryTitle, date: $formattedDate)';
  }
}
