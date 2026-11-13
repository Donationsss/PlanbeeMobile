import 'package:flutter/material.dart';

import 'data/app_database.dart';

class AnotacaoDia {
  final int id;
  final String texto;

  const AnotacaoDia({required this.id, required this.texto});
}

/// Anotações do calendário, agrupadas por data (yyyy-mm-dd).
class AnotacoesStore extends ChangeNotifier {
  int? _usuarioId;
  final Map<String, List<AnotacaoDia>> _porData = {};

  static String chave(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<AnotacaoDia> doDia(DateTime d) =>
      List.unmodifiable(_porData[chave(d)] ?? const <AnotacaoDia>[]);

  bool temAnotacao(DateTime d) => (_porData[chave(d)] ?? const []).isNotEmpty;

  Future<void> carregar(int usuarioId) async {
    _usuarioId = usuarioId;
    final db = await AppDatabase.instance.db;
    final linhas = await db.query(
      'anotacoes_calendario',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'id',
    );
    _porData.clear();
    for (final r in linhas) {
      _porData
          .putIfAbsent(r['data'] as String, () => [])
          .add(AnotacaoDia(id: r['id'] as int, texto: r['texto'] as String));
    }
    notifyListeners();
  }

  void limpar() {
    _usuarioId = null;
    _porData.clear();
    notifyListeners();
  }

  Future<void> adicionar(DateTime data, String texto) async {
    final uid = _usuarioId;
    final t = texto.trim();
    if (uid == null || t.isEmpty) return;
    final k = chave(data);
    final db = await AppDatabase.instance.db;
    final id = await db.insert('anotacoes_calendario', {
      'usuario_id': uid,
      'data': k,
      'texto': t,
      'criado_em': DateTime.now().toIso8601String(),
    });
    _porData.putIfAbsent(k, () => []).add(AnotacaoDia(id: id, texto: t));
    notifyListeners();
  }

  Future<void> remover(DateTime data, AnotacaoDia a) async {
    final db = await AppDatabase.instance.db;
    await db.delete('anotacoes_calendario', where: 'id = ?', whereArgs: [a.id]);
    _porData[chave(data)]?.removeWhere((e) => e.id == a.id);
    notifyListeners();
  }
}

final AnotacoesStore anotacoesStore = AnotacoesStore();
