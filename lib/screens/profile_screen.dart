import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../services/history_storage_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/purchase_service.dart';

/// Profil ve ayarlar ekranı
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _analysisCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final count = await HistoryStorageService.instance.getHistoryCount();
    if (mounted) {
      setState(() {
        _analysisCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 32),
            const SizedBox(height: 24),
            _buildUserSection(),
            const SizedBox(height: 24),
            _buildStatsCard(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil',
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ayarlar ve uygulama bilgileri',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.accentCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.insights,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam Analiz',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_analysisCount',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ayarlar',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppTheme.cardDecoration(),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.delete_sweep_outlined,
                title: 'Geçmişi Temizle',
                subtitle: 'Tüm kayıtlı analizleri sil',
                onTap: _showClearHistoryDialog,
                isDestructive: true,
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: 'Uygulama Sürümü',
                subtitle: 'v1.0.0',
                onTap: null,
              ),

              // Account Actions (Only if logged in)
              Consumer<AuthService>(
                builder: (context, auth, _) {
                  if (!auth.isLoggedIn) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.logout,
                        title: 'Çıkış Yap',
                        subtitle: 'Hesabınızdan çıkın',
                        onTap: () => _showSignOutDialog(auth),
                        isDestructive: true,
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        icon: Icons.delete_forever,
                        title: 'Hesabı Sil',
                        subtitle: 'Kalıcı olarak sil',
                        onTap: () => _showDeleteAccountDialog(auth),
                        isDestructive: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hakkında',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.cardDecoration(),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.back_hand,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Eloa',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mistik El Analizi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kadim el okuma sanatını modern teknoloji ile buluşturan bir uygulama. '
                'Elinizdeki çizgiler ve işaretler, binlerce yıllık bilgeliğin ışığında yorumlanır.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.6,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppTheme.textMuted.withOpacity(0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu uygulama eğlence amaçlıdır ve bilimsel bir teşhis değildir.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
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
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppTheme.accentCoral : AppTheme.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    (isDestructive ? AppTheme.accentCoral : AppTheme.accentGold)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textMuted,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 76,
      color: Colors.white.withOpacity(0.05),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Geçmişi Temizle',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tüm analiz geçmişiniz kalıcı olarak silinecek. Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await HistoryStorageService.instance.clearAllHistory();
              _loadStats();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tüm geçmiş temizlendi',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppTheme.cardLight,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Temizle',
              style: GoogleFonts.poppins(color: AppTheme.accentCoral),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(AuthService auth) {
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
              if (mounted) {
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

  void _showDeleteAccountDialog(AuthService auth) {
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
              if (mounted) {
                Navigator.pop(context);
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

  Widget _buildUserSection() {
    return Consumer2<AuthService, PurchaseService>(
      builder: (context, auth, purchase, _) {
        if (!auth.isLoggedIn) {
          return _buildLoginCard(auth);
        }
        return _buildUserProfile(auth, purchase);
      },
    );
  }

  Widget _buildLoginCard(AuthService auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 48,
            color: AppTheme.accentGold,
          ),
          const SizedBox(height: 16),
          Text(
            'Hesabınıza Giriş Yapın',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analizlerinizi nube kaydedin ve tüm cihazlarınızdan erişin.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          if (auth.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.accentCoral.withOpacity(0.3)),
              ),
              child: Text(
                auth.error!,
                style: GoogleFonts.poppins(
                  color: AppTheme.accentCoral,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: auth.isLoading ? null : () => auth.signInWithGoogle(),
              icon: auth.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.login),
              label: Text(
                auth.isLoading ? 'Giriş Yapılıyor...' : 'Google ile Giriş Yap',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(AuthService auth, PurchaseService purchase) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardDark,
            AppTheme.accentGold.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.accentGold.withOpacity(0.2),
            backgroundImage: auth.user?.photoURL != null
                ? NetworkImage(auth.user!.photoURL!)
                : null,
            child: auth.user?.photoURL == null
                ? const Icon(Icons.person, size: 36, color: AppTheme.accentGold)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.user?.displayName ?? 'Kullanıcı',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (purchase.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'PREMIUM',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.accentTeal.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars,
                                size: 14, color: AppTheme.accentTeal),
                            const SizedBox(width: 4),
                            Text(
                              '${purchase.tokenBalance} JETON',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentTeal,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
