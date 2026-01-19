import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/purchase_service.dart';
import '../core/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                        'Ayarlar',
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Account Section
                    _buildSectionTitle('Hesap'),
                    Consumer<AuthService>(
                      builder: (context, auth, _) {
                        if (auth.isLoggedIn) {
                          return _buildAccountCard(context, auth);
                        }
                        return _buildLoginCard(context, auth);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Premium Section
                    _buildSectionTitle('Premium'),
                    Consumer<PurchaseService>(
                      builder: (context, purchase, _) {
                        return _buildPremiumCard(context, purchase);
                      },
                    ),
                    const SizedBox(height: 24),

                    // App Section
                    _buildSectionTitle('Uygulama'),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.delete_forever,
                        title: 'Analiz Geçmişini Temizle',
                        subtitle: 'Tüm kayıtlı analizleri sil',
                        onTap: () => _showClearHistoryDialog(context),
                        isDestructive: true,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Legal Section
                    _buildSectionTitle('Yasal'),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.privacy_tip,
                        title: 'Gizlilik Politikası',
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        icon: Icons.description,
                        title: 'Kullanım Koşulları',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Danger Zone
                    Consumer<AuthService>(
                      builder: (context, auth, _) {
                        if (!auth.isLoggedIn) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Tehlikeli Bölge'),
                            _buildSettingsCard([
                              _buildSettingsTile(
                                icon: Icons.logout,
                                title: 'Çıkış Yap',
                                onTap: () => _showSignOutDialog(context, auth),
                                isDestructive: true,
                              ),
                              _buildSettingsTile(
                                icon: Icons.delete_outline,
                                title: 'Hesabımı Sil',
                                subtitle: 'Bu işlem geri alınamaz',
                                onTap: () =>
                                    _showDeleteAccountDialog(context, auth),
                                isDestructive: true,
                              ),
                            ]),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        'Eloa v1.0.0',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAccountCard(BuildContext context, AuthService auth) {
    final purchase = context.watch<PurchaseService>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: auth.user?.photoURL != null
                ? NetworkImage(auth.user!.photoURL!)
                : null,
            backgroundColor: AppTheme.accentGold.withOpacity(0.2),
            child: auth.user?.photoURL == null
                ? const Icon(Icons.person, color: AppTheme.accentGold)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.user?.displayName ?? 'Kullanıcı',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  auth.user?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (purchase.isPremium)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Premium Üye',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${purchase.tokenBalance} Jeton',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            purchase.isPremium ? Icons.workspace_premium : Icons.stars,
            color:
                purchase.isPremium ? AppTheme.accentGold : AppTheme.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, AuthService auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            'Henüz giriş yapmadınız',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (auth.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                auth.error!,
                style: GoogleFonts.poppins(
                  color: AppTheme.accentCoral,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: auth.isLoading ? null : () => auth.signInWithGoogle(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
            child: const Text('Google ile Giriş Yap'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, PurchaseService purchase) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/premium'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: purchase.isPremium ? AppTheme.goldGradient : null,
          color: purchase.isPremium ? null : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: purchase.isPremium
                ? Colors.transparent
                : AppTheme.accentGold.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium,
              color: purchase.isPremium ? Colors.white : AppTheme.accentGold,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.isPremium ? 'Premium Aktif' : 'Premium\'a Geç',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: purchase.isPremium
                          ? Colors.white
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    purchase.isPremium
                        ? 'Tüm özelliklere erişiminiz var'
                        : 'Sınırsız analiz ve daha fazlası',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: purchase.isPremium
                          ? Colors.white70
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: purchase.isPremium ? Colors.white : AppTheme.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppTheme.accentCoral : AppTheme.textPrimary;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Geçmişi Temizle',
            style: GoogleFonts.poppins(color: AppTheme.textPrimary)),
        content: Text(
          'Tüm analiz geçmişiniz silinecek. Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal',
                style: GoogleFonts.poppins(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Clear history
              Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral),
            child: Text('Temizle',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Çıkış Yap',
            style: GoogleFonts.poppins(color: AppTheme.textPrimary)),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal',
                style: GoogleFonts.poppins(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral),
            child: Text('Çıkış Yap',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Hesabı Sil',
            style: GoogleFonts.poppins(color: AppTheme.accentCoral)),
        content: Text(
          'Hesabınız ve tüm verileriniz kalıcı olarak silinecek. Bu işlem geri alınamaz!',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal',
                style: GoogleFonts.poppins(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.deleteAccount();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCoral),
            child: Text('Hesabımı Sil',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
