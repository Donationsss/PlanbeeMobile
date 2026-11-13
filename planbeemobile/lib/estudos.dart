import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planbeemobile/components/appbar.dart';

import 'components/bottombar.dart';
import 'estudos_store.dart';
import 'rotina_store.dart';

class Estudos extends StatefulWidget {
  const Estudos({super.key});

  @override
  State<Estudos> createState() => _EstudosState();
}

class _EstudosState extends State<Estudos> {
  static const int _duracao = 25 * 60;
  static const _tipos = ['Resumo', 'Exercícios', 'Revisão', 'Leitura'];

  final _assuntoCtrl = TextEditingController();

  String? _materia;
  String? _tipo;
  int _restante = _duracao;
  Timer? _timer;

  bool get _rodando => _timer?.isActive ?? false;

  @override
  void dispose() {
    _timer?.cancel();
    _assuntoCtrl.dispose();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _alternar() {
    if (_rodando) {
      _timer?.cancel();
      setState(() {});
      return;
    }
    if (_restante == 0) _restante = _duracao;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restante <= 1) {
        t.cancel();
        setState(() => _restante = 0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pomodoro concluído! Hora de descansar.')),
        );
      } else {
        setState(() => _restante--);
      }
    });
    setState(() {});
  }

  void _resetar() {
    _timer?.cancel();
    setState(() => _restante = _duracao);
  }

  /// Modal de anotações do estudo. Serve para criar (edicao = false)
  /// e para ver/editar uma anotação já salva (edicao = true).
  /// Retorna o texto digitado, ou null se o usuário fechar sem salvar.
  Future<String?> _abrirAnotacao({
    required String materia,
    required String tipo,
    required String assunto,
    required int segundos,
    required Color? cor,
    required String inicial,
    required bool edicao,
  }) {
    final ctrl = TextEditingController(text: inicial);

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final teclado = media.viewInsets.bottom;
        final alturaMax = media.size.height - teclado - media.padding.top - 16;
        final altura = (media.size.height * 0.78).clamp(0.0, alturaMax).toDouble();

        return Padding(
          padding: EdgeInsets.only(bottom: teclado),
          child: Container(
            height: altura,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9CF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Cabeçalho
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 10, 8, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffFFA53D), Color(0xffFFCA37)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: cor ?? Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  edicao ? 'Anotações do estudo' : 'Anotar estudo',
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$materia • $tipo',
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(assunto,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, size: 16),
                                const SizedBox(width: 4),
                                Text(_fmt(segundos),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Campo de anotação (ocupa o espaço restante)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Anotações',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            autofocus: !edicao,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            textAlignVertical: TextAlignVertical.top,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText:
                                  'O que você estudou? Dúvidas, ideias principais, o que revisar depois...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botão salvar
                Container(
                  padding: EdgeInsets.fromLTRB(
                      20, 10, 20, 14 + (teclado == 0 ? media.padding.bottom : 0)),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEB8A),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2)),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA53D),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text(
                        edicao ? 'Salvar alterações' : 'Salvar estudo',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _salvar() async {
    final assunto = _assuntoCtrl.text.trim();
    if (_materia == null || _tipo == null || assunto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha matéria, tipo e escreva o assunto.')),
      );
      return;
    }
    final doDia = rotinaStore.materiasDoDia(RotinaStore.diaDeHoje());
    final cor = doDia.where((m) => m.nome == _materia).map((m) => m.cor).firstOrNull;
    final materia = _materia!;
    final tipo = _tipo!;
    final segundos = _duracao - _restante;

    // Pausa o timer enquanto a anotação é escrita
    _timer?.cancel();
    setState(() {});

    final nota = await _abrirAnotacao(
      materia: materia,
      tipo: tipo,
      assunto: assunto,
      segundos: segundos,
      cor: cor,
      inicial: '',
      edicao: false,
    );
    if (nota == null || !mounted) return; // fechou sem salvar

    await estudosStore.adicionar(
      materia: materia,
      tipo: tipo,
      assunto: assunto,
      segundos: segundos,
      cor: cor,
      anotacao: nota,
    );
    if (!mounted) return;
    _assuntoCtrl.clear();
    _resetar();
  }

  Future<void> _editarAnotacao(ResumoEstudo r) async {
    final nota = await _abrirAnotacao(
      materia: r.materia,
      tipo: r.tipo,
      assunto: r.assunto,
      segundos: r.segundos,
      cor: r.cor,
      inicial: r.anotacao,
      edicao: true,
    );
    if (nota == null || !mounted) return;
    await estudosStore.atualizarAnotacao(r, nota);
  }

  Widget _botao(String texto, VoidCallback onPressed, {bool destaque = false}) {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: destaque ? const Color(0xFFFFA53D) : const Color(0xFFFFDA5E),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          texto,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white54,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([rotinaStore, estudosStore]),
      builder: (context, _) => _construir(context),
    );
  }

  Widget _construir(BuildContext context) {
    final dia = RotinaStore.diaDeHoje();
    final materias = rotinaStore.materiasDoDia(dia);
    final resumos = estudosStore.itens;
    // Se a matéria escolhida foi excluída da rotina, limpa a seleção.
    if (_materia != null && !materias.any((m) => m.nome == _materia)) {
      _materia = null;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDA5E),
        title: const MainAppBar(),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF9CF),
      body: Container(
        margin: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Colors.black26),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDA5E),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              // Painel superior: formulário + pomodoro
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEB8A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            materias.isEmpty
                                ? '${RotinaStore.nomesDias[dia]}: sem matérias na Rotina'
                                : 'Hoje • ${RotinaStore.nomesDias[dia]}',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _materia,
                            isExpanded: true,
                            decoration: _deco(
                                materias.isEmpty ? 'Adicione na Rotina' : 'Matéria'),
                            items: materias
                                .map((m) => DropdownMenuItem(
                                      value: m.nome,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: m.cor,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black26),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(m.nome,
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: materias.isEmpty
                                ? null
                                : (v) => setState(() => _materia = v),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _tipo,
                            isExpanded: true,
                            decoration: _deco('Tipo de estudo'),
                            items: _tipos
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => setState(() => _tipo = v),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _assuntoCtrl,
                            decoration: _deco('Assunto'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Text('Pomodoro',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            _fmt(_restante),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: _rodando ? Colors.deepOrange : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _botao(_rodando ? 'Pausar' : 'Estudar', _alternar,
                              destaque: true),
                          const SizedBox(height: 8),
                          _botao('Resetar', _resetar),
                          const SizedBox(height: 8),
                          _botao('Salvar', _salvar),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Área dos resumos
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEB8A),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: resumos.isEmpty
                      ? const Center(
                          child: Text(
                            'Área dos Resumos\nSalve uma sessão para vê-la aqui.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: resumos.length,
                          separatorBuilder: (_, __) => const Divider(height: 14),
                          itemBuilder: (context, i) {
                            final r = resumos[i];
                            return InkWell(
                              onTap: () => _editarAnotacao(r),
                              borderRadius: BorderRadius.circular(10),
                              child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: r.cor ?? Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black26),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${r.materia} • ${r.tipo}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(r.assunto),
                                      if (r.anotacao.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.sticky_note_2_outlined,
                                                  size: 13, color: Colors.black54),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  r.anotacao,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(_fmt(r.segundos)),
                                    Text(
                                      '${r.criadoEm.day.toString().padLeft(2, '0')}/${r.criadoEm.month.toString().padLeft(2, '0')}',
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.black54),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => estudosStore.remover(r),
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
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
