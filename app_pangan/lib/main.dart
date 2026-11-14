import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/core.dart';
import 'core/providers/gemini_provider.dart';
import 'features/features.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env belum tersedia (salin dari .env.example) — lanjutkan tanpa env
  }
  runApp(const ProviderScope(child: PanganKuApp()));
}

class PanganKuApp extends ConsumerWidget {
  const PanganKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(geminiInitializedProvider);
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
          ? _homeForRole(auth.user!.role)
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
          '/' => const MainNavScreen(),
          '/menu-all' => const MainNavScreen(),
          '/finance' => const FinanceScreen(),
          '/production' => const ProductionScreen(),
          '/harvest' => const ProductionScreen(initialSector: ProductionSector.darat),
          '/sell' => const SellScreen(),
          '/settings' => const SettingsScreen(),
          '/guide' => const PlantingGuideScreen(),
          '/report' => const ReportScreen(),
          '/market' => const MarketScreen(),
          '/notifications' => const NotificationsScreen(),
          '/consumer' => const ConsumerHome(),
          '/admin' => const AdminDashboard(),
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
  UserRole.konsumen => const ConsumerHome(),
  UserRole.petani => const MainNavScreen(),
  UserRole.peternak => const MainNavScreen(),
  UserRole.nelayan => const MainNavScreen(),
  UserRole.pelakuPangan => const MainNavScreen(),
  UserRole.pengepul => const MainNavScreen(),
  UserRole.olahan => const MainNavScreen(),
  UserRole.admin => const AdminDashboard(),
};