import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/go_pay_theme.dart';
import '../../../features/auth/auth_provider.dart';

/// Profil (Profile Tab) — GoPay style redesign
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
    final colors = GoPayColors();
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final initials = _getInitials(user?.name);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.bgCream,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ===== HEADER (GoPay Style) =====
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: false,
              backgroundColor: colors.brandPrimary,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderContent(initials, user, colors),
              ),
            ),

            // ===== CONTENT (White rounded panel overlapping header) =====
            SliverPersistentHeader(
              pinned: false,
              delegate: _ContentHeaderDelegate(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.bgCream,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
                  ),
                ),
              ),
            ),

            // Content slivers
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Akun & Profil
                  _buildSection('Akun & Profil', [
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
                    _MenuItem(
                      icon: Icons.arrow_upward_rounded,
                      title: 'Upgrade Peran',
                      subtitle: 'Jadi Petani, Peternak, Nelayan, dll',
                      trailing: _TrailingBadge(text: 'Baru'),
                      onTap: () => _showUpgradeRoleDialog(context, ref),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Preferensi Aplikasi
                  _buildSection('Preferensi Aplikasi', [
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
                  ]),

                  const SizedBox(height: 24),

                  // Bantuan & Informasi
                  _buildSection('Bantuan & Informasi', [
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
                  ]),

                  const SizedBox(height: 24),

                  // Pengaturan Lanjutan
                  _buildSection('Pengaturan Lanjutan', [
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan Aplikasi',
                      subtitle: 'Notifikasi, tema, bahasa, data',
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Logout Button
                  _buildLogoutButton(colors),

                  const SizedBox(height: 20),

                  // Version
                  Center(
                    child: Text(
                      'Versi $_version',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colors.neutral400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header content with avatar, name, role, phone
  Widget _buildHeaderContent(String initials, dynamic user, GoPayColors colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.brandPrimary, colors.brandSecondary],
              stops: const [0.0, 0.6],
            ),
          ),
        ),
        // Subtle texture overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _HeaderPatternPainter(),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Semantics(
                  label: 'Avatar pengguna, inisial $initials',
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  user?.name ?? 'Bapak Sugianto',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _roleLabel(user?.role ?? UserRole.petani),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Phone/Identifier
                Text(
                  user?.identifier ?? '0812-3456-789',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Section header + items
  Widget _buildSection(String title, List<Widget> items) {
    final colors = GoPayColors();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.neutral500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  /// Logout button
  Widget _buildLogoutButton(GoPayColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        label: 'Keluar dari akun',
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _confirmLogout(context, ref),
            borderRadius: BorderRadius.circular(GoPayRadius.pill),
            splashColor: colors.brandAccent.withValues(alpha: 0.12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: colors.surfaceWhite,
                borderRadius: BorderRadius.circular(GoPayRadius.pill),
                border: Border.all(color: colors.brandAccent, width: 1.5),
                boxShadow: [GoPayShadows.cardShadow()],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: colors.brandAccent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Keluar',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.brandAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      case UserRole.konsumen:
        return 'Konsumen';
      case UserRole.petani:
        return 'Petani';
      case UserRole.peternak:
        return 'Peternak';
      case UserRole.nelayan:
        return 'Nelayan';
      case UserRole.pelakuPangan:
        return 'Pelaku Pangan';
      case UserRole.pengepul:
        return 'Pengepul';
      case UserRole.olahan:
        return 'Pengolah';
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
          decoration: BoxDecoration(
            color: GoPayColors().surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
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
                    color: GoPayColors().neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Edit Profil',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: GoPayColors().textDark,
                ),
              ),
              const SizedBox(height: 24),
              _DialogTextField(
                controller: nameController,
                label: 'Nama Lengkap',
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _DialogTextField(
                controller: phoneController,
                label: 'Nomor Telepon',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      text: 'Batal',
                      type: _DialogButtonType.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      text: 'Simpan',
                      type: _DialogButtonType.primary,
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
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar dari Akun?', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'Anda akan keluar dari akun dan perlu login kembali.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.neutral500),
            ),
          ),
          _DialogButton(
            text: 'Keluar',
            type: _DialogButtonType.primary,
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
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keamanan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'Fitur keamanan (PIN, biometrik, 2FA) akan segera hadir.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Notifikasi', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'Pengaturan notifikasi akan segera hadir.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Bahasa', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'Hanya Bahasa Indonesia yang tersedia saat ini.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tema', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'Pengaturan tema (Terang/Gelap/Sistem) akan segera hadir.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sinkronisasi Data', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'Fitur backup & restore ke cloud akan segera hadir.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Pusat Bantuan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'FAQ, panduan, dan kontak support akan segera hadir.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Tentang Aplikasi', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'PanganKu Nasional v$_version\nEkosistem Intelijen Pangan Indonesia',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final colors = GoPayColors();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Kebijakan Privasi', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textDark)),
        content: Text(
          'Syarat & ketentuan penggunaan akan segera hadir.',
          style: GoogleFonts.inter(fontSize: 14, color: colors.neutral500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brandPrimary)),
          ),
        ],
      ),
    );
  }

  void _showUpgradeRoleDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    final authState = ref.read(authProvider);
    final user = authState.user;
    final colors = GoPayColors();

    if (user == null) return;

    // Role yang bisa di-upgrade (hanya konsumen -> produser, tidak admin)
    final availableRoles = [
      UserRole.petani,
      UserRole.peternak,
      UserRole.nelayan,
      UserRole.pelakuPangan,
      UserRole.pengepul,
      UserRole.olahan,
    ];

    UserRole? selectedRole = user.role;
    if (!availableRoles.contains(user.role)) {
      selectedRole = availableRoles.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(GoPayRadius.header)),
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
                      color: colors.neutral300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Upgrade Peran',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih peran baru Anda. Peran ini menentukan fitur yang dapat diakses.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.neutral500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ...availableRoles.map((role) {
                  final roleInfo = _getRoleInfo(role);
                  return RadioListTile<UserRole>(
                    value: role,
                    // ignore: deprecated_member_use
                    groupValue: selectedRole,
                    // ignore: deprecated_member_use
                    onChanged: (v) => setModalState(() => selectedRole = v),
                    title: Text(
                      roleInfo['title']!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      roleInfo['desc']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.neutral500,
                      ),
                    ),
                    activeColor: colors.brandPrimary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        text: 'Batal',
                        type: _DialogButtonType.secondary,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        text: 'Upgrade',
                        type: _DialogButtonType.primary,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (selectedRole != null && selectedRole != user.role) {
                            ref.read(authProvider.notifier).updateProfile(role: selectedRole);
                          }
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
      ),
    );
  }

  Map<String, String> _getRoleInfo(UserRole role) {
    switch (role) {
      case UserRole.petani:
        return {'title': 'Petani', 'desc': 'Budidaya tanaman pangan (padi, jagung, kedelai, dll)'};
      case UserRole.peternak:
        return {'title': 'Peternak', 'desc': 'Budidaya ternak (sapi, kambing, ayam, dll)'};
      case UserRole.nelayan:
        return {'title': 'Nelayan', 'desc': 'Penangkapan ikan & hasil laut'};
      case UserRole.pelakuPangan:
        return {'title': 'Pelaku Pangan', 'desc': 'Pedagang, distributor, grosir bahan pangan'};
      case UserRole.pengepul:
        return {'title': 'Pengepul', 'desc': 'Mengumpulkan hasil panen dari petani untuk dijual ulang'};
      case UserRole.olahan:
        return {'title': 'Pengolah', 'desc': 'Mengolah hasil panen jadi produk nilai tambah'};
      default:
        return {'title': '', 'desc': ''};
    }
  }
}

