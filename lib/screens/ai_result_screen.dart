import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/analysis_category.dart';
import '../services/ai_analysis_service.dart';

/// AI analiz sonuçlarını gösteren ekran
class AiResultScreen extends StatefulWidget {
  final AiAnalysisResult result;
  final AnalysisCategory category;
  final String handType;
  final File capturedImage;

  const AiResultScreen({
    super.key,
    required this.result,
    required this.category,
    required this.handType,
    required this.capturedImage,
  });

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  bool _isLoadingCommentary = false;
  String? _aiCommentary;
  String? _commentaryError;

  @override
  void initState() {
    super.initState();
    _loadAICommentary();
  }

  Future<void> _loadAICommentary() async {
    if (widget.result.matches.isEmpty) return;

    setState(() {
      _isLoadingCommentary = true;
      _commentaryError = null;
    });

    try {
      final aiService = AiAnalysisService();
      final commentary = await aiService.generateDetailedCommentary(
        analysisResult: widget.result,
        handType: widget.handType,
      );

      if (mounted) {
        setState(() {
          _aiCommentary = commentary;
          _isLoadingCommentary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _commentaryError = 'Yorum yüklenemedi: $e';
          _isLoadingCommentary = false;
        });
      }
    }
  }

  void _copyResultsToClipboard() {
    final buffer = StringBuffer();

    // Başlık ve uygulama ismi
    buffer.writeln('✨ ELOA - Mistik El Analizi ✨');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
    buffer.writeln('📋 ${widget.category.questionTitle} Sonuçları');
    buffer.writeln('🖐️ ${widget.handType} El Analizi');
    buffer.writeln();

    // Güven skoru
    buffer.writeln(
        '📊 Güven Skoru: %${(widget.result.confidence * 100).toInt()}');
    buffer.writeln();

    // AI Yorumu
    if (_aiCommentary != null && _aiCommentary!.isNotEmpty) {
      buffer.writeln('🔮 AI Yorumu:');
      buffer.writeln(_aiCommentary);
      buffer.writeln();
    }

    // Tespit edilen işaretler - geçerli olanları filtrele
    final validMatches = widget.result.matches.where((match) {
      final question = match['question'] as String?;
      final answer = match['matchedAnswer'] as Map<String, dynamic>?;
      final answerText = answer?['text'] as String?;
      return question != null &&
          question.isNotEmpty &&
          answerText != null &&
          answerText.isNotEmpty;
    }).toList();

    if (validMatches.isNotEmpty) {
      buffer.writeln('📌 Tespit Edilen İşaretler:');
      buffer.writeln('─────────────────────────');

      for (final match in validMatches) {
        final question = match['question'] as String? ?? '';
        final answer = match['matchedAnswer'] as Map<String, dynamic>?;
        final answerText = answer?['text'] as String? ?? '';
        final meaning = answer?['meaning'] as String? ?? '';

        buffer.writeln('• $question');
        buffer.writeln('  → $answerText');
        if (meaning.isNotEmpty) {
          buffer.writeln('  💡 $meaning');
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.questionTitle} Sonuçları'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _copyResultsToClipboard,
            icon: const Icon(Icons.copy),
            tooltip: 'Sonuçları Kopyala',
          ),
          IconButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.home),
            tooltip: 'Ana Sayfa',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fotoğraf ve özet başlık
            _buildHeader(colorScheme),

            const SizedBox(height: 24),

            // Güven skoru ve kalite
            _buildConfidenceCard(colorScheme),

            const SizedBox(height: 24),

            // AI Yorumu
            _buildCommentarySection(colorScheme),

            const SizedBox(height: 24),

            // Eşleşen işaretler listesi
            _buildMatchesList(colorScheme),

            const SizedBox(height: 32),

            // Yeniden analiz butonu
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.refresh),
              label: const Text('Yeni Analiz Yap'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.2),
            colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // El fotoğrafı küçük resmi
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              widget.capturedImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.handType} El Analizi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.category.questionTitle,
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.result.matches.length} işaret tespit edildi',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(ColorScheme colorScheme) {
    final confidence = widget.result.confidence;
    final quality = _parseQuality(widget.result.imageQuality);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildScoreIndicator(
              label: 'Güven Skoru',
              value: confidence,
              icon: Icons.psychology,
              color: _getConfidenceColor(confidence),
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: colorScheme.outline.withOpacity(0.2),
          ),
          Expanded(
            child: _buildScoreIndicator(
              label: 'Görsel Kalite',
              value: quality,
              icon: Icons.image,
              color: _getQualityColor(quality),
            ),
          ),
        ],
      ),
    );
  }

  double _parseQuality(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'good':
        return 0.9;
      case 'fair':
        return 0.6;
      case 'poor':
        return 0.3;
      default:
        return 0.5;
    }
  }

  Widget _buildScoreIndicator({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentarySection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Yorumu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingCommentary)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kişisel yorumunuz hazırlanıyor...',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else if (_commentaryError != null)
            Text(
              _commentaryError!,
              style: TextStyle(color: colorScheme.error),
            )
          else if (_aiCommentary != null)
            Text(
              _aiCommentary!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            )
          else
            Text(
              'Yorum hazırlanamadı.',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(ColorScheme colorScheme) {
    if (widget.result.matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu kategoride işaret bulunamadı',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Geçerli match'leri filtrele (boş soru veya cevap içerenleri çıkar)
    final validMatches = widget.result.matches.where((match) {
      final question = match['question'] as String?;
      final answer = match['matchedAnswer'] as Map<String, dynamic>?;
      final answerText = answer?['text'] as String?;
      return question != null &&
          question.isNotEmpty &&
          answerText != null &&
          answerText.isNotEmpty;
    }).toList();

    if (validMatches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tespit Edilen İşaretler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...validMatches.map((match) => _buildMatchCard(match, colorScheme)),
      ],
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match, ColorScheme colorScheme) {
    final question = match['question'] as String? ?? '';
    final answer = match['matchedAnswer'] as Map<String, dynamic>?;
    final answerText = answer?['text'] as String? ?? '';
    final meaning = answer?['meaning'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              answerText,
              style: TextStyle(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (meaning.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              meaning,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double value) {
    if (value >= 0.8) return Colors.green;
    if (value >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getQualityColor(double value) {
    if (value >= 0.7) return Colors.green;
    if (value >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
