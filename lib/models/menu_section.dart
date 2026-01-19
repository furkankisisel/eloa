import 'package:flutter/material.dart';
import 'analysis_category.dart';

/// UI'da gruplandırılmış menü bölümü
/// Netflix tarzı yatay kaydırmalı kategoriler için kullanılır
class MenuSection {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final List<AnalysisCategory> categories;

  const MenuSection({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.categories,
  });

  /// Tüm menü bölümlerini döndürür
  static List<MenuSection> getAllSections() {
    return [
      const MenuSection(
        title: 'Aşk ve İlişkiler',
        subtitle: 'Romantik hayatınızın sırları',
        icon: Icons.favorite,
        accentColor: Color(0xFFE91E63), // Pink
        categories: [
          AnalysisCategory.loveGeneral,
          AnalysisCategory.marriage,
          AnalysisCategory.children,
          AnalysisCategory.passion,
        ],
      ),
      const MenuSection(
        title: 'Zenginlik ve Kariyer',
        subtitle: 'Maddi başarı ve iş hayatı',
        icon: Icons.monetization_on,
        accentColor: Color(0xFFFFD700), // Gold
        categories: [
          AnalysisCategory.wealth,
          AnalysisCategory.career,
          AnalysisCategory.fame,
        ],
      ),
      const MenuSection(
        title: 'Gizem ve Tehlike',
        subtitle: 'Bilinmeyen güçler ve uyarılar',
        icon: Icons.visibility,
        accentColor: Color(0xFF9C27B0), // Purple
        categories: [
          AnalysisCategory.danger,
          AnalysisCategory.mystic,
          AnalysisCategory.travel,
        ],
      ),
      const MenuSection(
        title: 'Sağlık ve Karakter',
        subtitle: 'Bedensel ve zihinsel özellikler',
        icon: Icons.psychology,
        accentColor: Color(0xFF4CAF50), // Green
        categories: [
          AnalysisCategory.health,
          AnalysisCategory.character,
        ],
      ),
      const MenuSection(
        title: 'Tam Analiz',
        subtitle: 'Tüm detaylarla eksiksiz okuma',
        icon: Icons.auto_awesome,
        accentColor: Color(0xFFFF8C00), // Orange
        categories: [
          AnalysisCategory.full,
        ],
      ),
    ];
  }

  /// Belirli bir kategoriyi içeren section'ı bul
  static MenuSection? findSectionForCategory(AnalysisCategory category) {
    for (final section in getAllSections()) {
      if (section.categories.contains(category)) {
        return section;
      }
    }
    return null;
  }
}

/// Kategori kartı için UI verisi
class CategoryCardData {
  final AnalysisCategory category;
  final String title;
  final String subtitle;
  final IconData icon;
  final int estimatedMinutes;
  final int questionCount;
  final Color accentColor;

  CategoryCardData({
    required this.category,
    required this.accentColor,
  })  : title = category.questionTitle,
        subtitle = category.subtitle,
        icon = _getIconFromName(category.iconName),
        estimatedMinutes = category.estimatedMinutes,
        questionCount = category.questionCount;

  static IconData _getIconFromName(String name) {
    switch (name) {
      case 'favorite':
        return Icons.favorite;
      case 'diamond':
        return Icons.diamond;
      case 'child_care':
        return Icons.child_care;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'monetization_on':
        return Icons.monetization_on;
      case 'work':
        return Icons.work;
      case 'star':
        return Icons.star;
      case 'warning':
        return Icons.warning_amber;
      case 'visibility':
        return Icons.visibility;
      case 'flight':
        return Icons.flight_takeoff;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'psychology':
        return Icons.psychology;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.help_outline;
    }
  }
}
