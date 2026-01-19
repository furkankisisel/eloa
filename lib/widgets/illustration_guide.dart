import 'package:flutter/material.dart';

class IllustrationGuide extends StatelessWidget {
  final String illustrationName; // e.g., 'fate_line'
  final String label;

  const IllustrationGuide({
    super.key,
    required this.illustrationName,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Map simplified target names to actual filenames if needed,
    // or assume the provider passed the correct filename base.
    // For now, let's try to load directly from assets/illustrations/
    final path = 'assets/illustrations/$illustrationName.png';

    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  path,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, _, __) => const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white24, size: 50),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.7),
                    child: Text(
                      label.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
