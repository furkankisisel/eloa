import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../features/palmistry/providers/palmistry_provider.dart';
import '../models/palmistry/palmistry_app_data.dart';
import '../models/palmistry/palmistry_data.dart';
import '../widgets/illustration_guide.dart';
import '../widgets/custom_camera_picker.dart';
import 'processing_screen.dart';

class AnalysisWizardScreen extends StatefulWidget {
  final AppCategory category;
  final SubCategory? subCategory;
  final String subCategoryTitle;
  final String handSide;

  const AnalysisWizardScreen({
    super.key,
    required this.category,
    this.subCategory,
    required this.subCategoryTitle,
    required this.handSide,
  });

  @override
  State<AnalysisWizardScreen> createState() => _AnalysisWizardScreenState();
}

class _AnalysisWizardScreenState extends State<AnalysisWizardScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  List<dynamic> _steps = [];

  @override
  void initState() {
    super.initState();
    _prepareSteps();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PalmistryProvider>().clearAll();
    });
  }

  void _prepareSteps() {
    final provider = context.read<PalmistryProvider>();

    if (widget.subCategory != null) {
      _steps.addAll(widget.subCategory!.requiredData.visualInputs);
      final manualQs = provider.getQuestionsForSubCategory(widget.subCategory!);
      _steps.addAll(manualQs);
    } else {
      final manualQs = provider.getQuestionsForCategory(widget.category);
      _steps.addAll(manualQs);
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await CustomCameraPicker.pickImage(context);

    if (photo != null) {
      if (mounted) {
        context.read<PalmistryProvider>().addImage(photo);
        _nextStep();
      }
    }
  }

  void _answerQuestion(String questionId, PalmistryOption option) {
    context.read<PalmistryProvider>().answerQuestion(questionId, option);
    _nextStep();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessingScreen(
            category: widget.category,
            subCategory: widget.subCategory,
            subCategoryTitle: widget.subCategoryTitle,
            handSide: widget.handSide,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.category.categoryId.categoryColor;

    if (_steps.isEmpty) {
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
                  const CircularProgressIndicator(color: AppTheme.accentGold),
                  const SizedBox(height: 24),
                  Text(
                    "Analiz başlatılıyor...",
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProcessingScreen(
                            category: widget.category,
                            subCategory: widget.subCategory,
                            subCategoryTitle: widget.subCategoryTitle,
                            handSide: widget.handSide,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Devam Et"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(categoryColor),
              _buildProgressIndicator(categoryColor),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final stepItem = _steps[index];
                    if (stepItem is VisualInput) {
                      return _buildVisualStep(stepItem, categoryColor);
                    } else if (stepItem is PalmistryQuestion) {
                      return _buildManualStep(stepItem, categoryColor);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.subCategoryTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${widget.handSide} El • Adım ${_currentStep + 1}/${_steps.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted
                    ? categoryColor
                    : isCurrent
                        ? categoryColor.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVisualStep(VisualInput input, Color categoryColor) {
    String imgName = _mapTargetToIllustration(input.target);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt,
                    color: AppTheme.accentGold, size: 16),
                const SizedBox(width: 8),
                Text(
                  "FOTOĞRAF GEREKLİ",
                  style: GoogleFonts.poppins(
                    color: AppTheme.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            input.reason,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: IllustrationGuide(
              illustrationName: imgName,
              label: "Örnek: ${_humanize(input.target)}",
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("FOTOĞRAF ÇEK"),
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualStep(PalmistryQuestion q, Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app,
                    color: AppTheme.accentTeal, size: 16),
                const SizedBox(width: 8),
                Text(
                  "HİS VE GÖZLEM",
                  style: GoogleFonts.poppins(
                    color: AppTheme.accentTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            q.userQuestion ?? "",
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: AppTheme.textPrimary,
              fontSize: 20,
              height: 1.4,
            ),
          ),
          if (q.instruction != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                q.instruction!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: q.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final opt = q.options[i];
                return _buildOptionButton(
                    opt, q.questionId ?? "unknown", categoryColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
      PalmistryOption opt, String questionId, Color categoryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.cardDark,
            AppTheme.cardLight.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _answerQuestion(questionId, opt),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    opt.answer,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.textMuted.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mapTargetToIllustration(String target) {
    if (target.contains('kader')) return 'fate_line';
    if (target.contains('akil')) return 'head_line';
    if (target.contains('kalp')) return 'heart_line';
    if (target.contains('hayat')) return 'life';
    if (target.contains('gunes_cizgisi')) return 'sun_line';
    if (target.contains('merkur_cizgisi') || target.contains('saglik'))
      return 'health_line';
    if (target.contains('evlilik')) return 'marriage_line';
    if (target.contains('seyahat')) return 'travel_line';
    if (target.contains('sezgi')) return 'intuition_line';
    if (target.contains('jupiter_tepesi')) return 'jupiter_mount';
    if (target.contains('saturn_tepesi')) return 'saturn_mount';
    if (target.contains('gunes_tepesi')) return 'sun_mount';
    if (target.contains('merkur_tepesi')) return 'mercur_mount';
    if (target.contains('venus_tepesi')) return 'venus_mount';
    if (target.contains('mars_tepesi')) return 'mars_mount';
    if (target.contains('ay_tepesi')) return 'moon_mount';
    if (target.contains('mars_yaylasi') || target.contains('dunya'))
      return 'earth_mount';
    if (target.contains('basparmak')) return 'Head_finger';
    if (target.contains('isaret')) return 'Index_finger';
    if (target.contains('saturn_parmagi') || target.contains('orta_parmak'))
      return 'Middle_parmak';
    if (target.contains('yuzuk')) return 'Ring_finger';
    if (target.contains('serce')) return 'Pinky_finger';
    if (target.contains('venus_halka') || target.contains('venus_ring'))
      return 'venus_ring';
    if (target.contains('buyuk_ucgen') || target.contains('para_ucgen'))
      return 'money_triangle';
    if (target.contains('bilezik') || target.contains('rascette'))
      return 'rings';
    if (target.contains('nesil') || target.contains('cocuk'))
      return 'children_line';
    if (target.contains('tirnak') || target.contains('el_sekli'))
      return 'nails_and_handshape';
    if (target.contains('zaman_tayini'))
      return 'between_headline_and_heartline';
    if (target.contains('el_rengi') || target.contains('kirmizi_el'))
      return 'colors';
    if (target.contains('parmak_bogum')) return 'finger_joints';
    if (target.contains('parmak_uzunluk')) return 'finger_length';
    if (target.contains('parmak_uclari') || target.contains('parmak_uc'))
      return 'fingertips_';
    if (target.contains('yildiz_isaret') ||
        target.contains('kare_isaret') ||
        target.contains('ucgen_isaret') ||
        target.contains('izgara_isaret')) return 'signs';
    return target;
  }

  String _humanize(String s) {
    return s.replaceAll('_', ' ').toUpperCase();
  }
}
