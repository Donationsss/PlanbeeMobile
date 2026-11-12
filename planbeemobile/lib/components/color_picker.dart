import 'package:flutter/material.dart';

/// Seletor de cor simples (quadro S/V, matiz, transparência e hex),
/// sem depender de pacotes externos.
class SimpleColorPicker extends StatelessWidget {
  final HSVColor cor;
  final ValueChanged<HSVColor> onChanged;

  const SimpleColorPicker({super.key, required this.cor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final matizPuro = HSVColor.fromAHSV(1, cor.hue, 1, 1).toColor();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCB2B),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 120, child: _SvBox(cor: cor, onChanged: onChanged)),
          const SizedBox(height: 10),
          SizedBox(
            height: 18,
            child: _BarSlider(
              valor: cor.hue / 360,
              corThumb: matizPuro,
              onChanged: (v) => onChanged(cor.withHue(v * 360)),
              fundo: SizedBox.expand(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      for (var h = 0; h <= 360; h += 60)
                        HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 18,
            child: _BarSlider(
              valor: cor.alpha,
              corThumb: cor.toColor(),
              onChanged: (v) => onChanged(cor.withAlpha(v)),
              fundo: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _Xadrez())),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          cor.withAlpha(0).toColor(),
                          cor.withAlpha(1).toColor(),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _HexField(cor: cor, onChanged: onChanged)),
              const SizedBox(width: 6),
              Container(
                width: 44,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF58A1F),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${(cor.alpha * 100).round()}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SvBox extends StatelessWidget {
  final HSVColor cor;
  final ValueChanged<HSVColor> onChanged;

  const _SvBox({required this.cor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(6);
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight);

      void atualizar(Offset p) {
        final s = (p.dx / size.width).clamp(0.0, 1.0).toDouble();
        final v = 1 - (p.dy / size.height).clamp(0.0, 1.0).toDouble();
        onChanged(cor.withSaturation(s).withValue(v));
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => atualizar(d.localPosition),
        onPanUpdate: (d) => atualizar(d.localPosition),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: HSVColor.fromAHSV(1, cor.hue, 1, 1).toColor(),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: const LinearGradient(
                      colors: [Colors.white, Color(0x00FFFFFF)]),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Colors.black],
                  ),
                ),
              ),
            ),
            Positioned(
              left: cor.saturation * size.width - 8,
              top: (1 - cor.value) * size.height - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 2)],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _BarSlider extends StatelessWidget {
  final double valor; // 0..1
  final ValueChanged<double> onChanged;
  final Widget fundo;
  final Color corThumb;

  const _BarSlider({
    required this.valor,
    required this.onChanged,
    required this.fundo,
    required this.corThumb,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      const t = 18.0;

      void atualizar(Offset p) =>
          onChanged(((p.dx - t / 2) / (w - t)).clamp(0.0, 1.0).toDouble());

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => atualizar(d.localPosition),
        onPanUpdate: (d) => atualizar(d.localPosition),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipRRect(borderRadius: BorderRadius.circular(9), child: fundo),
            ),
            Positioned(
              left: valor.clamp(0.0, 1.0).toDouble() * (w - t),
              top: 0,
              bottom: 0,
              width: t,
              child: Container(
                decoration: BoxDecoration(
                  color: corThumb,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 2)],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Xadrez extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const q = 6.0;
    final a = Paint()..color = Colors.white;
    final b = Paint()..color = const Color(0xFFCCCCCC);
    for (var y = 0; y * q < size.height; y++) {
      for (var x = 0; x * q < size.width; x++) {
        canvas.drawRect(Rect.fromLTWH(x * q, y * q, q, q), (x + y) % 2 == 0 ? a : b);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HexField extends StatefulWidget {
  final HSVColor cor;
  final ValueChanged<HSVColor> onChanged;

  const _HexField({required this.cor, required this.onChanged});

  @override
  State<_HexField> createState() => _HexFieldState();
}

class _HexFieldState extends State<_HexField> {
  late final TextEditingController _ctrl;
  final FocusNode _foco = FocusNode();

  String _hex(HSVColor c) =>
      (c.toColor().toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _hex(widget.cor));
  }

  @override
  void didUpdateWidget(covariant _HexField old) {
    super.didUpdateWidget(old);
    if (!_foco.hasFocus) _ctrl.text = _hex(widget.cor);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _aplicar() {
    final txt = _ctrl.text.replaceAll('#', '').trim();
    final v = txt.length == 6 ? int.tryParse(txt, radix: 16) : null;
    if (v != null) {
      widget.onChanged(
        HSVColor.fromColor(Color(0xFF000000 | v)).withAlpha(widget.cor.alpha),
      );
    }
    _ctrl.text = _hex(widget.cor);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: TextField(
        controller: _ctrl,
        focusNode: _foco,
        maxLength: 7,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        onSubmitted: (_) => _aplicar(),
        onTapOutside: (_) {
          if (_foco.hasFocus) {
            _aplicar();
            _foco.unfocus();
          }
        },
        decoration: InputDecoration(
          counterText: '',
          prefixText: '#',
          prefixStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF58A1F),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
