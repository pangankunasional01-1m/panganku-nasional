import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AiExpertScreen extends StatefulWidget {
  const AiExpertScreen({super.key});

  @override
  State<AiExpertScreen> createState() => _AiExpertScreenState();
}

class _ChatMsg {
  final bool fromUser;
  final String text;
  const _ChatMsg(this.fromUser, this.text);
}

class _AiExpertScreenState extends State<AiExpertScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  final List<_ChatMsg> _msgs = const [
    _ChatMsg(
      false,
      'Halo! Saya Pakar AI PanganKu. Tanyakan seputar panduan tanam, pemupukan, hama, atau waktu panen komoditas Anda.',
    ),
  ];
  late final List<_ChatMsg> _history = List.of(_msgs);

  static const _quick = [
    'Kapan waktu tanam cabai?',
    'Cara atasi hama daun',
    'Takaran pupuk padi',
    'Tips panen bawang',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _answer(String q) {
    final t = q.toLowerCase();
    if (t.contains('cabai') && (t.contains('tanam') || t.contains('kapan'))) {
      return 'Cabai: tanam awal musim hujan (Nov–Des). Persemaian 21–25 hari, pindah tanam saat 4–5 daun. Jarak 60×50 cm, bedengan tinggi 30 cm agar drainase baik.';
    }
    if (t.contains('hama') || t.contains('ulat') || t.contains('daun')) {
      return 'Pengendalian hama: semprot ekstrak daun nimba 2×/minggu, pasang perangkap kuning (kutu/whitefly). Rotasi tanaman & sanitasi lahan. Jika serangan berat, gunakan insektisida sesuai dosis anjuran POPT.';
    }
    if (t.contains('pupuk') && t.contains('padi')) {
      return 'Pupuk padi (anjuran umum/ha): Urea 200–250 kg, NPK 200–300 kg. Tahap: dasar 1/3 N + seluruh P&K; susulan 21 HST & 42 HST masing-masing 1/3 N. Sesuaikan dengan uji tanah BWD/PUTS.';
    }
    if (t.contains('bawang') || t.contains('panen')) {
      return 'Panen bawang merah: 60–70 HST saat 60–70% daun rebah & menguning, leher lunak. Panen pagi cerah, kering-anginkan 7–14 hari sebelum simpan untuk umur simpan lebih lama.';
    }
    if (t.contains('tomat')) {
      return 'Tomat: butuh sinar penuh, tanah gembur pH 5.5–7. Ajir sejak 2 MST, pemangkasan tunas air. Siram teratur, hindari daun basah untuk cegah busuk/layu.';
    }
    if (t.contains('jagung')) {
      return 'Jagung: tanam jarak 75×25 cm (1 biji/lubang). Pemupukan N dua tahap (7–10 HST & 30–35 HST). Panen saat kelobot kering & biji mengkilap keras (±100–110 HST varietas biasa).';
    }
    if (t.contains('air') || t.contains('siram') || t.contains('irig')) {
      return 'Irigasi umum: siram pagi/sore, jaga lembap tanpa genang. Bedengan + drainase mencegah busuk akar. Mulsa jerami bantu tahan kelembapan & tekan gulma.';
    }
    if (t.contains('harga') || t.contains('jual')) {
      return 'Untuk harga & penjualan, buka menu Jual/Harga Komoditas di beranda. Saya fokus pada panduan budidaya; cek harga terkini sebelum panen agar margin optimal.';
    }
    return 'Pertanyaan dicatat: "$q". Saran umum: sesuaikan varietas dengan iklim lokal, gunakan benih bersertifikat, dan catat biaya/panen di aplikasi agar laba/rugi terpantau. Bisa sebutkan komoditas (cabai, padi, bawang, jagung, tomat) untuk panduan lebih spesifik.';
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty || _typing) return;
    _ctrl.clear();
    setState(() {
      _history.add(_ChatMsg(true, text));
      _typing = true;
    });
    _scrollEnd();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _history.add(_ChatMsg(false, _answer(text)));
      _typing = false;
    });
    _scrollEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text('Tanya Pakar AI',
            style: AppTheme.poppins(fontSize: 20, weight: FontWeight.w600)),
        backgroundColor: AppTheme.bgCream,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _history.length + (_typing ? 1 : 0),
              itemBuilder: (context, i) {
                if (i >= _history.length) return _bubble(false, 'Mengetik...');
                final m = _history[i];
                return _bubble(m.fromUser, m.text);
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quick.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ActionChip(
                label: Text(_quick[i],
                    style: AppTheme.inter(fontSize: 12, weight: FontWeight.w500)),
                onPressed: () => _send(_quick[i]),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppTheme.neutral200),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Tanya panduan tanam...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.neutral200),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                        backgroundColor: AppTheme.brandPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(bool fromUser, String text) {
    final align = fromUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = fromUser ? AppTheme.brandPrimary : Colors.white;
    final fg = fromUser ? Colors.white : AppTheme.textDark;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: fromUser ? null : Border.all(color: AppTheme.neutral200),
        ),
        child: Text(text,
            style: AppTheme.inter(fontSize: 14, color: fg, height: 1.4)),
      ),
    );
  }
}
