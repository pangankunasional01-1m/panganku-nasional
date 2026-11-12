import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../../auth/auth_provider.dart';

/// Pengaturan aplikasi + profil & peran.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notif = true;
  bool _dark = false;
  String _lang = 'Bahasa Indonesia';
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String _routeFor(UserRole role) => switch (role) {
        UserRole.petani => '/',
        UserRole.konsumen => '/consumer',
        UserRole.admin => '/admin',
      };

  Future<void> _editProfile(AppUser user) async {
    _nameCtrl.text = user.name;
    var role = user.role;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ubah Profil',
                  style: AppTheme.poppins(
                      fontSize: 18, weight: FontWeight.w700)),
              const SizedBox(height: 14),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              Text('Peran / Jenis Akun',
                  style: AppTheme.inter(
                      fontSize: 13,
                      weight: FontWeight.w600,
                      color: AppTheme.neutral500)),
              const SizedBox(height: 6),
              RadioGroup<UserRole>(
                groupValue: role,
                onChanged: (v) => setM(() => role = v ?? role),
                child: Column(
                  children: UserRole.values
                      .map((r) => RadioListTile<UserRole>(
                            value: r,
                            title: Text(switch (r) {
                              UserRole.petani => 'Petani / Produsen',
                              UserRole.konsumen => 'Konsumen',
                              UserRole.admin => 'Pemerintah / Admin',
                            }),
                            activeColor: AppTheme.brandPrimary,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && mounted) {
      final changedRole = role != user.role;
      ref.read(authProvider.notifier).updateProfile(
            name: _nameCtrl.text,
            role: role,
          );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Profil diperbarui.')));
      if (changedRole) {
        Navigator.pushNamedAndRemoveUntil(
            context, _routeFor(role), (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.bgCream,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _section('Profil & Peran'),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.brandPrimary.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: AppTheme.brandPrimary),
              ),
              title: Text(
                user?.name ?? 'Bapak Sugianto',
                style: AppTheme.poppins(fontSize: 16, weight: FontWeight.w600),
              ),
              subtitle: Text(
                user != null
                    ? '${user.roleLabel} · ${user.identifier}  (ketuk untuk ubah peran)'
                    : 'Petani · Cabai',
                style: AppTheme.inter(fontSize: 13, color: AppTheme.neutral500),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: user == null ? null : () => _editProfile(user),
            ),
          ),
          const SizedBox(height: 16),
          _section('Preferensi'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: AppTheme.brandPrimary,
                  ),
                  title: Text('Bahasa', style: AppTheme.inter(fontSize: 14)),
                  trailing: DropdownButton<String>(
                    value: _lang,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'Bahasa Indonesia',
                        child: Text('Bahasa Indonesia'),
                      ),
                      DropdownMenuItem(value: 'Jawa', child: Text('Jawa')),
                      DropdownMenuItem(value: 'Sunda', child: Text('Sunda')),
                    ],
                    onChanged: (v) => setState(() => _lang = v!),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications,
                    color: AppTheme.brandPrimary,
                  ),
                  title: Text(
                    'Notifikasi',
                    style: AppTheme.inter(fontSize: 14),
                  ),
                  value: _notif,
                  onChanged: (v) => setState(() => _notif = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.dark_mode,
                    color: AppTheme.brandPrimary,
                  ),
                  title: Text(
                    'Mode Gelap',
                    style: AppTheme.inter(fontSize: 14),
                  ),
                  value: _dark,
                  onChanged: (v) => setState(() => _dark = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section('Data & Sinkronisasi'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync, color: AppTheme.brandPrimary),
                  title: Text(
                    'Sinkronkan Sekarang',
                    style: AppTheme.inter(fontSize: 14),
                  ),
                  subtitle: Text(
                    'Terakhir: 2 menit lalu',
                    style: AppTheme.inter(
                      fontSize: 12,
                      color: AppTheme.neutral500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.statusDanger,
                  ),
                  title: Text(
                    'Hapus Data Lokal',
                    style: AppTheme.inter(
                      fontSize: 14,
                      color: AppTheme.statusDanger,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PButton(
            text: 'Keluar Akun',
            type: PButtonType.danger,
            icon: Icons.logout,
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'PanganKu Nasional v1.0.0',
              style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: AppTheme.poppins(
          fontSize: 16,
          weight: FontWeight.w700,
          color: AppTheme.textDark,
        ),
      ),
    );
  }
}
