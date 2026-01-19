import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palmistry_provider.dart';
import '../../../services/ai_analysis_service.dart';

class AnalysisResultScreen extends StatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final AiAnalysisService _aiService = AiAnalysisService();
  String? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    final provider = context.read<PalmistryProvider>();
    final promptStr = provider.generateAnalysisPrompt();

    // Check if user actually selected anything
    // Even if empty, we might want to let AI say "You didn't select anything"

    try {
      final response = await _aiService.generatePalmistryInterpretation(
          promptStr,
          images: provider.selectedImages);
      if (mounted) {
        setState(() {
          _result = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = "Bir hata oluştu: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Sonucu'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFFFD700)),
                      SizedBox(height: 16),
                      Text('Yıldızlar inceleniyor...',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Color(0xFFFFD700), size: 48),
                          const SizedBox(height: 24),
                          Text(
                            _result ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Kapat'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
