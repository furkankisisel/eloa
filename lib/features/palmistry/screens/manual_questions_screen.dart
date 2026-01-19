import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palmistry_provider.dart';
import '../../../models/palmistry/palmistry_data.dart';

class ManualQuestionsScreen extends StatefulWidget {
  const ManualQuestionsScreen({super.key});

  @override
  State<ManualQuestionsScreen> createState() => _ManualQuestionsScreenState();
}

class _ManualQuestionsScreenState extends State<ManualQuestionsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manuel Teyit Soruları'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<PalmistryProvider>(
            builder: (context, provider, _) {
              if (provider.manualQuestions == null) {
                return const Center(
                    child: Text('Sorular yüklenemedi',
                        style: TextStyle(color: Colors.white)));
              }

              final questions = [
                ...provider.manualQuestions!.tactileQuestions,
                ...provider.manualQuestions!.flexibilityQuestions,
                ...provider.manualQuestions!.colorConfirmationQuestions,
              ];

              if (questions.isEmpty) {
                return const Center(
                    child: Text('Soru bulunamadı',
                        style: TextStyle(color: Colors.white)));
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / questions.length,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD700)),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Force navigation via buttons
                      itemCount: questions.length,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemBuilder: (context, index) {
                        return _buildQuestionPage(
                            context, provider, questions[index]);
                      },
                    ),
                  ),
                  _buildNavigationButtons(context, questions.length),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPage(BuildContext context, PalmistryProvider provider,
      PalmistryQuestion question) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (question.instruction != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(question.instruction!,
                          style: const TextStyle(color: Colors.white70))),
                ]),
              ),
            ),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected =
                    provider.getAnswer(question.questionId ?? '')?.answer ==
                        option.answer;

                return GestureDetector(
                  onTap: () {
                    if (question.questionId != null) {
                      provider.answerQuestion(question.questionId!, option);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFD700).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : Colors.white10,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(option.answer,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16))),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFFFFD700)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, int totalQuestions) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentIndex > 0)
            ElevatedButton(
              onPressed: () {
                _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
              ),
              child: const Text('Geri'),
            )
          else
            const SizedBox(), // Spacer

          ElevatedButton(
            onPressed: () {
              if (_currentIndex < totalQuestions - 1) {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              } else {
                Navigator.pop(context); // Finish
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child:
                Text(_currentIndex < totalQuestions - 1 ? 'İlerle' : 'Tamamla'),
          ),
        ],
      ),
    );
  }
}
