import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:planbeemobile/components/appbar.dart';

import 'components/bottombar.dart';
import 'data/auth_service.dart';
import 'data/ofensiva_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  static const _verde = Color(0xFF43C04B);

  // Controla a volta da abelha em torno do favo (uma volta a cada 6 s).
  late final AnimationController _voo = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  int _sequencia = 0;
  List<bool> _semana = List<bool>.filled(7, false); // 0 = segunda

  @override
  void initState() {
    super.initState();
    _carregarOfensiva();
  }

  @override
  void dispose() {
    _voo.dispose();
    super.dispose();
  }

  /// Registra o acesso de hoje e atualiza as bolinhas e o contador.
  Future<void> _carregarOfensiva() async {
    final usuario = AuthService.usuario;
    if (usuario == null) return;
    try {
      final o = await OfensivaService.registrarAcesso(usuario.id);
      if (!mounted) return;
      setState(() {
        _sequencia = o.sequencia;
        _semana = o.semana;
      });
    } catch (e, st) {
      debugPrint('[Planbee] Falha ao registrar a ofensiva\n$e\n$st');
    }
  }

  Widget _buildDiaSemana(String nome, bool visitado) {
    return Column(
      children: [
        Text(nome,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 35,
          height: 70,
          decoration: BoxDecoration(
            color: visitado ? _verde : Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 2, spreadRadius: 0),
              BoxShadow(color: Colors.black12, blurRadius: 7, spreadRadius: 2),
            ],
          ),
        ),
      ],
    );
  }

  /// A abelha desenhada na posição [a] (radianos) da órbita.
  /// A posição é relativa ao tamanho do favo (Alignment), então funciona
  /// em qualquer tamanho de tela.
  Widget _abelha(double a) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(math.cos(a) * 1.15, math.sin(a) * 1.0),
        child: Transform.rotate(
          angle: math.sin(a * 2) * 0.25, // balanço leve enquanto voa
          child: Image.asset("assets/abelha_animada.png", scale: 9),
        ),
      ),
    );
  }

  /// Favo no centro e abelha girando: na metade de cima da órbita ela passa
  /// por trás do favo, na de baixo passa pela frente.
  Widget _favoComAbelha() {
    return AnimatedBuilder(
      animation: _voo,
      child: Image.asset("assets/favo.png", scale: 2.3),
      builder: (context, favo) {
        final a = _voo.value * 2 * math.pi;
        final atras = math.sin(a) < 0;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (atras) _abelha(a) else const SizedBox.shrink(),
            favo!,
            if (!atras) _abelha(a) else const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const dias = ["Seg", "Ter", "Qua", "Qui", "Sex"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDA5E),
        title: const MainAppBar(),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF9CF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Semana 1",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // cards
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 5,
                      offset: Offset(4, 4)),
                ],
                gradient: const LinearGradient(
                    colors: [Color(0xffFFA53D), Color(0xffFFCA37)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < dias.length; i++) ...[
                      if (i > 0)
                        const VerticalDivider(
                            color: Colors.white, thickness: 2.5),
                      _buildDiaSemana(dias[i], _semana[i]),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Row(
                children: [
                  const SizedBox(width: 33),
                  _favoComAbelha(),
                  const SizedBox(width: 12),
                  Flexible(
                    // Se a ofensiva passar de 2 dígitos, o número encolhe em vez de estourar a tela.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFE85A),
                              Color(0xFFFF6D00),
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          "$_sequencia",
                          style: const TextStyle(
                            fontSize: 140,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black12,
                                offset: Offset(3, 3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
