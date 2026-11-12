import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/core.dart';
import 'features/features.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PanganKuApp()));
}

class PanganKuApp extends ConsumerWidget {
  const PanganKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isLoading) {
      return MaterialApp(
        title: 'PanganKu Nasional',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(context),
        home: const PatternBackground(child: _SplashGate()),
      );
    }
    return MaterialApp(
      title: 'PanganKu Nasional',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      home: auth.isAuthenticated
          ? PatternBackground(child: _homeForRole(auth.user!.role))
          : const PatternBackground(child: LoginScreen()),
      onGenerateRoute: (settings) {
        if (!auth.isAuthenticated &&
            settings.name != '/login' &&
            settings.name != '/register') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const PatternBackground(child: LoginScreen()),
          );
        }
        final Widget? page = switch (settings.name) {
          '/login' => const PatternBackground(child: LoginScreen()),
          '/register' => const PatternBackground(child: RegisterScreen()),
          '/' => const PatternBackground(child: MainNavScreen()),
          '/finance' => const PatternBackground(child: FinanceScreen()),
          '/production' => const PatternBackground(child: ProductionScreen()),
          '/harvest' => const PatternBackground(child: ProductionScreen(initialSector: ProductionSector.darat)),
          '/sell' => const PatternBackground(child: SellScreen()),
          '/settings' => const PatternBackground(child: SettingsScreen()),
          '/guide' => const PatternBackground(child: PlantingGuideScreen()),
          '/report' => const PatternBackground(child: ReportScreen()),
          '/market' => const PatternBackground(child: MarketScreen()),
          '/notifications' => const PatternBackground(child: NotificationsScreen()),
          '/consumer' => const PatternBackground(child: ConsumerHome()),
          '/admin' => const PatternBackground(child: AdminDashboard()),
          _ => null,
        };
        if (page == null) return null;
        final noTransition =
            settings.name == '/' || settings.name == '/login';
        return noTransition
            ? MaterialPageRoute<void>(settings: settings, builder: (_) => page)
            : FadeSlideRoute<void>(settings: settings, page: page);
      },
    );
  }
}

class _SplashGate extends StatelessWidget {
  const _SplashGate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.eco_rounded,
                  color: AppTheme.brandPrimary, size: 38),
            ),
            const SizedBox(height: 18),
            Text('PanganKu Nasional',
                style: AppTheme.poppins(
                    fontSize: 20,
                    weight: FontWeight.w700,
                    color: AppTheme.textDark)),
            const SizedBox(height: 14),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}

  Widget _homeForRole(UserRole role) => switch (role) {
    UserRole.petani => const MainNavScreen(),
    UserRole.konsumen => const ConsumerHome(),
    UserRole.admin => const AdminDashboard(),
  };
