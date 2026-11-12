import 'package:flutter/material.dart';
import 'package:planbeemobile/components/appbar.dart';

import 'components/bottombar.dart';
import 'components/color_picker.dart';
import 'rotina_store.dart';

class Rotina extends StatefulWidget {
  const Rotina({super.key});

  @override
  State<Rotina> createState() => _RotinaState();
}

class _RotinaState extends State<Rotina> {
  static const _amarelo = Color(0xFFFFCB2B);
  static const _laranja = Color(0xFFF58A1F);

  // Cor inicial sugerida para cada dia (Dom ... Sáb), como no Figma.
  static const _paleta = [
    Color(0xFF0A55D6),
    Color(0xFFD00000),
    Color(0xFF12B312),
    Color(0xFF9800A5),
    Color(0xFF808080),
    Color(0xFFFFD580),
    Color(0xFFE9E9E9),
  ];

  final List<TextEditingController> _ctrls =
      List.generate(7, (_) => TextEditingController());
  final List<HSVColor> _cores = _paleta.map(HSVColor.fromColor).toList();

  /// Dia cujo seletor de cor está aberto (null = fechado).
  int? _pickerDia;

  void _alternarPicker(int dia) {
    setState(() => _pickerDia = _pickerDia == dia ? null : dia);
  }

  static double _altura(int n) => n <= 1 ? 80.0 : n * 44.0 + (n - 1) * 4;
  static const double _alturaPicker = 270;

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _adicionar(int dia) {
    final nome = _ctrls[dia].text.trim();
    if (nome.isEmpty) {
      _aviso('Digite o nome da matéria.');
      return;
    }
    final ok = rotinaStore.adicionar(dia, nome, _cores[dia].toColor());
    if (!ok) {
      _aviso('"$nome" já está na rotina de ${RotinaStore.nomesDias[dia]}.');
      return;
    }
    _ctrls[dia].clear();
  }

  void _remover(int dia, Materia m) {
    final indice = rotinaStore.remover(dia, m);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('"${m.nome}" removida de ${RotinaStore.nomesDias[dia]}'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => rotinaStore.inserir(dia, indice, m),
          ),
        ),
      );
  }

  Color _corTexto(Color fundo) =>
      (fundo.a < 0.6 || fundo.computeLuminance() > 0.5) ? Colors.black : Colors.white;

  Widget _rotuloDia(int dia) {
    return Container(
      width: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _amarelo,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        RotinaStore.nomesDias[dia],
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _entrada(int dia) {
    final ativo = dia == _pickerDia;
    return Container(
      width: 58,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _amarelo,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _ctrls[dia],
            onSubmitted: (_) => _adicionar(dia),
            style: const TextStyle(fontSize: 11),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'matéria',
              hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
              ),
            ),
          ),
          // Cor escolhida para a próxima matéria deste dia
          GestureDetector(
            onTap: () => _alternarPicker(dia),
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: ativo ? Colors.black87 : Colors.black12,
                  width: ativo ? 2 : 1,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _cores[dia].toColor(),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          Material(
            color: _laranja,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => _adicionar(dia),
              child: const SizedBox(
                height: 22,
                child: Icon(Icons.add, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bloco(int dia, Materia m, double altura) {
    final corTxt = _corTexto(m.cor);
    return Container(
      height: altura,
      decoration: BoxDecoration(
        color: m.cor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                m.nome,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: corTxt),
              ),
            ),
          ),
          // Botão de excluir matéria
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () => _remover(dia, m),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(Icons.close, size: 14, color: corTxt),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaDia(int dia, List<Materia> materias) {
    final n = materias.length;
    final altura = _altura(n);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: SizedBox(
        height: altura,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _rotuloDia(dia),
            const SizedBox(width: 3),
            _entrada(dia),
            const SizedBox(width: 3),
            SizedBox(
              width: 58,
              child: Column(
                children: [
                  for (var i = 0; i < n; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == n - 1 ? 0 : 4),
                      child: _bloco(dia, materias[i], n == 1 ? altura : 44),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDA5E),
        title: const MainAppBar(),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF9CF),
      body: Column(
        children: [
          // Título "Rotina"
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Container(
              height: 36,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDA5E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black38, blurRadius: 3, offset: Offset(0, 2)),
                ],
              ),
              child: const Text('Rotina', style: TextStyle(fontSize: 17)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListenableBuilder(
                listenable: rotinaStore,
                builder: (context, _) {
                  // Altura total da tabela, para posicionar o seletor
                  var total = 0.0;
                  final offsets = <double>[];
                  for (var d = 0; d < 7; d++) {
                    offsets.add(total);
                    total += _altura(rotinaStore.materiasDoDia(d).length) + 5;
                  }
                  final dia = _pickerDia;
                  final topoPicker = dia == null
                      ? 0.0
                      : offsets[dia]
                          .clamp(0.0, (total - _alturaPicker).clamp(0.0, total))
                          .toDouble();

                  return SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dias x matérias
                        SizedBox(
                          width: 180,
                          child: Column(
                            children: [
                              for (var d = 0; d < 7; d++)
                                _linhaDia(d, rotinaStore.materiasDoDia(d)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Seletor de cor: só aparece ao tocar na cor da matéria
                        Expanded(
                          child: SizedBox(
                            height: total,
                            child: Stack(
                              children: [
                                if (dia != null)
                                  Positioned(
                                    top: topoPicker,
                                    left: 0,
                                    right: 0,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Cor • ${RotinaStore.nomesDias[dia]}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () =>
                                                  setState(() => _pickerDia = null),
                                              borderRadius: BorderRadius.circular(12),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(Icons.close, size: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        SimpleColorPicker(
                                          cor: _cores[dia],
                                          onChanged: (h) =>
                                              setState(() => _cores[dia] = h),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
