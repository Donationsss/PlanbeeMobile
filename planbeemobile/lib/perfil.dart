import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planbeemobile/components/appbar.dart';
import 'package:planbeemobile/components/avatar_usuario.dart';

import 'data/auth_service.dart';
import 'login.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  bool _salvandoFoto = false;

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFEB8A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta?'),
        content: const Text(
            'Seus dados ficam salvos e estarão aqui quando você entrar de novo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            style:
                TextButton.styleFrom(backgroundColor: const Color(0xFFFFA53D)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await AuthService.sair();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (_) => false,
    );
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Menu com as opções da foto de perfil.
  Future<void> _abrirOpcoesFoto() async {
    if (_salvandoFoto) return;
    final temFoto = AuthService.usuario?.fotoBytes != null;

    final opcao = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFFFF9CF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Text('Foto de perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(ctx, 'escolher'),
            ),
            if (temFoto)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remover foto'),
                onTap: () => Navigator.pop(ctx, 'remover'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (opcao == 'escolher') await _escolherFoto();
    if (opcao == 'remover') await _removerFoto();
  }

  Future<void> _escolherFoto() async {
    try {
      final arquivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (arquivo == null) return; // usuário cancelou

      final bytes = await arquivo.readAsBytes();
      if (!mounted) return;
      setState(() => _salvandoFoto = true);
      await AuthService.atualizarFoto(base64Encode(bytes));
      if (!mounted) return;
      _aviso('Foto de perfil atualizada!');
    } catch (e, st) {
      if (!mounted) return;
      _aviso(AuthService.mensagemInesperada(
          'Não foi possível carregar a foto.', e, st));
    } finally {
      if (mounted) setState(() => _salvandoFoto = false);
    }
  }

  Future<void> _removerFoto() async {
    setState(() => _salvandoFoto = true);
    try {
      await AuthService.atualizarFoto(null);
      if (!mounted) return;
      _aviso('Foto de perfil removida.');
    } catch (e, st) {
      if (!mounted) return;
      _aviso(AuthService.mensagemInesperada(
          'Não foi possível remover a foto.', e, st));
    } finally {
      if (mounted) setState(() => _salvandoFoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = AuthService.usuario;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDA5E),
        title: const MainAppBar(),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF9CF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: _abrirOpcoesFoto,
                    child: const AvatarUsuario(
                      tamanho: 110,
                      tamanhoIcone: 70,
                      fundo: Color(0xFFFFDA5E),
                      sombra: true,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: const Color(0xFFFFA53D),
                      shape: const CircleBorder(),
                      elevation: 3,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _abrirOpcoesFoto,
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: _salvandoFoto
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.photo_camera,
                                  size: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Toque na foto para alterar',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Text(
                u?.nome ?? '',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(u?.email ?? '', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: _sair,
                icon: const Icon(Icons.logout, color: Colors.black),
                label: const Text('Sair',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCB20),
                  elevation: 6,
                  fixedSize: const Size(160, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
