import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import '../core/app_theme.dart';
import '../models/palmistry/palmistry_app_data.dart';
import '../models/analysis_history.dart';
import '../services/history_storage_service.dart';

class AdvancedResultScreen extends StatefulWidget {
  final AppCategory category;
  final String subCategoryTitle;
  final String handSide;
  final Map<String, dynamic> analysisResult;

  const AdvancedResultScreen({
    super.key,
    required this.category,
    required this.subCategoryTitle,
    required this.handSide,
    required this.analysisResult,
  });

  @override
  State<AdvancedResultScreen> createState() => _AdvancedResultScreenState();
}

class _AdvancedResultScreenState extends State<AdvancedResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaved = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _shareAnalysis() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final String archetype = widget.analysisResult['archetype'] ?? "Arketip";
      final String desc = widget.analysisResult['archetype_description'] ?? "";
      final String detailedComment =
          widget.analysisResult['detailed_commentary'] ?? "";
      final confidence = _parseConfidence();
      final traits = _parseTraits();

      final StringBuffer shareText = StringBuffer();
      shareText.writeln('🔮 ELOA - El Analizi Sonuçlarım ✨');
      shareText.writeln();
      shareText.writeln('📌 ${widget.subCategoryTitle}');
      shareText.writeln('🖐️ ${widget.handSide} El');
      shareText.writeln();
      shareText.writeln('🏷️ Arketip: $archetype');
      if (desc.isNotEmpty) shareText.writeln('📝 $desc');
      shareText.writeln();
      shareText.writeln('📊 Güven Oranı: %${(confidence * 100).round()}');
      shareText.writeln();

      if (traits.isNotEmpty) {
        shareText.writeln('✨ Özellikler:');
        traits.forEach((key, value) {
          shareText.writeln('  • $key: %${(value * 100).round()}');
        });
        shareText.writeln();
      }

      if (detailedComment.isNotEmpty) {
        shareText.writeln('💬 Yorum:');
        shareText.writeln(detailedComment.length > 500
            ? '${detailedComment.substring(0, 500)}...'
            : detailedComment);
        shareText.writeln();
      }

      shareText.writeln('─────────────────');
      shareText.writeln('🌟 Eloa ile analiz edildi');
      shareText.writeln('📱 eloa.app');

      await Share.share(shareText.toString(),
          subject: 'Eloa El Analizi - ${widget.subCategoryTitle}');
    } catch (e) {
      debugPrint('Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Paylaşım sırasında bir hata oluştu'),
              backgroundColor: AppTheme.accentCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  /// Build a widget that contains the full analysis for sharing
  Widget _buildShareableContent() {
    final categoryColor = widget.category.categoryId.categoryColor;
    final String archetype =
        widget.analysisResult['archetype'] ?? "BİLGE GEZGİN";
    final String desc =
        widget.analysisResult['archetype_description'] ?? "Analiz tamamlandı.";
    final traits = _parseTraits();
    final confidence = _parseConfidence();

    List<String> synthesisNotes = [];
    if (widget.analysisResult['synthesis_notes'] != null) {
      synthesisNotes =
          List<String>.from(widget.analysisResult['synthesis_notes']);
    }

    final String detailedComment =
        widget.analysisResult['detailed_commentary'] ??
            "Detaylı yorum alınamadı.";

    return Material(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.back_hand,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'ELOA',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Identity Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withOpacity(0.2),
                    AppTheme.cardDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: categoryColor.withOpacity(0.5), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    widget.subCategoryTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      archetype.toUpperCase(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareStatItem('${widget.handSide} El',
                          Icons.back_hand, categoryColor),
                      _buildShareStatItem('%${(confidence * 100).round()}',
                          Icons.verified, categoryColor),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Traits
            if (traits.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: traits.entries.take(4).map((e) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: categoryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${e.key}: %${(e.value * 100).round()}',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Synthesis notes preview
            if (synthesisNotes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border(left: BorderSide(color: categoryColor, width: 3)),
                ),
                child: Text(
                  synthesisNotes.first.length > 150
                      ? '${synthesisNotes.first.substring(0, 150)}...'
                      : synthesisNotes.first,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Commentary preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                detailedComment.length > 300
                    ? '${detailedComment.substring(0, 300)}...'
                    : detailedComment,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Watermark
            Text(
              'eloa.app',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textMuted,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareStatItem(String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _saveToHistory() async {
    if (_isSaved) return;

    final history = AnalysisHistory(
      id: AnalysisHistory.generateId(),
      createdAt: DateTime.now(),
      categoryId: widget.category.categoryId,
      categoryTitle: widget.category.displayTitle,
      subCategoryTitle: widget.subCategoryTitle,
      handType: '${widget.handSide} El',
      aiCommentary: widget.analysisResult['detailed_commentary'] as String?,
      matches: [],
      confidence: _parseConfidence(),
      archetype: widget.analysisResult['archetype'] as String?,
      traits: _parseTraitsForHistory(),
      uniqueFeatures: widget.analysisResult['synthesis_notes'] != null
          ? List<String>.from(widget.analysisResult['synthesis_notes'])
          : null,
    );

    await HistoryStorageService.instance.saveAnalysis(history);
    setState(() => _isSaved = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Analiz geçmişe kaydedildi'),
          backgroundColor: AppTheme.accentTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  double _parseConfidence() {
    final conf = widget.analysisResult['confidence'];
    if (conf is num) return conf.toDouble().clamp(0.0, 1.0);
    if (conf is String) {
      final parsed = double.tryParse(conf.replaceAll('%', ''));
      if (parsed != null) return (parsed / 100).clamp(0.0, 1.0);
    }
    return 0.85;
  }

  Map<String, int>? _parseTraitsForHistory() {
    if (widget.analysisResult['traits'] == null) return null;
    final Map<String, int> result = {};
    (widget.analysisResult['traits'] as Map).forEach((k, v) {
      if (v is num) {
        result[k.toString()] = (v * 100).round();
      }
    });
    return result.isEmpty ? null : result;
  }

  Map<String, double> _parseTraits() {
    Map<String, double> traits = {};
    if (widget.analysisResult['traits'] != null) {
      (widget.analysisResult['traits'] as Map).forEach((k, v) {
        double value = 0.5;
        if (v is num) {
          // If value > 1, assume it's already a percentage (0-100)
          value =
              v > 1 ? (v / 100).clamp(0.0, 1.0) : v.toDouble().clamp(0.0, 1.0);
        }
        traits[k.toString()] = value;
      });
    }
    return traits;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.category.categoryId.categoryColor;

    final String archetype =
        widget.analysisResult['archetype'] ?? "BİLGE GEZGİN";
    final String desc =
        widget.analysisResult['archetype_description'] ?? "Analiz tamamlandı.";
    final traits = _parseTraits();

    List<String> synthesisNotes = [];
    if (widget.analysisResult['synthesis_notes'] != null) {
      synthesisNotes =
          List<String>.from(widget.analysisResult['synthesis_notes']);
    }

    final String detailedComment =
        widget.analysisResult['detailed_commentary'] ??
            "Detaylı yorum alınamadı.";
    final confidence = _parseConfidence();

    return Scaffold(
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.mysticalGradient,
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(categoryColor),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildIdentityCard(archetype, desc, traits,
                              categoryColor, confidence),
                          const SizedBox(height: 32),
                          if (traits.isNotEmpty) ...[
                            _buildTraitsRadar(traits, categoryColor),
                            const SizedBox(height: 32),
                          ],
                          if (synthesisNotes.isNotEmpty) ...[
                            _buildSectionHeader(
                                "Sentez Raporu", Icons.auto_awesome),
                            const SizedBox(height: 16),
                            ...synthesisNotes.asMap().entries.map((e) =>
                                _buildInsightCard(
                                    e.value, e.key, categoryColor)),
                            const SizedBox(height: 32),
                          ],
                          _buildSectionHeader("Detaylı Yorum", Icons.menu_book),
                          const SizedBox(height: 16),
                          _buildDetailedCommentary(
                              detailedComment, categoryColor),
                          const SizedBox(height: 32),
                          _buildActionButtons(categoryColor),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(Color categoryColor) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 80,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accentGold,
                    ),
                  )
                : const Icon(Icons.share_outlined, color: AppTheme.textPrimary),
            onPressed: _isSharing ? null : _shareAnalysis,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Analiz Sonucu',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildIdentityCard(String archetype, String desc,
      Map<String, double> traits, Color categoryColor, double confidence) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              categoryColor.withOpacity(0.2),
              AppTheme.cardDark,
              AppTheme.cardLight.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: categoryColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.category.categoryId.categoryIcon,
                    color: categoryColor,
                    size: 28,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "ELOA KİMLİK",
                      style: GoogleFonts.poppins(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.subCategoryTitle,
                      style: GoogleFonts.poppins(
                        color: categoryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    categoryColor.withOpacity(0.3),
                    categoryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                archetype.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: categoryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.back_hand,
                    label: widget.handSide,
                    value: widget.handSide == 'Sağ' ? 'Aktif' : 'Pasif',
                    color: categoryColor,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildStatItem(
                    icon: Icons.category,
                    label: 'Kategori',
                    value: widget.category.displayTitle.split(' ').first,
                    color: categoryColor,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildStatItem(
                    icon: Icons.verified,
                    label: 'Güven',
                    value: '%${(confidence * 100).round()}',
                    color: categoryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTraitsRadar(Map<String, double> traits, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Text(
            'Kişilik Özellikleri',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: RadarChartPainter(
                traits: traits,
                color: categoryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: traits.entries.map((entry) {
              return _buildTraitChip(entry.key, entry.value, categoryColor);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitChip(String trait, double value, Color color) {
    final percentage = (value * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trait,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '%$percentage',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentGold, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGold.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(String text, int index, Color categoryColor) {
    bool isConflict = text.contains("ÇATIŞMA") || text.contains("Dikkat");
    final accentColor = isConflict ? AppTheme.accentCoral : categoryColor;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              accentColor.withOpacity(0.1),
              AppTheme.cardDark,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isConflict ? Icons.warning_amber : Icons.lightbulb_outline,
                color: accentColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                  fontStyle: isConflict ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedCommentary(String comment, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.cardDark,
            AppTheme.cardLight.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.handSide} El • ${widget.handSide == 'Sağ' ? 'Aktif' : 'Pasif'}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: categoryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            comment,
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color categoryColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaved ? null : _saveToHistory,
                icon:
                    Icon(_isSaved ? Icons.check : Icons.bookmark_add_outlined),
                label: Text(_isSaved ? 'Kaydedildi' : 'Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaved
                      ? AppTheme.accentTeal.withOpacity(0.3)
                      : AppTheme.accentTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareAnalysis,
                icon: _isSharing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.share),
                label: Text(_isSharing ? 'Paylaşılıyor...' : 'Paylaş'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacementNamed(context, '/home');
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Yeni Analiz Başlat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentGold,
              side: BorderSide(color: AppTheme.accentGold.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Radar Chart Painter
class RadarChartPainter extends CustomPainter {
  final Map<String, double> traits;
  final Color color;

  RadarChartPainter({required this.traits, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final count = traits.length;

    if (count < 3) return;

    final angleStep = (2 * math.pi) / count;

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final gridRadius = radius * (i / 4);
      canvas.drawCircle(center, gridRadius, gridPaint);
    }

    // Draw axis lines
    final values = traits.values.toList();
    for (int i = 0; i < count; i++) {
      final angle = -math.pi / 2 + angleStep * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw data polygon
    final dataPath = Path();
    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < count; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final angle = -math.pi / 2 + angleStep * i;
      final x = center.dx + radius * value * math.cos(angle);
      final y = center.dy + radius * value * math.sin(angle);

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final angle = -math.pi / 2 + angleStep * i;
      final x = center.dx + radius * value * math.cos(angle);
      final y = center.dy + radius * value * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
