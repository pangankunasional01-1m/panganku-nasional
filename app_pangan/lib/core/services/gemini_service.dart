import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late final GenerativeModel _model;
  late final GenerativeModel _modelPro;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY tidak ditemukan di .env');
    }

    // Validasi format key (Gemini key biasanya awalan "AIza" atau "AQ.")
    if (!apiKey.startsWith('AIza') && !apiKey.startsWith('AQ.')) {
      throw Exception('Format API key tidak valid. Key Gemini biasanya awalan "AIza" atau "AQ."');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );

    _modelPro = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 4096,
      ),
    );

    _initialized = true;
  }

  GenerativeModel get model => _model;
  GenerativeModel get modelPro => _modelPro;

  Future<String> generateText(String prompt, {bool usePro = false}) async {
    _checkInit();
    final model = usePro ? _modelPro : _model;
    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } on GenerativeAIException catch (e) {
      throw _formatError(e);
    }
  }

  Stream<String> generateTextStream(String prompt, {bool usePro = false}) async* {
    _checkInit();
    final model = usePro ? _modelPro : _model;
    try {
      final stream = model.generateContentStream([Content.text(prompt)]);
      await for (final chunk in stream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } on GenerativeAIException catch (e) {
      throw _formatError(e);
    }
  }

  Future<String> chatWithHistory(List<Content> history, String message, {bool usePro = false}) async {
    _checkInit();
    final model = usePro ? _modelPro : _model;
    try {
      final chat = model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? '';
    } on GenerativeAIException catch (e) {
      throw _formatError(e);
    }
  }

  Stream<String> chatWithHistoryStream(List<Content> history, String message, {bool usePro = false}) async* {
    _checkInit();
    final model = usePro ? _modelPro : _model;
    try {
      final chat = model.startChat(history: history);
      final stream = chat.sendMessageStream(Content.text(message));
      await for (final chunk in stream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } on GenerativeAIException catch (e) {
      throw _formatError(e);
    }
  }

  void _checkInit() {
    if (!_initialized) {
      throw Exception('GeminiService belum diinisialisasi. Panggil init() dulu.');
    }
  }

  Exception _formatError(GenerativeAIException e) {
    // ignore: dead_code, dead_null_aware_expression
    final msg = e.message ?? 'Unknown error';
    if (msg.contains('API_KEY_INVALID') || msg.contains('invalid argument') || msg.contains('API key')) {
      return Exception('API Key tidak valid / sudah expired. Buat key baru di Google AI Studio: https://aistudio.google.com/apikey');
    }
    if (msg.contains('QUOTA_EXCEEDED') || msg.contains('quota')) {
      return Exception('Kuota API habis. Cek billing/usage di Google Cloud Console.');
    }
    if (msg.contains('MODEL_NOT_FOUND')) {
      return Exception('Model tidak ditemukan. Periksa nama model di GenerativeModel().');
    }
    return Exception('Gemini API Error: $msg');
  }
}