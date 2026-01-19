import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroDisclaimerScreen extends StatefulWidget {
  const IntroDisclaimerScreen({super.key});

  @override
  State<IntroDisclaimerScreen> createState() => _IntroDisclaimerScreenState();
}

class _IntroDisclaimerScreenState extends State<IntroDisclaimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  // Text from 34_etik_ve_kullanim_prensipleri.json
  final String _disclaimerText =
      "\"Bu uygulama, kadim İlmi Sima ve El Okuma (Chiromancy) prensiplerine dayanarak geliştirilmiştir.\n\n"
      "Burada sunulan analizler, bilimsel bir tanı değil, binlerce yıllık insanlık birikiminin modern bir yansımasıdır.\n\n"
      "Karakteriniz kaderiniz değil, tuvalinizdir. Fırça sizin elinizde...\"";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _startSequence();
  }

  void _startSequence() async {
    // Fade in
    await _controller.forward();

    // Wait for reading
    await Future.delayed(const Duration(seconds: 4));

    // Fade out
    await _controller.reverse();

    // Navigate
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: AnimatedBuilder(
            animation: _opacityAnim,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnim.value,
                child: Text(
                  _disclaimerText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    // Mystical font
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.6,
                    letterSpacing: 1.1,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
