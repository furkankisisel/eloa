import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../services/dream_interpretation_service.dart';
import '../services/history_storage_service.dart';
import '../models/analysis_history.dart';

/// Rüya Tabiri Ekranı
/// Kullanıcı rüyasını metin olarak girer ve AI ile yorumlanır
class DreamInterpretationScreen extends StatefulWidget {
  const DreamInterpretationScreen({super.key});

  @override
  State<DreamInterpretationScreen> createState() =>
      _DreamInterpretationScreenState();
}

class _DreamInterpretationScreenState extends State<DreamInterpretationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _dreamController = TextEditingController();
  final DreamInterpretationService _dreamService = DreamInterpretationService();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  DreamInterpretationResult? _result;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _dreamController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _interpretDream() async {
    if (_dreamController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen rüyanızı yazın'),
          backgroundColor: AppTheme.accentCoral,
        ),
      );
      return;
    }

    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _result = null;
    });

    // Premium kısıtı kaldırıldı - herkes tam yorumu görebilir
    final result = await _dreamService.interpretDream(
      dreamText: _dreamController.text,
      isPremium: true, // Şimdilik herkes premium
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = result;
      });
      _animationController.forward(from: 0);

      // Başarılı ise geçmişe kaydet
      if (result.success && result.fullInterpretation != null) {
        await _saveToHistory(result.fullInterpretation!);
      }
    }
  }

  /// Rüya yorumunu geçmişe kaydet
  Future<void> _saveToHistory(String interpretation) async {
    final dreamPreview = _dreamController.text.length > 50
        ? '${_dreamController.text.substring(0, 50)}...'
        : _dreamController.text;

    final history = AnalysisHistory(
      id: AnalysisHistory.generateId(),
      createdAt: DateTime.now(),
      categoryId: 'ruya_tabiri',
      categoryTitle: 'Rüya Tabiri',
      subCategoryTitle: dreamPreview,
      handType: 'Rüya', // Rüya için özel
      aiCommentary: interpretation,
      matches: [],
    );

    await HistoryStorageService.instance.saveAnalysis(history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Rüya Tabiri',
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDreamInput(),
                const SizedBox(height: 20),
                _buildInterpretButton(),
                const SizedBox(height: 24),
                if (_isLoading) _buildLoadingIndicator(),
                if (_result != null) _buildResultCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(
        borderColor: AppTheme.accentPurple.withOpacity(0.3),
        opacity: 0.08,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.nights_stay_rounded,
            color: AppTheme.accentPurple,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Rüyanı Anlat',
            style: GoogleFonts.playfairDisplay(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gördüğün rüyayı detaylı bir şekilde yaz.\nEloa, kadim bilgileriyle rüyanı yorumlasın.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamInput() {
    return Container(
      decoration: AppTheme.glassDecoration(
        borderColor: AppTheme.accentGold.withOpacity(0.2),
        opacity: 0.06,
      ),
      child: TextField(
        controller: _dreamController,
        focusNode: _focusNode,
        maxLines: 8,
        minLines: 5,
        style: GoogleFonts.poppins(
          color: AppTheme.textPrimary,
          fontSize: 15,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText:
              'Örnek: Dün gece uçan bir at gördüm. At beni bir dağın tepesine götürdü ve orada parlak bir ışık vardı...',
          hintStyle: GoogleFonts.poppins(
            color: AppTheme.textMuted,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildInterpretButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _interpretDream,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Rüyamı Yorumla',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppTheme.accentPurple,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rüyanız yorumlanıyor...',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yıldızlar arasında anlam aranıyor ✨',
            style: GoogleFonts.poppins(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();

    if (!_result!.success) {
      return _buildErrorCard(_result!.error ?? 'Bir hata oluştu.');
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.accentCardDecoration(
              accentColor: AppTheme.accentPurple,
              borderRadius: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppTheme.accentGold,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Rüya Yorumun',
                      style: GoogleFonts.playfairDisplay(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _result!.displayInterpretation,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentCoral.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentCoral.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.accentCoral,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
