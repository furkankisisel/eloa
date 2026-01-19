import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/purchase_service.dart';
import '../core/app_theme.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppTheme.textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        'Premium',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: Consumer<PurchaseService>(
                  builder: (context, purchase, _) {
                    if (purchase.isPremium) {
                      return _buildPremiumActive(context);
                    }
                    return _buildPremiumOffer(context, purchase);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActive(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Premium Aktif! 🎉',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tüm premium özelliklere erişiminiz var.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumOffer(BuildContext context, PurchaseService purchase) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  'ELOA Premium',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tüm özelliklerin kilidini aç',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Balance Check
          if (!purchase.isPremium) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: AppTheme.accentTeal),
                  const SizedBox(width: 8),
                  Text(
                    'Jeton Bakiyeniz: ${purchase.tokenBalance}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Features
          _buildFeatureItem(Icons.all_inclusive, 'Sınırsız Analiz',
              'Günlük limit olmadan analiz yapın (Premium)'),
          _buildFeatureItem(Icons.stars, 'Tekli Analiz',
              'Jeton ile dilediğiniz zaman analiz yapın'),
          _buildFeatureItem(
              Icons.history, 'Tam Geçmiş', 'Tüm analizlerinizi saklayın'),

          const SizedBox(height: 32),

          // Products
          if (purchase.isLoading)
            const CircularProgressIndicator(color: AppTheme.accentGold)
          else if (purchase.products.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Ürünler yükleniyor...',
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => purchase.loadProducts(),
                    child: Text(
                      'Tekrar Dene',
                      style: GoogleFonts.poppins(color: AppTheme.accentGold),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Subscriptions
            if (purchase.products.any((p) => !p.id.contains('token'))) ...[
              Text(
                'Abonelikler',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold),
              ),
              const SizedBox(height: 12),
              ...purchase.products.where((p) => !p.id.contains('token')).map(
                  (product) => _buildProductCard(context, product, purchase,
                      isToken: false)),
              const SizedBox(height: 24),
            ],

            // Tokens
            if (purchase.products.any((p) => p.id.contains('token'))) ...[
              Text(
                'Jeton Paketleri',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentTeal),
              ),
              const SizedBox(height: 12),
              ...purchase.products.where((p) => p.id.contains('token')).map(
                  (product) => _buildProductCard(context, product, purchase,
                      isToken: true)),
            ],
          ],

          const SizedBox(height: 16),

          // Restore Button
          TextButton(
            onPressed:
                purchase.isLoading ? null : () => purchase.restorePurchases(),
            child: Text(
              'Satın Alımları Geri Yükle',
              style: GoogleFonts.poppins(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ),

          if (purchase.error != null) ...[
            const SizedBox(height: 16),
            Text(
              purchase.error!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.accentCoral,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppTheme.accentTeal, size: 24),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, dynamic product, PurchaseService purchase,
      {bool isToken = false}) {
    final color = isToken ? AppTheme.accentTeal : AppTheme.accentGold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isToken ? Icons.stars : Icons.workspace_premium,
            color: color,
          ),
        ),
        title: Text(
          product.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          product.description,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: ElevatedButton(
          onPressed:
              purchase.isLoading ? null : () => purchase.buyProduct(product),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            product.price,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
