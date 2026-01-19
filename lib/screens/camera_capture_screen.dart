import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_camera_picker.dart';
import '../providers/analysis_provider.dart';
import '../models/analysis_category.dart';
import '../services/ai_analysis_service.dart';
import '../services/purchase_service.dart';
import '../core/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_result_screen.dart';

/// Kamera ile el fotoğrafı çekme ekranı
/// Seçilen kategoriye göre özel talimatlar gösterir
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<AnalysisProvider>();
    final category = analysis.selectedCategory ?? AnalysisCategory.full;
    final handType = analysis.selectedHandIndex == 0 ? 'Sol' : 'Sağ';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.questionTitle} Analizi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kategori ve el bilgisi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 48,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$handType El Fotoğrafı',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getCaptureInstructions(category),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Görsel önizleme alanı
              Expanded(
                child: _capturedImage != null
                    ? _buildImagePreview()
                    : _buildPlaceholder(colorScheme),
              ),

              const SizedBox(height: 16),

              // Hata mesajı
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Butonlar
              if (_isAnalyzing)
                _buildAnalyzingIndicator(colorScheme)
              else
                _buildActionButtons(analysis, category, handType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Elinizin fotoğrafını çekin\nveya galeriden seçin',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _capturedImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: () => setState(() => _capturedImage = null),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingIndicator(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'El çizgileriniz analiz ediliyor...',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu işlem birkaç saniye sürebilir',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    AnalysisProvider analysis,
    AnalysisCategory category,
    String handType,
  ) {
    return Column(
      children: [
        if (_capturedImage == null) ...[
          // Kamera butonu
          ElevatedButton.icon(
            onPressed: () => _captureImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Fotoğraf Çek'),
          ),
          const SizedBox(height: 12),
          // Galeri butonu
          OutlinedButton.icon(
            onPressed: () => _captureImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeriden Seç'),
          ),
        ] else ...[
          // Analiz et butonu
          ElevatedButton.icon(
            onPressed: () => _startAnalysis(analysis, category, handType),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Analizi Başlat'),
          ),
          const SizedBox(height: 12),
          // Tekrar çek butonu
          OutlinedButton.icon(
            onPressed: () => setState(() => _capturedImage = null),
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Çek'),
          ),
        ],
      ],
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    setState(() => _errorMessage = null);

    try {
      final XFile? image;
      if (source == ImageSource.camera) {
        image = await CustomCameraPicker.pickImage(context);
      } else {
        image = await _picker.pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.rear,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
      }

      if (image != null) {
        setState(() {
          _capturedImage = File(image!.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fotoğraf alınamadı: $e';
      });
    }
  }

  Future<void> _startAnalysis(
    AnalysisProvider analysis,
    AnalysisCategory category,
    String handType,
  ) async {
    if (_capturedImage == null) return;

    // Jeton/Premium Kontrolü
    final purchaseService = context.read<PurchaseService>();
    final canProceed = await purchaseService.consumeToken();

    if (!canProceed) {
      if (mounted) _showInsufficientTokensDialog();
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final aiService = AiAnalysisService();
      final result = await aiService.analyzeHand(
        imageFile: _capturedImage!,
        category: category,
        handType: handType,
      );

      if (!mounted) return;

      if (result.hasError) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = result.errorMessage;
        });
        return;
      }

      // Sonuç ekranına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AiResultScreen(
            result: result,
            category: category,
            handType: handType,
            capturedImage: _capturedImage!,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'Analiz başarısız: $e';
        });
      }
    }
  }

  IconData _getCategoryIcon(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.loveGeneral:
        return Icons.favorite;
      case AnalysisCategory.marriage:
        return Icons.diamond;
      case AnalysisCategory.children:
        return Icons.child_care;
      case AnalysisCategory.passion:
        return Icons.local_fire_department;
      case AnalysisCategory.wealth:
        return Icons.attach_money;
      case AnalysisCategory.career:
        return Icons.work;
      case AnalysisCategory.fame:
        return Icons.star;
      case AnalysisCategory.danger:
        return Icons.warning;
      case AnalysisCategory.mystic:
        return Icons.auto_awesome;
      case AnalysisCategory.travel:
        return Icons.flight;
      case AnalysisCategory.health:
        return Icons.favorite_border;
      case AnalysisCategory.character:
        return Icons.psychology;
      case AnalysisCategory.full:
        return Icons.all_inclusive;
    }
  }

  String _getCaptureInstructions(AnalysisCategory category) {
    final baseInstruction =
        'Avuç içinizi kameraya doğru tutun. İyi aydınlatılmış bir ortamda olduğunuzdan emin olun.';

    switch (category) {
      case AnalysisCategory.loveGeneral:
      case AnalysisCategory.marriage:
      case AnalysisCategory.passion:
        return '$baseInstruction\n\n💕 Kalp çizginizin net görünmesi önemlidir.';
      case AnalysisCategory.wealth:
      case AnalysisCategory.career:
        return '$baseInstruction\n\n💰 Kader ve para çizgilerinize odaklanılacak.';
      case AnalysisCategory.health:
        return '$baseInstruction\n\n❤️ Sağlık çizginiz ve genel el yapınız incelenecek.';
      case AnalysisCategory.mystic:
        return '$baseInstruction\n\n✨ Mistik işaretler ve özel semboller aranacak.';
      case AnalysisCategory.travel:
        return '$baseInstruction\n\n✈️ Seyahat çizgileri ve işaretleri incelenecek.';
      case AnalysisCategory.character:
        return '$baseInstruction\n\n🧠 Kafa çizginiz ve parmak yapınız analiz edilecek.';
      default:
        return baseInstruction;
    }
  }

  void _showInsufficientTokensDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Row(
          children: [
            const Icon(Icons.stars, color: AppTheme.accentTeal),
            const SizedBox(width: 8),
            Text('Yetersiz Jeton',
                style: GoogleFonts.poppins(color: AppTheme.textPrimary)),
          ],
        ),
        content: Text(
          'Analiz yapmak için jetonunuz veya Premium üyeliğiniz bulunmamaktadır. Jeton satın alarak veya Premium üye olarak devam edebilirsiniz.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal',
                style: GoogleFonts.poppins(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/premium');
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
            child: Text('Mağazaya Git',
                style: GoogleFonts.poppins(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
