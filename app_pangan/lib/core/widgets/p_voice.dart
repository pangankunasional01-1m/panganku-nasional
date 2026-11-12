import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../animation/entrance_animation.dart';
import '../theme/app_theme.dart';
import 'p_button.dart';

class PVoiceInput extends StatefulWidget {
  final ValueChanged<String> onResult;
  final String? initialText;

  const PVoiceInput({super.key, required this.onResult, this.initialText});

  @override
  State<PVoiceInput> createState() => _PVoiceInputState();
}

class _PVoiceInputState extends State<PVoiceInput> {
  late final SpeechToText _speech;
  bool _listening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _text = widget.initialText ?? '';
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!_listening) {
      final available = await _speech.initialize();
      if (available && mounted) {
        setState(() => _listening = true);
        _speech.listen(
          onResult: (result) {
            if (!mounted) return;
            setState(() => _text = result.recognizedWords);
            widget.onResult(_text);
          },
        );
      }
    } else {
      setState(() => _listening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: widget.onResult,
          decoration: InputDecoration(
            hintText: 'Contoh: beli pupuk urea dua karung seratus empat puluh ribu',
            prefixIcon: const Icon(Icons.transcribe_rounded),
            suffixIcon: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                  key: ValueKey(_listening),
                  color: _listening ? AppTheme.brandAccent : AppTheme.brandPrimary,
                ),
              ),
              onPressed: _toggle,
            ),
          ),
          maxLines: 2,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: _listening
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(child: Waveform(color: AppTheme.brandAccent)),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 12),
        PButton(
          text: _listening ? 'Mendengarkan…' : 'Gunakan Suara',
          type: _listening ? PButtonType.danger : PButtonType.secondary,
          icon: Icons.mic_rounded,
          onPressed: _toggle,
        ),
        if (_text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Hasil suara: $_text', style: AppTheme.inter(fontSize: 12, color: AppTheme.neutral500)),
        ],
      ],
    );
  }
}
