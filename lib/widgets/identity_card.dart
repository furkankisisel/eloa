import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityCard extends StatelessWidget {
  final String userName;
  final String archetypeTitle; // e.g., "MANTIKLI LİDER"
  final String archetypeDesc; // e.g., "Duygularını yönetebilen..."
  final Map<String, double> traits; // "İrade": 0.8

  const IdentityCard({
    super.key,
    this.userName = "Gezgin",
    required this.archetypeTitle,
    required this.archetypeDesc,
    required this.traits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.fingerprint, color: Colors.grey[600], size: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "ELOA IDENTITY",
                    style: GoogleFonts.montserrat(
                      color: Colors.grey[400],
                      fontSize: 10,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    userName.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Archetype Title
          Text(
            archetypeTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: const Color(0xFFD4AF37), // Gold
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            archetypeDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white70,
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 32),

          // Traits Bars
          ...traits.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.key,
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value,
                      backgroundColor: Colors.grey[800],
                      color: _getColorForTrait(entry.key),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "%${(entry.value * 100).toInt()}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getColorForTrait(String trait) {
    if (trait.contains("İrade")) return Colors.red;
    if (trait.contains("Mantık")) return Colors.blue;
    if (trait.contains("Duygu") || trait.contains("Tutku")) return Colors.pink;
    return const Color(0xFFD4AF37);
  }
}
