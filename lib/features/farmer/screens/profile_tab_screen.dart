import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../../../core/widgets/pangan_sliver_header.dart';
import '../../../features/auth/auth_provider.dart';

/// Profil (Profile Tab) — akun dan pengaturan
class ProfileTabScreen extends ConsumerStatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  ConsumerState<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends ConsumerState<ProfileTabScreen> {
  String _version = '1.0.0 (Build 1)';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = '${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      // Keep default version
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final initials = _getInitials(user?.name);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          PanganSliverHeader(
            expandedHeight: 110,
            collapsedTitle: 'Profil',
            expandedContent: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Avatar pengguna, inisial $initials',
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        initials,
                        style: AppTheme.poppins(
                          fontSize: 28,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Bapak Sugianto',
                    style: AppTheme.poppins(
                      fontSize: 22,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _roleLabel(user?.role ?? UserRole.petani),
                      style: AppTheme.inter(
                        fontSize: 12,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.identifier ?? '0812-3456-789',
                    style: AppTheme.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── Menu Utama ──────────────────────────────────────────
                        _SectionHeader(title: 'Akun & Profil'),
                        const SizedBox(height: 12),
                        _MenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profil',
                          subtitle: 'Ubah nama, nomor telepon, foto',
                          onTap: () => _showEditProfileDialog(context, ref),
                        ),
                        _MenuItem(
                          icon: Icons.lock_outline_rounded,
                          title: 'Keamanan',
                          subtitle: 'Ubah PIN, biometrik, 2FA',
                          onTap: () => _showSecurityDialog(context),
                        ),
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifikasi',
                          subtitle: 'Kelola preferensi notifikasi',
                          onTap: () => _showNotificationSettings(context),
                        ),
                        const SizedBox(height: 24),
                        _SectionHeader(title: 'Preferensi Aplikasi'),
                        const SizedBox(height: 12),
                        _MenuItem(
                          icon: Icons.language_rounded,
                          title: 'Bahasa',
                          subtitle: 'Indonesia (Default)',
                          trailing: _TrailingBadge(text: 'ID'),
                          onTap: () => _showLanguageDialog(context),
                        ),
                        _MenuItem(
                          icon: Icons.palette_outlined,
                          title: 'Tema',
                          subtitle: 'Sistem / Terang / Gelap',
                          onTap: () => _showThemeDialog(context),
                        ),
                        _MenuItem(
                          icon: Icons.sync_rounded,
                          title: 'Sinkronisasi Data',
                          subtitle: 'Backup & restore ke cloud',
                          onTap: () => _showSyncDialog(context),
                        ),
                        const SizedBox(height: 24),
                        _SectionHeader(title: 'Bantuan & Informasi'),
                        const SizedBox(height: 12),
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Pusat Bantuan',
                          subtitle: 'FAQ, panduan, kontak support',
                          onTap: () => _showHelpDialog(context),
                        ),
                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          title: 'Tentang Aplikasi',
                          subtitle: 'PanganKu Nasional',
                          onTap: () => _showAboutDialog(context),
                        ),
                        _MenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Kebijakan Privasi',
                          subtitle: 'Syarat & ketentuan penggunaan',
                          onTap: () => _showPrivacyDialog(context),
                        ),
                        const SizedBox(height: 32),
                        // ── Logout Button ────────────────────────────────────────
                        Semantics(
                          label: 'Keluar dari akun',
                          button: true,
                          child: PButton(
                            text: 'Keluar',
                            icon: Icons.logout_rounded,
                            type: PButtonType.secondary,
                            onPressed: () => _confirmLogout(context, ref),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Versi $_version',
                          textAlign: TextAlign.center,
                          style: AppTheme.inter(
                            fontSize: 12,
                            color: AppTheme.neutral400,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.petani:
        return 'Petani';
      case UserRole.konsumen:
        return 'Konsumen';
      case UserRole.admin:
        return 'Admin';
    }
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final authState = ref.read(authProvider);
    final user = authState.user;
    final nameController = TextEditingController(text: user?.name ?? 'Bapak Sugianto');
    final phoneController = TextEditingController(text: user?.identifier ?? '08123456789');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Edit Profil',
                style: AppTheme.poppins(
                  fontSize: 20,
                  weight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PButton(
                      text: 'Batal',
                      type: PButtonType.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PButton(
                      text: 'Simpan',
                      type: PButtonType.primary,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(authProvider.notifier).updateProfile(
                              name: nameController.text,
                              identifier: phoneController.text,
                            );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar dari Akun?', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'Anda akan keluar dari akun dan perlu login kembali.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTheme.inter(
                fontSize: 14,
                weight: FontWeight.w600,
                color: AppTheme.neutral500,
              ),
            ),
          ),
          PButton(
            text: 'Keluar',
            type: PButtonType.primary,
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keamanan', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'Fitur keamanan (PIN, biometrik, 2FA) akan segera hadir.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 14, color: AppTheme.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Notifikasi', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'Pengaturan notifikasi akan segera hadir.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 14, color: AppTheme.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Bahasa', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'Hanya Bahasa Indonesia yang tersedia saat ini.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 14, color: AppTheme.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tema', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'Pengaturan tema (Terang/Gelap/Sistem) akan segera hadir.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 14, color: AppTheme.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sinkronisasi Data', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'Fitur backup & restore ke cloud akan segera hadir.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 14, color: AppTheme.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Pusat Bantuan', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'FAQ, panduan, dan kontak support akan segera hadir.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 14, color: AppTheme.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tentang Aplikasi', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'PanganKu Nasional v$_version\nEkosistem Intelijen Pangan Indonesia',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 14, color: AppTheme.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Kebijakan Privasi', style: AppTheme.poppins(fontSize: 18)),
        content: Text(
          'Syarat & ketentuan penggunaan akan segera hadir.',
          style: AppTheme.inter(fontSize: 14, color: AppTheme.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: AppTheme.inter(fontSize: 14, color: AppTheme.brandPrimary)),
          ),
        ],
      ),
    );
  }
}

class _TrailingBadge extends StatelessWidget {
  final String text;

  const _TrailingBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.brandPrimarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTheme.inter(
          fontSize: 11,
          weight: FontWeight.w600,
          color: AppTheme.brandPrimary,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTheme.poppins(
        fontSize: 14,
        weight: FontWeight.w700,
        color: AppTheme.neutral500,
      ).copyWith(letterSpacing: 0.5),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title, $subtitle',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: AppTheme.brandPrimary.withValues(alpha: 0.08),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: AppTheme.cardDecoration(
              radius: 14,
              shadows: AppTheme.softShadow(0.04),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.brandPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.poppins(
                          fontSize: 15,
                          weight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral400),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                Icon(Icons.chevron_right_rounded, color: AppTheme.neutral300, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}