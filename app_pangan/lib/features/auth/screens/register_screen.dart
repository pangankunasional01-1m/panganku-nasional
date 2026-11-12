import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  UserRole _role = UserRole.petani;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String _routeFor(UserRole role) => switch (role) {
    UserRole.petani => '/',
    UserRole.konsumen => '/consumer',
    UserRole.admin => '/admin',
  };

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final err = await ref
        .read(authProvider.notifier)
        .register(
          name: _nameCtrl.text,
          identifier: _idCtrl.text,
          password: _passCtrl.text,
          role: _role,
        );
    if (!mounted) return;
    if (err != null) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppTheme.statusDanger),
        );
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.pushNamedAndRemoveUntil(context, _routeFor(_role), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EntranceAnimation(
                      child: Text(
                        'Buat akun baru untuk mulai menggunakan PanganKu.',
                        style: AppTheme.inter(
                          fontSize: 14,
                          color: AppTheme.neutral400,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    EntranceAnimation(
                      delay: const Delay(60),
                      child: TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Nama minimal 3 karakter.'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    EntranceAnimation(
                      delay: const Delay(110),
                      child: TextFormField(
                        controller: _idCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP atau Email',
                          hintText: '0812xxxx atau nama@email.com',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Masukkan nomor HP atau email.';
                          if (t.length < 6) {
                            return 'Nomor HP/email tidak valid.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    EntranceAnimation(
                      delay: const Delay(160),
                      child: DropdownButtonFormField<UserRole>(
                        initialValue: _role,
                        decoration: const InputDecoration(
                          labelText: 'Peran',
                          prefixIcon: Icon(Icons.group_outlined),
                        ),
                        items: UserRole.values
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(switch (r) {
                                  UserRole.petani => 'Petani / Produsen',
                                  UserRole.konsumen => 'Konsumen',
                                  UserRole.admin => 'Pemerintah / Admin',
                                }),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _role = v ?? _role),
                      ),
                    ),
                    const SizedBox(height: 14),
                    EntranceAnimation(
                      delay: const Delay(210),
                      child: TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          labelText: 'Kata sandi',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Kata sandi minimal 6 karakter.'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    EntranceAnimation(
                      delay: const Delay(260),
                      child: TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi kata sandi',
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Konfirmasi kata sandi.';
                          }
                          if (v != _passCtrl.text) {
                            return 'Kata sandi tidak sama.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    EntranceAnimation(
                      delay: const Delay(310),
                      child: PButton(
                        text: 'Daftar',
                        icon: Icons.person_add_alt_1_rounded,
                        isLoading: loading,
                        onPressed: loading ? null : _submit,
                      ),
                    ),
                    const SizedBox(height: 10),
                    EntranceAnimation(
                      delay: const Delay(350),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Sudah punya akun? Masuk',
                          style: AppTheme.inter(
                            fontSize: 13,
                            weight: FontWeight.w600,
                            color: AppTheme.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
