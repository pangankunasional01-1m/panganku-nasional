import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final geminiInitializedProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(geminiServiceProvider);
  try {
    await service.init();
  } catch (_) {
    // GEMINI_API_KEY tidak tersedia — fitur AI akan tidak tersedia
  }
});