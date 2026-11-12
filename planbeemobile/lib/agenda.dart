import 'package:flutter/material.dart';
import 'package:planbeemobile/components/appbar.dart';

import 'components/bottombar.dart';
import 'rotina_store.dart';

class Agenda extends StatefulWidget {
  const Agenda({super.key});

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  static const _meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  static const _semana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  late DateTime _mesAtual;

  // Anotações por data (chave: yyyy-mm-dd)
  final Map<String, List<String>> _anotacoes = {};

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _mesAtual = DateTime(hoje.year, hoje.month);
  }

  String _chave(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _mudarMes(int delta) {
    setState(() => _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + delta));
  }

  String _nomeDiaCompleto(int i) {
    final nome = RotinaStore.nomesDias[i];
    return (i >= 1 && i <= 5) ? '$nome-feira' : nome;
  }

  Widget _tituloSecao(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(texto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  void _mostrarDetalhes(DateTime data) {
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final media = MediaQuery.of(ctx);
          final teclado = media.viewInsets.bottom;
          final alturaMax = media.size.height - teclado - media.padding.top - 16;
          final altura = (media.size.height * 0.82).clamp(0.0, alturaMax).toDouble();

          final lista = _anotacoes.putIfAbsent(_chave(data), () => []);
          final diaSemana = data.weekday % 7;
          final materias = rotinaStore.materiasDoDia(diaSemana);

          void adicionar() {
            final t = ctrl.text.trim();
            if (t.isEmpty) return;
            setState(() => lista.add(t));
            ctrl.clear();
            setSheet(() {});
          }

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
                    padding: const EdgeInsets.fromLTRB(20, 10, 8, 18),
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
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                              child: Text('${data.day}',
                                  style: const TextStyle(
                                      fontSize: 30, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_nomeDiaCompleto(diaSemana),
                                      style: const TextStyle(
                                          fontSize: 22, fontWeight: FontWeight.bold)),
                                  Text(
                                      '${_meses[data.month - 1]} de ${data.year}',
                                      style: const TextStyle(fontSize: 15)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _tituloSecao('Matérias do dia'),
                        if (materias.isEmpty)
                          Text(
                            'Nenhuma matéria na rotina de ${RotinaStore.nomesDias[diaSemana]}.',
                            style: const TextStyle(color: Colors.black54),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final m in materias)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 3,
                                          offset: Offset(0, 1)),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                      Text(m.nome),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 24),
                        _tituloSecao('Anotações'),
                        if (lista.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                Image.asset('assets/abelha_animada.png', height: 70),
                                const SizedBox(height: 10),
                                const Text('Nenhuma anotação ainda',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                const Text('Escreva algo abaixo para este dia.',
                                    style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          )
                        else
                          for (var i = 0; i < lista.length; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 3,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFA53D),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(lista[i],
                                        style: const TextStyle(fontSize: 15)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      setState(() => lista.removeAt(i));
                                      setSheet(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),

                  // Campo de nova anotação
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        16, 10, 16, 14 + (teclado == 0 ? media.padding.bottom : 0)),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEB8A),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, -2)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            onSubmitted: (_) => adicionar(),
                            decoration: InputDecoration(
                              hintText: 'Nova anotação',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(26),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: const Color(0xFFFFA53D),
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: adicionar,
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(Icons.add, size: 28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _celulaDia(DateTime data, bool hoje) {
    final temAnotacao = (_anotacoes[_chave(data)] ?? []).isNotEmpty;
    return InkWell(
      onTap: () => _mostrarDetalhes(data),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: hoje ? const Color(0xFFFFA53D) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${data.day}',
                style: TextStyle(
                    fontWeight: hoje ? FontWeight.bold : FontWeight.normal)),
            if (temAnotacao)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Color(0xFF2D2D2D), shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primeiro = DateTime(_mesAtual.year, _mesAtual.month, 1);
    final diasNoMes = DateTime(_mesAtual.year, _mesAtual.month + 1, 0).day;
    final deslocamento = primeiro.weekday % 7; // domingo = 0
    final agora = DateTime.now();

    final celulas = <Widget>[
      for (var i = 0; i < deslocamento; i++) const SizedBox.shrink(),
      for (var d = 1; d <= diasNoMes; d++)
        _celulaDia(
          DateTime(_mesAtual.year, _mesAtual.month, d),
          agora.year == _mesAtual.year &&
              agora.month == _mesAtual.month &&
              agora.day == d,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDA5E),
        title: const MainAppBar(),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF9CF),
      body: SingleChildScrollView(
        child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                onPressed: () => _mudarMes(-1),
                icon: const Icon(Icons.arrow_left),
              ),
              SizedBox(
                width: 230,
                child: Text(
                  _meses[_mesAtual.month - 1],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                iconSize: 40,
                onPressed: () => _mudarMes(1),
                icon: const Icon(Icons.arrow_right),
              ),
            ],
          ),
          Text('${_mesAtual.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // Calendário compacto: ocupa só o espaço que precisa
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(23),
              boxShadow: const [
                BoxShadow(
                    blurRadius: 10, offset: Offset(0, 4), color: Colors.black26),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDA5E),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      for (final s in _semana)
                        Expanded(
                          child: Center(
                            child: Text(s,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 7,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    children: celulas,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
