import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import 'result_screen.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  bool _initialized = false;
  late PageController _pageController;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final analysis = context.read<AnalysisProvider>();
      if (analysis.questions.isEmpty && !analysis.isAnalysisCompleted) {
        analysis.loadNextModule();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<AnalysisProvider>();
    final questions = analysis.questions;

    if (analysis.isAnalysisCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ResultScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: _buildGradientBackground(),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, analysis),
              _buildProgressIndicator(analysis, questions.length),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  onPageChanged: (index) {
                    setState(() => _currentQuestionIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final q = questions[index] as Map<String, dynamic>;
                    return _buildQuestionPage(context, analysis, q, index);
                  },
                ),
              ),
              _buildNavigationButtons(context, analysis, questions),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A0A2E),
          Color(0xFF16213E),
          Color(0xFF0F0F23),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AnalysisProvider analysis) {
    final moduleNames = ['El Yapısı', 'Ten Rengi', 'Parmaklar'];
    final currentModule = analysis.currentModuleIndex < moduleNames.length
        ? moduleNames[analysis.currentModuleIndex]
        : 'Analiz';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showExitDialog(context),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  currentModule,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adım ${analysis.currentModuleIndex + 1}/${analysis.totalModules}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
      AnalysisProvider analysis, int totalQuestions) {
    final answeredCount = analysis.selectedOptions.length;
    final progress = totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru ${_currentQuestionIndex + 1}/$totalQuestions',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% tamamlandı',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(BuildContext context, AnalysisProvider analysis,
      Map<String, dynamic> question, int index) {
    final category = question['category']?.toString() ?? '';
    final questionText = question['question_text']?.toString() ?? 'Soru';
    final rawOpts = question['options'] as List<dynamic>? ?? const [];
    final options =
        rawOpts.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          ...options
              .map((opt) => _buildOptionCard(context, analysis, question, opt)),
          const SizedBox(height: 16),
          // Boş Geç butonu
          _buildSkipButton(context, analysis, question),
        ],
      ),
    );
  }

  Widget _buildSkipButton(
    BuildContext context,
    AnalysisProvider analysis,
    Map<String, dynamic> question,
  ) {
    final selected = analysis.selectedOptions[question['id']];
    final isSkipped = selected != null && selected['isSkipped'] == true;

    return GestureDetector(
      onTap: () => analysis.skipQuestion(question),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: isSkipped
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSkipped
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: isSkipped ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSkipped ? Icons.check_circle : Icons.not_interested,
              color: isSkipped ? Colors.white70 : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isSkipped ? 'Bu soru atlandı' : 'Bu işaret bende yok, boş geç',
              style: TextStyle(
                fontSize: 14,
                color: isSkipped ? Colors.white70 : Colors.white38,
                fontWeight: isSkipped ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    AnalysisProvider analysis,
    Map<String, dynamic> question,
    Map<String, dynamic> option,
  ) {
    final selected = analysis.selectedOptions[question['id']];
    final isSelected = selected != null && selected['label'] == option['label'];
    final imagePath = option['image_path']?.toString();
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return GestureDetector(
      onTap: () => analysis.selectOption(question, option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.2),
                    const Color(0xFF9C27B0).withOpacity(0.2),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['label']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFFFD700)
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['description']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Küçük görsel önizleme (varsa)
                if (hasImage)
                  GestureDetector(
                    onTap: () => _showImageDialog(
                        context, imagePath, analysis.selectedHandIndex == 0),
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Transform.flip(
                          flipX: analysis.selectedHandIndex ==
                              0, // Sol el için yansıt
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                color: Colors.white38,
                                size: 24,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(
      BuildContext context, String imagePath, bool flipImage) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Transform.flip(
                  flipX: flipImage, // Sol el için yansıt
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.white38,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Görsel yüklenemedi',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Kapat',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context,
      AnalysisProvider analysis, List<Map<String, dynamic>> questions) {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex == questions.length - 1;
    final currentQuestion = questions[_currentQuestionIndex];
    final isAnswered =
        analysis.selectedOptions.containsKey(currentQuestion['id']);
    final allAnswered = _allQuestionsAnswered(questions, analysis);
    final isLastModule =
        analysis.currentModuleIndex >= analysis.totalModules - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          if (!isFirstQuestion)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Önceki'),
              ),
            ),
          if (!isFirstQuestion) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isAnswered
                  ? () {
                      if (isLastQuestion) {
                        if (allAnswered) {
                          _completeModule(analysis);
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white.withOpacity(0.1),
                disabledForegroundColor: Colors.white38,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isLastQuestion
                    ? (isLastModule ? 'Analizi Tamamla' : 'Sonraki Adım')
                    : 'Devam Et',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _allQuestionsAnswered(
      List<Map<String, dynamic>> questions, AnalysisProvider analysis) {
    for (final q in questions) {
      if (q['question_text'] == null) continue;
      if (!analysis.selectedOptions.containsKey(q['id'])) {
        return false;
      }
    }
    return true;
  }

  void _completeModule(AnalysisProvider analysis) {
    final List<Map<String, dynamic>> selections = [];
    for (final q in analysis.questions) {
      final selected = analysis.selectedOptions[q['id']];
      // Boş geçilen soruları dahil etme
      if (selected != null && selected['isSkipped'] != true) {
        selections.add({
          'category': q['category'],
          'question': q['question_text'],
          'label': selected['label'],
          'description': selected['description'],
          'analysis_result': selected['analysis_result'],
        });
      }
    }

    final moduleResult = <String, dynamic>{
      'moduleIndex': analysis.currentModuleIndex,
      'selections': selections,
    };

    analysis.accumulateResults(moduleResult);

    setState(() {
      _currentQuestionIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Analizi Bırak', style: TextStyle(color: Colors.white)),
        content: const Text(
          'İlerlemeniz kaybolacak. Emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Çık', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
