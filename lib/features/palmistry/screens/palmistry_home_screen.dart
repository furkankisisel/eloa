import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palmistry_provider.dart';
import '../../../models/palmistry/palmistry_app_data.dart';
import 'category_detail_screen.dart';
import 'reading_rules_screen.dart';
import 'analysis_result_screen.dart';

class PalmistryHomeScreen extends StatefulWidget {
  const PalmistryHomeScreen({super.key});

  @override
  State<PalmistryHomeScreen> createState() => _PalmistryHomeScreenState();
}

class _PalmistryHomeScreenState extends State<PalmistryHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PalmistryProvider>();
      provider.loadData().then((_) {
        _checkOnboardingDisclaimer(context);
      });
    });
  }

  void _checkOnboardingDisclaimer(BuildContext context) {
    final provider = context.read<PalmistryProvider>();
    // We wait for data to be loaded to get the text
    if (!provider.hasAcceptedDisclaimer && provider.ethicsData != null) {
      final disclaimer = provider.getDisclaimer('onboarding_uyarisi');
      if (disclaimer != null) {
        _showDisclaimerDialog(context, disclaimer, isBlocking: true,
            onAccept: () {
          provider.acceptDisclaimer();
        });
      }
    }
  }

  void _showDisclaimerDialog(BuildContext context, dynamic disclaimer,
      {bool isBlocking = false, VoidCallback? onAccept}) {
    showDialog(
      context: context,
      barrierDismissible: !isBlocking,
      builder: (context) => WillPopScope(
        onWillPop: () async => !isBlocking,
        child: AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text('YASAL UYARI',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Text(
              disclaimer.text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (onAccept != null) onAccept();
                Navigator.pop(context);
              },
              child: const Text('OKUDUM, ANLADIM',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFFFFD700))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PalmistryProvider>();
    final categories = provider.appCategories;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('El Analizi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReadingRulesScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)))
              : Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryCard(context, categories[index]);
                        },
                      ),
                    ),
                    _buildPersistentResultButton(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Kendi Kendine El Analizi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hayatınızın haritasını keşfetmek için aşağıdaki kategorileri tamamlayın.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, AppCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (category.categoryId == 'saglik_ve_yasam') {
            final provider = context.read<PalmistryProvider>();
            final warning = provider.getDisclaimer('saglik_uyarisi');
            if (warning != null) {
              _showDisclaimerDialog(context, warning, onAccept: () {
                _navigateToCategory(context, category);
              });
              return;
            }
          }
          _navigateToCategory(context, category);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Color(0xFFFFD700)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.displayTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white54, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersistentResultButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnalysisResultScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'ANALİZİ TAMAMLA VE YORUMLA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, AppCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: category),
      ),
    );
  }
}
