import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palmistry_provider.dart';

class ReadingRulesScreen extends StatelessWidget {
  const ReadingRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PalmistryProvider>();
    final rulesData = provider.readingRules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('El Okuma Usulleri'),
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
          child: rulesData == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoCard(context, rulesData.categoryInfo.description),
                    const SizedBox(height: 16),
                    ...rulesData.readingRules
                        .map((rule) => _buildRuleCard(context, rule)),
                    if (rulesData.fingerprints.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Parmak İzleri',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...rulesData.fingerprints
                          .map((fp) => _buildFingerprintCard(context, fp)),
                    ],
                    if (rulesData.handGestures.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'El Duruş ve Hareketleri',
                          style: TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...rulesData.handGestures
                          .map((g) => _buildGestureCard(context, g)),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String? description) {
    if (description == null) return const SizedBox.shrink();
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          description,
          style:
              const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, dynamic rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      child: ExpansionTile(
        title: Text(
          rule.name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          rule.description,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        iconColor: const Color(0xFFFFD700),
        collapsedIconColor: Colors.white54,
        children: [
          if (rule.details != null)
            ...(rule.details as List).map((d) => ListTile(
                  title: Text(d.hand ?? '',
                      style: const TextStyle(color: Color(0xFFFFD700))),
                  subtitle: Text(
                      "${d.meaning ?? ''}\n${d.interpretationLogic ?? ''}",
                      style: const TextStyle(color: Colors.white70)),
                  isThreeLine: true,
                )),
        ],
      ),
    );
  }

  Widget _buildFingerprintCard(BuildContext context, dynamic fp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fp.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(fp.visualDesc,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text(fp.meaning, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureCard(BuildContext context, dynamic gesture) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      child: ExpansionTile(
        title: Text(
          gesture.name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconColor: Colors.pinkAccent,
        collapsedIconColor: Colors.white54,
        children: [
          ...(gesture.types as List).map((t) => ListTile(
                title: Text(t.style,
                    style: const TextStyle(color: Colors.pinkAccent)),
                subtitle: Text(t.meaning,
                    style: const TextStyle(color: Colors.white70)),
              )),
        ],
      ),
    );
  }
}
