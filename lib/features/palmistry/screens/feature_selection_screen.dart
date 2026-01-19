import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/palmistry_provider.dart';
import '../../../models/palmistry/palmistry_data.dart';

class FeatureSelectionScreen extends StatelessWidget {
  final String topicId;
  final PalmistrySection section;

  const FeatureSelectionScreen({
    super.key,
    required this.topicId,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: section.features.length,
            itemBuilder: (context, index) {
              final feature = section.features[index];
              return _buildFeatureCard(context, feature);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, PalmistryFeature feature) {
    return Consumer<PalmistryProvider>(
      builder: (context, provider, _) {
        final isSelected =
            provider.getSelectedFeature(topicId, section.id)?.id == feature.id;

        return Card(
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              provider.selectFeature(topicId, section.id, feature);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        feature.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFFFFD700)
                              : Colors.white,
                        ),
                      )),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: Color(0xFFFFD700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature.bookContent,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
