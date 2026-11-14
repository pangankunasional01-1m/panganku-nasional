import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/animation/entrance_animation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/p_button.dart';
import '../auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String _routeFor(UserRole role) => switch (role) {
    UserRole.konsumen => '/consumer',
    UserRole.petani => '/',
    UserRole.peternak => '/',
    UserRole.nelayan => '/',
    UserRole.pelakuPangan => '/',
    UserRole.pengepul => '/',
    UserRole.olahan => '/',
    UserRole.admin => '/admin',
  };

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final err = await ref
        .read(authProvider.notifier)
        .login(identifier: _idCtrl.text, password: _passCtrl.text);
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
    final role = ref.read(authProvider).user?.role ?? UserRole.petani;
    Navigator.pushNamedAndRemoveUntil(context, _routeFor(role), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EntranceAnimation(
                      child: Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: AppTheme.glow(AppTheme.brandPrimary),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'PanganKu Nasional',
                            style: AppTheme.poppins(
                              fontSize: 26,
                              weight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Masuk untuk melanjutkan',
                            style: AppTheme.inter(
                              fontSize: 14,
                              color: AppTheme.neutral400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    EntranceAnimation(
                      delay: const Delay(100),
                      child: TextFormField(
                        controller: _idCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP atau Email',
                          hintText: '0812xxxx atau nama@email.com',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Masukkan nomor HP atau email.'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    EntranceAnimation(
                      delay: const Delay(160),
                      child: TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
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
                            tooltip: _obscure
                                ? 'Tampilkan sandi'
                                : 'Sembunyikan sandi',
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Masukkan kata sandi.'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 22),
                    EntranceAnimation(
                      delay: const Delay(220),
                      child: PButton(
                        text: 'Masuk',
                        icon: Icons.login_rounded,
                        isLoading: loading,
                        onPressed: loading ? null : _submit,
                      ),
                    ),
                    const SizedBox(height: 14),
                    EntranceAnimation(
                      delay: const Delay(280),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun?',
                            style: AppTheme.inter(
                              fontSize: 13,
                              color: AppTheme.neutral400,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                            child: Text(
                              'Daftar',
                              style: AppTheme.inter(
                                fontSize: 13,
                                weight: FontWeight.w700,
                                color: AppTheme.brandPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    EntranceAnimation(
                      delay: const Delay(320),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.brandPrimary.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                        child: Text(
                          'Akun Demo:\n• Petani: 08123456789 / petani123\n• Konsumen: 08111222333 / konsumen123\n• Admin: admin / admin123',
                          style: AppTheme.inter(
                            fontSize: 12,
                            weight: FontWeight.w500,
                            color: AppTheme.brandPrimaryDark,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
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
