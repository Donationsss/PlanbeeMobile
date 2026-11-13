import 'package:flutter/material.dart';

import 'data/app_database.dart';

class ResumoEstudo {
  final int id;
  final String materia;
  final String tipo;
  final String assunto;
  final int segundos;
  final Color? cor;
  final DateTime criadoEm;
  String anotacao;

  ResumoEstudo({
    required this.id,
    required this.materia,
    required this.tipo,
    required this.assunto,
    required this.segundos,
    required this.criadoEm,
    this.cor,
    this.anotacao = '',
  });
}

/// Estudos salvos (mais recentes primeiro), guardados no SQLite.
class EstudosStore extends ChangeNotifier {
  int? _usuarioId;
  final List<ResumoEstudo> _itens = [];

  List<ResumoEstudo> get itens => List.unmodifiable(_itens);

  Future<void> carregar(int usuarioId) async {
    _usuarioId = usuarioId;
    final db = await AppDatabase.instance.db;
    final linhas = await db.query(
      'sessoes_estudo',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'id DESC',
    );
    _itens
      ..clear()
      ..addAll(linhas.map((r) => ResumoEstudo(
            id: r['id'] as int,
            materia: r['materia'] as String,
            tipo: r['tipo'] as String,
            assunto: r['assunto'] as String,
            segundos: r['segundos'] as int,
            cor: r['cor'] == null ? null : Color(r['cor'] as int),
            anotacao: (r['anotacao'] as String?) ?? '',
            criadoEm: DateTime.tryParse(r['criado_em'] as String) ?? DateTime.now(),
          )));
    notifyListeners();
  }

  void limpar() {
    _usuarioId = null;
    _itens.clear();
    notifyListeners();
  }

  Future<void> adicionar({
    required String materia,
    required String tipo,
    required String assunto,
    required int segundos,
    required Color? cor,
    required String anotacao,
  }) async {
    final uid = _usuarioId;
    if (uid == null) return;
    final agora = DateTime.now();
    final db = await AppDatabase.instance.db;
    final id = await db.insert('sessoes_estudo', {
      'usuario_id': uid,
      'materia': materia,
      'tipo': tipo,
      'assunto': assunto,
      'segundos': segundos,
      'cor': cor?.toARGB32(),
      'anotacao': anotacao,
      'criado_em': agora.toIso8601String(),
    });
    _itens.insert(
      0,
      ResumoEstudo(
        id: id,
        materia: materia,
        tipo: tipo,
        assunto: assunto,
        segundos: segundos,
        cor: cor,
        anotacao: anotacao,
        criadoEm: agora,
      ),
    );
    notifyListeners();
  }

  Future<void> atualizarAnotacao(ResumoEstudo r, String texto) async {
    final db = await AppDatabase.instance.db;
    await db.update('sessoes_estudo', {'anotacao': texto},
        where: 'id = ?', whereArgs: [r.id]);
    r.anotacao = texto;
    notifyListeners();
  }

  Future<void> remover(ResumoEstudo r) async {
    final db = await AppDatabase.instance.db;
    await db.delete('sessoes_estudo', where: 'id = ?', whereArgs: [r.id]);
    _itens.removeWhere((e) => e.id == r.id);
    notifyListeners();
  }
}

final EstudosStore estudosStore = EstudosStore();
