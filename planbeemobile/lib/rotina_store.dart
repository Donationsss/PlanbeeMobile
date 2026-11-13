import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'data/app_database.dart';

/// Matéria lançada na rotina de um dia da semana.
class Materia {
  final int id;
  final String nome;
  final Color cor;

  const Materia({required this.id, required this.nome, required this.cor});
}

/// Matérias de cada dia da semana (0 = Domingo ... 6 = Sábado),
/// guardadas no SQLite e mantidas em memória para a interface.
class RotinaStore extends ChangeNotifier {
  static const nomesDias = [
    'Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado',
  ];

  int? _usuarioId;
  final List<List<Materia>> _dias = List.generate(7, (_) => <Materia>[]);

  /// Índice do dia de hoje no mesmo formato (0 = Domingo).
  static int diaDeHoje() => DateTime.now().weekday % 7;

  List<Materia> materiasDoDia(int dia) => List.unmodifiable(_dias[dia]);

  Future<void> carregar(int usuarioId) async {
    _usuarioId = usuarioId;
    final db = await AppDatabase.instance.db;
    final linhas = await db.query(
      'materias_rotina',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'dia, ordem, id',
    );
    for (final l in _dias) {
      l.clear();
    }
    for (final r in linhas) {
      _dias[r['dia'] as int].add(Materia(
        id: r['id'] as int,
        nome: r['nome'] as String,
        cor: Color(r['cor'] as int),
      ));
    }
    notifyListeners();
  }

  /// Esvazia a memória (usado ao sair da conta).
  void limpar() {
    _usuarioId = null;
    for (final l in _dias) {
      l.clear();
    }
    notifyListeners();
  }

  /// Retorna false se o nome estiver vazio, já existir naquele dia
  /// ou se não houver usuário logado.
  Future<bool> adicionar(int dia, String nome, Color cor) async {
    final uid = _usuarioId;
    final n = nome.trim();
    if (uid == null || n.isEmpty) return false;
    final existe =
        _dias[dia].any((m) => m.nome.toLowerCase() == n.toLowerCase());
    if (existe) return false;

    try {
      final db = await AppDatabase.instance.db;
      final id = await db.insert('materias_rotina', {
        'usuario_id': uid,
        'dia': dia,
        'nome': n,
        'cor': cor.toARGB32(),
        'ordem': _dias[dia].length,
      });
      _dias[dia].add(Materia(id: id, nome: n, cor: cor));
      notifyListeners();
      return true;
    } on DatabaseException {
      // Índice único: o mesmo nome foi enviado duas vezes rapidamente.
      return false;
    }
  }

  /// Remove e devolve a posição em que a matéria estava (para desfazer).
  Future<int> remover(int dia, Materia materia) async {
    final i = _dias[dia].indexWhere((m) => m.id == materia.id);
    if (i < 0) return -1;
    final db = await AppDatabase.instance.db;
    await db.delete('materias_rotina', where: 'id = ?', whereArgs: [materia.id]);
    _dias[dia].removeAt(i);
    await _salvarOrdem(dia);
    notifyListeners();
    return i;
  }

  /// Recoloca uma matéria removida na posição original (Desfazer).
  Future<void> inserir(int dia, int indice, Materia materia) async {
    final uid = _usuarioId;
    if (uid == null) return;
    if (_dias[dia].any((m) => m.nome.toLowerCase() == materia.nome.toLowerCase())) {
      return;
    }
    final lista = _dias[dia];
    final pos = indice.clamp(0, lista.length).toInt();
    final db = await AppDatabase.instance.db;
    await db.insert('materias_rotina', {
      'id': materia.id,
      'usuario_id': uid,
      'dia': dia,
      'nome': materia.nome,
      'cor': materia.cor.toARGB32(),
      'ordem': pos,
    });
    lista.insert(pos, materia);
    await _salvarOrdem(dia);
    notifyListeners();
  }

  Future<void> _salvarOrdem(int dia) async {
    final db = await AppDatabase.instance.db;
    final batch = db.batch();
    for (var i = 0; i < _dias[dia].length; i++) {
      batch.update('materias_rotina', {'ordem': i},
          where: 'id = ?', whereArgs: [_dias[dia][i].id]);
    }
    await batch.commit(noResult: true);
  }
}

final RotinaStore rotinaStore = RotinaStore();
