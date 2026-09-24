import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final budget = context.read<BudgetProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenlik & Ayarlar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Security Status Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Donanım Destekli Güvenlik',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verileriniz cihazınızdaki Keystore/Keychain ile şifrelenir ve harici sunuculara aktarılmaz.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Settings Group
          const Text(
            'Giriş & Kilit Güvenliği',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                // PIN Setup or Change
                ListTile(
                  leading: const Icon(Icons.pin_rounded, color: AppColors.primaryLight),
                  title: Text(auth.hasPin ? 'PIN Kodunu Değiştir' : 'Güvenlik PIN Kodu Oluştur'),
                  subtitle: Text(
                    auth.hasPin ? 'Mevcut 4 haneli PIN aktif' : 'Uygulama açılışında PIN sorulmasını sağlayın',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => AuthScreen(
                          isInitialSetup: true,
                          onUnlocked: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('PIN kodunuz başarıyla güncellendi')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),

                // Biometrics Switch
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primaryLight),
                  title: const Text('Biyometrik Kimlik Doğrulama'),
                  subtitle: const Text('Parmak İzi / Face ID ile hızlı ve güvenli kilit açma', style: TextStyle(fontSize: 12)),
                  value: auth.biometricEnabled,
                  onChanged: auth.hasPin
                      ? (val) async {
                          await auth.setBiometricEnabled(val);
                        }
                      : null,
                ),
                const Divider(height: 1, indent: 56),

                // Lock Now
                ListTile(
                  leading: const Icon(Icons.lock_clock_rounded, color: AppColors.primaryLight),
                  title: const Text('Uygulamayı Hemen Kilitle'),
                  subtitle: const Text('Uygulama ekranını kilitler ve kimlik doğrulaması ister', style: TextStyle(fontSize: 12)),
                  onTap: () => auth.lockApp(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management
          const Text(
            'Veri & Gizlilik',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.expense),
                  title: const Text('Tüm Verileri Temizle', style: TextStyle(color: AppColors.expense)),
                  subtitle: const Text('Kayıtlı tüm gelir, gider ve bütçe hedeflerini kalıcı olarak siler', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Tüm Veriler Silinecek!'),
                        content: const Text(
                          'Bu işlem geri alınamaz. Kayıtlı tüm gelir ve gider işlemleriniz yerel hafızadan silinecektir. Devam etmek istiyor musunuz?',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
                            child: const Text('Evet, Hepsini Sil'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await budget.clearAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tüm veriler başarıyla temizlendi')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Architecture Highlights
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_moon_outlined, size: 20, color: AppColors.primaryLight),
                      SizedBox(width: 8),
                      Text('Güvenlik Mimarisi Standartları', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityBullet('Flutter AOT Makine Kodu', 'Kod tersine mühendisliğe karşı C++ benzeri makine koduna derlenmiştir.'),
                  _buildSecurityBullet('Sıfır Bulut İletişimi', 'Finansal verileriniz internete veya üçüncü parti sunuculara gitmez.'),
                  _buildSecurityBullet('Tuzlanmış SHA-256 Hash', 'PIN kodunuz asla düz metin olarak kaydedilmez.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
        ),
      ),
    );
  }

  Widget _buildSecurityBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.income),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
