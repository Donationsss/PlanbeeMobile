import 'package:flutter/material.dart';

/// Matéria lançada na rotina de um dia da semana.
class Materia {
  final String nome;
  final Color cor;

  const Materia({required this.nome, required this.cor});
}

/// Guarda as matérias de cada dia da semana (0 = Domingo ... 6 = Sábado).
/// É compartilhado entre Rotina, Estudos e Agenda.
class RotinaStore extends ChangeNotifier {
  static const nomesDias = [
    'Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado',
  ];

  final List<List<Materia>> _dias = List.generate(7, (_) => <Materia>[]);

  /// Índice do dia de hoje no mesmo formato (0 = Domingo).
  static int diaDeHoje() => DateTime.now().weekday % 7;

  List<Materia> materiasDoDia(int dia) => List.unmodifiable(_dias[dia]);

  /// Retorna false se o nome estiver vazio ou já existir naquele dia.
  bool adicionar(int dia, String nome, Color cor) {
    final n = nome.trim();
    if (n.isEmpty) return false;
    final existe =
        _dias[dia].any((m) => m.nome.toLowerCase() == n.toLowerCase());
    if (existe) return false;
    _dias[dia].add(Materia(nome: n, cor: cor));
    notifyListeners();
    return true;
  }

  /// Remove e devolve a posição em que a matéria estava (para desfazer).
  int remover(int dia, Materia materia) {
    final i = _dias[dia].indexOf(materia);
    if (i >= 0) {
      _dias[dia].removeAt(i);
      notifyListeners();
    }
    return i;
  }

  void inserir(int dia, int indice, Materia materia) {
    final lista = _dias[dia];
    lista.insert(indice.clamp(0, lista.length).toInt(), materia);
    notifyListeners();
  }
}

final RotinaStore rotinaStore = RotinaStore();
