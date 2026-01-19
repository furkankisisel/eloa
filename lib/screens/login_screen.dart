import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.back_hand_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'ELOA',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kadim Bilgelik, Modern Yapay Zeka',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const Spacer(),

                // Google Sign-In Button
                Consumer<AuthService>(
                  builder: (context, auth, _) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    final success =
                                        await auth.signInWithGoogle();
                                    if (success && context.mounted) {
                                      Navigator.pushReplacementNamed(
                                          context, '/home');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: auth.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Image.network(
                                    'https://www.google.com/favicon.ico',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.g_mobiledata,
                                        size: 24),
                                  ),
                            label: Text(
                              auth.isLoading
                                  ? 'Giriş yapılıyor...'
                                  : 'Google ile Giriş Yap',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            auth.error!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.accentCoral,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Skip Button
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Text(
                    'Giriş yapmadan devam et',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Terms
                Text(
                  'Giriş yaparak Gizlilik Politikası\'nı kabul etmiş olursunuz.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
