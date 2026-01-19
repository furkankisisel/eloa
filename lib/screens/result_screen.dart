import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../models/analysis_category.dart';
import '../models/analysis_history.dart';
import '../services/history_storage_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // AI yorumunu otomatik olarak başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analysis = context.read<AnalysisProvider>();
      if (analysis.aiCommentary == null && !analysis.isLoadingAI) {
        analysis.generateAiCommentary();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<AnalysisProvider>();
    final results = _buildHumanReadableResults(analysis);
    final personality = _generatePersonalitySummary(analysis);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(context, analysis),
                ),
                // AI Commentary Card
                SliverToBoxAdapter(
                  child: _buildAICommentaryCard(context, analysis),
                ),
                // Personality Summary Card
                SliverToBoxAdapter(
                  child: _buildPersonalityCard(context, personality),
                ),
                // Section Title
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Text(
                      'Detaylı Analiz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                // Result Cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildResultCard(
                        context,
                        results[index],
                        index,
                      ),
                      childCount: results.length,
                    ),
                  ),
                ),
                // Bottom Button
                SliverToBoxAdapter(
                  child: _buildBottomSection(context, analysis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AnalysisProvider analysis) {
    // Kategori ikonunu belirle
    IconData categoryIcon;
    final category = analysis.selectedCategory;

    if (category == null) {
      categoryIcon = Icons.auto_awesome;
    } else {
      switch (category) {
        case AnalysisCategory.loveGeneral:
        case AnalysisCategory.marriage:
        case AnalysisCategory.passion:
          categoryIcon = Icons.favorite;
          break;
        case AnalysisCategory.children:
          categoryIcon = Icons.child_care;
          break;
        case AnalysisCategory.wealth:
          categoryIcon = Icons.monetization_on;
          break;
        case AnalysisCategory.career:
          categoryIcon = Icons.work;
          break;
        case AnalysisCategory.fame:
          categoryIcon = Icons.star;
          break;
        case AnalysisCategory.danger:
          categoryIcon = Icons.warning_amber;
          break;
        case AnalysisCategory.mystic:
          categoryIcon = Icons.visibility;
          break;
        case AnalysisCategory.travel:
          categoryIcon = Icons.flight_takeoff;
          break;
        case AnalysisCategory.health:
          categoryIcon = Icons.health_and_safety;
          break;
        case AnalysisCategory.character:
          categoryIcon = Icons.psychology;
          break;
        case AnalysisCategory.full:
          categoryIcon = Icons.auto_awesome;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Mystical Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              categoryIcon,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${analysis.selectedCategoryLabel} Analizi',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tamamlandı',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: Text(
              analysis.selectedHandLabel,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityCard(
      BuildContext context, Map<String, dynamic> personality) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9C27B0).withOpacity(0.3),
            const Color(0xFF4A148C).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: const Color(0xFFFFD700).withOpacity(0.9),
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                'Seçim Özeti',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Traits chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (personality['traits'] as List<String>).map((trait) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  trait,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAICommentaryCard(
      BuildContext context, AnalysisProvider analysis) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A5F).withOpacity(0.6),
            const Color(0xFF0D1B2A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yapay Zeka Yorumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                    Text(
                      'Gemini AI tarafından oluşturuldu',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              if (analysis.aiCommentary != null && !analysis.isLoadingAI)
                IconButton(
                  onPressed: () => analysis.generateAiCommentary(),
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  tooltip: 'Yeniden oluştur',
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAIContent(analysis),
        ],
      ),
    );
  }

  Widget _buildAIContent(AnalysisProvider analysis) {
    if (analysis.isLoadingAI) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFFFD700).withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Yapay zeka analizinizi hazırlıyor...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    if (analysis.aiError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                analysis.aiError!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.redAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () => analysis.generateAiCommentary(),
              child: const Text(
                'Tekrar Dene',
                style: TextStyle(color: Color(0xFFFFD700)),
              ),
            ),
          ],
        ),
      );
    }

    if (analysis.aiCommentary != null) {
      return SelectableText(
        analysis.aiCommentary!,
        style: const TextStyle(
          fontSize: 14,
          height: 1.8,
          color: Colors.white,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildResultCard(
      BuildContext context, Map<String, String> result, int index) {
    final icons = [
      Icons.back_hand_outlined,
      Icons.fitness_center,
      Icons.touch_app,
      Icons.gesture,
      Icons.palette,
      Icons.fingerprint,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icons[index % icons.length],
              color: const Color(0xFFFFD700),
              size: 22,
            ),
          ),
          title: Text(
            result['category'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            result['selection'] ?? '',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFFFFD700).withOpacity(0.8),
            ),
          ),
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white54,
          children: [
            Text(
              _cleanAnalysisText(result['analysis'] ?? ''),
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, AnalysisProvider analysis) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bu analiz eğlence amaçlıdır ve bilimsel bir teşhis değildir.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Save Button
          if (!_isSaved)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _saveToHistory(analysis),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Geçmişe Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Geçmişe Kaydedildi',
                    style: TextStyle(
                        color: Color(0xFF4CAF50), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Ana Sayfa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _copyResultsToClipboard(analysis),
                  icon: const Icon(Icons.copy),
                  label: const Text('Kopyala'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: New Analysis button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await analysis.resetAnalysis();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Yeni Analiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToHistory(AnalysisProvider analysis) async {
    final results = _buildHumanReadableResults(analysis);

    // Convert results to matches format
    final matches = results
        .map((r) => {
              'question_text': r['category'] ?? '',
              'matched_option': {
                'label': r['selection'] ?? '',
                'analysis_result': r['analysis'] ?? '',
              },
            })
        .toList();

    final history = AnalysisHistory(
      id: AnalysisHistory.generateId(),
      createdAt: DateTime.now(),
      categoryId: analysis.selectedCategory?.name ?? 'unknown',
      categoryTitle: analysis.selectedCategoryLabel,
      handType: analysis.selectedHandLabel,
      aiCommentary: analysis.aiCommentary,
      matches: matches,
      confidence: 0.0,
    );

    final success = await HistoryStorageService.instance.saveAnalysis(history);

    if (mounted && success) {
      setState(() {
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analiz geçmişe kaydedildi! 📚'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _cleanAnalysisText(String text) {
    // Remove citation markers like [cite: 123]
    return text
        .replaceAll(RegExp(r'\s*\[cite:\s*[\d\-,\s]+\]'), '')
        .replaceAll(RegExp(r'\[cite_start\]'), '')
        .replaceAll(RegExp(r'\[cite_end\]'), '');
  }

  void _copyResultsToClipboard(AnalysisProvider analysis) {
    final buffer = StringBuffer();
    final results = _buildHumanReadableResults(analysis);

    // Başlık ve uygulama ismi
    buffer.writeln('✨ ELOA - Mistik El Analizi ✨');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
    buffer.writeln('📋 ${analysis.selectedCategoryLabel} Analizi');
    buffer.writeln('🖐️ ${analysis.selectedHandLabel}');
    buffer.writeln();

    // AI Yorumu
    if (analysis.aiCommentary != null && analysis.aiCommentary!.isNotEmpty) {
      buffer.writeln('🔮 Yapay Zeka Yorumu:');
      buffer.writeln(analysis.aiCommentary);
      buffer.writeln();
    }

    // Detaylı analiz sonuçları
    if (results.isNotEmpty) {
      buffer.writeln('📌 Detaylı Analiz:');
      buffer.writeln('─────────────────────────');

      for (final result in results) {
        final category = result['category'] ?? '';
        final selection = result['selection'] ?? '';
        final analysisText = _cleanAnalysisText(result['analysis'] ?? '');

        buffer.writeln('• $category');
        buffer.writeln('  → $selection');
        if (analysisText.isNotEmpty) {
          buffer.writeln('  💡 $analysisText');
        }
        buffer.writeln();
      }
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Eloa uygulamasıyla analiz edildi.');
    buffer.writeln('📲 Siz de keşfedin!');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sonuçlar panoya kopyalandı! 📋'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, String>> _buildHumanReadableResults(
      AnalysisProvider analysis) {
    final List<Map<String, String>> results = [];

    for (final module in analysis.accumulatedResults) {
      final selections = module['selections'] as List<dynamic>? ?? [];
      for (final sel in selections) {
        if (sel is Map) {
          results.add({
            'category': sel['category']?.toString() ?? '',
            'selection': sel['label']?.toString() ?? '',
            'analysis': sel['analysis_result']?.toString() ?? '',
          });
        }
      }
    }

    return results;
  }

  Map<String, dynamic> _generatePersonalitySummary(AnalysisProvider analysis) {
    final traits = <String>[];

    for (final module in analysis.accumulatedResults) {
      final selections = module['selections'] as List<dynamic>? ?? [];
      for (final sel in selections) {
        if (sel is Map) {
          final label = sel['label']?.toString() ?? '';
          if (label.isNotEmpty) {
            traits.add(label);
          }
        }
      }
    }

    return {
      'traits': traits.take(8).toList(),
    };
  }
}