/// Persistent header delegate for the white content panel
class _ContentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _ContentHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 0;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

/// Trailing badge
class _TrailingBadge extends StatelessWidget {
  final String text;

  const _TrailingBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.brandPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.brandPrimary,
        ),
      ),
    );
  }
}

/// Menu item
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
    final colors = GoPayColors();
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
          splashColor: colors.brandPrimary.withValues(alpha: 0.08),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.dividerLight),
              boxShadow: [GoPayShadows.cardShadow()],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.brandPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.brandPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(fontSize: 12, color: colors.neutral400),
                      ),
                    ],
                  ),
                ),
                // ignore: use_null_aware_elements
                if (trailing != null) trailing!,
                Icon(Icons.chevron_right_rounded, color: colors.neutral300, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog text field
class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final TextInputType? keyboardType;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: colors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: colors.neutral400),
        prefixIcon: Icon(prefixIcon, color: colors.neutral400, size: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.brandPrimary, width: 1.5),
        ),
        filled: true,
        fillColor: colors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

/// Dialog button types
enum _DialogButtonType { primary, secondary }

/// Dialog button
class _DialogButton extends StatelessWidget {
  final String text;
  final _DialogButtonType type;
  final VoidCallback onPressed;

  const _DialogButton({
    required this.text,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GoPayColors();
    final isPrimary = type == _DialogButtonType.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: isPrimary ? colors.brandPrimary.withValues(alpha: 0.12) : colors.neutral200,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? colors.brandPrimary : colors.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: colors.dividerLight),
            boxShadow: isPrimary ? [GoPayShadows.cardShadow()] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : colors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle pattern painter for header
class _HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const double spacing = 36;
    const double dotSize = 2;

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final offsetX = (y ~/ spacing) % 2 == 0 ? 0 : spacing / 2;
        canvas.drawCircle(Offset(x + offsetX, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}