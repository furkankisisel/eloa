import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../features/palmistry/providers/palmistry_provider.dart';
import '../models/palmistry/palmistry_app_data.dart';
import 'advanced_result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final AppCategory category;
  final SubCategory? subCategory;
  final String subCategoryTitle;
  final String handSide;

  const ProcessingScreen({
    super.key,
    required this.category,
    this.subCategory,
    required this.subCategoryTitle,
    required this.handSide,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  String _statusText = "Görüntüler Taranıyor...";
  double _progress = 0.0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _steps = [
    "Hatlar Belirleniyor...",
    "Kombinasyonlar Taranıyor...",
    "Çelişkili Veriler Çözümleniyor...",
    "Sentez Katmanı Uygulanıyor...",
    "Nihai Rapor Hazırlanıyor..."
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startAnalysis();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startAnalysis() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          _statusText = _steps[i];
          _progress = (i + 1) / _steps.length;
        });
      }
    }

    final provider = context.read<PalmistryProvider>();
    final resultData =
        await provider.analyzeWithAI(subCategory: widget.subCategory);

    if (resultData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Bağlantı hatası. Lütfen internetinizi kontrol edin."),
            backgroundColor: AppTheme.accentCoral,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (resultData['success'] == false) {
      if (mounted) {
        String reason = resultData['reason'] ?? "Bilinmeyen hata.";
        String errorCode = resultData['error_code'] ?? "UNKNOWN";

        if (errorCode == 'POOR_IMAGE') {
          _showRetryDialog(
            "Görsel Yetersiz",
            "Yüklediğiniz fotoğraf analiz edilemedi.\n\nSebep: $reason\n\nLütfen elinizi daha aydınlık ve net bir şekilde çekip tekrar deneyin.",
          );
        } else {
          _showRetryDialog("Analiz Hatası", reason);
        }
      }
      return;
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdvancedResultScreen(
            category: widget.category,
            subCategoryTitle: widget.subCategoryTitle,
            handSide: widget.handSide,
            analysisResult: resultData,
          ),
        ),
      );
    }
  }

  void _showRetryDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              "TEKRAR DENE",
              style: GoogleFonts.poppins(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.category.categoryId.categoryColor;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Category info
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: categoryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.subCategoryTitle,
                    style: GoogleFonts.poppins(
                      color: categoryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Animated progress indicator
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Progress ring
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(
                          value: _progress,
                          color: AppTheme.accentGold,
                          strokeWidth: 3,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      // Center icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.back_hand,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Status text
                Text(
                  _statusText,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Progress percentage
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "%${(_progress * 100).toInt()}",
                    style: GoogleFonts.poppins(
                      color: AppTheme.accentGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 80),

                // Info text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Yapay zeka ile elinizi analiz ediyoruz...\nBu işlem birkaç saniye sürebilir.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
